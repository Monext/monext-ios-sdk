import Foundation
import OSLog
import ThreeDS_SDK

final class PaymentAPI: PaymentAPIProtocol {
    
    // MARK: - self
    private let scheme = "https"
    private let servicesPath = "/services"
    private let tokenPath = "/token"
    private let applicationJSON = "application/json"
    private let defaultLanguage = "en"
    
    // MARK: - Endpoints
    private enum Endpoint {
        case stateCurrent(token: String)
        case isDone(token: String, cardCode: String)
        case payment(token: String)
        case securePayment(token: String)
        case sdkPaymentRequest(token: String)
        case walletPayment(token: String)
        case availableCardNetworks(token: String)
        case fetchSchemes(token: String)
        case log
        
        var path: String {
            let tokenPath = "/token/\(token)"
            switch self {
            case .stateCurrent:
                return "\(tokenPath)/state/current"
            case .isDone(_, let cardCode):
                let timestamp = Int(Date().timeIntervalSince1970)
                return "\(tokenPath)/cardCode/\(cardCode)/activewaiting/isDone?timestamp=\(timestamp)"
            case .payment:
                return "\(tokenPath)/paymentRequest"
            case .securePayment:
                return "\(tokenPath)/securedPaymentRequest"
            case .sdkPaymentRequest:
                return "\(tokenPath)/SdkPaymentRequest"
            case .walletPayment:
                return "\(tokenPath)/walletPaymentRequest"
            case .availableCardNetworks:
                return "\(tokenPath)/availablecardnetworks"
            case .fetchSchemes:
                return "\(tokenPath)/directoryServerSdkKeys"
            case .log:
                return "/log"
            }
        }
        
        private var token: String {
            switch self {
            case .stateCurrent(let token),
                 .isDone(let token, _),
                 .payment(let token),
                 .securePayment(let token),
                 .sdkPaymentRequest(let token),
                 .walletPayment(let token),
                 .availableCardNetworks(let token),
                 .fetchSchemes(let token):
                return token
            case .log:
                return ""
            }
        }
    }
    
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    private let config: MnxtSDKConfiguration
    internal let environment: MnxtEnvironment
    
    private var baseURL: URL {
        var components = URLComponents()
        let (host, extraPath) = extractHostAndPath(from: environment.host)
        components.scheme = self.scheme
        components.host = host
        components.path = extraPath + self.servicesPath
        return components.url!
    }

    
    // MARK: - Initialization
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        config: MnxtSDKConfiguration,
        environment: MnxtEnvironment = .sandbox
    ) {
        self.session = session
        self.decoder = decoder
        self.config = config
        self.environment = environment
    }
    
    // MARK: - Public Methods
    public func stateCurrent(sessionToken: String) async throws -> SessionState {
        try await performRequest(
            endpoint: .stateCurrent(token: sessionToken),
            method: .GET
        )
    }
    
    public func isDone(sessionToken: String, cardCode: String) async throws -> Bool {
        try await performRequest(
            endpoint: .isDone(token: sessionToken, cardCode: cardCode),
            method: .GET
        )
    }
    
    public func payment(sessionToken: String, params: PaymentRequest) async throws -> SessionState {
        try await performRequest(
            endpoint: .payment(token: sessionToken),
            method: .POST,
            parameters: params
        )
    }
    
    public func securePayment(sessionToken: String, params: SecuredPaymentRequest) async throws -> SessionState {
        try await performRequest(
            endpoint: .securePayment(token: sessionToken),
            method: .POST,
            parameters: params
        )
    }
    
    public func sdkPaymentRequest(sessionToken: String, params: AuthenticationResponse) async throws -> SessionState {
        try await performRequest(
            endpoint: .sdkPaymentRequest(token: sessionToken),
            method: .POST,
            parameters: params
        )
    }
    
    public func walletPayment(sessionToken: String, params: WalletPaymentRequest) async throws -> SessionState {
        try await performRequest(
            endpoint: .walletPayment(token: sessionToken),
            method: .POST,
            parameters: params
        )
    }
    
    public func availableCardNetworks(sessionToken: String, params: AvailableCardNetworksRequest) async throws ->
    AvailableCardNetworksResponse {
        try await performRequest(
            endpoint: .availableCardNetworks(token: sessionToken),
            method: .POST,
            parameters: params
        )
    }
    
    public func fetchSchemes(sessionToken: String) async throws -> DirectoryServerSdkKeyListResponse {
        try await performRequest(
           endpoint: .fetchSchemes(token: sessionToken),
           method: .GET
       )
   }
    
    // MARK: - Logging API
    public func sendLog(message: String, level: String = "INFO", url: String? = "", token: String? = "", loggerName: String = "") async throws {
        let payload = LogPayload(
            logger: "SDK iOS - \(AppVersion.marketingVersion)",
            timestamp: Self.currentTimestampMillis(),
            level: level,
            url: url,
            message:
                "\(loggerName) - \(message)",
            token: token
        )
        try await performVoidRequest(endpoint: .log, method: .POST, parameters: payload)
    }
    
    public func sendError(
        message: String,
        url: String? = "",
        token: String? = "",
        loggerName: String = ""
    ) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                print("ERROR: \(loggerName) - \(message)")
                try await self.sendLog(
                    message: message,
                    level: "ERROR",
                    url: url,
                    token: token,
                    loggerName: loggerName
                )
            } catch {
                Logger.network.error("Failed to report error to /payline-widget/log: \(error, privacy: .public)")
            }
        }
    }
    
    func returnURLString(sessionToken: String) -> String {
            var comps = URLComponents()
            let (host, extraPath) = extractHostAndPath(from: environment.host)
            comps.scheme = "https"
            comps.host = host
            comps.path = extraPath + "/v2"
            comps.queryItems = [URLQueryItem(name: "token", value: sessionToken)]
            return comps.string!
    }
    
    func getEnvironment() -> MnxtEnvironment {
        return self.environment
    }
    
}

// MARK: - Private Helpers & Networking
private extension PaymentAPI {
    struct LogPayload: Encodable {
        let logger: String
        let timestamp: Int64
        let level: String
        let url: String?
        let message: String
        let token: String?
        
        enum CodingKeys: String, CodingKey {
            case logger, timestamp, level, url, message, token
        }
    }
    
    private static func currentTimestampMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    private struct EmptyParams: Encodable {}
    
    struct EmptyResponse: Decodable {}
    
    private func performRequest<T: Decodable, P: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: P? = nil
    ) async throws -> T {
        let url = try createURL(for: endpoint)
        let request = try buildRequest(url: url, method: method, parameters: parameters)
        return try await makeRequest(request: request)
    }
    
    private func performRequest<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod
    ) async throws -> T {
        return try await performRequest(endpoint: endpoint, method: method, parameters: Optional<EmptyParams>.none)
    }
    
    private func performVoidRequest<P: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: P? = nil
    ) async throws {
        let url = try createURL(for: endpoint)
        let request = try buildVoidRequest(url: url, endpoint: endpoint, method: method, parameters: parameters)

        let (data, response) = try await session.data(for: request)
        logResponse(response, data: data)
        _ = try mapResponse(response: (data: data, response: response))
    }

    /// Construit la requête pour les endpoints void. Gère le cas particulier de /log (form-urlencoded).
    private func buildVoidRequest<P: Encodable>(
        url: URL,
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: P? = nil
    ) throws -> URLRequest {
        if case .log = endpoint {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue

            let (host, _) = extractHostAndPath(from: environment.host)

            // Headers adaptés pour form-urlencoded
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(self.applicationJSON, forHTTPHeaderField: "Accept")
            request.setValue(config.language ?? Locale.current.language.languageCode?.identifier ?? self.defaultLanguage,
                             forHTTPHeaderField: "Accept-Language")
            request.setValue(host, forHTTPHeaderField: "Origin")
            request.setValue("IOS \(AppVersion.fullVersion)", forHTTPHeaderField: "X-Widget-SDK")

            if method != .GET, let params = parameters {
                request.httpBody = try formURLEncodedBody(for: params, wrapArray: true)
            }

            return request
        } else {
            return try buildRequest(url: url, method: method, parameters: parameters)
        }
    }
    
    // Helper pour encoder un Encodable en "data=[{...}]&layout=JsonLayout"
    private func formURLEncodedBody<P: Encodable>(for parameters: P, wrapArray: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        // Configure le encoder si besoin (dates, etc.)
        let jsonData = try encoder.encode(parameters)
        guard var jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NetworkError.encodingError(NSError(domain: "Encoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot convert JSON data to string"]))
        }

        if wrapArray {
            jsonString = "[\(jsonString)]"
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "data", value: jsonString),
            URLQueryItem(name: "layout", value: "JsonLayout")
        ]

        guard let percentEncodedQuery = components.percentEncodedQuery,
              let body = percentEncodedQuery.data(using: .utf8) else {
            throw NetworkError.encodingError(NSError(domain: "Encoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot build form body"]))
        }

        return body
    }
    
    private func createURL(for endpoint: Endpoint) throws -> URL {
        if case .log = endpoint {
            let (host, extraPath) = extractHostAndPath(from: environment.host)
            var comps = URLComponents()
            comps.scheme = self.scheme
            comps.host = host
            comps.path = extraPath + endpoint.path
            guard let url = comps.url else {
                throw NetworkError.invalidURL
            }
            return url
        }
        
        // baseURL (/services) + endpoint.path
        let baseURLString = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fullURLString = baseURLString + endpoint.path
        
        guard let url = URL(string: fullURLString) else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    private func buildRequest<T: Encodable>(
        url: URL,
        method: HTTPMethod,
        parameters: T? = nil
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let (host, _) = extractHostAndPath(from: environment.host)
        
        // Add headers
        let headers = [
            "Content-Type": self.applicationJSON,
            "Accept": self.applicationJSON,
            "Accept-Language": config.language ?? Locale.current.language.languageCode?.identifier ?? self.defaultLanguage,
            "Origin": host,
            "X-Widget-SDK": "IOS \(AppVersion.fullVersion)",
        ]
        
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // N'ajoute le body que si ce n'est pas une requête GET et qu'il y a des paramètres
        if method != .GET, let parameters = parameters {
            do {
                request.httpBody = try JSONEncoder().encode(parameters)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        return request
    }
    
    private func makeRequest<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        logResponse(response, data: data)
        
        let mappedResponse = try mapResponse(response: (data: data, response: response))
        
        do {
            return try decoder.decode(T.self, from: mappedResponse)
        } catch {
            self.sendError(message: error.localizedDescription)
            Logger.network.error("\(error, privacy: .public)")
            throw NetworkError.decodingError(error)
        }
    }
    
    func mapResponse(response: (data: Data, response: URLResponse)) throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response.data
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.from(statusCode: httpResponse.statusCode, data: response.data)
        }
        
        return response.data
    }
    
    func extractHostAndPath(from host: String) -> (host: String, path: String) {
        var hostWithScheme = host
        if !host.contains("://") {
            hostWithScheme = "https://\(host)"
        }
        
        guard let components = URLComponents(string: hostWithScheme) else {
            return (host, "")
        }
        
        let cleanHost = components.host ?? host
        let path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        return (cleanHost, path.isEmpty ? "" : "/\(path)")
    }
    
    func logResponse(_ response: URLResponse, data: Data) {
        Logger.network.debug("\(response, privacy: .public)")
        if let message = String(data: data, encoding: .utf8) {
            Logger.network.debug("\(message, privacy: .public)")
        }
    }
}
