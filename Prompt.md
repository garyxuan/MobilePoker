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
