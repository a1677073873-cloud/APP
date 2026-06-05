import Foundation

@Observable
class EmergencyContactStore {
    private(set) var contacts: [EmergencyContact] = []
    private let storageKey = "emergency_contacts_v1"

    init() {
        load()
    }

    func add(_ contact: EmergencyContact) {
        contacts.append(contact)
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            contacts.remove(at: index)
        }
        save()
    }

    var hasContacts: Bool { !contacts.isEmpty }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: data)
        else { return }
        contacts = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
