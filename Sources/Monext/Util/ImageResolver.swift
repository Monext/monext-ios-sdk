//
//  ImageResolver.swift
//  Monext
//
//  Created by Joshua Pierce on 13/11/2024.
//

import SwiftUI

@MainActor
struct ImageResolver {
    
    static func imageChipForPaymentMethod(_ paymentMethodType: PaymentMethod, expanded: Bool = false) -> some View {
        ImageChip {
            HStack {
                
                if expanded {
                    Spacer()
                }
                
                switch paymentMethodType {
                case .cards:
                    Image(moduleImage: "ic.creditcards")
                default:
                    if let cardCode = paymentMethodType.data?.cardCode {
                        imageForCardCode(cardCode)
                    }
                    
                    if let data = paymentMethodType.data, data.hasLogo == true, let logo = data.logo {
                        AsyncImage(url: URL(string: logo.url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: CGFloat(logo.width), height: CGFloat(logo.height))
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fit)
                                    .frame(width: CGFloat(logo.width), height: CGFloat(logo.height))
                            case .failure:
                                Text(data.logo?.title ?? "Unknown")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                
                if case .cards = paymentMethodType {
                    Text("Card")
                        .font(Appearance.DefaultFontBook().semibold16)
                }
                
                if expanded {
                    Spacer()
                }
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
        }
    }
    
    static func imageChipForAcceptedCards(_ cardCode: String?) -> some View {
        
        var view: (any View)?
        
        switch cardCode {
            
        case PaymentMethodCardCode.cb.rawValue:
            view = HStack {
                imageChipForCardCode("CB")
                imageChipForCardCode("VISA")
                imageChipForCardCode("MASTERCARD")
            }
            
        case PaymentMethodCardCode.mcvisa.rawValue:
            view = HStack {
                imageChipForCardCode("VISA")
                imageChipForCardCode("MASTERCARD")
            }
        
        default:
            view = imageChipForCardCode(cardCode)
        }
        
        if let view {
            return AnyView(view)
        }
        return AnyView(EmptyView())
    }
    
    static func imageChipForCardCode(_ cardCode: String?) -> some View {
        ImageChip { imageForCardCode(cardCode) }
    }
    
    static func imageForCardCode(_ cardCode: String?) -> some View {
        
        var view: Image?
        
        switch cardCode {
        case "CB":
            view = Image(moduleImage: "logo.cartesbancaires")
        case "VISA":
            view = Image(moduleImage: "logo.visa")
        case "MASTERCARD":
            view = Image(moduleImage: "logo.mastercard")
        case PaymentMethodCardCode.amex.rawValue:
            view = Image(moduleImage: "logo.amex")
        default:
            break
        }
        
        if let view {
            return AnyView(view.frame(width: 50))
        }
        return AnyView(EmptyView())
    }
}

struct UnknownImageError: Error {}

@MainActor
struct ImageChip<Content: View>: View {
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
        }
        .frame(height: 48)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


#Preview {
    VStack {
        
        Spacer()
        
        ImageResolver.imageChipForPaymentMethod(PreviewData.paymentMethods.first!)
        
        Spacer()
        
        ImageResolver.imageChipForPaymentMethod(PreviewData.paymentMethods[1])
        
        Spacer()
        
        ImageResolver.imageChipForPaymentMethod(PreviewData.paymentMethods[2])
        
        Spacer()
        
        ImageResolver.imageChipForCardCode("VISA")
        
        Spacer()
        
        ImageResolver.imageChipForAcceptedCards("CB")
        
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.9))
}
