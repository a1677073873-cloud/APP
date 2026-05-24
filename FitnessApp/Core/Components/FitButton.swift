import SwiftUI

enum FitButtonStyle {
    case primary, secondary, tertiary, destructive

    var backgroundColor: Color {
        switch self {
        case .primary: return .oceanBlue
        case .secondary: return .clear
        case .tertiary: return .clear
        case .destructive: return .dangerRed
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return .oceanBlue
        case .tertiary: return .secondaryText
        case .destructive: return .white
        }
    }

    var borderColor: Color {
        switch self {
        case .secondary: return .oceanBlue
        default: return .clear
        }
    }
}

struct FitButton: View {
    let title: String
    var style: FitButtonStyle = .primary
    var icon: String? = nil
    var isFullWidth: Bool = true
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.fitCallout)
                }
                Text(title)
                    .font(.fitHeadline)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor, lineWidth: 1)
            )
            .foregroundColor(style.foregroundColor)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
