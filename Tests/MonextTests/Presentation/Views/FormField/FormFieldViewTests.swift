//
//  FormFieldViewTests.swift
//  MonextTests
//
//  Created by SDK Mobile on 09/09/2025.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import Monext

// MARK: - Dummy Formatter pour tests
private struct DummyFormatter: FormFieldView.Formatter {
    func format(_ text: String) -> String {
        text
            .chunked(size: 2)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
    }
    func preformattedRawValue(_ text: String) -> String {
        text.replacingOccurrences(of: " ", with: "")
    }
}

private extension String {
    func chunked(size: Int) -> [String] {
        guard size > 0 else { return [self] }
        var result: [String] = []
        var buffer = ""
        for (idx, ch) in enumerated() {
            buffer.append(ch)
            if (idx + 1) % size == 0 {
                result.append(buffer)
                buffer = ""
            }
        }
        if !buffer.isEmpty { result.append(buffer) }
        return result
    }
}

// MARK: - Host View pour injecter FocusState et Environment
private struct FormFieldHost: View {
    
    @State var externalValue: String
    let label: LocalizedStringKey
    let errorMessage: LocalizedStringKey?
    let formatter: (any FormFieldView.Formatter)?
    let placeholder: String?
    let onInfoTap: (() -> Void)?
    let sessionStore: SessionStateStore
    
    @FocusState private var focused: String?
    
    var body: some View {
        FormFieldView(
            label: label,
            textValue: Binding(
                get: { externalValue },
                set: { externalValue = $0 }
            ),
            errorMessage: errorMessage,
            formatter: formatter,
            useOnSurfaceStyle: false,
            keyboardType: .numberPad,
            focusedState: $focused,
            focusedField: "PHONE_NUMBER",
            onTappedInfoAccessory: onInfoTap,
            placeholder: placeholder
        )
        .environmentObject(sessionStore)
    }
}

final class FormFieldViewTests: XCTestCase {
    
    @MainActor
    func makeSessionStore() -> SessionStateStore {
        SessionStateStore(
            paymentAPI: MockPaymentAPI(),
            appearance: .init(),
            config: .init(),
            applePayConfiguration: .init()
        )
    }
    
    // MARK: - Tests
    
    @MainActor
    func testLabelIsDisplayed() throws {
        let host = FormFieldHost(
            externalValue: "",
            label: "Card Number",
            errorMessage: nil,
            formatter: nil,
            placeholder: "0000 0000 0000 0000",
            onInfoTap: nil,
            sessionStore: makeSessionStore()
        )
        ViewHosting.host(view: host)
        
        let text = try host.inspect().find(text: "Card Number").string()
        XCTAssertEqual(text, "Card Number")
    }
    
    @MainActor
    func testPlaceholderIsShownInitially() throws {
        let host = FormFieldHost(
            externalValue: "",
            label: "Card Number",
            errorMessage: nil,
            formatter: nil,
            placeholder: "0000 0000 0000 0000",
            onInfoTap: nil,
            sessionStore: makeSessionStore()
        )
        ViewHosting.host(view: host)
        
        XCTAssertEqual(host.placeholder, "0000 0000 0000 0000")
    }
    
    @MainActor
    func testErrorMessageIsDisplayed() throws {
        let host = FormFieldHost(
            externalValue: "",
            label: "Card Number",
            errorMessage: "Format invalide",
            formatter: nil,
            placeholder: nil,
            onInfoTap: nil,
            sessionStore: makeSessionStore()
        )
        ViewHosting.host(view: host)
        
        let error = try host.inspect().find(text: "Format invalide").string()
        XCTAssertEqual(error, "Format invalide")
    }
    
    @MainActor
    func testNoErrorMessageWhenNil() throws {
        let host = FormFieldHost(
            externalValue: "",
            label: "Card Number",
            errorMessage: nil,
            formatter: nil,
            placeholder: nil,
            onInfoTap: nil,
            sessionStore: makeSessionStore()
        )
        ViewHosting.host(view: host)
        
        XCTAssertThrowsError(
            try host.inspect().find(text: "Format invalide")
        )
    }
    
    @MainActor
    func testInfoAccessoryTapCallsClosure() throws {
        let exp = expectation(description: "Info tapped")
        let host = FormFieldHost(
            externalValue: "",
            label: "Card Number",
            errorMessage: nil,
            formatter: nil,
            placeholder: nil,
            onInfoTap: { exp.fulfill() },
            sessionStore: makeSessionStore()
        )
        ViewHosting.host(view: host)
        
        let image = try host.inspect().find(ViewType.Image.self)
        try image.callOnTapGesture()
        
        wait(for: [exp], timeout: 1.0)
    }
}
