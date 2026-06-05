import SwiftUI

struct EmergencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddSheet = false

    var store: EmergencyContactStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if store.contacts.isEmpty {
                    emptyState
                } else {
                    contactsList
                }
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("紧急联系人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.fitHeadline)
                            .foregroundColor(.oceanBlue)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("完成") { dismiss() }
                        .font(.fitBody)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddContactView { contact in
                    store.add(contact)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "phone.badge.shield")
                .font(.system(size: 48))
                .foregroundColor(.mediumGray)

            VStack(spacing: 8) {
                Text("未设置紧急联系人")
                    .font(.fitHeadline)
                    .foregroundColor(.darkText)
                Text("设置后，当系统检测到危机信号时\n可选择向紧急联系人发送求助短信")
                    .font(.fitCallout)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }

            FitButton(title: "添加紧急联系人", style: .secondary, icon: "plus") {
                showAddSheet = true
            }
            .padding(.horizontal, 60)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var contactsList: some View {
        List {
            ForEach(store.contacts) { contact in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.oceanBlue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.fitCallout)
                            .foregroundColor(.darkText)
                        Text(contact.phone)
                            .font(.fitCaption)
                            .foregroundColor(.secondaryText)
                    }
                    Spacer()
                    Text(contact.relationship)
                        .font(.fitCaption2)
                        .foregroundColor(.mediumGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.lightGray))
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                store.delete(at: indexSet)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Add Contact Sheet

struct AddContactView: View {
    let onSave: (EmergencyContact) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var relationship = "朋友"

    private let relationships = ["家人", "伴侣", "朋友", "同事", "医生"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    FitTextField(placeholder: "联系人姓名", text: $name)
                    FitTextField(placeholder: "手机号码", text: $phone, keyboardType: .phonePad)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("关系")
                            .font(.fitCaption)
                            .foregroundColor(.secondaryText)
                        Picker("关系", selection: $relationship) {
                            ForEach(relationships, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                FitButton(
                    title: "保存",
                    style: .primary,
                    isDisabled: name.isEmpty || phone.isEmpty
                ) {
                    let contact = EmergencyContact(
                        name: name,
                        phone: phone,
                        relationship: relationship
                    )
                    onSave(contact)
                    dismiss()
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("添加联系人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}
