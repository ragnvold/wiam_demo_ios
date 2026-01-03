//
//  LoanCalculatorReducer.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

// MARK: - Reducer

enum LoanCalculatorReducer {
    static func reduce(
        state: inout LoanCalculatorState,
        action: LoanCalculatorAction,
        env: LoanCalculatorEnvironment
    ) -> [Effect<LoanCalculatorAction>] {

        switch action {

        case .onAppear:
            return [
                    .run { send in
                        let restored = try? env.storage.load()
                        await send(LoanCalculatorAction._restoreTerms(restored ?? nil))
                        
                        await send(LoanCalculatorAction._recalculate)
                    }
                ]

        case .amountChanged(let raw):
            let clamped = raw.clamped(to: state.config.amountRange)
            if clamped != state.terms.amount {
                state.terms.amount = clamped
                return [.send(._recalculate)]
            }
            return []

        case .periodChanged(let days):
            guard state.config.allowedPeriodsDays.contains(days) else { return [] }
            if days != state.terms.periodDays {
                state.terms.periodDays = days
                return [.send(._recalculate)]
            }
            return []

        case ._recalculate:            
            state.computed = LoanCalculator.compute(
                terms: state.terms,
                config: state.config,
                now: env.now(),
                calendar: env.calendar
            )
            return []

        case .submitTapped:
            guard state.ui != .submitting else { return [] }
            state.ui = .submitting

            let request = LoanApplicationRequest(
                amount: state.terms.amount,
                period: state.terms.periodDays,
                totalRepayment: state.computed.totalRepayment
            )

            let termsToPersist = state.terms

            return [
                .run { _ in
                    try? env.storage.save(termsToPersist)
                },
                .run { send in
                    do {
                        let response = try await env.repository.submitLoanApplication(request)
                        await send(LoanCalculatorAction._submitResponse(.success(response)))
                    } catch {
                        await send(LoanCalculatorAction._submitResponse(.failure(env.errorMapper(error))))
                    }
                }
            ]

        case ._submitResponse(let result):
            switch result {

            case .success(let response):
                state.ui = .submittedSuccess(response)

            case .failure(let err):
                state.ui = .submittedFailure(
                    err.errorDescription ?? "Unknown error"
                )
            }
            return []

        case .messageDismissed:
            state.ui = .idle
            return []
            
        case ._restoreTerms(let restored):
            guard let restored else {
                return [.send(LoanCalculatorAction._recalculate)]
            }

            var fixed = restored
            fixed.amount = fixed.amount.clamped(to: state.config.amountRange)
            if !state.config.allowedPeriodsDays.contains(fixed.periodDays) {
                fixed.periodDays = state.config.allowedPeriodsDays.first ?? state.terms.periodDays
            }

            state.terms = fixed
            return [.send(LoanCalculatorAction._recalculate)]
        }
    }
}
