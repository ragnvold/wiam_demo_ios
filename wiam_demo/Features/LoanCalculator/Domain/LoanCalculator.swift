//
//  LoanCalculator.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

enum LoanCalculator {
    static func compute(
        terms: LoanTerms,
        config: LoanCalculatorConfig,
        now: Date,
        calendar: Calendar
    ) -> LoanComputed {

        let periodRatePercent = config.aprPercent(for: terms.periodDays)
        let amount = terms.amount
        let rate = periodRatePercent / 100

        let interest = (amount * rate).rounded(scale: 2)
        let total = (amount + interest).rounded(scale: 2)

        let repayDate = calendar.date(byAdding: .day, value: terms.periodDays, to: now) ?? now
        return LoanComputed(totalRepayment: total, repayDate: repayDate)
    }
}

extension Decimal {
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .bankers) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }

    func clamped(to range: ClosedRange<Decimal>) -> Decimal {
        if self < range.lowerBound { return range.lowerBound }
        if self > range.upperBound { return range.upperBound }
        return self
    }
}
