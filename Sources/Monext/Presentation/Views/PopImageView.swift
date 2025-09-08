//
//  PopImageView.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI

struct PopImageView: View {
    
    let style: Style
    
    @State
    private var imageScale: CGFloat = 0.0
    
    private let animationDuration: CGFloat = 0.3
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        
        let image: Image
        let circleColor: Color
        
        switch style {
        case .success:
            image = Image(moduleImage: "ic.check.large")
            circleColor = config.confirmationColor
        case .failure:
            image = Image(moduleImage: "ic.exclamationpoint.large")
            circleColor = config.errorColor
        case .custom(let customImage):
            image = customImage
            circleColor = .clear
        }
        
        return image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 106, height: 106)
            .background(Circle().fill(circleColor))
            .scaleEffect(imageScale)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        imageScale = 1.2
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                        withAnimation(.easeOut(duration: animationDuration)) {
                            imageScale = 1.0
                        }
                    }
                }
            }
    }
    
    enum Style {
        case success
        case failure
        case custom(Image)
    }
}

#Preview {
    
    let params = PreviewData.paymentSheetConfig
    
    VStack {
        Spacer()
        
        PopImageView(style: .success)
        
        Spacer()
        
        PopImageView(style: .failure)
        
        Spacer()
        
        PopImageView(style: .custom(
            Image(systemName: "creditcard")
        ))
        
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environmentObject(PreviewData.sessionStore)
}
