import SwiftUI
import Observation

@MainActor
@Observable
class HealthProfileViewModel {
    private let store = WorkoutStore.shared

    var allRecords: [WorkoutRecord] { store.allRecords() }

    var thisWeekCount: Int { store.thisWeekCount() }

    var totalDuration: TimeInterval {
        allRecords.reduce(0) { $0 + $1.duration }
    }

    var totalCalories: Int {
        allRecords.reduce(0) { $0 + $1.caloriesEstimate }
    }

    var averageCaloriesPerSession: Int {
        let count = allRecords.count
        guard count > 0 else { return 0 }
        return totalCalories / count
    }

    var consecutiveDays: Int {
        let sorted = allRecords.map { Calendar.current.startOfDay(for: $0.date) }
        let uniqueDays = Array(Set(sorted)).sorted(by: >)
        guard let today = uniqueDays.first, Calendar.current.isDateInToday(today) || Calendar.current.isDateInYesterday(today) else {
            return uniqueDays.first.flatMap { Calendar.current.isDateInToday($0) ? 1 : 0 } ?? 0
        }
        var count = 0
        var cursor = Calendar.current.startOfDay(for: Date())
        for day in uniqueDays {
            if Calendar.current.isDate(day, inSameDayAs: cursor) {
                count += 1
                cursor = Calendar.current.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else if Calendar.current.isDate(day, equalTo: cursor, toGranularity: .day) == false {
                break
            }
        }
        return count
    }

    var totalWorkoutCount: Int { allRecords.count }

    var todayRecords: [WorkoutRecord] {
        let today = Calendar.current.startOfDay(for: Date())
        return allRecords.filter { Calendar.current.startOfDay(for: $0.date) == today }
    }

    var todayTotalDuration: TimeInterval {
        todayRecords.reduce(0) { $0 + $1.duration }
    }

    var todayTotalCalories: Int {
        todayRecords.reduce(0) { $0 + $1.caloriesEstimate }
    }

    var thisWeekTotalDuration: TimeInterval {
        store.totalDurationThisWeek()
    }

    var formattedTotalDuration: String {
        let mins = Int(totalDuration) / 60
        return "\(mins)分钟"
    }

    var formattedTodayDuration: String {
        let mins = Int(todayTotalDuration) / 60
        let secs = Int(todayTotalDuration) % 60
        if mins > 0 {
            return "\(mins)分\(secs)秒"
        }
        return "\(secs)秒"
    }

    func deleteRecord(_ record: WorkoutRecord) {
        store.delete(record)
    }
}
