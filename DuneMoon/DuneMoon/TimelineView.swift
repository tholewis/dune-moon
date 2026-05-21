//
//  TimelineView.swift
//  DuneMoon
//
//  Interactive timeline for scrubbing through dates
//

import SwiftUI

struct TimelineView: View {
    @Binding var selectedDate: Date
    @State private var dragOffset: CGFloat = 0
    
    private let calendar = Calendar.current
    private let itemWidth: CGFloat = 60
    private let itemSpacing: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 8) {
            // Timeline scrubber
            GeometryReader { geometry in
                HStack(spacing: itemSpacing) {
                    ForEach(-15...15, id: \.self) { offset in
                        let date = calendar.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
                        TimelineDayItem(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            size: itemWidth
                        )
                    }
                }
                .offset(x: geometry.size.width / 2 - itemWidth / 2 - (15 * (itemWidth + itemSpacing)) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let days = Int(-value.translation.width / (itemWidth + itemSpacing))
                            if let newDate = calendar.date(byAdding: .day, value: days, to: selectedDate) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDate = newDate
                                }
                            }
                            withAnimation(.spring(response: 0.3)) {
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(height: itemWidth + 40)
            
            // Date indicator with Dune styling
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [duneOrange, duneSand],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .textCase(.uppercase)
                .kerning(2)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(duneBlack.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(duneOrange.opacity(0.3), lineWidth: 1)
                        )
                )
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

struct TimelineDayItem: View {
    let date: Date
    let isSelected: Bool
    let size: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            // Mini moon phase
            let phaseData = MoonPhaseCalculator.calculatePhase(for: date)
            MoonPhaseView(phaseData: phaseData, size: size * 0.6, showGlow: isSelected)
                .scaleEffect(isSelected ? 1.2 : 1.0)
            
            // Day number
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: isSelected ? 14 : 11, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? duneOrange : duneSand.opacity(0.6))
        }
        .frame(width: size)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var duneOrange: Color {
        Color(red: 1.0, green: 0.55, blue: 0.26)
    }
    
    private var duneSand: Color {
        Color(red: 0.83, green: 0.65, blue: 0.45)
    }
}

#Preview {
    TimelineView(selectedDate: .constant(Date()))
        .background(Color(red: 0.1, green: 0.08, blue: 0.06))
}
