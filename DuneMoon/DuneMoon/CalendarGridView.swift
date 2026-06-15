//
//  CalendarGridView.swift
//  DuneMoon
//
//  Monthly calendar grid showing moon phases
//

import SwiftUI

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(duneOrange)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(duneBlack.opacity(0.6))
                                .overlay(
                                    Circle()
                                        .stroke(duneOrange.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [duneOrange, duneSand],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .textCase(.uppercase)
                    .kerning(2)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(duneOrange)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(duneBlack.opacity(0.6))
                                .overlay(
                                    Circle()
                                        .stroke(duneOrange.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal)
            
            // Day headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(duneSand.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortWeekdaySymbols
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }
        
        var dates: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while dates.count < 42 { // 6 weeks max
            if calendar.isDate(currentDate, equalTo: monthInterval.start, toGranularity: .month) ||
               calendar.isDate(currentDate, equalTo: monthInterval.end, toGranularity: .month) ||
               (currentDate > monthInterval.start && currentDate < monthInterval.end) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
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

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            // Day number
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
            
            // Mini moon phase
            let phaseData = MoonPhaseCalculator.calculatePhase(for: date)
            Text(phaseData.emoji)
                .font(.system(size: 24))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var textColor: Color {
        if isSelected {
            return duneOrange
        } else if isCurrentMonth {
            return duneSand
        } else {
            return duneSand.opacity(0.3)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return duneOrange.opacity(0.15)
        } else {
            return duneBlack.opacity(0.3)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return duneOrange
        } else {
            return duneOrange.opacity(0.2)
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
    CalendarGridView(selectedDate: .constant(Date()))
        .background(Color(red: 0.1, green: 0.08, blue: 0.06))
}
