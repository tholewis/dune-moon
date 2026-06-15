//
//  PhaseInfoPanel.swift
//  DuneMoon
//
//  Detailed moon phase information display
//

import SwiftUI
import CoreLocation

struct PhaseInfoPanel: View {
    let date: Date
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherMoon = WeatherMoonService()

    // Seeded with the local calculation; upgraded to WeatherKit values when available.
    @State private var moonTimes: (rise: Date?, set: Date?) = (nil, nil)
    // True once WeatherKit moonrise/moonset have replaced the local seed.
    @State private var usingWeatherKit = false

    private var phaseData: MoonPhaseData {
        MoonPhaseCalculator.calculatePhase(for: date)
    }

    // Re-run the WeatherKit fetch whenever the date or resolved location changes.
    private var moonTimesTaskID: String {
        let coord = locationManager.coordinate
        return "\(date.timeIntervalSince1970)-\(coord.latitude)-\(coord.longitude)"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Phase name and illumination
            VStack(spacing: 8) {
                Text(phaseData.phaseName)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [duneOrange, duneSand],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .textCase(.uppercase)
                    .kerning(3)
                
                HStack(spacing: 4) {
                    Image(systemName: phaseData.isWaxing ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(phaseData.isWaxing ? duneBlue : duneOrange)
                    
                    Text(phaseData.isWaxing ? "Waxing" : "Waning")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(duneSand.opacity(0.8))
                }
            }
            .padding(.bottom, 8)
            
            // Illumination percentage with progress bar
            VStack(spacing: 12) {
                HStack {
                    Text("Illumination")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(duneSand.opacity(0.7))
                    
                    Spacer()
                    
                    Text(String(format: "%.1f%%", phaseData.illumination))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(duneOrange)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(duneBlack.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(duneOrange.opacity(0.2), lineWidth: 1)
                            )
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [duneOrange, duneBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (phaseData.illumination / 100))
                            .shadow(color: duneOrange.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(duneBlack.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(duneOrange.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Moon rise and set times
            HStack(spacing: 16) {
                InfoCard(
                    icon: "sunrise.fill",
                    title: "Moonrise",
                    value: formatTime(moonTimes.rise),
                    color: duneBlue
                )
                
                InfoCard(
                    icon: "sunset.fill",
                    title: "Moonset",
                    value: formatTime(moonTimes.set),
                    color: duneOrange
                )
            }

            // Apple Weather attribution — required whenever WeatherKit data is shown.
            if usingWeatherKit, let attribution = weatherMoon.attribution {
                WeatherAttributionView(attribution: attribution)
            }

            // Next phase countdown
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(duneSand.opacity(0.7))
                    
                    Text("Next Phase")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(duneSand.opacity(0.7))
                    
                    Spacer()
                }
                
                HStack {
                    Text(phaseData.nextPhaseName)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(duneOrange)
                        .textCase(.uppercase)
                        .kerning(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(phaseData.daysToNextPhase)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(duneBlue)
                        
                        Text("days")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(duneSand.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(duneBlack.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(duneBlue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding()
        .onAppear {
            locationManager.requestLocation()
        }
        .task(id: moonTimesTaskID) {
            let coord = locationManager.coordinate

            // Seed immediately with the local calculation so the cards are never blank
            // while loading, offline, or for dates outside WeatherKit's window.
            moonTimes = MoonPhaseCalculator.calculateMoonTimes(
                for: date,
                latitude: coord.latitude,
                longitude: coord.longitude
            )
            usingWeatherKit = false

            // Upgrade to WeatherKit's location-accurate times when available.
            if let weatherTimes = await weatherMoon.moonTimes(for: date, at: coord) {
                moonTimes = weatherTimes
                usingWeatherKit = true
            }
        }
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
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

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(duneSand.opacity(0.7))
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(duneBlack.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var duneSand: Color {
        Color(red: 0.83, green: 0.65, blue: 0.45)
    }
    
    private var duneBlack: Color {
        Color(red: 0.1, green: 0.08, blue: 0.06)
    }
}

#Preview {
    PhaseInfoPanel(date: Date())
        .background(Color(red: 0.1, green: 0.08, blue: 0.06))
}
