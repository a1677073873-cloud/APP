import SwiftUI
import PhotosUI

/// 发布活动页
struct PublishActivityView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var draft = ActivityDraft()
    @State private var showPublishAlert = false

    // 封面图选择
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    private let sportTypes = ["有氧运动", "力量训练", "HIIT", "柔韧性训练", "自定义"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 封面图上传
                coverImagePicker

                // 活动名称
                inputSection(title: "活动名称") {
                    TextField("给你的活动取个吸引人的名字", text: $draft.title)
                        .font(.fitBody)
                }

                // 运动类型
                inputSection(title: "运动类型") {
                    Picker("运动类型", selection: $draft.sportType) {
                        ForEach(sportTypes, id: \.self) { type in
                            HStack {
                                Image(systemName: sportIcon(for: type))
                                Text(type)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.oceanBlue)
                }

                // 活动时间
                inputSection(title: "活动时间") {
                    DatePicker("", selection: $draft.date, in: Date()...)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                // 活动地点
                inputSection(title: "活动地点") {
                    TextField("如：朝阳公园南门", text: $draft.location)
                        .font(.fitBody)
                }

                // 人数限制
                inputSection(title: "人数限制") {
                    VStack(spacing: 10) {
                        HStack {
                            Text("最多")
                                .font(.fitBody)
                                .foregroundColor(.secondaryText)
                            TextField("", value: $draft.maxParticipants, format: .number)
                                .font(.fitBody)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.lightGray)
                                )
                            Text("人")
                                .font(.fitBody)
                                .foregroundColor(.secondaryText)
                            Spacer()
                        }

                        // 快捷选择
                        HStack(spacing: 8) {
                            ForEach([10, 20, 25, 30], id: \.self) { num in
                                QuickCountButton(
                                    count: num,
                                    isSelected: draft.maxParticipants == num,
                                    action: { draft.maxParticipants = num }
                                )
                            }
                        }
                    }
                }

                // 报名费用
                inputSection(title: "报名费用") {
                    VStack(spacing: 12) {
                        Toggle("免费活动", isOn: $draft.isFree)
                            .font(.fitBody)
                            .tint(.mintGreen)

                        if !draft.isFree {
                            HStack {
                                Text("¥")
                                    .font(.fitBody)
                                    .foregroundColor(.secondaryText)
                                TextField("输入金额", value: $draft.fee, format: .number)
                                    .font(.fitBody)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.lightGray)
                            )

                            // 收款方式
                            HStack(spacing: 6) {
                                Text("收款方式")
                                    .font(.fitCaption)
                                    .foregroundColor(.secondaryText)

                                ForEach(PaymentMethod.allCases, id: \.self) { method in
                                    Button {
                                        draft.paymentMethod = method
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: draft.paymentMethod == method ? "checkmark.circle.fill" : "circle")
                                                .font(.fitCaption)
                                            Text(method.rawValue)
                                                .font(.fitCaption)
                                        }
                                        .foregroundColor(draft.paymentMethod == method ? .mintGreen : .secondaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(draft.paymentMethod == method ? .mintGreen.opacity(0.1) : Color.lightGray)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // 活动描述
                inputSection(title: "活动详情描述") {
                    ZStack(alignment: .topLeading) {
                        if draft.description.isEmpty {
                            Text("描述活动内容、注意事项、适合人群等信息...")
                                .font(.fitBody)
                                .foregroundColor(.mediumGray)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $draft.description)
                            .font(.fitBody)
                            .frame(minHeight: 140)
                            .scrollContentBackground(.hidden)
                    }
                }
            }
            .padding(20)
        }
        .background(Color.lightGray.ignoresSafeArea())
        .navigationTitle("发布活动")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            FitButton(
                title: "确认发布",
                style: .primary,
                icon: "paperplane.fill",
                isDisabled: !draft.isValid
            ) {
                viewModel.publishActivity(draft)
                showPublishAlert = true
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Rectangle()
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
            )
        }
        .alert("发布成功", isPresented: $showPublishAlert) {
            Button("好的") {
                dismiss()
            }
        } message: {
            Text("你的活动「\(draft.title)」已成功发布，现在可以在活动列表中看到了。")
        }
    }

    // MARK: - Cover Image Picker

    private var coverImagePicker: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        // 重新选择提示
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title2)
                            Text("点击更换封面图")
                                .font(.fitCaption)
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundColor(.mediumGray)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.mediumGray.opacity(0.06))

                    VStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(.mediumGray)

                        Text("上传封面图")
                            .font(.fitCallout)
                            .foregroundColor(.mediumGray)

                        Text("支持 JPG、PNG，建议尺寸 750×400")
                            .font(.fitCaption2)
                            .foregroundColor(.mediumGray.opacity(0.7))
                    }
                }
                .frame(height: 180)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = image
                        draft.coverImageData = data
                    }
                }
            }
        }
    }

    // MARK: - Input Section

    private func inputSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.fitCaption)
                .foregroundColor(.secondaryText)
                .padding(.leading, 4)

            content()
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.pureWhite)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.lightGray, lineWidth: 0.5)
                )
        }
    }

    private func sportIcon(for type: String) -> String {
        switch type {
        case "力量训练": return "dumbbell.fill"
        case "有氧运动": return "heart.circle.fill"
        case "HIIT": return "flame.fill"
        case "柔韧性训练": return "figure.mind.and.body"
        case "自定义": return "star.fill"
        default: return "figure.run"
        }
    }
}

// MARK: - Quick Count Button

struct QuickCountButton: View {
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(count)")
                .font(.fitCaption)
                .foregroundColor(isSelected ? Color.white : Color.oceanBlue)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.oceanBlue : Color.oceanBlue.opacity(0.1))
                )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PublishActivityView(viewModel: ActivityViewModel())
    }
}
