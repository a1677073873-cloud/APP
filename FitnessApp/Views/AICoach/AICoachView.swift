import SwiftUI

struct AICoachView: View {
    var dismissAction: (() -> Void)? = nil

    @State private var viewModel = ChatViewModel()
    @State private var contactStore = EmergencyContactStore()
    @State private var showEmergencySettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.messages.isEmpty {
                    welcomeView
                } else {
                    chatListView
                }
                inputBar
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("AI教练")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let dismiss = dismissAction {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            Haptics.light()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEmergencySettings = true
                    } label: {
                        Image(systemName: "phone.badge.shield")
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showEmergencySettings) {
                EmergencySettingsView(store: contactStore)
            }
            .sheet(isPresented: $viewModel.showEmergencyPrompt) {
                emergencyPromptView
            }
            .alert("是否需要帮助？", isPresented: $viewModel.showCrisisAlert) {
                Button("发送求助短信") {
                    viewModel.confirmSendCrisisSMS()
                }
                Button("我先陪TA聊聊", role: .cancel) {
                    viewModel.dismissCrisisAlert()
                }
            } message: {
                Text("我们注意到你可能正在经历困难时刻。是否要给紧急联系人发送求助短信？")
            }
            .onAppear {
                viewModel.checkFirstLaunch()
            }
        }
    }

    // MARK: - First Launch Emergency Prompt

    private var emergencyPromptView: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "phone.badge.shield")
                    .font(.system(size: 56))
                    .foregroundColor(.coral)

                VStack(spacing: 10) {
                    Text("安全保障设置")
                        .font(.fitTitle2)
                        .foregroundColor(.darkText)
                    Text("为了在紧急情况下能及时帮助到你，建议设置紧急联系人。当系统检测到危机信号时，可一键向联系人发送求助短信。")
                        .font(.fitBody)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 4) {
                    Text("你的联系人信息仅存储在本地")
                        .font(.fitCaption)
                        .foregroundColor(.mediumGray)
                    Text("不会上传至服务器")
                        .font(.fitCaption)
                        .foregroundColor(.mediumGray)
                }

                VStack(spacing: 12) {
                    FitButton(title: "设置紧急联系人", style: .primary, icon: "person.badge.plus") {
                        viewModel.showEmergencyPrompt = false
                        showEmergencySettings = true
                    }
                    .padding(.horizontal, 40)

                    Button("稍后设置") {
                        viewModel.showEmergencyPrompt = false
                    }
                    .font(.fitCallout)
                    .foregroundColor(.secondaryText)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.lightGray.ignoresSafeArea())
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Emergency Contact Entry Card

    private var emergencyContactEntryCard: some View {
        Button {
            showEmergencySettings = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "phone.badge.shield")
                    .font(.title3)
                    .foregroundColor(.coral)
                VStack(alignment: .leading, spacing: 2) {
                    Text("设置紧急联系人")
                        .font(.fitCallout)
                        .foregroundColor(.darkText)
                    Text("危机时刻可一键求助")
                        .font(.fitCaption)
                        .foregroundColor(.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.fitCaption)
                    .foregroundColor(.mediumGray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.pureWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.coral.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "heart.text.clinic.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.mintGreen)
                    .padding(.top, 48)

                VStack(spacing: 8) {
                    Text("你好，我是你的AI健身教练")
                        .font(.fitTitle2)
                        .foregroundColor(.darkText)
                    Text("你可以向我咨询训练计划、动作指导、营养建议，或者只是聊聊今天的感受。")
                        .font(.fitBody)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                if contactStore.contacts.isEmpty {
                    emergencyContactEntryCard
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("可以试试问我：")
                        .font(.fitCaption)
                        .foregroundColor(.mediumGray)
                        .padding(.leading, 4)

                    ForEach(suggestedQuestions, id: \.self) { question in
                        Button {
                            viewModel.sendSuggestedQuestion(question)
                        } label: {
                            Text(question)
                                .font(.fitCallout)
                                .foregroundColor(.oceanBlue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.pureWhite)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.oceanBlue.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Chat List

    private var chatListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                    }

                    if viewModel.isLoading {
                        TypingIndicator()
                            .padding(.leading, 12)
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isLoading) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = viewModel.messages.last {
            withAnimation {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        } else if viewModel.isLoading {
            withAnimation {
                proxy.scrollTo("typing", anchor: .bottom)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("输入消息...", text: $viewModel.inputText, axis: .vertical)
                .font(.fitBody)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.lightGray)
                )
                .lineLimit(4)
                .disabled(viewModel.isLoading)

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: viewModel.isLoading ? "stopwatch" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? .mediumGray : .oceanBlue
                    )
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.pureWhite)
    }

    private let suggestedQuestions = [
        "今天适合练什么？",
        "如何缓解运动后的肌肉酸痛？",
        "帮我制定一个减脂计划",
        "练完腿太疼了怎么办？",
        "如何改善圆肩驼背？",
        "适合新手的核心训练有哪些？"
    ]
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .assistant {
                coachAvatar
            } else {
                Spacer(minLength: 60)
            }

            Text(message.content)
                .font(.fitBody)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(message.role == .user ? Color.oceanBlue : Color.pureWhite)
                )
                .foregroundColor(message.role == .user ? .white : .darkText)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            message.role == .user ? Color.clear : Color.lightGray,
                            lineWidth: 0.5
                        )
                )

            if message.role == .user {
                Spacer(minLength: 60)
            }
        }
    }

    private var coachAvatar: some View {
        Image(systemName: "heart.circle.fill")
            .font(.title3)
            .foregroundColor(.mintGreen)
            .frame(width: 28, height: 28)
            .background(Circle().fill(Color.mintGreen.opacity(0.12)))
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotOffset = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.mediumGray)
                    .frame(width: 6, height: 6)
                    .opacity(dotOffset == i ? 1 : 0.3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.pureWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                dotOffset = (dotOffset + 1) % 3
            }
        }
    }
}
