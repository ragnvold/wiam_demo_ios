//
//  LoanCalculatorReducerTests.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import XCTest
@testable import wiam_demo

final class LoanCalculatorReducerTests: XCTestCase {

    // MARK: - Mocks

    private final class MockLoanRepository: LoanRepository {
        var result: Result<LoanApplicationResponse, Error>

        init(result: Result<LoanApplicationResponse, Error>) {
            self.result = result
        }

        func submitLoanApplication(_ request: LoanApplicationRequest) async throws -> LoanApplicationResponse {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
    }

    private final class MockTermsStorage: LoanTermsStorage {
        var stored: LoanTerms?
        var savedTerms: LoanTerms?

        init(stored: LoanTerms? = nil) {
            self.stored = stored
        }

        func save(_ terms: LoanTerms) throws {
            savedTerms = terms
            stored = terms
        }

        func load() throws -> LoanTerms? {
            stored
        }

        func clear() throws {
            stored = nil
        }
    }

    private struct TestError: LocalizedError {
        let errorDescription: String? = "Test error"
    }

    // MARK: - Helpers

    private var calendarUTC: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }

    private func makeDateUTC(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return calendarUTC.date(from: comps)!
    }

    private func makeEnv(
        repositoryResult: Result<LoanApplicationResponse, Error> = .success(
            LoanApplicationResponse(id: 101, amount: 5_000, period: 7, totalRepayment: 5_014.38)
        ),
        storedTerms: LoanTerms? = nil,
        now: Date = Date(timeIntervalSince1970: 0)
    ) -> LoanCalculatorEnvironment {

        let repo = MockLoanRepository(result: repositoryResult)
        let storage = MockTermsStorage(stored: storedTerms)

        return LoanCalculatorEnvironment(
            repository: repo,
            now: { now },
            calendar: calendarUTC,
            errorMapper: { error in
                if let e = error as? LocalizedError, let msg = e.errorDescription {
                    return .unknown(msg)
                }
                return .unknown(error.localizedDescription)
            },
            storage: storage
        )
    }

    private func runEffects(
        _ effects: [Effect<LoanCalculatorAction>],
        collect maxActions: Int = 10
    ) async -> [LoanCalculatorAction] {
        var actions: [LoanCalculatorAction] = []
        for effect in effects {
            await effect.run { action in
                actions.append(action)
            }
            if actions.count >= maxActions { break }
        }
        return actions
    }

    // MARK: - Tests

    func test_amountChanged_clampsToRange_andTriggersRecalculate() async {
        var state = await MainActor.run { LoanCalculatorState() }
        let env = makeEnv()
        
        state.terms.amount = 10_000

        let effects = LoanCalculatorReducer.reduce(
            state: &state,
            action: .amountChanged(1),
            env: env
        )

        XCTAssertEqual(state.terms.amount, state.config.amountRange.lowerBound)

        let produced = await runEffects(effects)
        XCTAssertEqual(produced, [. _recalculate]) // if this line errors, use LoanCalculatorAction._recalculate
    }

    func test_periodChanged_invalidValue_doesNothing() async {
        var state = await MainActor.run { LoanCalculatorState() }
        let env = makeEnv()

        let effects = LoanCalculatorReducer.reduce(
            state: &state,
            action: .periodChanged(999),
            env: env
        )

        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(state.terms.periodDays, LoanTerms.default.periodDays)
    }

    func test_recalculate_updatesComputed_totalAndDueDate() {
        var state = LoanCalculatorState()
        let now = makeDateUTC(year: 2026, month: 1, day: 1)

        let env = makeEnv(now: now)

        state.terms = LoanTerms(amount: 5_000, periodDays: 7)

        _ = LoanCalculatorReducer.reduce(
            state: &state,
            action: ._recalculate,
            env: env
        )

        XCTAssertEqual(NSDecimalNumber(decimal: state.computed.totalRepayment).stringValue, "5375")

        let expectedDue = makeDateUTC(year: 2026, month: 1, day: 8)
        XCTAssertEqual(state.computed.repayDate, expectedDue)
    }

    func test_submitTapped_setsSubmitting_andSavesTerms_andEmitsSubmitResponseSuccess() async {
        var state = LoanCalculatorState()
        let now = makeDateUTC(year: 2026, month: 1, day: 1)

        let response = LoanApplicationResponse(
            id: 777,
            amount: 10_000,
            period: 14,
            totalRepayment: 10_057.53
        )

        let storage = MockTermsStorage(stored: nil)
        let repo = MockLoanRepository(result: .success(response))

        let env = LoanCalculatorEnvironment(
            repository: repo,
            now: { now },
            calendar: calendarUTC,
            errorMapper: { _ in .unknown("mapped") },
            storage: storage
        )

        state.terms = LoanTerms(amount: 10_000, periodDays: 14)
        _ = LoanCalculatorReducer.reduce(state: &state, action: ._recalculate, env: env)

        let effects = LoanCalculatorReducer.reduce(
            state: &state,
            action: .submitTapped,
            env: env
        )

        XCTAssertEqual(state.ui, .submitting)

        // ВАЖНО: исполняем эффекты, чтобы storage.save реально отработал
        let produced = await runEffects(effects)

        XCTAssertEqual(storage.savedTerms, state.terms)

        XCTAssertTrue(produced.contains(where: { action in
            if case ._submitResponse(.success(let r)) = action {
                return r.id == 777
            }
            return false
        }))
    }


    func test_submitResponse_success_setsSubmittedSuccess() {
        var state = LoanCalculatorState()
        let env = makeEnv()

        let response = LoanApplicationResponse(id: 101, amount: 5_000, period: 7, totalRepayment: 5_014.38)

        _ = LoanCalculatorReducer.reduce(
            state: &state,
            action: ._submitResponse(.success(response)),
            env: env
        )

        XCTAssertEqual(state.ui, .submittedSuccess(response))
    }

    func test_submitResponse_failure_setsSubmittedFailureWithMessage() {
        var state = LoanCalculatorState()
        let env = makeEnv()

        let error = LoanSubmitError.unknown("Boom")

        _ = LoanCalculatorReducer.reduce(
            state: &state,
            action: ._submitResponse(.failure(error)),
            env: env
        )

        XCTAssertEqual(state.ui, .submittedFailure("Boom"))
    }

    func test_restoreTerms_appliesClamping_andTriggersRecalculate() async {
        var state = await MainActor.run { LoanCalculatorState() }
        let env = makeEnv()

        let restored = LoanTerms(amount: 1, periodDays: 999) // invalid both

        let effects = LoanCalculatorReducer.reduce(
            state: &state,
            action: ._restoreTerms(restored),
            env: env
        )

        XCTAssertEqual(state.terms.amount, state.config.amountRange.lowerBound)
        XCTAssertEqual(state.terms.periodDays, state.config.allowedPeriodsDays.first)

        let produced = await runEffects(effects)
        XCTAssertEqual(produced, [LoanCalculatorAction._recalculate])
    }

    func test_onAppear_emitsRestoreTermsAndRecalculate() async {
        let stored = LoanTerms(amount: 20_000, periodDays: 21)
        let now = makeDateUTC(year: 2026, month: 1, day: 1)

        let storage = MockTermsStorage(stored: stored)
        let repo = MockLoanRepository(result: .success(LoanApplicationResponse(id: 1, amount: 0, period: 7, totalRepayment: 0)))

        let env = LoanCalculatorEnvironment(
            repository: repo,
            now: { now },
            calendar: calendarUTC,
            errorMapper: { _ in .unknown("mapped") },
            storage: storage
        )

        var state = await MainActor.run { LoanCalculatorState() }

        let effects = LoanCalculatorReducer.reduce(
            state: &state,
            action: .onAppear,
            env: env
        )

        let produced = await runEffects(effects)
        XCTAssertTrue(produced.contains(where: { if case ._restoreTerms = $0 { return true } else { return false } }))
        XCTAssertTrue(produced.contains(LoanCalculatorAction._recalculate))
    }
}
