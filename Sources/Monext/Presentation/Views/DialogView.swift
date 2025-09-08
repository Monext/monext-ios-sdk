//
//  DialogView.swift
//  Monext
//
//  Created by Joshua Pierce on 05/12/2024.
//
//  adapted from https://stackademic.com/blog/custom-alert-in-swiftui-df860da27e57
//

import SwiftUI

fileprivate let animationDuration = 0.4

// MARK: - DialogView

struct DialogView<A: View, M: View>: View {
    
    let titleKey: LocalizedStringKey
    @Binding var isPresented: Bool
    @Binding var isAnimating: Bool
    let actions: () -> A
    let message: () -> M
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        isPresented: Binding<Bool>,
        isAnimating: Binding<Bool>,
        @ViewBuilder message: @escaping () -> M,
        @ViewBuilder actions: @escaping () -> A
    ) {
        self.titleKey = titleKey
        self._isPresented = isPresented
        self._isAnimating = isAnimating
        self.actions = actions
        self.message = message
    }
    
    var body: some View {
        
        ZStack {
            
            Color.gray
                .ignoresSafeArea()
                .opacity(isPresented ? 0.6 : 0)
            
            if isAnimating {
                VStack(spacing: 16) {
                    
                    Text(titleKey)
                    
                    message()
                        .font(config.fonts.semibold16)
                        .fontWeight(.light)
                    
                    HStack {
                        actions()
                    }
                }
                .frame(maxWidth: 330)
                .padding(16)
                .font(config.fonts.bold16)
                .foregroundStyle(config.onSurfaceColor)
                .background(config.surfaceColor)
                .clipShape(RoundedRectangle(cornerRadius: config.cardRadius))
                .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .zIndex(.greatestFiniteMagnitude)
        .onAppear() {
            show()
        }
        .onTapGesture {
            dismiss()
        }
    }
    
    private func dismiss() {
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            isAnimating = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isPresented = false
        }
    }
    
    func show() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            isAnimating = true
        }
    }
}

// MARK: - ExitPaymentDialog

struct ExitPaymentDialog: ViewModifier {
    
    @Binding
    var isPresented: Bool
    
    @State
    var isAnimating: Bool = false
    
    let onExit: () -> Void
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    func body(content: Content) -> some View {
        content
            .dialog("Exit Payment", isPresented: $isPresented, isAnimating: $isAnimating) {
                
                Text("You are about to cancel the payment of your order. No amount will be debited from your account.")
                
            } actions: {
                
                Button(action: { dismiss(notifyOnExit: true) }) {
                    Text("Exit")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                
                Button(action: { dismiss(notifyOnExit: false) }) {
                    Text("Stay")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(config.onSecondaryColor)
                .background(
                    RoundedRectangle(cornerRadius: config.buttonRadius)
                        .fill(config.secondaryColor)
                )
            }
    }
    
    func dismiss(notifyOnExit: Bool) {
        withAnimation(.easeInOut(duration: animationDuration)) {
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isPresented = false
            if notifyOnExit {
                onExit()
            }
        }
    }
}

// MARK: - CvvInfoDialog

struct CvvInfoDialog: ViewModifier {
    
    @Binding var isPresented: Bool
    
    @State var isAnimating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .dialog("CVV", isPresented: $isPresented, isAnimating: $isAnimating) {
                
                Text("Please enter the security code written on your card. It may have 3 or 4 digits.")
                
            } actions: {
                // N/A
            }
    }
}

// MARK: - CardNetworkInfoDialog

struct CardNetworkInfoDialog: ViewModifier {
    
    @Binding var isPresented: Bool
    
    @State var isAnimating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .dialog("Info", isPresented: $isPresented, isAnimating: $isAnimating) {
                
                Text("Your card has two different networks. Please choose the one you prefer to use.")
                
            } actions: {
                // N/A
            }
    }
}

// MARK: - Extensions

extension View {
    
    func dialog<A: View, M: View>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, isAnimating: Binding<Bool>, @ViewBuilder message: @escaping () -> M, @ViewBuilder actions: @escaping () -> A) -> some View {
        fullScreenCover(isPresented: isPresented) {
            DialogView(
                titleKey,
                isPresented: isPresented,
                isAnimating: isAnimating,
                message: message,
                actions: actions
            )
            .presentationBackgroundCompat()
        }
        .transaction { transaction in
//            if isPresented.wrappedValue {
                transaction.disablesAnimations = true
                transaction.animation = .linear(duration: 0.1)
//            }
        }
    }
    
    func presentationBackgroundCompat() -> some View {
        if #available(iOS 16.4, *) {
            return presentationBackground(.clear)
        } else {
            return background(FullScreenCoverBackgroundRemovalView())
        }
    }
}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        BackgroundRemovalView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview {
    
    @Previewable @State var isPresentedExit = false
    @Previewable @State var isPresentedCvv = false
    @Previewable @State var isPresentedCardNetwork = false
    
    let config = PreviewData.paymentSheetConfig
    
    VStack {
        
        Button(action: { isPresentedExit.toggle() }) {
            Text("Test Exit Payment")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .foregroundColor(.white)
        .background(Capsule().fill(Color.black))
        .padding()
        .modifier(
            ExitPaymentDialog(
                isPresented: $isPresentedExit,
                onExit: { }
            )
        )
        
        Button(action: { isPresentedCvv.toggle() }) {
            Text("Test CVV")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .foregroundColor(.white)
        .background(Capsule().fill(Color.black))
        .padding()
        .modifier(CvvInfoDialog(isPresented: $isPresentedCvv))
        
        Button(action: { isPresentedCardNetwork.toggle() }) {
            Text("Test CardNetwork")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .foregroundColor(.white)
        .background(Capsule().fill(Color.black))
        .padding()
        .modifier(CardNetworkInfoDialog(isPresented: $isPresentedCardNetwork))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.5, green: 0.8, blue: 0.5))
    .environmentObject(PreviewData.sessionStore)
}
