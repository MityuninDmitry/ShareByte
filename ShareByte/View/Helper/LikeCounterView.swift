//
//  AppCustomButtonView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/24/23.
//

import SwiftUI

extension View {
    func LikeCounterEffect(systemImage: String, font: Font, likeCounter: Int, activeTint: Color, inActiveTint: Color) -> some View {
        self
            .modifier(
                LikeCounterModifier(systemImage: systemImage, font: font, likeCounter: likeCounter, activeTint: activeTint, inActiveTint: inActiveTint)
            )
    }
}

struct LikeCounterView: View {
    
    var systemImage: String = "suit.heart.fill"
    var activeTint: Color = .pink
    var inActiveTint: Color = .gray
    
    var currentLikeCounter: Int
    var onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 15) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .LikeCounterEffect(
                        systemImage: systemImage,
                        font: .title2,
                        likeCounter: currentLikeCounter,
                        activeTint: activeTint,
                        inActiveTint: inActiveTint)
                    .foregroundStyle(currentLikeCounter > 0 ? activeTint : inActiveTint)
                    
                    Text("\(currentLikeCounter)")
                    .foregroundStyle(currentLikeCounter > 0 ? activeTint : inActiveTint)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(currentLikeCounter > 0 ? activeTint.opacity(0.25) : Color("BG"))
        }
       
       
        
        
    }
}

struct LikeCounterModifier: ViewModifier {
    var systemImage: String
    var font: Font
    var likeCounter: Int
    var activeTint: Color
    var inActiveTint: Color
    
    @State private var particles: [Particle] = []
    @State private var oldLikeCounter: Int = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .foregroundStyle(likeCounter > 0 ? activeTint : inActiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            .opacity(likeCounter > 0 ? 1 : 0)
                            
                    }
                }
                .onAppear {
                    oldLikeCounter = likeCounter
                    if particles.isEmpty {
                        for _ in (1...10) {
                            let particle = Particle()
                            particles.append(particle)
                        }
                    }
                }
                .onChange(of: likeCounter) { newValue in
                    
                    if likeCounter == 0 {
                        for index in particles.indices {
                            particles[index].reset()
                        }
                        oldLikeCounter = newValue
                    }
                    if oldLikeCounter <= newValue {
                        for index in particles.indices {
                            particles[index].reset()
                            
                            let total: CGFloat = CGFloat(particles.count)
                            let progress: CGFloat = CGFloat(index) / total
                            
                            let maxX: CGFloat = (progress > 0.5) ? 100 : -100
                            let maxY: CGFloat = 60
                            
                            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
                            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY) + 35
                            
                            let randomScale: CGFloat = .random(in: 0.35...1)
                            
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                                let extraRandomY: CGFloat = .random(in: 0...30)
                                
                                particles[index].randomX = randomX + extraRandomX
                                particles[index].randomY = -randomY - extraRandomY
                                
                            }
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                particles[index].scale = randomScale
                            }
                            
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7).delay(0.25 + (Double(index) * 0.005))) {
                                particles[index].scale = 0.001
                            }
                        }
                    }
                    oldLikeCounter = newValue
                    
                }
            }
    }
}


#Preview {
    TestLikeCounterView()
        .preferredColorScheme(.dark)
}
