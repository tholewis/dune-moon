//
//  SpiceGlowEffect.swift
//  DuneMoon
//
//  Animated spice-inspired glow effects for Dune aesthetic
//

import SwiftUI

struct SpiceGlowEffect: ViewModifier {
    @State private var animationPhase: Double = 0
    let color: Color
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(intensity * 0.6),
                radius: 8 + (animationPhase * 4),
                x: 0,
                y: 0
            )
            .shadow(
                color: color.opacity(intensity * 0.3),
                radius: 16 + (animationPhase * 8),
                x: 0,
                y: 0
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    animationPhase = 1.0
                }
            }
    }
}

extension View {
    func spiceGlow(color: Color = Color(red: 1.0, green: 0.55, blue: 0.26), intensity: Double = 1.0) -> some View {
        self.modifier(SpiceGlowEffect(color: color, intensity: intensity))
    }
}

struct PulsingSpiceOrb: View {
    @State private var pulsePhase: Double = 0
    @State private var rotationDegrees: Double = 0
    
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            duneOrange,
                            duneBlue,
                            duneOrange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size * (1.0 + pulsePhase * 0.2))
                .opacity(1.0 - pulsePhase * 0.5)
                .rotationEffect(.degrees(rotationDegrees))
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            duneOrange.opacity(0.6),
                            duneBlue.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size)
                .blur(radius: 10)
                .scaleEffect(1.0 + pulsePhase * 0.1)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3)
                .repeatForever(autoreverses: true)
            ) {
                pulsePhase = 1.0
            }
            
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                rotationDegrees = 360
            }
        }
    }
    
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26)
    }
    
    private var duneBlue: Color {
        Color(red: 0.29, green: 0.62, blue: 0.85)
    }
}

struct FloatingSpiceParticles: View {
    @State private var particles: [SpiceParticle] = []
    
    let bounds: CGSize
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .blur(radius: particle.blur)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            generateParticles()
            startAnimation()
        }
    }
    
    private func generateParticles() {
        particles = (0..<20).map { _ in
            SpiceParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...bounds.width),
                    y: CGFloat.random(in: 0...bounds.height)
                ),
                size: CGFloat.random(in: 1...3),
                color: Bool.random() ? duneOrange : duneBlue,
                opacity: Double.random(in: 0.1...0.4),
                blur: CGFloat.random(in: 2...4)
            )
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for index in particles.indices {
                var particle = particles[index]
                
                // Move particle up and slightly sideways
                particle.position.y -= CGFloat.random(in: 0.2...0.6)
                particle.position.x += CGFloat.random(in: -0.3...0.3)
                
                // Fade out as it rises
                particle.opacity *= 0.995
                
                // Reset particle if it goes off screen or fades too much
                if particle.position.y < -10 || particle.opacity < 0.05 {
                    particle.position = CGPoint(
                        x: CGFloat.random(in: 0...bounds.width),
                        y: bounds.height + 10
                    )
                    particle.opacity = Double.random(in: 0.1...0.4)
                }
                
                particles[index] = particle
            }
        }
    }
    
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26)
    }
    
    private var duneBlue: Color {
        Color(red: 0.29, green: 0.62, blue: 0.85)
    }
}

struct SpiceParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    let blur: CGFloat
}

#Preview {
    ZStack {
        Color(red: 0.1, green: 0.08, blue: 0.06)
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            // Pulsing orb
            PulsingSpiceOrb(size: 100)
            
            // Glow effect example
            Text("SPICE GLOW")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.26))
                .spiceGlow()
        }
        
        // Floating particles
        GeometryReader { geometry in
            FloatingSpiceParticles(bounds: geometry.size)
        }
        .allowsHitTesting(false)
    }
}
