//
//  LoanCalculatorView.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import SwiftUI

struct LoanCalculatorView: View {
    @ObservedObject var store: LoanCalculatorStore

    @State private var amountValue: Double = 0
    @State private var periodIndex: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                amountSection
                periodSection
                summarySection
                submitSection
            }
            .navigationTitle("Loan Calculator")
        }
        .onAppear {
            syncLocalFromState()
            store.dispatch(.onAppear)
        }
        .onChange(of: store.state.terms.amount) {
            syncLocalFromState()
        }
        .onChange(of: store.state.terms.periodDays) {
            syncLocalFromState()
        }
    }

    // MARK: - Sections

    private var amountSection: some View {
        Section("Amount") {
            HStack {
                Text("Amount")
                Spacer()
                Text(formatMoney(store.state.terms.amount))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(
                value: Binding(
                    get: { amountValue },
                    set: { newValue in
                        amountValue = newValue
                        store.dispatch(.amountChanged(Decimal(newValue)))
                    }
                ),
                in: amountRangeDouble,
                step: 100
            )
            .accessibilityLabel("Loan amount")

            HStack {
                Text(formatMoney(Decimal(amountRangeDouble.lowerBound)))
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                Spacer()
                Text(formatMoney(Decimal(amountRangeDouble.upperBound)))
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
    }

    private var periodSection: some View {
        Section("Term") {
            HStack {
                Text("Term")
                Spacer()
                Text("\(store.state.terms.periodDays) days")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(
                value: Binding(
                    get: { periodIndex },
                    set: { newValue in
                        let rounded = newValue.rounded()
                        periodIndex = rounded
                        let idx = Int(rounded)
                        let periods = store.state.config.allowedPeriodsDays
                        guard periods.indices.contains(idx) else { return }
                        store.dispatch(.periodChanged(periods[idx]))
                    }
                ),
                in: 0...Double(max(0, store.state.config.allowedPeriodsDays.count - 1)),
                step: 1
            )
            .accessibilityLabel("Loan term")

            HStack {
                Text("\(store.state.config.allowedPeriodsDays.first ?? 0)d")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                Spacer()
                Text("\(store.state.config.allowedPeriodsDays.last ?? 0)d")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
    }

    private var summarySection: some View {
        Section("Summary") {
            summaryRow(title: "APR", value: formatPercent(store.state.config.aprPercent))
            summaryRow(title: "Total repayment", value: formatMoney(store.state.computed.totalRepayment))
            summaryRow(title: "Repay date", value: formatDate(store.state.computed.repayDate))
        }
    }

    private var submitSection: some View {
        Section {
            Button {
                store.dispatch(.submitTapped)
            } label: {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Submit application")
                    }
                    Spacer()
                }
            }
            .disabled(isLoading)
        }
        .alert(
            alertTitle,
            isPresented: Binding(
                get: { isAlertPresented },
                set: { presented in
                    if !presented {
                        store.dispatch(.messageDismissed)
                    }
                }
            )
        ) {
            Button("OK") {
                store.dispatch(.messageDismissed)
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - UI helpers

    private var isLoading: Bool {
        if case .submitting = store.state.ui { return true }
        return false
    }

    private var isAlertPresented: Bool {
        switch store.state.ui {
        case .submittedSuccess, .submittedFailure:
            return true
        default:
            return false
        }
    }

    private var alertTitle: String {
        switch store.state.ui {
        case .submittedSuccess:
            return "Application submitted"
        case .submittedFailure:
            return "Submission failed"
        default:
            return ""
        }
    }

    private var alertMessage: String {
        switch store.state.ui {
        case .submittedSuccess(let response):
            return "ID: \(response.id)\nAmount: \(formatMoney(response.amount))\nTerm: \(response.period) days\nTotal: \(formatMoney(response.totalRepayment))"
        case .submittedFailure(let message):
            return message
        default:
            return ""
        }
    }

    // MARK: - Helpers

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private var amountRangeDouble: ClosedRange<Double> {
        let r = store.state.config.amountRange
        return (r.lowerBound.doubleValue)...(r.upperBound.doubleValue)
    }

    private func syncLocalFromState() {
        let amount = store.state.terms.amount.doubleValue
        if amountValue != amount { amountValue = amount }

        let periods = store.state.config.allowedPeriodsDays
        if let idx = periods.firstIndex(of: store.state.terms.periodDays) {
            let v = Double(idx)
            if periodIndex != v { periodIndex = v }
        }
    }

    private func formatPercent(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return percentFormatter.string(from: number) ?? "\(number)%"
    }

    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}

private let percentFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    f.maximumFractionDigits = 0
    f.multiplier = 1
    return f
}()

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = .current
    f.dateStyle = .medium
    f.timeStyle = .none
    return f
}()

private func formatMoney(_ value: Decimal) -> String {
    let number = NSDecimalNumber(decimal: value)
    return moneyFormatter.string(from: number) ?? "\(number)"
}

private func formatDays(_ days: Int) -> String {
    if days == 1 { return "1 day" }
    return "\(days) days"
}

private func formatDate(_ date: Date) -> String {
    dateFormatter.string(from: date)
}

private let moneyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.locale = Locale(identifier: "en_US")
    f.usesGroupingSeparator = true
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 0
    return f
}()

private extension Decimal {
    var doubleValue: Double { NSDecimalNumber(decimal: self).doubleValue }
}
