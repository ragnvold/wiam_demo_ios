//
//  LoanRepository.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

protocol LoanRepository {
    func submitLoanApplication(
        _ request: LoanApplicationRequest
    ) async throws -> LoanApplicationResponse
}
