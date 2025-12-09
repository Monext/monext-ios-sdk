//
//  FormattingTextFieldTests.swift
//  MonextTests
//
//  Created by SDK Mobile on 09/12/2025.
//

import XCTest
import SwiftUI
import UIKit
@testable import Monext

// Dummy formatter (même implémentation que celle dans tes autres tests)
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

// ObservableObject pour exposer la valeur liée au FormattingTextField
private class TFModel: ObservableObject {
    @Published var raw: String = ""
}

// Host SwiftUI view qui expose Binding via l'ObservableObject
private struct TFHostView: View {
    @ObservedObject var model: TFModel
    @FocusState private var focused: String?
    var formatter: (any FormFieldView.Formatter)?
    var placeholder: String?
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        FormattingTextField<String>(
            rawText: Binding(get: { model.raw }, set: { model.raw = $0 }),
            formatter: formatter,
            placeholder: placeholder,
            keyboardType: keyboardType,
            focusedState: $focused,
            focusedField: "PHONE_NUMBER",
            uiFont: nil,
            textColor: nil,
            placeholderColor: nil,
            kerning: 0,
            contentInsets: .init(top: 8, left: 8, bottom: 8, right: 8),
            textAlignment: .natural
        )
        .frame(width: 320, height: 44)
    }
}

@MainActor
final class FormattingTextFieldTests: XCTestCase {

    // Helper pour trouver le UITextField dans la hiérarchie de vues du hosting controller
    private func findTextField(in view: UIView) -> UITextField? {
        if let tf = view as? UITextField { return tf }
        for sub in view.subviews {
            if let found = findTextField(in: sub) { return found }
        }
        return nil
    }

    // Crée un hosting controller et attend le layout minimal
    private func makeHostingController<V: View>(rootView: V) -> UIHostingController<V> {
        let vc = UIHostingController(rootView: rootView)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        // force layout
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        return vc
    }

    @MainActor
    func testInitialAttributedTextAndPlaceholderWithFormatter() throws {
        let model = TFModel()
        model.raw = "1234" // on attend "12 34"
        let hostView = TFHostView(model: model, formatter: DummyFormatter(), placeholder: "0000 0000")
        let vc = makeHostingController(rootView: hostView)

        guard let tf = findTextField(in: vc.view) else {
            XCTFail("UITextField not found in hosting controller view hierarchy")
            return
        }

        // Vérifie le texte attribué (formaté)
        XCTAssertEqual(tf.attributedText?.string, "12 34", "Le texte attribué devrait être formaté par le DummyFormatter")

        // Vérifie le placeholder attribué
        if let ph = tf.attributedPlaceholder?.string {
            XCTAssertEqual(ph, "0000 0000")
        } else {
            XCTFail("attributedPlaceholder missing")
        }
    }

    @MainActor
    func testTypingUpdatesAttributedTextRawBindingAndCursorPosition() throws {
        let model = TFModel()
        model.raw = ""
        let hostView = TFHostView(model: model, formatter: DummyFormatter(), placeholder: "00 00")
        let vc = makeHostingController(rootView: hostView)

        guard let tf = findTextField(in: vc.view) else {
            XCTFail("UITextField not found in hosting controller view hierarchy")
            return
        }

        guard let delegate = tf.delegate else {
            XCTFail("UITextField delegate not set or not conforming to UITextFieldDelegate")
            return
        }

        // 1) Simule insertion "1" à la position 0
        let range0 = NSRange(location: 0, length: 0)
        _ = delegate.textField?(tf, shouldChangeCharactersIn: range0, replacementString: "1")
        // After coordinator handling, attributedText should be "1" and raw model "1"
        XCTAssertEqual(tf.attributedText?.string, "1")
        XCTAssertEqual(model.raw, "1")

        // cursor should be at offset 1
        let selStart1 = tf.selectedTextRange?.start
        let offset1 = selStart1.map { tf.offset(from: tf.beginningOfDocument, to: $0) } ?? -1
        XCTAssertEqual(offset1, 1, "Cursor should be at offset 1 after inserting '1'")

        // 2) Simule insertion "2" at end -> should format to "12"
        let currentText = tf.attributedText?.string ?? ""
        let rangeEnd = NSRange(location: currentText.count, length: 0)
        _ = delegate.textField?(tf, shouldChangeCharactersIn: rangeEnd, replacementString: "2")
        XCTAssertEqual(tf.attributedText?.string, "12")
        XCTAssertEqual(model.raw, "12")
        let selStart2 = tf.selectedTextRange?.start
        let offset2 = selStart2.map { tf.offset(from: tf.beginningOfDocument, to: $0) } ?? -1
        XCTAssertEqual(offset2, 2, "Cursor should be at offset 2 after inserting '2' resulting in '12'")

        // 3) Simule insertion "3" at end -> raw becomes "123", formatted "12 3"
        let currentText2 = tf.attributedText?.string ?? ""
        let rangeEnd2 = NSRange(location: currentText2.count, length: 0)
        _ = delegate.textField?(tf, shouldChangeCharactersIn: rangeEnd2, replacementString: "3")
        XCTAssertEqual(tf.attributedText?.string, "12 3")
        XCTAssertEqual(model.raw, "123")
        let selStart3 = tf.selectedTextRange?.start
        let offset3 = selStart3.map { tf.offset(from: tf.beginningOfDocument, to: $0) } ?? -1
        // After formatting "12 3", cursor should be after the '3' -> index 4 (characters: '1','2',' ','3' => offset 4)
        XCTAssertEqual(offset3, 4, "Cursor should be after the inserted digit in the formatted string '12 3'")

        // 4) Simule suppression (backspace) : remove last character
        let currentText3 = tf.attributedText?.string ?? ""
        let delRange = NSRange(location: max(0, currentText3.count - 1), length: 1)
        _ = delegate.textField?(tf, shouldChangeCharactersIn: delRange, replacementString: "")
        // expected raw "12", formatted "12"
        XCTAssertEqual(model.raw, "12")
        XCTAssertEqual(tf.attributedText?.string, "12")
    }

    @MainActor
    func testEditingChangedUpdatesRawYsingFormatter() throws {
        let model = TFModel()
        model.raw = ""
        let hostView = TFHostView(model: model, formatter: DummyFormatter(), placeholder: nil)
        let vc = makeHostingController(rootView: hostView)

        guard let tf = findTextField(in: vc.view) else {
            XCTFail("UITextField not found")
            return
        }

        // Access coordinator
        guard let coord = tf.delegate as? FormattingTextField<String>.Coordinator else {
            XCTFail("Coordinator not found as delegate")
            return
        }

        // Set attributedText to a formatted string and call editingChanged(_:)
        tf.attributedText = NSAttributedString(string: "12 34")
        coord.editingChanged(tf)

        // Coordinator should call formatter.preformattedRawValue and update the parent's raw binding (model.raw)
        XCTAssertEqual(model.raw, "1234", "editingChanged should strip formatting via preformattedRawValue and update binding")
    }

    @MainActor
    func testTextFieldDidBeginEditingUpdatesCoordinatorObservedFocus() throws {
        let model = TFModel()
        model.raw = ""
        let hostView = TFHostView(model: model, formatter: nil, placeholder: nil)
        let vc = makeHostingController(rootView: hostView)

        guard let tf = findTextField(in: vc.view) else {
            XCTFail("UITextField not found")
            return
        }

        guard let coord = tf.delegate as? FormattingTextField<String>.Coordinator else {
            XCTFail("Coordinator not found as delegate")
            return
        }

        // Ensure initial observed focus is something different
        coord.lastObservedSwiftUIFocus = nil

        // Call the delegate method directly (it schedules a DispatchQueue.main.async)
        coord.textFieldDidBeginEditing(tf)

        // Wait for the async DispatchQueue.main.async inside the coordinator
        let exp = expectation(description: "coordinator updated lastObservedSwiftUIFocus after begin editing")
        DispatchQueue.main.async {
            // nested async to ensure the coordinator's async block ran first
            DispatchQueue.main.async {
                XCTAssertEqual(coord.lastObservedSwiftUIFocus, coord.parent.focusedField)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    @MainActor
    func testTextFieldDidEndEditingUpdatesCoordinatorObservedFocusToNil() throws {
        let model = TFModel()
        model.raw = ""
        let hostView = TFHostView(model: model, formatter: nil, placeholder: nil)
        let vc = makeHostingController(rootView: hostView)

        guard let tf = findTextField(in: vc.view) else {
            XCTFail("UITextField not found")
            return
        }

        guard let coord = tf.delegate as? FormattingTextField<String>.Coordinator else {
            XCTFail("Coordinator not found as delegate")
            return
        }

        // Set initial observed focus to the field value
        coord.lastObservedSwiftUIFocus = coord.parent.focusedField

        // Call the delegate method directly (it schedules a DispatchQueue.main.async)
        coord.textFieldDidEndEditing(tf)

        // Wait for the async DispatchQueue.main.async inside the coordinator
        let exp = expectation(description: "coordinator updated lastObservedSwiftUIFocus after end editing")
        DispatchQueue.main.async {
            // nested async to ensure the coordinator's async block ran first
            DispatchQueue.main.async {
                XCTAssertNil(coord.lastObservedSwiftUIFocus)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
