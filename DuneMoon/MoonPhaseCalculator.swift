//
//  MoonPhaseCalculator.swift
//  DuneMoon
//
//  Moon phase calculations based on astronomical algorithms
//

import Foundation
import CoreLocation

struct MoonPhaseData {
    let phase: Double // 0.0 to 1.0 (0 = new moon, 0.5 = full moon)
    let illumination: Double // Percentage illuminated
    let phaseName: String
    let isWaxing: Bool
    let daysToNextPhase: Int
    let nextPhaseName: String

    // Moon phase emoji corresponding to the current phase value
    var emoji: String {
        switch phase {
        case ..<0.05, 0.95...: return "🌑" // New Moon
        case ..<0.20:          return "🌒" // Waxing Crescent
        case ..<0.30:          return "🌓" // First Quarter
        case ..<0.45:          return "🌔" // Waxing Gibbous
        case ..<0.55:          return "🌕" // Full Moon
        case ..<0.70:          return "🌖" // Waning Gibbous
        case ..<0.80:          return "🌗" // Last Quarter
        default:               return "🌘" // Waning Crescent
        }
    }
}

class MoonPhaseCalculator {
    
    // Calculate moon phase for a given date
    static func calculatePhase(for date: Date) -> MoonPhaseData {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Julian date calculation
        let year = components.year!
        let month = components.month!
        let day = components.day!
        
        let julianDate = calculateJulianDate(year: year, month: month, day: day)
        
        // Known new moon: January 6, 2000
        let knownNewMoon = 2451550.1
        let synodicMonth = 29.53058867 // Average lunar cycle
        
        let daysSinceNewMoon = julianDate - knownNewMoon
        let newMoons = daysSinceNewMoon / synodicMonth
        let phase = newMoons - floor(newMoons)
        
        let illumination = calculateIllumination(phase: phase)
        let isWaxing = phase < 0.5
        let phaseName = getPhaseName(phase: phase)
        
        let (daysToNext, nextName) = calculateNextPhase(currentPhase: phase)
        
        return MoonPhaseData(
            phase: phase,
            illumination: illumination,
            phaseName: phaseName,
            isWaxing: isWaxing,
            daysToNextPhase: daysToNext,
            nextPhaseName: nextName
        )
    }
    
    private static func calculateJulianDate(year: Int, month: Int, day: Int) -> Double {
        var y = year
        var m = month
        
        if m <= 2 {
            y -= 1
            m += 12
        }
        
        let a = y / 100
        let b = 2 - a + (a / 4)
        
        let jd = floor(365.25 * Double(y + 4716)) +
                 floor(30.6001 * Double(m + 1)) +
                 Double(day) + Double(b) - 1524.5
        
        return jd
    }
    
    private static func calculateIllumination(phase: Double) -> Double {
        // Convert phase to illumination percentage
        if phase < 0.5 {
            return phase * 200.0
        } else {
            return (1.0 - phase) * 200.0
        }
    }
    
    private static func getPhaseName(phase: Double) -> String {
        switch phase {
        case 0..<0.033: return "New Moon"
        case 0.033..<0.216: return "Waxing Crescent"
        case 0.216..<0.283: return "First Quarter"
        case 0.283..<0.466: return "Waxing Gibbous"
        case 0.466..<0.533: return "Full Moon"
        case 0.533..<0.716: return "Waning Gibbous"
        case 0.716..<0.783: return "Last Quarter"
        case 0.783..<0.967: return "Waning Crescent"
        default: return "New Moon"
        }
    }
    
    private static func calculateNextPhase(currentPhase: Double) -> (Int, String) {
        let phases: [(threshold: Double, name: String)] = [
            (0.033, "New Moon"),
            (0.216, "Waxing Crescent"),
            (0.283, "First Quarter"),
            (0.466, "Waxing Gibbous"),
            (0.533, "Full Moon"),
            (0.716, "Waning Gibbous"),
            (0.783, "Last Quarter"),
            (0.967, "Waning Crescent"),
            (1.033, "New Moon")
        ]
        
        for phase in phases {
            if currentPhase < phase.threshold {
                let daysToNext = Int((phase.threshold - currentPhase) * 29.53)
                return (max(1, daysToNext), phase.name)
            }
        }
        
        return (1, "New Moon")
    }
    
    // Calculate moonrise and moonset times for a given location
    static func calculateMoonTimes(for date: Date, latitude: Double = 37.7749, longitude: Double = -122.4194) -> (rise: Date?, set: Date?) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return (nil, nil)
        }
        
        // Calculate moon's position and rise/set times using astronomical algorithms
        let jd = calculateJulianDate(year: year, month: month, day: day)
        
        // Calculate moon's right ascension and declination
        let (ra, dec) = calculateMoonPosition(julianDate: jd)
        
        // Calculate hour angle for rise and set (-1 for rise, 1 for set events)
        let (riseHA, setHA) = calculateHourAngles(declination: dec, latitude: latitude)
        
        // Convert hour angles to UTC times
        let riseTime = calculateEventTime(julianDate: jd, hourAngle: riseHA, rightAscension: ra, longitude: longitude)
        let setTime = calculateEventTime(julianDate: jd, hourAngle: setHA, rightAscension: ra, longitude: longitude)
        
        // Convert to Date objects
        let riseDate = julianDateToDate(riseTime, calendar: calendar)
        let setDate = julianDateToDate(setTime, calendar: calendar)
        
        return (riseDate, setDate)
    }
    
    // Calculate moon's position (simplified)
    private static func calculateMoonPosition(julianDate: Double) -> (ra: Double, dec: Double) {
        // Moon's mean longitude
        let L0 = 218.316 + 13.176396 * (julianDate - 2451545.0)
        let L = L0.truncatingRemainder(dividingBy: 360.0)
        
        // Moon's mean anomaly
        let M = (134.963 + 13.064993 * (julianDate - 2451545.0)).truncatingRemainder(dividingBy: 360.0)
        
        // Moon's mean elongation
        let D = (297.850 + 12.190749 * (julianDate - 2451545.0)).truncatingRemainder(dividingBy: 360.0)
        
        // Convert to radians
        let Mrad = M * .pi / 180.0
        let Drad = D * .pi / 180.0
        
        // Calculate ecliptic longitude (simplified)
        let lambda = L + 6.289 * sin(Mrad)
        
        // Calculate ecliptic latitude (simplified)
        let beta = 5.128 * sin(Drad)
        
        // Convert to right ascension and declination
        let lambdaRad = lambda * .pi / 180.0
        let betaRad = beta * .pi / 180.0
        let epsilon = 23.439 * .pi / 180.0 // Earth's obliquity
        
        let ra = atan2(sin(lambdaRad) * cos(epsilon) - tan(betaRad) * sin(epsilon), cos(lambdaRad))
        let dec = asin(sin(betaRad) * cos(epsilon) + cos(betaRad) * sin(epsilon) * sin(lambdaRad))
        
        return (ra * 180.0 / .pi, dec * 180.0 / .pi)
    }
    
    // Calculate local sidereal time
    private static func calculateLocalSiderealTime(julianDate: Double, longitude: Double) -> Double {
        let T = (julianDate - 2451545.0) / 36525.0
        var theta = 280.46061837 + 360.98564736629 * (julianDate - 2451545.0) + 0.000387933 * T * T
        theta = theta.truncatingRemainder(dividingBy: 360.0)
        return (theta + longitude).truncatingRemainder(dividingBy: 360.0)
    }
    
    // Calculate hour angles for rise and set
    private static func calculateHourAngles(declination: Double, latitude: Double) -> (rise: Double, set: Double) {
        let decRad = declination * .pi / 180.0
        let latRad = latitude * .pi / 180.0
        
        // Standard altitude for moonrise/set (accounting for refraction and moon's semi-diameter)
        let h0 = -0.833 * .pi / 180.0 // -50 arcminutes
        
        let cosH = (sin(h0) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad))
        
        // Check if moon is always above or below horizon
        if cosH > 1 {
            // Moon never rises
            return (0, 0)
        } else if cosH < -1 {
            // Moon never sets
            return (0, 0)
        }
        
        let H = acos(cosH) * 180.0 / .pi
        
        return (-H, H) // Negative for rise, positive for set
    }
    
    // Calculate event time from hour angle
    private static func calculateEventTime(julianDate: Double, hourAngle: Double, rightAscension: Double, longitude: Double) -> Double {
        let lst = calculateLocalSiderealTime(julianDate: julianDate, longitude: longitude)
        var localHour = (hourAngle + rightAscension - lst) / 15.0 // Convert degrees to hours
        
        // Normalize to 0-24 hours
        while localHour < 0 { localHour += 24 }
        while localHour >= 24 { localHour -= 24 }
        
        return julianDate + (localHour / 24.0)
    }
    
    // Convert Julian date to Date object
    private static func julianDateToDate(_ jd: Double, calendar: Calendar) -> Date? {
        // Convert JD to date components
        let Z = Int(jd + 0.5)
        let F = (jd + 0.5) - Double(Z)
        
        var A = Z
        if Z >= 2299161 {
            let alpha = Int((Double(Z) - 1867216.25) / 36524.25)
            A = Z + 1 + alpha - alpha / 4
        }
        
        let B = A + 1524
        let C = Int((Double(B) - 122.1) / 365.25)
        let D = Int(365.25 * Double(C))
        let E = Int(Double(B - D) / 30.6001)
        
        let day = B - D - Int(30.6001 * Double(E))
        let month = E < 14 ? E - 1 : E - 13
        let year = month > 2 ? C - 4716 : C - 4715
        
        let hours = F * 24.0
        let hour = Int(hours)
        let minutes = (hours - Double(hour)) * 60.0
        let minute = Int(minutes)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        
        return calendar.date(from: components)
    }
}
