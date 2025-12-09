//  FormattingTextField.swift
//  Monext
//
//  Created by lucas bianciotto on 9/12/2025.
//

import SwiftUI
import UIKit

/// UITextField subclass that supports content insets and uses attributedText for kerning/font.
final class PaddingTextField: UITextField {
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    override var intrinsicContentSize: CGSize {
        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        let height = contentInsets.top + contentInsets.bottom + lineHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: ceil(height))
    }
}

/// UITextField wrapper that applies a Formatter
struct FormattingTextField<ID: Hashable>: UIViewRepresentable {
    @Binding var rawText: String
    var formatter: (any FormFieldView.Formatter)?
    var placeholder: String?
    var keyboardType: UIKeyboardType = .default

    // Focus handling
    var focusedState: FocusState<ID?>.Binding
    var focusedField: ID?

    // Styling
    var uiFont: UIFont?
    var textColor: UIColor?
    var placeholderColor: UIColor?
    var kerning: Double = 0

    var contentInsets: UIEdgeInsets = .init(top: 16, left: 20, bottom: 16, right: 20)
    var textAlignment: NSTextAlignment = .natural

    func makeUIView(context: Context) -> UITextField {
        let tf = PaddingTextField()
        tf.delegate = context.coordinator
        tf.keyboardType = keyboardType
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.textAlignment = textAlignment
        tf.contentInsets = contentInsets
        tf.borderStyle = .none
        tf.adjustsFontSizeToFitWidth = false

        let initial = formatter?.format(rawText) ?? rawText
        tf.attributedText = makeAttributedString(for: initial)

        if let ph = placeholder {
            let phColor = placeholderColor ?? textColor?.withAlphaComponent(0.6) ?? UIColor.systemGray
            tf.attributedPlaceholder = NSAttributedString(
                string: ph,
                attributes: [
                    .foregroundColor: phColor,
                    .font: uiFont ?? UIFont.preferredFont(forTextStyle: .body),
                    .kern: kerning
                ]
            )
        }

        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        guard let tf = uiView as? PaddingTextField else { return }

        // Update insets
        if tf.contentInsets != contentInsets {
            tf.contentInsets = contentInsets
            tf.invalidateIntrinsicContentSize()
            tf.setNeedsLayout()
        }

        // 1) Update text only when necessary (don't clobber while editing)
        let desired = formatter?.format(rawText) ?? rawText
        let currentText = tf.attributedText?.string ?? tf.text ?? ""
        if currentText != desired && !(uiView.isFirstResponder && context.coordinator.updatingFromSelf) {
            tf.attributedText = makeAttributedString(for: desired)
        }

        // 2) Sync focus — only act when the FocusState changed
        // We update coordinator view of SwiftUI focus immediately, then perform responder changes async
        let currentSwiftUIFocus = focusedState.wrappedValue
        if context.coordinator.lastObservedSwiftUIFocus != currentSwiftUIFocus {
            context.coordinator.lastObservedSwiftUIFocus = currentSwiftUIFocus

            // Do responder changes asynchronously to reduce race with keyboard appearance.
            DispatchQueue.main.async {
                if currentSwiftUIFocus == self.focusedField {
                    if !uiView.isFirstResponder {
                        uiView.becomeFirstResponder()
                    }
                } else {
                    // Only resign if the field is first responder and not in active editing moment.
                    if uiView.isFirstResponder {
                        if let tf = uiView as? UITextField {
                            if !tf.isEditing {
                                uiView.resignFirstResponder()
                            } else {
                                // If editing is active, skip resign to avoid losing focus during keyboard show.
                            }
                        } else {
                            uiView.resignFirstResponder()
                        }
                    }
                }
            }
        }

        // Update style if needed
        if let font = uiFont, tf.font != font {
            tf.font = font
            tf.invalidateIntrinsicContentSize()
        }
        if let color = textColor, tf.textColor != color {
            tf.textColor = color
        }
        if let ph = placeholder {
            let phColor = placeholderColor ?? textColor?.withAlphaComponent(0.6) ?? UIColor.systemGray
            tf.attributedPlaceholder = NSAttributedString(
                string: ph,
                attributes: [
                    .foregroundColor: phColor,
                    .font: uiFont ?? UIFont.preferredFont(forTextStyle: .body),
                    .kern: kerning
                ]
            )
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    fileprivate func makeAttributedString(for string: String) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = uiFont ?? UIFont.preferredFont(forTextStyle: .body)
        attributes[.foregroundColor] = textColor ?? UIColor.label
        if kerning != 0 {
            attributes[.kern] = kerning
        }
        return NSAttributedString(string: string, attributes: attributes)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FormattingTextField
        var updatingFromSelf = false
        var lastObservedSwiftUIFocus: ID?

        init(_ parent: FormattingTextField) {
            self.parent = parent
            self.lastObservedSwiftUIFocus = parent.focusedState.wrappedValue
        }

        @objc func editingChanged(_ textField: UITextField) {
            let current = textField.attributedText?.string ?? textField.text ?? ""
            let raw: String
            if let formatter = parent.formatter {
                raw = formatter.preformattedRawValue(current)
            } else {
                raw = current
            }
            if parent.rawText != raw {
                parent.rawText = raw
            }
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Update FocusState synchronously so SwiftUI sees the change and can update toolbar, etc.
            if parent.focusedState.wrappedValue != parent.focusedField {
                parent.focusedState.wrappedValue = parent.focusedField
            }
            // Reflect the intended focus immediately in coordinator (don't rely on reading binding synchronously)
            lastObservedSwiftUIFocus = parent.focusedField
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.focusedState.wrappedValue == parent.focusedField {
                parent.focusedState.wrappedValue = nil
            }
            lastObservedSwiftUIFocus = parent.focusedState.wrappedValue
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            // Work with NSString to keep indices in UTF-16 units (UITextInput expects that)
            let currentText = (textField.attributedText?.string ?? textField.text ?? "") as NSString
            guard range.location != NSNotFound else { return true }

            let newTextNSString = currentText.replacingCharacters(in: range, with: string) as NSString

            let raw: String
            if let formatter = parent.formatter {
                raw = formatter.preformattedRawValue(newTextNSString as String)
            } else {
                raw = newTextNSString as String
            }

            let formatted: String
            if let formatter = parent.formatter {
                formatted = formatter.format(raw)
            } else {
                formatted = raw
            }

            // compute cursor position in formatted string
            let lowerBoundOffset = range.location
            let insertionIndexInNewText = lowerBoundOffset + (string as NSString).length
            let prefixNSString = newTextNSString.substring(with: NSRange(location: 0, length: min(insertionIndexInNewText, newTextNSString.length))) as NSString
            let prefix = prefixNSString as String

            let digitsBeforeCursorInRaw: Int
            if let formatter = parent.formatter {
                digitsBeforeCursorInRaw = formatter.preformattedRawValue(prefix).count
            } else {
                digitsBeforeCursorInRaw = prefix.count
            }

            var charsSeen = 0
            var newCursorCharIndex = 0
            if digitsBeforeCursorInRaw == 0 {
                newCursorCharIndex = 0
            } else {
                var found = false
                for (i, ch) in formatted.enumerated() {
                    if parent.formatter != nil {
                        if ch.isNumber {
                            charsSeen += 1
                        }
                    } else {
                        charsSeen += 1
                    }
                    if charsSeen >= digitsBeforeCursorInRaw {
                        newCursorCharIndex = i + 1
                        found = true
                        break
                    }
                }
                if !found {
                    newCursorCharIndex = formatted.count
                }
            }

            // Convert char index to UTF-16 offset for UITextInput APIs
            let prefixIndex = formatted.index(formatted.startIndex, offsetBy: min(newCursorCharIndex, formatted.count))
            let utf16Offset = formatted[..<prefixIndex].utf16.count

            updatingFromSelf = true
            let attr = parent.makeAttributedString(for: formatted)
            textField.attributedText = attr
            setCursorPosition(textField, offset: utf16Offset)

            // Update binding raw
            if parent.rawText != raw {
                parent.rawText = raw
            }

            DispatchQueue.main.async { [weak self] in self?.updatingFromSelf = false }
            return false
        }

        private func setCursorPosition(_ textField: UITextField, offset: Int) {
            let start = textField.beginningOfDocument
            if let pos = textField.position(from: start, offset: offset),
               let range = textField.textRange(from: pos, to: pos) {
                textField.selectedTextRange = range
                return
            }
            let end = textField.endOfDocument
            if let range = textField.textRange(from: end, to: end) {
                textField.selectedTextRange = range
            }
        }
    }
}
