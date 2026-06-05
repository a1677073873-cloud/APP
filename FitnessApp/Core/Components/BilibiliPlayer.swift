import SwiftUI
import SafariServices

/// B站视频入口 — 点击打开 B站视频（SFSafariViewController 应用内浏览器）
struct BilibiliPlayerView: View {
    let bvid: String

    @State private var showSafari = false

    private var videoURL: URL {
        URL(string: "https://www.bilibili.com/video/\(bvid)")!
    }

    var body: some View {
        Button {
            showSafari = true
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.9))

                Text("点击播放教学视频")
                    .font(.fitCallout)
                    .foregroundColor(.white.opacity(0.8))

                Text("将在浏览器中打开 B站")
                    .font(.fitCaption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.45, blue: 0.55), Color(red: 0.1, green: 0.3, blue: 0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .fullScreenCover(isPresented: $showSafari) {
            SafariView(url: videoURL)
                .ignoresSafeArea()
        }
    }
}

// MARK: - SFSafariViewController 封装

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - BV 号工具

extension BilibiliPlayerView {
    static func extractBV(_ input: String?) -> String? {
        guard let input = input?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else { return nil }
        if input.hasPrefix("BV"), input.count >= 10 { return input }
        if let range = input.range(of: "BV[0-9A-Za-z]+", options: .regularExpression) {
            return String(input[range])
        }
        return nil
    }
}
