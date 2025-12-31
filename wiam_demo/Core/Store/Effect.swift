//
//  Effect.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

struct Effect<Action> {
    let run: (@escaping (Action) async -> Void) async -> Void
}

extension Effect {
    static func send(_ action: Action) -> Effect {
        Effect { send in
            await send(action)
        }
    }

    static func run(
        operation: @escaping (@escaping (Action) async -> Void) async -> Void
    ) -> Effect {
        Effect { send in
            await operation(send)
        }
    }

    static var none: Effect {
        Effect { _ in }
    }
}
