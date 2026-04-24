//
//  AppIconGenerator.swift
//  DuneMoon
//
//  Generates Dune-inspired app icon
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient - deep desert night
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.09, blue: 0.07),
                    Color(red: 0.08, green: 0.06, blue: 0.04),
                    Color(red: 0.05, green: 0.04, blue: 0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle radial glow from center
            RadialGradient(
                colors: [
                    Color(red: 0.2, green: 0.15, blue: 0.1).opacity(0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            
            // Main moon with spice glow
            ZStack {
                // Outer spice glow layers
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.4),
                                Color(red: 0.29, green: 0.62, blue: 0.85).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 180,
                            endRadius: 280
                        )
                    )
                    .frame(width: 560, height: 560)
                    .blur(radius: 30)
                
                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.5),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 150,
                            endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .blur(radius: 20)
                
                // Moon body
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.88, green: 0.70, blue: 0.50), // Bright sand
                                Color(red: 0.83, green: 0.65, blue: 0.45), // Mid sand
                                Color(red: 0.70, green: 0.55, blue: 0.38)  // Dark sand edge
                            ],
                            center: UnitPoint(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 220
                        )
                    )
                    .frame(width: 440, height: 440)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.6),
                                        Color(red: 0.29, green: 0.62, blue: 0.85).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.3), radius: 20)
                
                // Subtle crescent phase overlay (showing a slight waxing gibbous)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 440, height: 440)
                    .offset(x: 150)
                    .mask(
                        Circle()
                            .frame(width: 440, height: 440)
                    )
                
                // Highlight on the bright side
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.clear
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 440, height: 440)
                    .blendMode(.overlay)
            }
            
            // Decorative geometric corner accents (Fremen style)
            VStack {
                HStack {
                    FremencornerAccent()
                        .stroke(Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .padding(40)
                    
                    Spacer()
                    
                    FremencornerAccent()
                        .stroke(Color(red: 0.29, green: 0.62, blue: 0.85).opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .rotation3DEffect(.degrees(90), axis: (x: 0, y: 1, z: 0))
                        .padding(40)
                }
                
                Spacer()
                
                HStack {
                    FremencornerAccent()
                        .stroke(Color(red: 0.29, green: 0.62, blue: 0.85).opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .rotation3DEffect(.degrees(270), axis: (x: 0, y: 1, z: 0))
                        .padding(40)
                    
                    Spacer()
                    
                    FremencornerAccent()
                        .stroke(Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .padding(40)
                }
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// Geometric Fremen-style corner accent
struct FremencornerAccent: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // L-shaped corner with geometric detail
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.3))
        path.addLine(to: CGPoint(x: rect.maxX * 0.1, y: rect.maxY * 0.2))
        path.addLine(to: CGPoint(x: rect.maxX * 0.2, y: rect.maxY * 0.3))
        path.addLine(to: CGPoint(x: rect.maxX * 0.3, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        
        return path
    }
}

#Preview {
    AppIconView()
}
