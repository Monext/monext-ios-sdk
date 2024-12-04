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
        case payment(token: String)
        case securePayment(token: String)
        case sdkPaymentRequest(token: String)
        case walletPayment(token: String)
        case availableCardNetworks(token: String)
        case fetchSchemes(token: String)
        
        var path: String {
            let tokenPath = "/token/\(token)"
            switch self {
            case .stateCurrent:
                return "\(tokenPath)/state/current"
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
            }
        }
        
        private var token: String {
            switch self {
            case .stateCurrent(let token),
                 .payment(let token),
                 .securePayment(let token),
                 .sdkPaymentRequest(let token),
                 .walletPayment(let token),
                 .availableCardNetworks(let token),
                 .fetchSchemes(let token):
                return token
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

// MARK: - Private Methods
private extension PaymentAPI {
    private func performRequest<T: Decodable, P: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: P? = ""
    ) async throws -> T {
        let url = try createURL(for: endpoint)
        let request = try buildRequest(url: url, method: method, parameters: parameters)
        return try await makeRequest(request: request)
    }
    
    private func createURL(for endpoint: Endpoint) throws -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path += endpoint.path
        
        guard let url = components.url else {
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
            "Accept-Language": config.language ?? Locale.current.language.languageCode?.identifier ?? self.defaultLanguage, // Returns the value configured by the integrator in MnxtSDKConfiguration, or the language value of the device, or English by default.
            "Origin": host,
            "X-Widget-SDK": "IOS \(AppVersion.fullVersion)",
        ]
        
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // N'ajoute le body que si ce n'est pas une requête GET et qu'il y a des paramètres
        // TODO: Fix
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
        
        let mappedResponse = try mapResponse(response: (data, response))
        
        do {
            return try decoder.decode(T.self, from: mappedResponse)
        } catch {
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
