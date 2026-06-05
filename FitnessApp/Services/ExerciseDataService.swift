import Foundation

class ExerciseDataService {
    static let shared = ExerciseDataService()
    private var exercises: [Exercise] = []

    private init() {
        loadExercises()
    }

    func allExercises() -> [Exercise] { exercises }
    func exercises(for category: ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.category == category }
    }

    func search(_ query: String) -> [Exercise] {
        guard !query.isEmpty else { return exercises }
        let q = query.lowercased()
        return exercises.filter {
            $0.name.lowercased().contains(q) ||
            $0.targetMuscles.contains { $0.lowercased().contains(q) } ||
            $0.category.rawValue.contains(q)
        }
    }

    private func loadExercises() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("未找到 exercises.json")
            exercises = builtInExercises()
            return
        }
        do {
            let data = try Data(contentsOf: url)
            exercises = try JSONDecoder().decode([Exercise].self, from: data)
        } catch {
            print("解析 exercises.json 失败: \(error)")
            exercises = builtInExercises()
        }
    }

    // 备用：硬编码数据
    private func builtInExercises() -> [Exercise] {
        return [
            // 胸部
            Exercise(name: "标准俯卧撑", category: .chest, description: "经典上肢推力动作，有效锻炼胸肌、三角肌前束和肱三头肌", difficulty: .beginner, targetMuscles: ["胸大肌", "三角肌前束", "肱三头肌"], instructions: ["双手略宽于肩撑地", "身体成一条直线", "屈肘下降至胸部接近地面", "推起回到起始位置"], tips: ["保持核心收紧不塌腰"], videoURL: "BV1A6dEBPE4y"),
            Exercise(name: "哑铃卧推", category: .chest, description: "哑铃卧推可增加胸部力量和肌肉维度，同时增强肩关节稳定性", difficulty: .intermediate, targetMuscles: ["胸大肌", "三角肌前束", "肱三头肌"], instructions: ["仰卧在平板凳上", "双手各持哑铃于胸部两侧", "向上推起哑铃至手臂伸直", "缓慢下放至起始位置"], tips: ["双脚踩稳地面", "肩胛骨收紧"]),
            Exercise(name: "上斜哑铃飞鸟", category: .chest, description: "针对胸肌上部，增加胸部宽度和形态", difficulty: .intermediate, targetMuscles: ["胸大肌上部", "三角肌前束"], instructions: ["仰卧在上斜凳上约30-45度", "双手持哑铃在胸部上方", "微屈肘，向外打开手臂", "感受胸肌拉伸后收回"], tips: ["手臂微弯保持固定角度"]),
            Exercise(name: "双杠臂屈伸", category: .chest, description: "自重训练动作，重点刺激下胸部和肱三头肌", difficulty: .advanced, targetMuscles: ["胸大肌下部", "肱三头肌", "三角肌前束"], instructions: ["双手握双杠支撑身体", "身体前倾约30度", "屈肘下降至肩部略低于肘", "推起至手臂伸直"], tips: ["身体前倾越多，胸部发力越多"]),
            Exercise(name: "弹力带夹胸", category: .chest, description: "适合居家训练，弹力带提供持续张力", difficulty: .beginner, targetMuscles: ["胸大肌中缝"], instructions: ["将弹力带固定在身后与胸同高", "双手各握弹力带一端", "向前做夹胸动作至双手并拢", "缓慢控制回位"], tips: ["弹力带张力不宜过大"]),

            // 背部
            Exercise(name: "引体向上", category: .back, description: "背部训练的王牌动作，锻炼背阔肌宽度和手臂力量", difficulty: .advanced, targetMuscles: ["背阔肌", "大圆肌", "肱二头肌"], instructions: ["正握单杠略宽于肩", "悬挂身体，肩胛骨下沉", "发力向上拉至下巴过杠", "控制下放至起始位置"], tips: ["不要借力摆动", "从助力引体开始练习"]),
            Exercise(name: "哑铃划船", category: .back, description: "单侧背部训练，纠正左右不平衡", difficulty: .intermediate, targetMuscles: ["背阔肌", "菱形肌", "斜方肌中下部"], instructions: ["单膝跪凳，同侧手撑凳面", "另一手持哑铃自然下垂", "将哑铃拉向髋部", "控制下放"], tips: ["保持腰背平直", "感受背部发力而非手臂"]),
            Exercise(name: "坐姿绳索划船", category: .back, description: "安全高效的背部厚度训练动作", difficulty: .beginner, targetMuscles: ["背阔肌", "菱形肌", "后三角肌"], instructions: ["坐于划船机上双脚蹬踏板", "双手握V把手臂伸直", "将把手拉向腹部", "夹紧背部后慢放"], tips: ["拉时挺胸，放时含胸"]),
            Exercise(name: "高位下拉", category: .back, description: "引体向上的替代动作，适合各阶段训练者", difficulty: .beginner, targetMuscles: ["背阔肌", "大圆肌", "肱二头肌"], instructions: ["坐于下拉器下，大腿固定", "宽握横杆", "下拉至锁骨位置", "缓慢放回"], tips: ["不要过分后仰借力"]),
            Exercise(name: "超人式伸展", category: .back, description: "强化下背部和臀部肌群，改善体态", difficulty: .beginner, targetMuscles: ["竖脊肌", "臀大肌", "菱形肌"], instructions: ["俯卧，双臂前伸", "同时抬起双臂和双腿", "保持2秒后放下"], tips: ["动作幅度优先于数量"]),

            // 腿部
            Exercise(name: "深蹲", category: .legs, description: "下肢训练之王，全面锻炼腿部力量和核心稳定性", difficulty: .beginner, targetMuscles: ["股四头肌", "臀大肌", "腘绳肌", "核心"], instructions: ["双脚与肩同宽站立", "挺胸收腹", "屈髋屈膝下蹲", "大腿低于水平线后站起"], tips: ["膝盖不要超过脚尖过多", "重心在脚掌中部"], videoURL: "BV1fW42197ch"),
            Exercise(name: "弓步蹲", category: .legs, description: "单侧训练改善腿部平衡和稳定性", difficulty: .beginner, targetMuscles: ["股四头肌", "臀大肌", "腘绳肌"], instructions: ["双脚前后分开约一步距离", "身体垂直下蹲", "前后膝均约90度", "蹬地回到起始位置"], tips: ["前膝不超过脚尖"]),
            Exercise(name: "罗马尼亚硬拉", category: .legs, description: "针对腘绳肌和臀部的精准训练", difficulty: .intermediate, targetMuscles: ["腘绳肌", "臀大肌", "竖脊肌"], instructions: ["双脚与髋同宽站立", "微屈膝，髋部后推", "身体前倾至背部即将弯曲", "收缩臀部回到直立"], tips: ["保持背部平直全程", "杠铃贴近小腿"]),
            Exercise(name: "保加利亚分腿蹲", category: .legs, description: "高阶单侧腿部训练，极大刺激股四头肌和臀部", difficulty: .advanced, targetMuscles: ["股四头肌", "臀大肌", "核心"], instructions: ["后脚搭在凳上约40cm高", "前脚向前一步", "垂直下蹲至前大腿水平", "前脚发力站起"], tips: ["前脚全掌着地"]),
            Exercise(name: "臀桥", category: .legs, description: "康复和塑形兼顾，激活臀部改善骨盆前倾", difficulty: .beginner, targetMuscles: ["臀大肌", "腘绳肌", "核心"], instructions: ["仰卧屈膝脚掌踩地", "双臂放身体两侧", "臀部发力向上抬起", "顶峰收缩2秒后下放"], tips: ["不要过度挺腰"]),
            Exercise(name: "靠墙静蹲", category: .legs, description: "安全的下肢耐力训练，适合康复期", difficulty: .beginner, targetMuscles: ["股四头肌", "臀大肌"], instructions: ["背靠墙，双脚前移一步", "沿墙下滑至大腿平行地面", "保持此姿势不动"], tips: ["膝盖不要超过脚尖", "从30秒开始逐渐增加"]),

            // 肩部
            Exercise(name: "哑铃推举", category: .shoulders, description: "肩部维度和力量的基础动作", difficulty: .intermediate, targetMuscles: ["三角肌前中束", "肱三头肌", "斜方肌"], instructions: ["坐姿，双手持哑铃于肩部两侧", "向上推举至头顶", "控制下放至起始位置"], tips: ["不要锁死肘关节"]),
            Exercise(name: "侧平举", category: .shoulders, description: "打造肩宽的关键动作，重点刺激三角肌中束", difficulty: .beginner, targetMuscles: ["三角肌中束"], instructions: ["双手持哑铃自然垂于体侧", "微屈肘", "向两侧抬起手臂至与肩同高", "缓慢下放"], tips: ["不要借力摆动", "使用小重量"]),
            Exercise(name: "面拉", category: .shoulders, description: "改善圆肩驼背，强化肩袖和后三角肌", difficulty: .beginner, targetMuscles: ["三角肌后束", "肩袖肌群", "菱形肌"], instructions: ["站姿面对龙门架", "高位滑轮绳索与面部同高", "双手拉向面部两侧", "夹紧肩胛骨"], tips: ["不要用腰部借力"]),

            // 手臂
            Exercise(name: "哑铃弯举", category: .arms, description: "肱二头肌训练的经典动作", difficulty: .beginner, targetMuscles: ["肱二头肌", "肱肌"], instructions: ["站姿双手持哑铃", "上臂紧贴身体两侧", "屈肘将哑铃举向肩部", "控制下放"], tips: ["身体不要摆动借力"]),
            Exercise(name: "绳索下压", category: .arms, description: "肱三头肌塑形的最佳动作之一", difficulty: .beginner, targetMuscles: ["肱三头肌"], instructions: ["面对高位滑轮站立", "握绳索手臂弯曲", "下压至手臂完全伸直", "控制回位"], tips: ["上臂保持不动"]),
            Exercise(name: "锤式弯举", category: .arms, description: "增加前臂和肱肌力量", difficulty: .beginner, targetMuscles: ["肱肌", "肱桡肌", "肱二头肌"], instructions: ["双手持哑铃掌心相对", "上臂固定", "弯举至肩部高度", "控制下放"], tips: ["腕关节保持中立"]),
            Exercise(name: "窄距俯卧撑", category: .arms, description: "自重训练强化肱三头肌", difficulty: .intermediate, targetMuscles: ["肱三头肌", "胸大肌", "三角肌前束"], instructions: ["双手并拢拇指食指相触", "身体成直线", "屈肘下降", "推起"], tips: ["下降时肘部贴近身体"]),

            // 核心
            Exercise(name: "平板支撑", category: .core, description: "核心稳定性的基础训练", difficulty: .beginner, targetMuscles: ["腹横肌", "腹直肌", "竖脊肌"], instructions: ["俯卧，前臂撑地", "脚尖点地身体悬空", "身体成一条直线", "保持不动"], tips: ["不要塌腰或撅臀", "从30秒开始"]),
            Exercise(name: "卷腹", category: .core, description: "精准刺激腹直肌，比仰卧起坐更安全", difficulty: .beginner, targetMuscles: ["腹直肌"], instructions: ["仰卧屈膝脚掌踩地", "双手轻放耳侧", "上背部离地卷起", "顶峰收缩后下放"], tips: ["下背部不离地", "不要用手拉头"]),
            Exercise(name: "俄罗斯转体", category: .core, description: "锻炼腹斜肌和旋转核心力量", difficulty: .intermediate, targetMuscles: ["腹斜肌", "腹直肌", "髋屈肌"], instructions: ["坐姿后仰约45度", "双脚离地或踩地", "双手合十左右旋转"], tips: ["初学者脚可踩地"]),
            Exercise(name: "鸟狗式", category: .core, description: "康复经典动作，提高核心稳定和协调性", difficulty: .beginner, targetMuscles: ["竖脊肌", "腹横肌", "臀大肌"], instructions: ["四足跪姿", "同时抬起对侧手和腿", "水平伸展保持2秒", "换侧重复"], tips: ["动作缓慢控制", "不要翻髋"]),
            Exercise(name: "死虫式", category: .core, description: "安全的核心训练，适合初学者和康复", difficulty: .beginner, targetMuscles: ["腹横肌", "腹直肌"], instructions: ["仰卧双臂上举", "屈髋屈膝90度", "对侧手脚同时下放", "回到起始位置换侧"], tips: ["下背部始终贴地"]),

            // 有氧
            Exercise(name: "开合跳", category: .cardio, description: "经典全身有氧热身动作", difficulty: .beginner, targetMuscles: ["全身", "心肺系统"], instructions: ["双脚并拢站立", "跳起同时分开双脚双手过头", "跳回起始位置"], tips: ["膝盖微屈缓冲落地"]),
            Exercise(name: "高抬腿", category: .cardio, description: "高效燃脂，提升下肢爆发力", difficulty: .intermediate, targetMuscles: ["髋屈肌", "股四头肌", "心肺系统"], instructions: ["原地快速交替抬腿", "大腿抬至与地面平行", "摆臂配合节奏"], tips: ["保持核心收紧"]),
            Exercise(name: "波比跳", category: .cardio, description: "全身燃脂之王，高效HIIT动作", difficulty: .advanced, targetMuscles: ["全身", "心肺系统"], instructions: ["站立开始", "下蹲手撑地", "双脚跳至平板位置", "做俯卧撑后跳回", "向上跳起并拍手"], tips: ["初学者可省略俯卧撑"]),
            Exercise(name: "跳绳", category: .cardio, description: "便携高效的有氧运动，每小时消耗600+千卡", difficulty: .beginner, targetMuscles: ["小腿", "核心", "心肺系统"], instructions: ["双手握跳绳两端", "以手腕发力摇绳", "脚尖着地轻轻跳跃", "保持节奏"], tips: ["落地时膝盖微屈"]),

            // 柔韧性
            Exercise(name: "猫牛式", category: .flexibility, description: "脊柱灵活性基础动作，缓解腰背僵硬", difficulty: .beginner, targetMuscles: ["脊柱", "核心"], instructions: ["四足跪姿", "吸气时塌腰抬头（牛式）", "呼气时拱背低头（猫式）", "缓慢交替"], tips: ["配合呼吸节奏"]),
            Exercise(name: "婴儿式", category: .flexibility, description: "放松全身，恢复呼吸，适合训练后放松", difficulty: .beginner, targetMuscles: ["背部", "髋部", "肩部"], instructions: ["跪坐，双膝分开", "上身前倾额头贴地", "双臂前伸或放体侧", "保持深呼吸"], tips: ["每个呼吸尽量让身体下沉"]),
            Exercise(name: "蝴蝶式拉伸", category: .flexibility, description: "打开髋关节，改善久坐带来的僵硬", difficulty: .beginner, targetMuscles: ["髋内收肌", "腹股沟"], instructions: ["坐姿，脚掌相对", "双手握脚", "膝盖向地面下压", "保持30秒"], tips: ["不要用力按压膝盖"]),
            Exercise(name: "鸽子式", category: .flexibility, description: "深度髋部拉伸，缓解梨状肌紧张", difficulty: .intermediate, targetMuscles: ["梨状肌", "臀大肌", "髋屈肌"], instructions: ["前腿弯曲横放", "后腿向后伸直", "上身慢慢前倾", "保持30-60秒"], tips: ["前方小腿尽量与垫子前缘平行"]),
            Exercise(name: "站姿前屈", category: .flexibility, description: "拉伸后链肌群，缓解腰痛", difficulty: .beginner, targetMuscles: ["腘绳肌", "竖脊肌", "小腿"], instructions: ["双脚与髋同宽站立", "髋部折叠前屈", "双手触地或小腿", "保持膝盖微弯"], tips: ["不要弓背", "放松头部"]),

            // 康复
            Exercise(name: "肩袖外旋", category: .rehabilitation, description: "强化肩袖肌群，预防肩部损伤", difficulty: .beginner, targetMuscles: ["冈下肌", "小圆肌"], instructions: ["侧卧，上臂夹毛巾卷", "肘关节弯曲90度", "手持小哑铃向外旋转", "缓慢回位"], tips: ["动作全程上臂不动"]),
            Exercise(name: "弹力带肩胛后缩", category: .rehabilitation, description: "改善圆肩驼背，强化菱形肌", difficulty: .beginner, targetMuscles: ["菱形肌", "斜方肌中下部"], instructions: ["双手握弹力带前伸", "保持手臂伸直", "向后夹紧肩胛骨", "缓慢回位"], tips: ["只动肩胛不动手臂"]),
            Exercise(name: "臀中肌蚌式开合", category: .rehabilitation, description: "激活臀中肌，改善膝盖疼痛和步态", difficulty: .beginner, targetMuscles: ["臀中肌"], instructions: ["侧卧屈膝约45度", "双脚并拢", "上方膝盖像蚌壳一样打开", "缓慢闭合"], tips: ["骨盆不要翻转"]),
            Exercise(name: "颈椎缩下巴", category: .rehabilitation, description: "纠正前伸头位，缓解颈肩不适", difficulty: .beginner, targetMuscles: ["颈深屈肌"], instructions: ["坐直或靠墙站", "下巴向后水平缩回", "感觉后颈拉伸", "保持5秒放松"], tips: ["不要低头，是水平后移"]),
            Exercise(name: "髂胫束泡沫轴放松", category: .rehabilitation, description: "放松大腿外侧筋膜，缓解跑步膝", difficulty: .beginner, targetMuscles: ["髂胫束", "阔筋膜张肌"], instructions: ["侧卧泡沫轴放大腿外侧", "用手支撑身体", "从髋部向膝盖滚动", "痛点多停留"], tips: ["缓慢滚动，保持呼吸"]),
            Exercise(name: "踝关节活动度训练", category: .rehabilitation, description: "改善踝关节灵活性，预防崴脚", difficulty: .beginner, targetMuscles: ["踝关节", "小腿"], instructions: ["坐姿腿伸直", "脚踝顺时针慢转10圈", "逆时针慢转10圈", "勾脚尖和绷脚尖交替"], tips: ["动作幅度尽可能大"]),
        ]
    }
}
