import SwiftUI
import Foundation

struct PendingScreen: View {
    
    let onExit: () -> Void
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    @State private var attributedMessage: AttributedString?
    
    private var config: Appearance { sessionStore.appearance }
    
    private var amount: String {
        sessionStore.sessionState?.info?.formattedAmount ?? ""
    }
    
    private var orderRef: String {
        sessionStore.sessionState?.info?.orderRef ?? ""
    }
    
    private var localizedHTML: String? {
        sessionStore.sessionState?.paymentOnholdPartner?.message?.localizedMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    
                    Image(systemName: "hourglass.circle.fill")
                        .font(.system(size: 64, weight: .regular))
                        .foregroundStyle(config.secondaryColor)
                    
                    Text("Payment pending")
                        .font(config.fonts.bold24)
                        .foregroundStyle(config.onBackgroundColor)
                    
                    if let attributedMessage {
                        Text(attributedMessage)
                            .font(config.fonts.semibold16)
                            .foregroundStyle(config.onBackgroundColor)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Your payment is pending. Please contact your merchant for further information.")
                            .font(config.fonts.semibold16)
                            .foregroundStyle(config.onBackgroundColor)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }
            .background(config.backgroundColor)
            
            Button(action: { onExit() }) {
                Text("Back to the app")
                    .font(config.fonts.bold18)
                    .padding(.vertical, 10)
                    .foregroundStyle(config.onSecondaryColor)
                    .frame(maxWidth: .infinity)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: config.buttonRadius)
                    .fill(config.secondaryColor)
            )
            .padding(16)
            .background(config.surfaceColor)
        }
        .onAppear { rebuildAttributedMessage() }
        .onChange(of: localizedHTML) { _ in rebuildAttributedMessage() }
    }
    
    private func rebuildAttributedMessage() {
        guard let html = localizedHTML, !html.isEmpty else {
            attributedMessage = nil
            return
        }
        let nodes = RichHTMLMessageParser().parse(html)
        let builder = RichAttributedBuilder(
            baseFont: config.fonts.semibold16,
            baseColor: config.onBackgroundColor,
            linkColor: config.secondaryColor,
            underlineLinks: true,
            addSoftWrapForLongWords: true
        )
        attributedMessage = builder.build(from: nodes)
    }
}

#Preview {
    PendingScreen() {}
        .environmentObject(PreviewData.sessionStore)
}
