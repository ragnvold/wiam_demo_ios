//
//  LoanApplicationResponse.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

import Foundation

struct LoanApplicationResponse: Decodable, Equatable {
    let id: Int
    let amount: Decimal
    let period: Int
    let totalRepayment: Decimal

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case period
        case totalRepayment
    }

    init(id: Int, amount: Decimal, period: Int, totalRepayment: Decimal) {
        self.id = id
        self.amount = amount
        self.period = period
        self.totalRepayment = totalRepayment
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(Int.self, forKey: .id)
        period = try c.decode(Int.self, forKey: .period)

        amount = try c.decodeDecimalFlexible(forKey: .amount)
        totalRepayment = try c.decodeDecimalFlexible(forKey: .totalRepayment)
    }

    static func decode(from data: Data, using decoder: JSONDecoder) throws -> LoanApplicationResponse {
        try decoder.decode(LoanApplicationResponse.self, from: data)
    }
}

private extension KeyedDecodingContainer {
    func decodeDecimalFlexible(forKey key: Key) throws -> Decimal {
        if let d = try? decode(Decimal.self, forKey: key) {
            return d
        }
        if let s = try? decode(String.self, forKey: key) {
            if let decimal = Decimal(string: s, locale: Locale(identifier: "en_US_POSIX")) {
                return decimal
            }
        }
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "Expected Decimal as number or string."
        )
    }
}
