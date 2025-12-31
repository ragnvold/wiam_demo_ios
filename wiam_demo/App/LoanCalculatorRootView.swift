//
//  ContentView.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import SwiftUI

@MainActor
struct LoanCalculatorRootView: View {
    @StateObject private var store = AppDI().makeLoanCalculatorStore()

    var body: some View {
        LoanCalculatorView(store: store)
    }
}

#Preview {
    LoanCalculatorRootView()
}
