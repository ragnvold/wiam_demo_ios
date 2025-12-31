//
//  Store.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation
import Combine

@MainActor
final class Store<State, Action, Environment>: ObservableObject {

    typealias Reducer = (inout State, Action, Environment) -> [Effect<Action>]

    @Published private(set) var state: State

    private let reducer: Reducer
    private let environment: Environment
    private let middlewares: [AnyMiddleware<State, Action>]

    init(
        initialState: State,
        reducer: @escaping Reducer,
        environment: Environment,
        middlewares: [AnyMiddleware<State, Action>] = []
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
        self.middlewares = middlewares
    }

    /// Dispatch is MainActor so state mutations stay safe and SwiftUI-friendly.
    func dispatch(_ action: Action) {
        let effects = reducer(&state, action, environment)

        // Run middlewares after reducer so they see the updated state.
        for mw in middlewares {
            mw.process(action: action, state: state)
        }

        guard !effects.isEmpty else { return }
        runEffects(effects)
    }

    private func runEffects(_ effects: [Effect<Action>]) {
        for effect in effects {
            Task {
                await effect.run { [weak self] nextAction in
                    guard let self else { return }
                    await MainActor.run {
                        self.dispatch(nextAction)
                    }
                }
            }
        }
    }
}
