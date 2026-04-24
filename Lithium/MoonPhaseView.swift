//  MoonPhaseView.swift
//  DuneMoon
//
//  Dune-inspired moon phase visualization
//

import SwiftUI

struct MoonPhaseView: View {
    let phaseData: MoonPhaseData
    let size: CGFloat
    let showGlow: Bool
    
    init(phaseData: MoonPhaseData, size: CGFloat = 200, showGlow: Bool = true) {
        self.phaseData = phaseData
        self.size = size
        self.showGlow = showGlow
    }
    
    var body: some View {
        ZStack {
            // Outer glow (spice effect)
            if showGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                duneOrange.opacity(0.6),
                                duneBlue.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.4,
                            endRadius: size * 0.65
                        )
                    )
                    .frame(width: size * 1.3, height: size * 1.3)
                    .blur(radius: 20)
            }
            
            // Moon base circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [duneSand, duneSandDark],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(duneOrange.opacity(0.3), lineWidth: 2)
                )
            
            // Shadow overlay to create phase effect
            MoonShadowShape(phase: phaseData.phase)
                .fill(duneBlack)
                .frame(width: size, height: size)
            
            // Subtle texture overlay
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear,
                            duneBlack.opacity(0.2)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .blendMode(.overlay)
        }
    }
    
    // Dune color palette
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26) // #FF8C42
    }
    
    private var duneBlue: Color {
        Color(red: 0.29, green: 0.62, blue: 0.85) // #4A9FD8
    }
    
    private var duneSand: Color {
        Color(red: 0.83, green: 0.65, blue: 0.45) // #D4A574
    }
    
    private var duneSandDark: Color {
        Color(red: 0.55, green: 0.45, blue: 0.33) // #8B7355
    }
    
    private var duneBlack: Color {
        Color(red: 0.1, green: 0.08, blue: 0.06) // #1a1410
    }
}

// Custom shape to create moon phase shadow
struct MoonShadowShape: Shape {
    let phase: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        
        // Phase 0 = New Moon (fully dark)
        // Phase 0.5 = Full Moon (no shadow)
        // Phase 1 = New Moon again (fully dark)
        
        if phase <= 0.03 || phase >= 0.97 {
            // New moon - full shadow
            path.addEllipse(in: rect)
        } else if phase > 0.47 && phase < 0.53 {
            // Full moon - no shadow
            return path
        } else if phase < 0.5 {
            // Waxing phases (0 to 0.5) - shadow on left
            // Convert phase to terminator position (-1 to 1, where 0 is center)
            let terminatorX = (phase - 0.25) * 4 // Maps 0->-1, 0.25->0, 0.5->1
            
            // Draw left semicircle (always in shadow during waxing)
            path.move(to: CGPoint(x: center.x, y: center.y - radius))
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: true
            )
            
            // Draw terminator curve (ellipse connecting top and bottom)
            path.addCurve(
                to: CGPoint(x: center.x, y: center.y - radius),
                control1: CGPoint(x: center.x + terminatorX * radius, y: center.y + radius * 0.66),
                control2: CGPoint(x: center.x + terminatorX * radius, y: center.y - radius * 0.66)
            )
        } else {
            // Waning phases (0.5 to 1.0) - shadow on right
            let terminatorX = ((1.0 - phase) - 0.25) * 4 // Maps for right side
            
            // Draw right semicircle (in shadow during waning)
            path.move(to: CGPoint(x: center.x, y: center.y - radius))
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )
            
            // Draw terminator curve
            path.addCurve(
                to: CGPoint(x: center.x, y: center.y - radius),
                control1: CGPoint(x: center.x - terminatorX * radius, y: center.y + radius * 0.66),
                control2: CGPoint(x: center.x - terminatorX * radius, y: center.y - radius * 0.66)
            )
        }
        
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        // New Moon
        MoonPhaseView(
            phaseData: MoonPhaseData(
                phase: 0.0,
                illumination: 0,
                phaseName: "New Moon",
                isWaxing: true,
                daysToNextPhase: 7,
                nextPhaseName: "First Quarter"
            ),
            size: 150
        )
        
        // First Quarter
        MoonPhaseView(
            phaseData: MoonPhaseData(
                phase: 0.25,
                illumination: 50,
                phaseName: "First Quarter",
                isWaxing: true,
                daysToNextPhase: 7,
                nextPhaseName: "Full Moon"
            ),
            size: 150
        )
        
        // Full Moon
        MoonPhaseView(
            phaseData: MoonPhaseData(
                phase: 0.5,
                illumination: 100,
                phaseName: "Full Moon",
                isWaxing: false,
                daysToNextPhase: 7,
                nextPhaseName: "Last Quarter"
            ),
            size: 150
        )
    }
    .padding()
    .background(Color(red: 0.1, green: 0.08, blue: 0.06))
}
