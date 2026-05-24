import SwiftUI

struct FitTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .keyboardType(keyboardType)
        .font(.fitBody)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.lightGray))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mediumGray.opacity(0.3), lineWidth: 0.5))
        .autocorrectionDisabled()
    }
}

struct FitSearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索动作..."

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.mediumGray)
            TextField(placeholder, text: $text).font(.fitBody)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.mediumGray)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.lightGray))
    }
}
