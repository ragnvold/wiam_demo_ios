//
//  Middleware.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

protocol Middleware {
    associatedtype State
    associatedtype Action

    func process(action: Action, state: State)
}

struct AnyMiddleware<State, Action>: Middleware {
    private let _process: (Action, State) -> Void

    init<M: Middleware>(_ middleware: M) where M.State == State, M.Action == Action {
        _process = middleware.process
    }

    func process(action: Action, state: State) {
        _process(action, state)
    }
}
