//
//  ArrakisMoonView.swift
//  Lithium
//
//  Vintage poster with dynamic moon emoji
//

import SwiftUI

struct ArrakisMoonView: View {
    let phaseData: MoonPhaseData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Use the actual poster image as background
                Image("ArrakisPoster")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // Overlay the dynamic moon emoji to completely cover the illustrated moon
                VStack {
                    HStack {
                        Text(moonEmoji)
                            .font(.system(size: 200))
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 2, y: 2)
                            .padding(.leading, 8)
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                    Spacer()
                }
                
                // Info section at bottom with background extending to screen bottom
                VStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("ARRAKIS")
                            .font(.system(size: 44, weight: .black, design: .serif))
                            .foregroundColor(Color(red: 0.25, green: 0.20, blue: 0.15))
                            .kerning(6)
                            .padding(.top, 16)
                        
                        Text(phaseData.phaseName.uppercased())
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.25))
                            .kerning(3)
                        
                        Text("LUNAR OBSERVATORY")
                            .font(.system(size: 9, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.28))
                            .kerning(2)
                            .padding(.bottom, 6)
                        
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text(String(format: "%.0f%%", phaseData.illumination))
                                    .font(.system(size: 28, weight: .black, design: .serif))
                                    .foregroundColor(Color(red: 0.25, green: 0.20, blue: 0.15))
                                Text("ILLUMINATION")
                                    .font(.system(size: 9, weight: .black, design: .serif))
                                    .foregroundColor(Color(red: 0.35, green: 0.28, blue: 0.22))
                                    .kerning(1)
                            }
                            
                            Rectangle()
                                .fill(Color(red: 0.45, green: 0.35, blue: 0.28))
                                .frame(width: 2, height: 50)
                            
                            VStack(spacing: 4) {
                                Text(phaseData.phaseName.uppercased())
                                    .font(.system(size: 20, weight: .black, design: .serif))
                                    .foregroundColor(Color(red: 0.25, green: 0.20, blue: 0.15))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                                Text("PHASE")
                                    .font(.system(size: 9, weight: .black, design: .serif))
                                    .foregroundColor(Color(red: 0.35, green: 0.28, blue: 0.22))
                                    .kerning(1)
                            }
                        }
                        
                        Text("TAP ANYWHERE TO RETURN")
                            .font(.system(size: 9, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.28))
                            .kerning(2)
                            .padding(.top, 8)
                            .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        // Extend background to bottom of screen
                        VStack(spacing: 0) {
                            Color(red: 0.96, green: 0.94, blue: 0.90)
                            Color(red: 0.96, green: 0.94, blue: 0.90)
                                .ignoresSafeArea(edges: .bottom)
                        }
                    )
                }
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
    
    // Get appropriate moon emoji based on phase
    private var moonEmoji: String {
        let phase = phaseData.phase
        
        if phase < 0.05 || phase > 0.95 {
            return "🌑" // New Moon
        } else if phase < 0.20 {
            return "🌒" // Waxing Crescent
        } else if phase < 0.30 {
            return "🌓" // First Quarter
        } else if phase < 0.45 {
            return "🌔" // Waxing Gibbous
        } else if phase < 0.55 {
            return "🌕" // Full Moon
        } else if phase < 0.70 {
            return "🌖" // Waning Gibbous
        } else if phase < 0.80 {
            return "🌗" // Last Quarter
        } else {
            return "🌘" // Waning Crescent
        }
    }
}

#Preview {
    ArrakisMoonView(
        phaseData: MoonPhaseData(
            phase: 0.25,
            illumination: 50,
            phaseName: "First Quarter",
            isWaxing: true,
            daysToNextPhase: 7,
            nextPhaseName: "Full Moon"
        )
    )
}
