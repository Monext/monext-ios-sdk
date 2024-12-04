import Foundation

actor RequestHandlerStorage {
    private var requestHandler: ( @Sendable (URLRequest) async throws -> (HTTPURLResponse, Data))?

    func setHandler(_ handler: @Sendable @escaping (URLRequest) async throws -> (HTTPURLResponse, Data)) async {
        requestHandler = handler
    }

    func executeHandler(for request: URLRequest) async throws -> (HTTPURLResponse, Data) {
        guard let handler = requestHandler else {
            throw MockURLProtocolError.noRequestHandler
        }
        return try await handler(request)
    }
    
    // MARK: - Cleanup Methods
    
    /// Clears the current request handler
    func clearHandler() async {
        requestHandler = nil
    }
    
    /// Checks if a handler is currently set
    func hasHandler() async -> Bool {
        return requestHandler != nil
    }
}

final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    private static let requestHandlerStorage = RequestHandlerStorage()

    static func setHandler(_ handler: @Sendable @escaping (URLRequest) async throws -> (HTTPURLResponse, Data)) async {
        await requestHandlerStorage.setHandler { request in
            try await handler(request)
        }
    }

    func executeHandler(for request: URLRequest) async throws -> (HTTPURLResponse, Data) {
        return try await Self.requestHandlerStorage.executeHandler(for: request)
    }
    
    // MARK: - Cleanup Methods
    
    /// Clears the current mock handler
    static func clearHandler() async {
        await requestHandlerStorage.clearHandler()
    }
    
    /// Checks if a handler is currently set
    static func hasHandler() async -> Bool {
        return await requestHandlerStorage.hasHandler()
    }
    
    /// Sets a default error handler for unhandled requests (useful for debugging)
    static func setDefaultErrorHandler() async {
        await setHandler { request in
            let error = MockURLProtocolError.noRequestHandler
            let response = HTTPURLResponse(
                url: request.url ?? URL(string: "https://example.com")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            throw error
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Task {
            do {
                let (response, data) = try await self.executeHandler(for: request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {}
}

enum MockURLProtocolError: Error, LocalizedError {
    case noRequestHandler
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .noRequestHandler:
            return "No request handler has been set for MockURLProtocol"
        case .invalidURL:
            return "The provided URL is invalid"
        }
    }
}
