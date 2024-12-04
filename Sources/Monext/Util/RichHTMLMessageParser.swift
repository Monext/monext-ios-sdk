import Foundation
import SwiftUI

// Représente des morceaux inline simples depuis votre HTML (subset)
enum RichInlineNode {
    case text(String)
    case link(text: String, url: URL)
    case lineBreak
}

struct RichHTMLMessageParser {
    // Parse un HTML très simple (<br>, </br>, <a href="">) en nœuds.
    func parse(_ html: String) -> [RichInlineNode] {
        // 1) Décode les entités HTML de base (si nécessaire)
        let decoded = html.htmlEntityDecoded
        
        // 2) Normalise TOUTES les variantes de br: <br>, <br/>, <br />, </br>
        let brPattern = "(?i)<\\s*/?\\s*br\\s*/?\\s*>"
        let brNormalized = decoded.replacingOccurrences(of: brPattern, with: "<<<BR>>>", options: .regularExpression)
        
        // 3) On segmente sur les <a href="...">...</a>
        let anchorRegex = try! NSRegularExpression(pattern: "(?is)<a\\b[^>]*href\\s*=\\s*\"(.*?)\"[^>]*>(.*?)</a>")
        
        var nodes: [RichInlineNode] = []
        
        func pushPlainText(_ s: String) {
            guard !s.isEmpty else { return }
            // Split sur <<<BR>>> pour générer des lineBreak
            let parts = s.components(separatedBy: "<<<BR>>>")
            for i in 0..<parts.count {
                let part = parts[i]
                if !part.isEmpty {
                    let stripped = part.removingHTMLTags()
                    if !stripped.isEmpty {
                        nodes.append(.text(stripped))
                    }
                }
                if i < parts.count - 1 {
                    nodes.append(.lineBreak)
                }
            }
        }
        
        let full = brNormalized as NSString
        let matches = anchorRegex.matches(in: brNormalized, range: NSRange(location: 0, length: full.length))
        
        var lastLocation = 0
        for m in matches {
            let rangeBefore = NSRange(location: lastLocation, length: m.range.location - lastLocation)
            if rangeBefore.length > 0, let before = full.substring(with: rangeBefore).nilIfEmpty {
                pushPlainText(before)
            }
            
            // href et inner text
            let href = full.substring(with: m.range(at: 1))
            let inner = full.substring(with: m.range(at: 2))
            
            if let url = URL(string: href.htmlEntityDecoded.trimmingCharacters(in: .whitespacesAndNewlines)) {
                // Convertit aussi </br> à \n
                let display = inner
                    .replacingOccurrences(of: brPattern, with: "\n", options: .regularExpression)
                    .removingHTMLTags()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let displayOrURL = display.isEmpty ? url.absoluteString : display
                nodes.append(.link(text: displayOrURL, url: url))
            } else {
                // URL invalide, on pousse juste le texte interne
                pushPlainText(inner)
            }
            
            lastLocation = m.range.location + m.range.length
        }
        
        // Reste après le dernier lien
        if lastLocation < full.length {
            let tail = full.substring(from: lastLocation)
            pushPlainText(tail)
        }
        
        return nodes
    }
}

// Construit un AttributedString stylé depuis des nœuds
struct RichAttributedBuilder {
    var baseFont: Font
    var baseColor: Color
    var linkColor: Color
    var underlineLinks: Bool = true
    var addSoftWrapForLongWords: Bool = true
    
    func build(from nodes: [RichInlineNode]) -> AttributedString {
        var result = AttributedString()
        
        func appendText(_ string: String) {
            var s = AttributedString(addSoftWrapForLongWords ? string.insertingSoftWraps() : string)
            s.font = baseFont
            s.foregroundColor = baseColor
            result += s
        }
        
        func appendLink(text: String, url: URL) {
            var s = AttributedString(addSoftWrapForLongWords ? text.insertingSoftWrapsInURL() : text)
            s.font = baseFont
            s.foregroundColor = linkColor
            s.link = url
            if underlineLinks {
                s.underlineStyle = Text.LineStyle.single
            }
            result += s
        }
        
        for node in nodes {
            switch node {
            case .text(let t):
                appendText(t)
            case .link(let text, let url):
                appendLink(text: text, url: url)
            case .lineBreak:
                result.append(AttributedString("\n"))
            }
        }
        return result
    }
}

// MARK: - Helpers

private extension String {
    var htmlEntityDecoded: String {
        var s = self
        let map: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'"
        ]
        for (k, v) in map { s = s.replacingOccurrences(of: k, with: v) }
        s = s.replacingOccurrences(of: "&#(\\d+);", with: { (_, m) in
            if let code = m.first, let n = Int(code), let scalar = UnicodeScalar(n) { return String(scalar) }
            return ""
        })
        s = s.replacingOccurrences(of: "&#x([0-9a-fA-F]+);", with: { (_, m) in
            if let hex = m.first, let n = Int(hex, radix: 16), let scalar = UnicodeScalar(n) { return String(scalar) }
            return ""
        })
        return s
    }
    
    func replacingOccurrences(of pattern: String, with transform: (_ full: String, _ captures: [String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        let ns = self as NSString
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: ns.length))
        var result = ""
        var last = 0
        for m in matches {
            let range = m.range
            if range.location > last {
                result += ns.substring(with: NSRange(location: last, length: range.location - last))
            }
            var caps: [String] = []
            for i in 1..<m.numberOfRanges {
                let r = m.range(at: i)
                caps.append(r.location != NSNotFound ? ns.substring(with: r) : "")
            }
            let fullMatch = ns.substring(with: range)
            result += transform(fullMatch, caps)
            last = range.location + range.length
        }
        if last < ns.length { result += ns.substring(from: last) }
        return result
    }
    
    func removingHTMLTags() -> String {
        self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var nilIfEmpty: String? { isEmpty ? nil : self }
    
    func insertingSoftWraps(maxRun: Int = 20) -> String {
        var out = ""
        var run = 0
        for ch in self {
            if ch.isWhitespace || ch.isNewline {
                run = 0
                out.append(ch)
            } else {
                run += 1
                out.append(ch)
                if run >= maxRun {
                    out.append("\u{200B}") // Zero-width space
                    run = 0
                }
            }
        }
        return out
    }
    
    func insertingSoftWrapsInURL() -> String {
        var out = ""
        for ch in self {
            out.append(ch)
            if "/?&=_-#:.".contains(ch) {
                out.append("\u{200B}")
            }
        }
        return out
    }
}
