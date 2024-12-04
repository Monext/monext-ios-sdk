//
//  RedirectionWebView.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI
import WebKit

struct RedirectionWebView: UIViewRepresentable {
    
    let data: RedirectionData
    let onComplete: () -> Void
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    var targetUrl: URL? {
        URL(string: data.requestUrl)
    }
    
    var postData: String {
        (data.requestFields ?? [:])
            .map { (key, value) -> String in
                "\(key)=\(value)"
            }
            .joined(separator: "&")
    }
    
    var urlRequest: URLRequest? {
        guard let url = targetUrl else { return nil }
        var request = URLRequest(url: url)
        if data.requestType.uppercased() == "POST" {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData.data(using: .utf8)
        } else {
            request.httpMethod = "GET"
        }
        return request
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        
        let script = WKUserScript(
            source: "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; document.getElementsByTagName('head')[0].appendChild(meta);",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)
        
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let request = urlRequest else { return }
        if context.coordinator.lastRequest != request {
            context.coordinator.lastRequest = request
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        let parent: RedirectionWebView
        var lastRequest: URLRequest?
        
        var redirectionUrl: String {
            var comps = URLComponents()
            comps.scheme = "https"
           
            let fullHost = parent.sessionStore.env.host

             if let url = URL(string: "https://\(fullHost)"),
                let host = url.host {
                comps.host = host
                comps.path = url.path
             }

            return comps.string ?? ""
        }
        
        init(_ parent: RedirectionWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("did start provisional")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            print("did fail provisional")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("did commit")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            print("did fail")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("did finish")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
            print("did decidePolicy")
            if navigationResponse.response.url?.absoluteString.starts(with: redirectionUrl) == true {
                parent.onComplete()
            }
            decisionHandler(.allow)
        }
    }
}
