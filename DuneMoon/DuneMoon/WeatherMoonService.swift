//
//  WeatherMoonService.swift
//  DuneMoon
//
//  Provides accurate, location-specific moon data (phase + moonrise/moonset) via
//  WeatherKit, with the local MoonPhaseCalculator used as a fallback by callers.
//

import Foundation
import CoreLocation
import WeatherKit
import SwiftUI
import os

private let weatherLog = Logger(subsystem: "AlienArchitecture.DuneMoon", category: "WeatherKit")

/// A snapshot of WeatherKit's moon data for a single day and location. The phase fields
/// match what Apple Weather shows, since both come from the same WeatherKit `MoonPhase`.
struct WeatherMoon {
    let rise: Date?
    let set: Date?
    let phaseName: String
    let phaseEmoji: String
    let isWaxing: Bool
    /// True when WeatherKit's daily label is New or Full. These are whole-day "instant"
    /// labels: WeatherKit calls the entire new-moon day "New Moon", whereas the
    /// instantaneous phase (what Apple Weather's headline shows) is already a crescent
    /// once past the exact instant. Callers refine these using the local calculation.
    let isNewOrFull: Bool
}

extension MoonPhaseData {
    /// Applies WeatherKit's phase as a display override so the shown phase matches Apple
    /// Weather. For WeatherKit's whole-day New/Full labels, the instantaneous local
    /// classification is kept instead, so a new-moon day past the exact instant reads as
    /// a crescent (matching Apple Weather's live headline) rather than "New Moon" all day.
    func applyingWeatherKit(_ wk: WeatherMoon) -> MoonPhaseData {
        guard !wk.isNewOrFull else {
            // Keep the time-accurate local phase for the boundary instant.
            return self
        }
        var copy = self
        copy.phaseNameOverride = wk.phaseName
        copy.emojiOverride = wk.phaseEmoji
        copy.isWaxingOverride = wk.isWaxing
        return copy
    }
}

/// Fetches moon phase and moonrise/moonset for a given date and location from WeatherKit.
///
/// WeatherKit only covers a limited window around the present (its daily forecast is
/// ~10 contiguous days from today), is asynchronous, and requires network access plus
/// the WeatherKit entitlement. Any failure (offline, out of range, not entitled) returns
/// `nil` so the caller can fall back to a local calculation.
@MainActor
final class WeatherMoonService: ObservableObject {
    private let service = WeatherService.shared

    /// Cache of resolved moon data keyed by rounded coordinate + day, to avoid refetching.
    private var cache: [Key: WeatherMoon] = [:]

    /// The required Apple Weather attribution, loaded lazily the first time WeatherKit
    /// data is successfully shown. `nil` until then.
    @Published private(set) var attribution: WeatherAttribution?

    private struct Key: Hashable {
        let lat: Double
        let lon: Double
        let day: Date
    }

    /// Returns moon data for `date` at `coordinate`, or `nil` if WeatherKit can't supply
    /// it (offline, out of range, or not entitled). Results are cached.
    func moon(
        for date: Date,
        at coordinate: CLLocationCoordinate2D
    ) async -> WeatherMoon? {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        // Round the coordinate so nearby requests share a cache entry.
        let key = Key(
            lat: (coordinate.latitude * 100).rounded() / 100,
            lon: (coordinate.longitude * 100).rounded() / 100,
            day: day
        )
        if let cached = cache[key] {
            return cached
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            weatherLog.debug("Requesting WeatherKit daily forecast for \(coordinate.latitude), \(coordinate.longitude) on \(day, privacy: .public)")
            let forecast = try await service.weather(for: location, including: .daily)
            guard let match = forecast.first(where: {
                calendar.isDate($0.date, inSameDayAs: day)
            }) else {
                weatherLog.error("WeatherKit returned \(forecast.count) days but none matched \(day, privacy: .public) — likely outside the forecast window.")
                return nil // Requested day is outside WeatherKit's forecast window.
            }

            let result = WeatherMoon(
                rise: match.moon.moonrise,
                set: match.moon.moonset,
                phaseName: match.moon.phase.displayName,
                phaseEmoji: match.moon.phase.emoji,
                isWaxing: match.moon.phase.isWaxing,
                isNewOrFull: match.moon.phase == .new || match.moon.phase == .full
            )
            cache[key] = result
            weatherLog.debug("WeatherKit moon: phase \(result.phaseName, privacy: .public), rise \(String(describing: result.rise), privacy: .public), set \(String(describing: result.set), privacy: .public)")

            // Attribution is mandatory whenever Apple Weather data is displayed.
            if attribution == nil {
                do {
                    attribution = try await service.attribution
                } catch {
                    weatherLog.error("WeatherKit attribution fetch failed: \(error.localizedDescription, privacy: .public)")
                }
            }

            return result
        } catch {
            weatherLog.error("WeatherKit request failed: \(error.localizedDescription, privacy: .public) — full: \(String(describing: error), privacy: .public)")
            return nil
        }
    }
}

/// Maps WeatherKit's `MoonPhase` enum to the app's display strings. These names and
/// emoji match Apple Weather, since they describe the same 8 WeatherKit phases.
private extension MoonPhase {
    var displayName: String {
        switch self {
        case .new:            return "New Moon"
        case .waxingCrescent: return "Waxing Crescent"
        case .firstQuarter:   return "First Quarter"
        case .waxingGibbous:  return "Waxing Gibbous"
        case .full:           return "Full Moon"
        case .waningGibbous:  return "Waning Gibbous"
        case .lastQuarter:    return "Last Quarter"
        case .waningCrescent: return "Waning Crescent"
        @unknown default:     return "Unknown"
        }
    }

    var emoji: String {
        switch self {
        case .new:            return "🌑"
        case .waxingCrescent: return "🌒"
        case .firstQuarter:   return "🌓"
        case .waxingGibbous:  return "🌔"
        case .full:           return "🌕"
        case .waningGibbous:  return "🌖"
        case .lastQuarter:    return "🌗"
        case .waningCrescent: return "🌘"
        @unknown default:     return "🌑"
        }
    }

    var isWaxing: Bool {
        switch self {
        case .new, .waxingCrescent, .firstQuarter, .waxingGibbous: return true
        default: return false
        }
    }
}

/// The Apple Weather attribution mark and legal link, required by WeatherKit whenever
/// its data is shown. Uses the dark-background mark since the app's panels are dark.
struct WeatherAttributionView: View {
    let attribution: WeatherAttribution

    var body: some View {
        Link(destination: attribution.legalPageURL) {
            AsyncImage(url: attribution.combinedMarkDarkURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Text(attribution.serviceName)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.83, green: 0.65, blue: 0.45).opacity(0.6))
            }
            .frame(height: 14)
        }
    }
}
