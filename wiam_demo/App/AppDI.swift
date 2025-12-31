//
//  AppDI.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

struct AppDI {

    @MainActor
    func makeLoanCalculatorStore() -> LoanCalculatorStore {
        let env = makeLoanCalculatorEnvironment()

        return Store(
            initialState: LoanCalculatorState(),
            reducer: LoanCalculatorReducer.reduce,
            environment: env
        )
    }

    private func makeLoanCalculatorEnvironment() -> LoanCalculatorEnvironment {
        LoanCalculatorEnvironment(
            repository: makeLoanRepository(),
            now: { Date() },
            calendar: .current,
            errorMapper: mapLoanSubmitError(_:),
            storage: UserDefaultsLoanTermsStorage()
        )
    }

    private func makeLoanRepository() -> LoanRepository {
        LiveLoanRepository(api: makeLoanAPI())
    }

    private func makeLoanAPI() -> LoanAPI {
        // Подставь URL своего mock-сервера.
        // Пример: https://mock.yourdomain.com/api/
        let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!
        return LoanAPI(baseURL: baseURL)
    }

    private func mapLoanSubmitError(_ error: Error) -> LoanSubmitError {
            if let apiError = error as? LoanAPIError {
                return .server(apiError.localizedDescription)
            }
            if let urlError = error as? URLError {
                return .network(urlError.localizedDescription)
            }
            return .unknown(error.localizedDescription)
        }
}
