//
//  LoanLocalStorage.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

protocol LoanTermsStorage {
    func save(_ terms: LoanTerms) throws
    func load() throws -> LoanTerms?
    func clear() throws
}

final class UserDefaultsLoanTermsStorage: LoanTermsStorage {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let key = "loan.terms.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ terms: LoanTerms) throws {
        let data = try encoder.encode(terms)
        defaults.set(data, forKey: key)
    }

    func load() throws -> LoanTerms? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try decoder.decode(LoanTerms.self, from: data)
    }

    func clear() throws {
        defaults.removeObject(forKey: key)
    }
}
