import Foundation

class WorkoutStore {
    static let shared = WorkoutStore()

    private let key = "workout_records"
    private var records: [WorkoutRecord] = []

    private init() {
        load()
    }

    func allRecords() -> [WorkoutRecord] {
        records.sorted { $0.date > $1.date }
    }

    func recentRecords(limit: Int = 5) -> [WorkoutRecord] {
        Array(allRecords().prefix(limit))
    }

    func thisWeekCount() -> Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return records.filter { $0.date >= startOfWeek }.count
    }

    func totalDurationThisWeek() -> TimeInterval {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return records.filter { $0.date >= startOfWeek }.reduce(0) { $0 + $1.duration }
    }

    func save(_ record: WorkoutRecord) {
        records.append(record)
        persist()
    }

    func delete(_ record: WorkoutRecord) {
        records.removeAll { $0.id == record.id }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WorkoutRecord].self, from: data) else {
            records = []
            return
        }
        records = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
