//
//  LoanAPI.swift
//  wiam_demo
//
//  Created by Nikita Parmenov on 31.12.2025.
//

import Foundation

final class LoanAPI {
    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        self.encoder = encoder

        let decoder = JSONDecoder()
        self.decoder = decoder
    }

    func submitLoanApplication(_ request: LoanApplicationRequest) async throws -> LoanApplicationResponse {
        // Пример endpoint. Подгони под свой mock-сервер.
        let url = baseURL.appendingPathComponent("posts")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw LoanAPIError.invalidResponse
        }

        // 2xx
        if (200...299).contains(http.statusCode) {
            do {
                // Response декодим через кастомный decoder ниже, чтобы Decimal парсился и как string, и как number.
                return try LoanApplicationResponse.decode(from: data, using: decoder)
            } catch {
                throw LoanAPIError.decoding(error.localizedDescription)
            }
        }

        // Не 2xx. Пытаемся вытащить текст ошибки, если он есть.
        let serverText = String(data: data, encoding: .utf8)
        throw LoanAPIError.http(statusCode: http.statusCode, body: serverText)
    }
}

enum LoanAPIError: Error, LocalizedError, Equatable {
    case invalidResponse
    case http(statusCode: Int, body: String?)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .http(let status, let body):
            if let body, !body.isEmpty {
                return "Server error (\(status)): \(body)"
            }
            return "Server error (\(status))."
        case .decoding(let msg):
            return "Failed to decode response: \(msg)"
        }
    }
}
