import '../localization/app_locale.dart';

class LegalConstants {
  static String getPrivacyPolicy([String? langCode]) {
    final code = langCode ?? AppLocale.instance.currentCode;
    return code == 'zh' ? privacyPolicyZh : privacyPolicyEn;
  }

  static String getDisclaimer([String? langCode]) {
    final code = langCode ?? AppLocale.instance.currentCode;
    return code == 'zh' ? disclaimerZh : disclaimerEn;
  }

  static String getTermsOfUse([String? langCode]) {
    final code = langCode ?? AppLocale.instance.currentCode;
    return code == 'zh' ? termsOfUseZh : termsOfUseEn;
  }

  // -------------------------------------------------------------
  // 1. 隐私政策 (Privacy Policy)
  // -------------------------------------------------------------
  static const String privacyPolicyZh = '''
# EmpathIQ 用户隐私保护政策
**生效日期：2026年9月**

欢迎使用 EmpathIQ（“我们”或“本产品”）。我们深知人际沟通记录与私密心理对话的高度敏感性，将用户数据安全与隐私防护置于最高优先级。

### 1. 数据采集与最小化原则
- **免账号纯净探索**：您无需注册手机号或绑定实名身份即可使用本产品的核心功能（游客身份完全可用）。
- **零追踪 SDK**：本产品绝不集成任何第三方广告打点、行为追踪或商业画像 SDK。

### 2. 对话文本与聊天长截图的内存生命周期
- **纯内存即时流转**：当您在输入框输入文本或上传聊天截图时，数据仅通过强加密的 TLS 1.3 通道传输至无状态服务节点进行实时语义推理。
- **无持久化存储承诺**：我们**绝不**将您的私密聊天截图或文字保存至任何云端数据库或物理磁盘；推理任务一旦结束，所有内存图片与 Base64 缓存立即从服务器内存彻底释放并销毁。
- **零 AI 训练承诺**：您的所有输入数据绝不会被用于 Google Gemini、OpenAI 或任何开源大语言模型的二次训练或调优。

### 3. 本地设备持久化存储 (Local-Only)
- 您的每日扫描额度打卡记录、最近 10 条解码历史、自定义 API 密钥仅加密保存在您当前设备本地（通过 SharedPreferences / LocalStorage）。
- 您随时可以在设置面板中一键重置或清空所有本地解码历史。

### 4. 设备权限调用说明
- **相册/文件选择权限**：仅在您主动点击“📷 上传聊天截图”时向系统请求授权读取所选文件，绝不扫描或上传您设备相册中的其他无关照片。
- **剪贴板读取**：仅在应用切回前台时探测剪贴板是否存在短文本，供您便捷一键粘贴，绝不上传剪贴板历史。

### 5. 用户权利与注销
您拥有完全的数据自主权。如需彻底清除本地所有痕迹，只需卸载本应用或在系统应用管理中点击“清除缓存与数据”，所有本地记录即刻物理抹除。
''';

  static const String privacyPolicyEn = '''
# EmpathIQ Privacy Policy
**Effective Date: September 2026**

Welcome to EmpathIQ ("we", "us", or "our"). We deeply respect the personal and confidential nature of your interpersonal conversations and emotional disclosures. Protecting your data privacy is our highest commitment.

### 1. Data Minimization & Pure Exploration
- **Guest Access by Default**: You are not required to provide sensitive personal credentials or real-name identification to use the core subtext decoder.
- **Zero Ad Trackers**: We do not embed behavioral advertising SDKs, profiling tools, or third-party data brokers.

### 2. In-Memory Processing of Chat Text & Screenshots
- **Stateless Ephemeral Pipeline**: When you enter conversation snippets or upload chat screenshots, data is transmitted strictly over encrypted TLS 1.3 to our stateless serverless proxy solely to generate psychological inferences.
- **No Cloud Storage Guarantee**: Your uploaded screenshots and conversational subtexts are **never stored** on permanent cloud disks or persistent databases. As soon as the analysis completes, all temporary in-memory buffers and Base64 payloads are completely purged.
- **Zero AI Training Guarantee**: Your sensitive inputs are **never utilized** to train, fine-tune, or reinforce Google Gemini, OpenAI, or any foundation models.

### 3. Local-Only Storage
- Your settings, custom API keys, daily quotas, and the 10 most recent cached decodes reside strictly on your local device hardware via SharedPreferences.
- You can wipe your cached history and custom credentials at any time directly within the Settings panel.

### 4. Device Permissions
- **Photo Library / File Access**: Requested only when you intentionally select "Upload Chat Screenshot". We never scan, index, or access unrelated media on your device.
- **Clipboard Access**: Used exclusively to detect active text snippets for convenient one-tap pasting. No clipboard history is ever logged or transmitted.

### 5. User Rights & Data Deletion
You retain absolute control over your digital footprint. Simply clearing the app's cache or uninstalling EmpathIQ will immediately erase all locally stored data.
''';

  // -------------------------------------------------------------
  // 2. 法律与心理健康免责声明 (Legal & Psychological Disclaimer)
  // -------------------------------------------------------------
  static const String disclaimerZh = '''
# EmpathIQ 心理健康与法律免责声明
**重要须知：使用本产品即代表您已充分阅读并同意本免责协议**

### 1. 非临床医疗与非执业咨询声明
- EmpathIQ 是一款基于认知心理学、非暴力沟通（NVC）理论与自然语言处理模型的“社交情商模拟与自我反思辅助工具”。
- **本产品绝不提供任何执业心理咨询、精神医学诊断、心理危机干预、临床处方建议或法律/婚姻家庭调解裁决**。本产品输出的所有内容不能替代持牌精神科医生、注册心理咨询师或专业律师的正式当面意见。

### 2. 算法输出的或然性与用户完全自主责任
- 潜台词透视、情绪温度数值、心防百分比及三种破局应对策略（稳妥共情、幽默破冰、温和界限）均为 AI 算法基于概率推演出的假设性分析，并非客观事实或确凿证据。
- **用户对自身言行承担 100% 完全法律责任**：在现实生活中是否采纳、发送 AI 推荐的任何话术策略，均由用户完全自主决定并独立承担一切人际沟通后果、人际关系破裂、职场人事纠纷或衍生心理波动。EmpathIQ 及其开发运营团队不对用户的任何现实行为后果承担任何直接或连带法律责任。

### 3. 紧急心理援助与自杀/危机干预提示
**EmpathIQ 绝非紧急生命救援或危机救助系统！**
如果您、您的对话对象或身边任何人正在经历极度的心理崩溃、自残冲动、自杀意念、家庭暴力或人身威胁，**请立即停止使用本软件，并立刻寻求外部专业紧急求助**：
- 🇨🇳 **中国大陆紧急救援**：
  - 报警电话：`110` / 医疗急救：`120`
  - 全国希望24小时心理危机干预热线：`400-161-9995`
  - 北京市心理援助热线：`010-82951332`
- 🇺🇸 **北美危机热线 (US & Canada)**：
  - Emergency Call: `911`
  - Suicide & Crisis Lifeline: Call or Text `988`
  - Crisis Text Line: Text `HOME` to `741741`
- 🌐 **其他国家/地区**：请即刻拨打所在地的法定报警急救电话或前往最近的公立综合医院急诊科。
''';

  static const String disclaimerEn = '''
# EmpathIQ Psychological & Legal Disclaimer
**Important Notice: By using this application, you acknowledge and accept all terms of this disclaimer.**

### 1. Non-Clinical & Non-Therapeutic Nature
- EmpathIQ is an educational communication reflection tool powered by cognitive psychology, Nonviolent Communication (NVC) frameworks, and AI linguistic models.
- **EmpathIQ does NOT provide licensed psychological therapy, clinical mental health diagnosis, medical intervention, psychiatric treatment, or legal/marital counsel**. It is not a substitute for professional in-person medical evaluation, therapy, or legal representation.

### 2. Algorithmic Inferences & Sole User Liability
- Subtext breakdowns, emotional temperatures, defense guard percentages, and tactical response strategies (Empathy, Humor, Boundary) represent automated algorithmic hypotheses, not definitive facts.
- **You retain 100% responsibility for your actions**: Deciding whether to adopt, adapt, or send any proposed replies in your real-world relationships is solely at your own discretion and risk. EmpathIQ and its creators disclaim all liability for any relationship disputes, emotional distress, employment conflicts, or legal damages arising from your communication choices.

### 3. Crisis Hotline & Emergency Interventions
**EmpathIQ is NOT an emergency response service!**
If you, your partner, or someone you know is in acute psychological crisis, experiencing suicidal thoughts, self-harm impulses, domestic abuse, or physical danger, **please immediately cease using this application and contact emergency services**:
- 🇺🇸 / 🇨🇦 **United States & Canada**:
  - Emergency: `911`
  - Suicide & Crisis Lifeline: Dial or Text `988`
  - Crisis Text Line: Text `HOME` to `741741`
- 🇬🇧 **United Kingdom**:
  - Emergency: `999`
  - Samaritans Helpline: `116 123`
- 🇦🇺 **Australia**:
  - Emergency: `000`
  - Lifeline: `13 11 14`
- 🌐 **Global**: Contact your local emergency medical provider or report to the nearest hospital emergency department immediately.
''';

  // -------------------------------------------------------------
  // 3. 使用条款与订阅协议 (Terms of Use / EULA)
  // -------------------------------------------------------------
  static const String termsOfUseZh = '''
# EmpathIQ 最终用户许可协议 (EULA) 与订阅服务条款
**生效日期：2026年9月**

### 1. 协议接受与许可范围
下载或使用 EmpathIQ 即表示您同意受本协议约束。我们授予您一项个人的、非排他性的、不可转让的、可撤销的有限许可，仅供您个人非商业性使用。

### 2. Pro 订阅与计费政策
- **订阅类型**：我们提供连续按年（Yearly）、按月（Monthly）、按周（Weekly，可含3天免费试用）以及应急 10 次点卡包（One-Time Pack）。
- **自动续费规则**：根据 Apple App Store 与 Google Play 平台规范，订阅将在当前计费周期结束前 24 小时内自动向您的平台账户扣费续期，除非您在周期结束前至少提前 24 小时关闭自动续订。
- **试用期说明**：免费试用期（如提供）未用部分将在您购买对应订阅时立即失效。
- **取消与退款**：您随时可以在 Apple ID 设置或 Google Play “付款与订阅”中心管理并取消订阅。退款事宜均遵循对应应用商店的官方退款政策处理。

### 3. 公平使用与服务可用性
- 免费用户享受每日 3 次免费解码额度（于每日午夜 00:00 自动刷新）。
- 严禁通过自动化逆向工程、爬虫脚本或攻击性滥用行为访问本服务，违者我们将保留限制其本地设备访问或阻断 IP 的权利。
''';

  static const String termsOfUseEn = '''
# EmpathIQ Terms of Use (EULA) & Subscription Terms
**Effective Date: September 2026**

### 1. Acceptance of Terms & License
By downloading or using EmpathIQ, you agree to be bound by this End User License Agreement. We grant you a personal, revocable, non-exclusive, non-transferable limited license for personal, non-commercial use.

### 2. Pro Subscriptions & Auto-Renewal Policy
- **Billing Cycles**: We offer Auto-Renewable Yearly, Monthly, and Weekly (with optional 3-day trial) subscriptions, as well as an emergency 10-Scan One-Time Pack.
- **Auto-Renewal**: Payment will be charged to your Apple ID / Google Play Account at confirmation of purchase. Subscriptions automatically renew unless cancelled in Account Settings at least 24 hours before the end of the current billing cycle.
- **Trial Periods**: Any unused portion of a free trial period will be forfeited when you purchase a subscription.
- **Managing & Canceling**: You can manage or turn off auto-renewal at any time in your Apple App Store or Google Play Subscriptions Center.

### 3. Fair Use & Abuse Prevention
- Free tier accounts are allocated 3 free scans per day (resetting at midnight local time).
- Reverse-engineering, automated bot traffic, or abusive exploitation of our Serverless backend is strictly prohibited.
''';
}
