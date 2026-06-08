//
//  ScreenshotProtected.swift
//  Monext
//

import SwiftUI
import UIKit

// MARK: - UIViewRepresentable

private struct ScreenshotProtectedWrapper<Content: View>: UIViewRepresentable {
    let content: Content

    func makeUIView(context: Context) -> UIView {
        let secureField = UITextField()
        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false

        guard let secureView = secureField.layer.sublayers?.first?.delegate as? UIView else {
            let hosting = UIHostingController(rootView: content)
            hosting.view.backgroundColor = .clear
            return hosting.view
        }

        secureView.subviews.forEach { $0.removeFromSuperview() }
        secureView.isUserInteractionEnabled = true

        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        secureView.addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: secureView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: secureView.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: secureView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: secureView.trailingAnchor),
        ])

        let container = UIView()
        container.backgroundColor = .clear
        secureView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(secureView)

        NSLayoutConstraint.activate([
            secureView.topAnchor.constraint(equalTo: container.topAnchor),
            secureView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            secureView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            secureView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        container.tag = 42
        objc_setAssociatedObject(container, &hostingKey, hosting, .OBJC_ASSOCIATION_RETAIN)

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        let hosting = objc_getAssociatedObject(uiView, &hostingKey) as? UIHostingController<Content>
        let width = proposal.width ?? UIScreen.main.bounds.width
        return hosting?.sizeThatFits(in: CGSize(width: width, height: .infinity))
    }
}

private nonisolated(unsafe) var hostingKey: UInt8 = 0

// MARK: - ViewModifier

struct ScreenshotProtected: ViewModifier {
    func body(content: Content) -> some View {
        ScreenshotProtectedWrapper(content: content)
    }
}

// MARK: - View extensions

extension View {
    func screenshotProtected() -> some View {
        modifier(ScreenshotProtected())
    }

    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
