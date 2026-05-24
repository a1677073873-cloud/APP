import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.fitCaption)
                .foregroundColor(.secondaryText)
            Text(value)
                .font(.fitTitle2)
                .foregroundColor(.darkText)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.fitCaption2)
                    .foregroundColor(.mediumGray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lightGray, lineWidth: 0.5))
    }
}

struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(.mediumGray)
            Text(message)
                .font(.fitCallout)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
