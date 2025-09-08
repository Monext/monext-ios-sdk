//
//  PopImageViewTests.swift
//  Monext
//
//  Created by SDK Mobile on 09/09/2025.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import Monext

final class PopImageViewTests: XCTestCase {
    
    @MainActor
    func createSessionStateStore() -> SessionStateStore {
        let appearance = Appearance(
            confirmationColor: .green,
            errorColor: .red
        )
        let applePayConfig = ApplePayConfiguration()
        
        return SessionStateStore(
            paymentAPI: MockPaymentAPI(),
            appearance: appearance,
            config: .init(),
            applePayConfiguration: applePayConfig
        )
    }
    
    @MainActor
    func testSuccessStyleShowsCheckImageAndConfirmationColor() throws {
        let sessionStateStore = createSessionStateStore()
 
        let sut = PopImageView(style: .success).environmentObject(sessionStateStore)
        
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssert(try image.actualImage().name().contains("ic.check.large") == true)
        
        let circle = try image.background().shape()
        let color = try circle.shapeFillColor()
        XCTAssertEqual(color, sessionStateStore.appearance.confirmationColor)
    }
    
    @MainActor
    func testFailureStyleShowsExclamationImageAndErrorColor() throws {
        let sessionStateStore = createSessionStateStore()
        let sut = PopImageView(style: .failure).environmentObject(sessionStateStore)
        
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssert(try image.actualImage().name().contains("ic.exclamationpoint.large") == true)
        
        let circle = try image.background().shape()
        let color = try circle.shapeFillColor()
        XCTAssertEqual(color, sessionStateStore.appearance.errorColor)
    }
    
    @MainActor
    func testCustomStyleShowsPassedImageAndNoCircle() throws {
        let sessionStateStore = createSessionStateStore()
        let customImage = Image(systemName: "creditcard")
        let sut = PopImageView(style: .custom(customImage)).environmentObject(sessionStateStore)
        
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertEqual(try image.actualImage().name(), "creditcard")
        
        let circle = try image.background().shape()
        let color = try circle.shapeFillColor()
        XCTAssertEqual(color, .clear)
    }
}

extension InspectableView where View == ViewType.Shape {
    func shapeFillColor() throws -> Color {
        // Mirror sur l'InspectableView<Shape>
        let mirror = Mirror(reflecting: self)
        guard let content = mirror.children.first(where: { $0.label == "content" })?.value else {
            throw InspectionError.attributeNotFound(label: "content", type: "\(type(of: self))")
        }
        // Mirror sur le Content
        let contentMirror = Mirror(reflecting: content)
        guard let view = contentMirror.children.first(where: { $0.label == "view" })?.value else {
            throw InspectionError.attributeNotFound(label: "view", type: "\(type(of: content))")
        }
        // Mirror sur le _ShapeView<Circle, Color>
        let shapeMirror = Mirror(reflecting: view)
        if let style = shapeMirror.children.first(where: { $0.label == "style" })?.value as? Color {
            return style
        }
        throw InspectionError.attributeNotFound(label: "style", type: "\(type(of: view))")
    }
}
