//
//  LoanCalculatorEnvironment.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

struct LoanCalculatorEnvironment {
    var repository: LoanRepository
    var now: () -> Date
    var calendar: Calendar
    var errorMapper: (Error) -> LoanSubmitError
    var storage: LoanTermsStorage
}
