//
//  Strings.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 03.01.2026.
//

import Foundation

enum Strings {
    static let loanCalculatorTitle = NSLocalizedString(
        "loan_calculator_title",
        comment: ""
    )

    static let sectionData = NSLocalizedString("section_data", comment: "")
    static let sectionSummary = NSLocalizedString("section_summary", comment: "")

    static let amountTitle = NSLocalizedString("amount_title", comment: "")
    static let amountAccessibility = NSLocalizedString("amount_accessibility", comment: "")

    static let termTitle = NSLocalizedString("term_title", comment: "")
    static let termAccessibility = NSLocalizedString("term_accessibility", comment: "")

    static func termDays(_ days: Int) -> String {
        String(
            format: NSLocalizedString("term_days_format", comment: ""),
            days
        )
    }
    
    static func termDaysShort(_ days: Int) -> String {
        String(
            format: NSLocalizedString("term_days_short_format", comment: ""),
            days
        )
    }

    static let summaryApr = NSLocalizedString("summary_apr", comment: "")
    static let summaryTotalRepayment = NSLocalizedString("summary_total_repayment", comment: "")
    static let summaryRepayDate = NSLocalizedString("summary_repay_date", comment: "")

    static let submitApplication = NSLocalizedString("submit_application", comment: "")

    static let alertSuccessTitle = NSLocalizedString("alert_success_title", comment: "")
    static let alertFailureTitle = NSLocalizedString("alert_failure_title", comment: "")
    static let alertOk = NSLocalizedString("alert_ok", comment: "")

    static func alertSuccessMessage(
        id: Int,
        amount: String,
        term: Int,
        total: String
    ) -> String {
        String(
            format: NSLocalizedString("alert_success_message_format", comment: ""),
            id,
            amount,
            term,
            total
        )
    }
}
