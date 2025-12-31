//
//  LiveLoanRepository.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

final class LiveLoanRepository: LoanRepository {
    private let api: LoanAPI

    init(api: LoanAPI) {
        self.api = api
    }

    func submitLoanApplication(_ request: LoanApplicationRequest) async throws -> LoanApplicationResponse {
        try await api.submitLoanApplication(request)
    }
}
