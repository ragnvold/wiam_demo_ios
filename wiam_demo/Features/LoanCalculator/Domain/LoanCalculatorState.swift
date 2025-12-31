//
//  LoanCalculatorState.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

struct LoanCalculatorState: Equatable {
    var terms: LoanTerms = .default
    var ui: LoanCalculatorUI = .idle
    var config: LoanCalculatorConfig = .default

    /// Держим последние вычисления отдельно.
    /// Reducer обновляет их при изменении terms.
    var computed: LoanComputed = .zero

    /// Для тостов/алертов. Можно заменить на свой AlertState.
    var message: MessageState? = nil
}

struct LoanTerms: Equatable, Codable {
    var amount: Decimal
    var periodDays: Int

    static let `default` = LoanTerms(amount: 5_000, periodDays: 7)
}

struct LoanCalculatorConfig: Equatable {
    var amountRange: ClosedRange<Decimal>
    var allowedPeriodsDays: [Int]
    var aprPercent: Decimal

    static let `default` = LoanCalculatorConfig(
        amountRange: 5_000...50_000,
        allowedPeriodsDays: [7, 14, 21, 28],
        aprPercent: 15
    )
}

struct LoanComputed: Equatable {
    var totalRepayment: Decimal
    var repayDate: Date

    static let zero = LoanComputed(totalRepayment: 0, repayDate: Date(timeIntervalSince1970: 0))
}

enum LoanCalculatorUI: Equatable {
    case idle
    case submitting
    case submittedSuccess(LoanApplicationResponse)
    case submittedFailure(String)
}

// Универсальная структура сообщения (баннер/алерт/снэкбар)
struct MessageState: Equatable, Identifiable {
    let id: UUID
    var title: String
    var body: String?

    static func info(_ title: String, body: String? = nil, id: UUID = UUID()) -> MessageState {
        MessageState(id: id, title: title, body: body)
    }
}
