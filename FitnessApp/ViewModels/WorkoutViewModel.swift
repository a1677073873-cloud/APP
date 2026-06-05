import SwiftUI
import Observation

@Observable
class WorkoutViewModel {
    var selectedType: WorkoutType?
    var isActive = false
    var isPaused = false
    var elapsedSeconds: Int = 0
    var caloriesPerMinute: Double = 6.0

    private var timer: Timer?
    private var startDate: Date?

    var formattedTime: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    var estimatedCalories: Int {
        Int(Double(elapsedSeconds) / 60.0 * caloriesPerMinute)
    }

    func startWorkout(type: WorkoutType) {
        selectedType = type
        isActive = true
        isPaused = false
        elapsedSeconds = 0
        startDate = Date()

        switch type {
        case .strength: caloriesPerMinute = 5.0
        case .cardio: caloriesPerMinute = 8.0
        case .flexibility: caloriesPerMinute = 3.0
        case .hiit: caloriesPerMinute = 10.0
        case .custom: caloriesPerMinute = 6.0
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.elapsedSeconds += 1
            }
        }
    }

    func stopWorkout() -> WorkoutRecord {
        timer?.invalidate()
        timer = nil
        isActive = false
        isPaused = false

        let record = WorkoutRecord(
            date: startDate ?? Date(),
            type: selectedType ?? .custom,
            duration: TimeInterval(elapsedSeconds),
            caloriesEstimate: estimatedCalories
        )

        WorkoutStore.shared.save(record)
        return record
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        isActive = false
        isPaused = false
        elapsedSeconds = 0
        selectedType = nil
    }
}
