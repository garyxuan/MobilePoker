你是一个资深 iOS 工程师，正在为一个名为 MobilePoker 的 SwiftUI 应用实现 MVP。

这是一个【线下真实扑克牌的数字替代品】，不是游戏：
- 无服务器
- 无账号
- 无云
- 不做公平性、防作弊、胜负判断
- 手机仅作为“纸牌展示与同步”的替代物
- 目标是“尽量真实、尽量克制、没有游戏感”

---

## 一、整体技术约束

- 使用 SwiftUI
- 使用 MultipeerConnectivity 做本地点对点通信
- 一局最多 3 个玩家
- 一台设备作为 Host（发牌者/状态权威）
- Host 维护唯一 GameState
- 其他设备只发送 Action，不直接修改状态
- 状态通过 snapshot 广播同步
- 手牌是私有的（只发送给对应玩家）

---

## 二、你需要实现的核心模块

### 1️⃣ 数据模型（Models）

请创建以下模型，放在 `Models/` 目录：

- Card（52 张标准扑克牌，不含大小王）
- Suit / Rank enum
- Player
- GameState
- TableCardStack
- Phase enum

要求：
- Card 有稳定 id（如 "spades-1"）
- GameState 包含：
  - players
  - hostID
  - deck
  - hands: [playerID: [Card]]
  - table: [TableCardStack]
  - currentTurnPlayerID（可选）
  - revision（Int）

---

### 2️⃣ 通信层（Networking）

请使用 MultipeerConnectivity 实现：

- Peer discovery（自动发现附近设备）
- 一台设备可以创建 table（Host）
- 其他设备加入 table（Client）
- 使用 Codable + JSON 进行消息传输

定义以下消息类型：

#### ClientAction
- joinTable(player)
- requestDeal(cardsPerPlayer)
- playCards(playerID, cardIDs)
- requestResync(lastKnownRevision)

#### ServerEvent
- stateSnapshot(GameState裁剪版)
- error(message)

要求：
- Client 只发送 ClientAction
- Host 接收 action，更新 GameState，再广播 ServerEvent
- Snapshot 需要“按接收者裁剪”：
  - 公共字段给所有人
  - hands 只包含当前接收者自己的手牌

---

### 3️⃣ Host 状态引擎（HostEngine）

请实现一个 `GameEngine`（或 `HostEngine`）类：

- 持有当前 GameState
- 提供 `apply(action: ClientAction)` 方法
- 在方法内：
  - 校验最基本合法性（例如牌是否存在于该玩家手牌中）
  - 更新 GameState
  - revision += 1
  - 生成 snapshot 并广播

重点：
- 不实现任何扑克牌规则（不判断牌型、不比大小）
- 出牌只是“从手牌移到桌面”
- 如果出错，直接忽略或返回 error

---

### 4️⃣ SwiftUI 状态存储

请创建一个 `GameStore : ObservableObject`：

- 保存本地渲染用的 GameState（已裁剪）
- 监听 ServerEvent
- 更新 UI

---

### 5️⃣ MVP UI（极简、无游戏感）

只实现以下 3 个界面：

#### A. LobbyView
- 显示“已加入 X / 3 人”
- Host 有一个「开始发牌」按钮
- 非 Host 显示“等待发牌”

#### B. HandView（最重要）
- 全屏横向展示手牌
- 每张牌是一个简单的 CardView（白底 + 花色 + 点数）
- 点一下选中
- 上滑出牌
- 下滑取消选择
- 不要动画、音效、特效

#### C. TableView
- 显示最近出的牌（TableCardStack）
- 按时间顺序堆叠
- 就像桌面中间的牌

---

## 三、UI 风格约束（非常重要）

- 不要“游戏 UI”
- 不要渐变、不用卡通字体
- 尽量像“纸牌”
- 背景中性（桌面感即可）
- 所有交互要安静、克制

---

## 四、工程结构建议（可调整）

- MobilePokerApp.swift
- Models/
- Networking/
- Engine/
- Store/
- Views/
  - LobbyView.swift
  - HandView.swift
  - TableView.swift
  - CardView.swift

---

## 五、目标结果

最终我希望：
- 三台 iPhone 打开 App
- 一台创建牌桌
- 另外两台自动发现并加入
- 点击“开始发牌”
- 每个人只看到自己的手牌
- 上滑出牌，其他人看到桌面更新
- 可以反复“再来一局”

请一步一步实现，先保证正确性，再考虑体验细节。





你是一个资深 iOS/SwiftUI 工程师 + 交互细节控。请在 MobilePoker 工程里，实现 MVP 的 HandView（手牌界面）与相关组件，目标是“纸牌替代物”，不是游戏：真实、克制、无炫技。

请严格遵循以下交互与布局规范（像素级/阈值级），并给出可运行代码（SwiftUI）。

---

# 0. 目标体验（必须满足）
- 手感像“拿着一叠牌”，不是在玩游戏 UI
- 操作全程安静：无音效、无夸张动画、无粒子/光效
- 单手可用：拇指点选 + 上滑出牌
- “误触容忍”优先：宁可少触发，也别误出牌

---

# 1. HandView 的整体布局（尺寸与间距）
## 1.1 背景与安全区
- 使用中性桌面背景（纯色或很轻微纹理，不要渐变、不要炫彩）
- 内容遵循 safe area，底部保留操作空间：
  - 底部安全区 + 额外 padding 12pt
- 顶部仅放极简状态条（可选）：玩家名/连接状态/“轮到你”（如果有）

## 1.2 手牌区域（核心）
- 手牌区域在屏幕下半部分，占高约 45%（使用 GeometryReader 适配）
- 手牌横向排列，允许左右滚动（但默认居中显示）
- 手牌之间采用“叠牌”效果（overlap），像现实手牌扇形但这里先做平铺重叠：
  - 默认 overlap：每张牌露出 22pt（iPhone 13/14/15 基准）
  - 当牌数 <= 8：露出 28pt
  - 当牌数 >= 14：露出 16pt
  - 计算公式：reveal = clamp(16, 28, availableWidth / max(8, cardCount) * 0.9)

## 1.3 牌面尺寸（像纸牌）
- 牌宽高比固定：宽:高 = 2.5:3.5（标准扑克牌比例）
- 基准高度：160pt（小屏自动缩放到 140pt，下限 128pt）
- 圆角：12pt
- 边框：1pt（浅灰）
- 阴影：极轻（可用系统默认 shadow，radius 2, y 1），不要“漂浮感”

---

# 2. CardView（视觉规范：真实、克制）
## 2.1 牌面元素
- 白底
- 左上角：点数 + 花色（小）
- 右下角：点数 + 花色（小，旋转 180° 或镜像）
- 中央：花色大图标（♠ ♥ ♦ ♣），不做插画，不做渐变
- 文字字体：
  - 点数：系统 serif 或 rounded 都可，但要像纸牌印刷，建议使用 `.system(.title3, design: .serif)` 或 `.system(.headline, design: .serif)`
  - 花色符号：直接用 SF Symbol 或 Unicode 符号（优先 Unicode）
- 红桃/方块为红色，黑桃/梅花为黑色（使用系统 semantic：.red / .primary）

## 2.2 选中态（必须非常克制）
- 选中时：牌向上“抬起” 18pt（offset y = -18）
- 选中时：边框加深（或加 2pt 的描边），不要发光
- 选中时：阴影略增强一点点（radius +1）
- 不要缩放动画，不要弹簧效果

---

# 3. 交互规范（关键）
## 3.1 点选与多选
- 点击一张牌：切换选中状态
- 支持多选（用于一次出多张牌）
- 多选时，选中的牌都抬起 18pt
- 点击空白区域：清空选择（可选，但建议实现）

## 3.2 上滑出牌（防误触）
- 仅当“至少选中 1 张牌”时，上滑才有效
- 上滑判定必须严格：
  - 对“选中牌组区域”进行 DragGesture
  - 满足以下才触发出牌：
    - 垂直位移 dy <= -80pt（向上拖至少 80pt）
    - 且水平位移 |dx| <= 60pt（避免左右滑动误触）
    - 且结束速度 predictedEndTranslation.height <= -120pt（快速上滑也算）
- 触发出牌时：
  - 立即调用 `onPlaySelected(cardIDs: [String])`
  - 立即清空本地 selection（让 UI 回到未选中）
- 不要做飞出动画；最多做 0.12s 的淡出（可选），但默认不做

## 3.3 下滑取消选择（更轻）
- 如果用户对选中牌组向下拖：
  - dy >= 60pt 时：清空选择
- 这条优先级低于上滑出牌（先判断上滑）

## 3.4 长按
- 不实现长按菜单（避免游戏感）
- 可选：长按仅用于“临时放大预览”：
  - 按住放大到 1.08 倍，松手恢复
  - 这一步可以先不做，除非很简单

---

# 4. 手势冲突处理（必须处理好）
- 手牌列表允许水平滚动（ScrollView horizontal）
- 上下拖手势用于出牌/取消，会与横向滚动冲突
- 解决策略：
  1) 手牌容器使用 `.simultaneousGesture` 或 `.highPriorityGesture` 对纵向 drag 优先
  2) 仅当纵向位移超过 12pt 时，锁定为“纵向手势”，否则让横向滚动继续
- 要实现一个手势方向锁：
  - 初始 0~12pt 内不判定
  - 超过阈值后判断 abs(dy) > abs(dx) 则为纵向，否则横向

---

# 5. 可用性与可读性细节
- 手牌底部增加一个极简提示条（仅在没有选牌时显示）：
  - “点选牌，上滑出牌”
- 当有选牌时提示条变为：
  - “上滑出牌 · 下滑取消（N）”
- 提示条字体小、灰色、无背景或轻微毛玻璃（不要像游戏 UI）

---

# 6. 代码结构要求（必须）
请实现以下文件（或等价组织）：

- Views/HandView.swift
- Views/CardView.swift
- Views/HandCarouselView.swift（负责 overlap 布局 + 选择）
- Views/HandHintBar.swift（提示条）
- (可选) Utilities/Clamp.swift 或 helper

HandView 需要：
- 输入：`hand: [Card]`
- 输出回调：`onPlaySelected: ([String]) -> Void`
- 支持外部更新手牌时，自动清理不存在的 selection（防止同步后选中失效）

---

# 7. 性能与状态
- selection 用 `Set<Card.ID>` 存
- 布局计算要避免 O(n^2)
- CardView 尽量纯 view，不要在 body 里做重计算
- 使用 `EquatableView` 或 `.equatable()`（可选）优化

---

# 8. 交付标准
- 编译通过
- iPhone 模拟器能跑
- 手牌 5~20 张都不会挤爆、不会超出屏幕
- 上滑出牌几乎不会误触
- 视觉非常克制，像“纸牌”，不像游戏

现在开始实现，直接给出完整代码文件内容（逐个文件输出）。
