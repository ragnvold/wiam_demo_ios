//
//  LoanApplicationRequest.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

struct LoanApplicationRequest: Encodable, Equatable {
    let amount: Decimal
    let period: Int
    let totalRepayment: Decimal

    enum CodingKeys: String, CodingKey {
        case amount
        case period
        case totalRepayment
    }
}
