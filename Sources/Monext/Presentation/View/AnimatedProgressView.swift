//
//  AnimatedProgressView.swift
//  Monext
//
//  Created by Joshua Pierce on 27/11/2024.
//

import SwiftUI

struct AnimatedProgressView: View {
    
    @State
    private var rotationAngle = 0.0
    
    var body: some View {
        ZStack {
            Image(moduleImage: "ic.progress.indefinite")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
        }
    }
}

#Preview {
    ZStack {
        AnimatedProgressView()
            .foregroundStyle(.green)
            .frame(width: 50, height: 50)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
