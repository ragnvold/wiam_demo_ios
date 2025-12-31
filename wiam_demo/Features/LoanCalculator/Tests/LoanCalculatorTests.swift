//
//  LoanCalculatorTests.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import XCTest
@testable import wiam_demo

final class LoanCalculatorTests: XCTestCase {

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

    private func assertDecimalEqual(_ a: Decimal, _ b: Decimal, file: StaticString = #filePath, line: UInt = #line) {
        let na = NSDecimalNumber(decimal: a)
        let nb = NSDecimalNumber(decimal: b)
        XCTAssertEqual(na.compare(nb), .orderedSame, "Expected \(na) == \(nb)", file: file, line: line)
    }

    func test_compute_totalRepayment_5000_7days_apr15() {
        let now = makeDateUTC(year: 2026, month: 1, day: 1)
        let terms = LoanTerms(amount: 5_000, periodDays: 7)

        let result = LoanCalculator.compute(
            terms: terms,
            aprPercent: 15,
            now: now,
            calendar: calendarUTC
        )

        // interest = 5000 * 0.15 * 7/365 = 14.3835616... -> 14.38
        // total = 5014.38
        assertDecimalEqual(result.totalRepayment, Decimal(string: "5014.38")!)

        let expectedDue = makeDateUTC(year: 2026, month: 1, day: 8)
        XCTAssertEqual(result.repayDate, expectedDue)
    }

    func test_compute_totalRepayment_50000_28days_apr15() {
        let now = makeDateUTC(year: 2026, month: 2, day: 10)
        let terms = LoanTerms(amount: 50_000, periodDays: 28)

        let result = LoanCalculator.compute(
            terms: terms,
            aprPercent: 15,
            now: now,
            calendar: calendarUTC
        )

        // interest = 50000 * 0.15 * 28/365 = 575.3424657... -> 575.34
        // total = 50575.34
        assertDecimalEqual(result.totalRepayment, Decimal(string: "50575.34")!)

        let expectedDue = makeDateUTC(year: 2026, month: 3, day: 10)
        XCTAssertEqual(result.repayDate, expectedDue)
    }
}
