import SwiftUI

/// 活动详情页
struct ActivityDetailView: View {
    let activity: Activity
    @ObservedObject var viewModel: ActivityViewModel

    @State private var showJoinAlert = false
    @State private var joinSuccess = false
    @State private var conflictActivity: Activity? = nil
    @State private var showConflictAlert = false
    @State private var showPayment = false
    @State private var paymentMethod: PaymentMethod = .wechat
    @State private var showCancelAlert = false
    @State private var refundSuccess = false

    private var currentActivity: Activity {
        viewModel.activities.first(where: { $0.id == activity.id }) ?? activity
    }

    private var hasJoined: Bool {
        viewModel.isJoined(currentActivity)
    }

    private func performJoin() {
        let result = viewModel.joinActivity(currentActivity)
        if result.success {
            Haptics.success()
            joinSuccess = true
            showJoinAlert = true
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    heroCover
                    infoSection
                    descriptionSection
                }
                .padding(.bottom, 90) // 为底部固定栏留空间
            }
            .background(Color.lightGray)

            bottomBar
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("活动详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .alert(joinSuccess ? "报名成功" : "无法加入", isPresented: $showJoinAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(joinSuccess
                ? "你已成功报名「\(currentActivity.title)」，活动开始前可通过 App 查看提醒。"
                : "很遗憾，该活动名额已满。下次早点来哦！")
        }
        .alert("时间冲突", isPresented: $showConflictAlert) {
            Button("我知道了", role: .cancel) {}
        } message: {
            if let conflict = conflictActivity {
                Text("该活动与你已报名的「\(conflict.title)」时间冲突（\(conflict.formattedTimeRange)），请先取消其中一个再报名。")
            }
        }
        .alert("确认取消报名？", isPresented: $showCancelAlert) {
            Button("确认取消", role: .destructive) {
                Haptics.light()
                viewModel.cancelJoin(currentActivity)
                if !currentActivity.isFree {
                    refundSuccess = true
                }
            }
            Button("再想想", role: .cancel) {}
        } message: {
            if currentActivity.isFree {
                Text("取消后你将从「\(currentActivity.title)」中退出，名额将释放给其他人。")
            } else {
                Text("取消后「\(currentActivity.title)」的费用 ¥\(String(format: "%.0f", currentActivity.fee)) 将退还到你的原支付账户（\(currentActivity.fee > 0 ? "模拟退款" : "")），预计 1-3 个工作日到账。")
            }
        }
        .alert("退款成功", isPresented: $refundSuccess) {
            Button("好的", role: .cancel) {}
        } message: {
            Text("¥\(String(format: "%.0f", currentActivity.fee)) 已原路退回。")
        }
        .sheet(isPresented: $showPayment) {
            PaymentSheetView(
                activityTitle: currentActivity.title,
                amount: currentActivity.fee,
                selectedMethod: $paymentMethod,
                onDismiss: { success in
                    if success {
                        performJoin()
                    }
                }
            )
        }
    }

    // MARK: - Hero Cover

    private var heroCover: some View {
        ZStack {
            if let image = currentActivity.coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipped()
                    .overlay(Color.black.opacity(0.25))
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [coverGradientStart, coverGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Image(systemName: currentActivity.sportIcon)
                    .font(.system(size: 56))
                    .foregroundColor(.white.opacity(0.8))

                Text(currentActivity.title)
                    .font(.fitTitle1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(height: 240)
    }

    private var coverGradientStart: Color {
        switch activity.sportType {
        case "力量训练": return .coral
        case "有氧运动": return .oceanBlue
        case "柔韧性训练": return .mintGreen
        case "HIIT": return .warmAmber
        case "自定义": return .lavender
        default: return .stoneGray
        }
    }

    private var coverGradientEnd: Color {
        switch activity.sportType {
        case "力量训练": return Color(red: 180/255, green: 120/255, blue: 110/255)
        case "有氧运动": return Color(red: 100/255, green: 150/255, blue: 170/255)
        case "柔韧性训练": return Color(red: 120/255, green: 170/255, blue: 150/255)
        case "HIIT": return Color(red: 180/255, green: 150/255, blue: 110/255)
        case "自定义": return Color(red: 150/255, green: 140/255, blue: 170/255)
        default: return Color(red: 140/255, green: 135/255, blue: 130/255)
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(spacing: 0) {
            // 标题 + Tag
            HStack(alignment: .center, spacing: 10) {
                Text(activity.title)
                    .font(.fitTitle2)
                    .foregroundColor(.darkText)

                Spacer()

                SportTag(label: activity.sportType, color: sportTagColor)

                if activity.isFree {
                    TagChip(label: "免费", color: .successGreen)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            Divider().padding(.horizontal, 20)

            // 信息行
            VStack(spacing: 14) {
                DetailInfoRow(icon: "calendar.badge.clock", title: "活动时间", value: currentActivity.formattedDateTime)
                DetailInfoRow(icon: "mappin.and.ellipse", title: "活动地点", value: activity.location)
                DetailInfoRow(icon: "dollarsign.circle", title: "报名费用", value: activity.formattedFee)
                DetailInfoRow(icon: "person.2", title: "报名人数", value: "\(activity.participantsText)（剩余 \(activity.remainingSpots) 个名额）")
                DetailInfoRow(icon: "person.crop.circle", title: "发起人", value: activity.publisherName)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.top, -20)
    }

    private var sportTagColor: Color {
        switch activity.sportType {
        case "力量训练": return .coral
        case "有氧运动": return .oceanBlue
        case "柔韧性训练": return .mintGreen
        case "HIIT": return .warmAmber
        case "自定义": return .lavender
        default: return .stoneGray
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("活动详情")
                .font(.fitHeadline)
                .foregroundColor(.darkText)

            Text(activity.description)
                .font(.fitBody)
                .foregroundColor(.secondaryText)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            // 价格 / 人数
            VStack(alignment: .leading, spacing: 2) {
                Text(currentActivity.formattedFee)
                    .font(.fitTitle3)
                    .foregroundColor(currentActivity.isFull ? .dangerRed : .coral)
                Text("\(currentActivity.currentParticipants)/\(currentActivity.maxParticipants)人已报名")
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
            }

            Spacer()

            if hasJoined {
                Button {
                    showCancelAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Text("取消加入")
                            .font(.fitCallout)
                            .foregroundColor(.dangerRed)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.dangerRed.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.dangerRed.opacity(0.3), lineWidth: 1)
                    )
                }

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.fitCallout)
                        .foregroundColor(.mintGreen)
                    Text("已加入")
                        .font(.fitCallout)
                        .foregroundColor(.mintGreen)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.mintGreen.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.mintGreen.opacity(0.3), lineWidth: 1)
                )
            } else if currentActivity.isFull {
                FitButton(
                    title: "名额已满",
                    style: .secondary,
                    isFullWidth: false,
                    isDisabled: true
                ) {}
            } else {
                FitButton(
                    title: "立即加入",
                    style: .primary,
                    icon: "hand.raised.fill",
                    isFullWidth: false
                ) {
                    // 先检查时间冲突
                    let joinedActivities = viewModel.activities.filter { viewModel.joinedActivityIDs.contains($0.id) }
                    if let conflict = joinedActivities.first(where: { $0.overlaps(with: currentActivity) }) {
                        conflictActivity = conflict
                        showConflictAlert = true
                        return
                    }

                    // 付费活动 → 弹出支付页面
                    if currentActivity.isFree {
                        performJoin()
                    } else {
                        paymentMethod = .wechat
                        showPayment = true
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Rectangle()
                .fill(Color.pureWhite)
                .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
        )
    }
}

// MARK: - Detail Info Row

struct DetailInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.oceanBlue)
                .frame(width: 24)

            Text(title)
                .font(.fitCallout)
                .foregroundColor(.secondaryText)
                .frame(width: 72, alignment: .leading)

            Text(value)
                .font(.fitCallout)
                .foregroundColor(.darkText)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ActivityDetailView(
            activity: ActivityViewModel().activities[0],
            viewModel: ActivityViewModel()
        )
    }
}
