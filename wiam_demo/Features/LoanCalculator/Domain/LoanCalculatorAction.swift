//
//  LoanCalculatorAction.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

// MARK: - Action

enum LoanCalculatorAction: Equatable {
    // User intent
    case onAppear
    case amountChanged(Decimal)
    case periodChanged(Int)
    case submitTapped
    case messageDismissed

    // Internal flow
    case _recalculate
    case _submitResponse(Result<LoanApplicationResponse, LoanSubmitError>)
    case _restoreTerms(LoanTerms?)
}

// MARK: - Errors

enum LoanSubmitError: Equatable, LocalizedError {
    case network(String)
    case server(String)
    case decoding(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network(let msg): return msg
        case .server(let msg): return msg
        case .decoding(let msg): return msg
        case .unknown(let msg): return msg
        }
    }
}
