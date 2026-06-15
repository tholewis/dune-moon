//
//  WeatherMoonService.swift
//  DuneMoon
//
//  Provides accurate, location-specific moonrise/moonset times via WeatherKit,
//  with the local MoonPhaseCalculator used as a fallback by callers.
//

import Foundation
import CoreLocation
import WeatherKit
import SwiftUI
import os

private let weatherLog = Logger(subsystem: "AlienArchitecture.DuneMoon", category: "WeatherKit")

/// Fetches moonrise/moonset for a given date and location from WeatherKit.
///
/// WeatherKit only covers a limited window around the present (its daily forecast is
/// ~10 contiguous days from today), is asynchronous, and requires network access plus
/// the WeatherKit entitlement. Any failure (offline, out of range, not entitled) returns
/// `nil` so the caller can fall back to a local calculation.
@MainActor
final class WeatherMoonService: ObservableObject {
    private let service = WeatherService.shared

    /// Cache of resolved times keyed by rounded coordinate + day, to avoid refetching.
    private var cache: [Key: (rise: Date?, set: Date?)] = [:]

    /// The required Apple Weather attribution, loaded lazily the first time WeatherKit
    /// data is successfully shown. `nil` until then.
    @Published private(set) var attribution: WeatherAttribution?

    private struct Key: Hashable {
        let lat: Double
        let lon: Double
        let day: Date
    }

    /// Returns moonrise/moonset for `date` at `coordinate`, or `nil` if WeatherKit can't
    /// supply it (offline, out of range, or not entitled). Results are cached.
    func moonTimes(
        for date: Date,
        at coordinate: CLLocationCoordinate2D
    ) async -> (rise: Date?, set: Date?)? {
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

            let result = (rise: match.moon.moonrise, set: match.moon.moonset)
            cache[key] = result
            weatherLog.debug("WeatherKit moon times: rise \(String(describing: result.rise), privacy: .public), set \(String(describing: result.set), privacy: .public)")

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
