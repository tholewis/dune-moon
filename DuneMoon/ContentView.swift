//
//  ContentView.swift
//  DuneMoon
//
//  Dune-inspired Moon Phase Tracker
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    @State private var showArrakisView = false

    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherMoon = WeatherMoonService()
    @State private var wkMoon: WeatherMoon?

    // Local calculation, with WeatherKit's phase applied as a display override when
    // available (so the main display matches Apple Weather). Illumination stays local.
    private var phaseData: MoonPhaseData {
        let data = MoonPhaseCalculator.calculatePhase(for: selectedDate)
        if let wk = wkMoon {
            return data.applyingWeatherKit(wk)
        }
        return data
    }

    // Re-run the WeatherKit fetch whenever the date or resolved location changes.
    private var moonTaskID: String {
        let coord = locationManager.coordinate
        return "\(selectedDate.timeIntervalSince1970)-\(coord.latitude)-\(coord.longitude)"
    }
    
    var body: some View {
        ZStack {
            // Dune desert background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.08, blue: 0.06), // Deep black
                    Color(red: 0.15, green: 0.12, blue: 0.09), // Dark brown
                    Color(red: 0.1, green: 0.08, blue: 0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle sand texture overlay
            Color(red: 0.55, green: 0.45, blue: 0.33)
                .opacity(0.03)
                .ignoresSafeArea()
            
            // Floating spice particles
            GeometryReader { geometry in
                FloatingSpiceParticles(bounds: geometry.size)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header with title
                    VStack(spacing: 8) {
                        Text("MOON PHASE TRACKER")
                            .font(.system(size: 16, weight: .black, design: .serif))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [duneOrange, duneSand],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .kerning(4)
                            .spiceGlow(intensity: 0.5)
                        
                        // Decorative line
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(duneOrange.opacity(0.5))
                                .frame(height: 1)
                            
                            Circle()
                                .fill(duneOrange)
                                .frame(width: 4, height: 4)
                            
                            Rectangle()
                                .fill(duneOrange.opacity(0.5))
                                .frame(height: 1)
                        }
                        .frame(width: 200)
                        
                        Text("Arrakis Lunar Observatory")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundColor(duneSand.opacity(0.6))
                            .kerning(2)
                            .italic()
                    }
                    .padding(.top, 20)
                    
                    // Main moon phase display
                    VStack(spacing: 16) {
                        Text(phaseData.displayEmoji)
                            .font(.system(size: 200))
                            .frame(width: 240, height: 240)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 2, y: 2)
                            .spiceGlow(intensity: 0.5)
                            .id(selectedDate)
                        
                        // Quick stats below moon
                        HStack(spacing: 30) {
                            StatBadge(
                                label: "Phase",
                                value: phaseData.displayName,
                                icon: "moon.stars.fill"
                            )
                            .id("\(selectedDate)-phase")
                            
                            StatBadge(
                                label: "Illuminated",
                                value: String(format: "%.0f%%", phaseData.illumination),
                                icon: "light.max"
                            )
                            .id("\(selectedDate)-illumination")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    // View toggle buttons
                    HStack(spacing: 16) {
                        ViewToggleButton(
                            icon: "calendar",
                            label: "Calendar",
                            isActive: showCalendar
                        ) {
                            withAnimation(.spring(response: 0.4)) {
                                showCalendar = true
                            }
                        }
                        
                        ViewToggleButton(
                            icon: "timeline.selection",
                            label: "Timeline",
                            isActive: !showCalendar
                        ) {
                            withAnimation(.spring(response: 0.4)) {
                                showCalendar = false
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Timeline or Calendar view
                    if showCalendar {
                        CalendarGridView(selectedDate: $selectedDate)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        TimelineView(selectedDate: $selectedDate)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                    
                    // Phase information panel
                    PhaseInfoPanel(date: selectedDate)
                    
                    // On Arrakis button
                    Button(action: {
                        showArrakisView = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 18, weight: .bold))
                            
                            Text("ON ARRAKIS")
                                .font(.system(size: 16, weight: .black, design: .serif))
                                .kerning(3)
                        }
                        .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.06))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [duneOrange, duneOrange.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: duneOrange.opacity(0.5), radius: 12, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(duneSand.opacity(0.3), lineWidth: 2)
                        )
                    }
                    .padding(.vertical, 20)
                    .spiceGlow(intensity: 0.3)
                    
                    // Footer quote
                    VStack(spacing: 4) {
                        Text("\"The moon is our constant companion\"")
                            .font(.system(size: 12, weight: .medium, design: .serif))
                            .foregroundColor(duneSand.opacity(0.5))
                            .italic()
                        
                        Text("- Fremen Wisdom")
                            .font(.system(size: 10, weight: .regular, design: .serif))
                            .foregroundColor(duneOrange.opacity(0.6))
                            .kerning(1)
                    }
                    .padding(.vertical, 30)
                }
            }
            .fullScreenCover(isPresented: $showArrakisView) {
                ArrakisMoonView(phaseData: phaseData)
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .task(id: moonTaskID) {
                // When this returns nil (offline / out of range / not entitled), the
                // display falls back to the local calculation.
                wkMoon = await weatherMoon.moon(for: selectedDate, at: locationManager.coordinate)
            }
        }
    }
    
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26)
    }
    
    private var duneSand: Color {
        Color(red: 0.83, green: 0.65, blue: 0.45)
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(duneBlue)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(duneSand.opacity(0.6))
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(duneOrange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(duneBlack.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(duneOrange.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26)
    }
    
    private var duneBlue: Color {
        Color(red: 0.29, green: 0.62, blue: 0.85)
    }
    
    private var duneSand: Color {
        Color(red: 0.83, green: 0.65, blue: 0.45)
    }
    
    private var duneBlack: Color {
        Color(red: 0.1, green: 0.08, blue: 0.06)
    }
}

struct ViewToggleButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isActive ? duneBlack : duneSand)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? duneOrange : duneBlack.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(duneOrange.opacity(isActive ? 0.8 : 0.3), lineWidth: isActive ? 2 : 1)
                    )
            )
            .shadow(color: isActive ? duneOrange.opacity(0.3) : .clear, radius: 8)
        }
    }
    
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26)
    }
    
    private var duneSand: Color {
        Color(red: 0.83, green: 0.65, blue: 0.45)
    }
    
    private var duneBlack: Color {
        Color(red: 0.1, green: 0.08, blue: 0.06)
    }
}

#Preview {
    ContentView()
}