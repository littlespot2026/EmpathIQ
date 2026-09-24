import '../localization/app_locale.dart';
import '../models/dilemma_model.dart';

class DilemmaSeed {
  static List<DilemmaModel> get dilemmas => getCurrentDilemmas();

  static List<DilemmaModel> getCurrentDilemmas([String? langCode]) {
    final code = langCode ?? AppLocale.instance.currentCode;
    if (code == 'zh') {
      return _zhDilemmas;
    }
    return _enDilemmas;
  }

  static final List<DilemmaModel> _enDilemmas = [
    DilemmaModel(
      id: 'dilemma_01',
      title: "Partner's Silent Code: 'Whatever, Suit Yourself'",
      category: 'Partner / Intimate',
      scenario:
          'On Friday night, you suggest grabbing hotpot, but your partner previously hinted at wanting a quiet movie night. After a silent pause, they reply coldly:',
      spokenText: '“Whatever, suit yourself. As long as you are happy.”',
      contextDescription:
          'Goal: Spot the feeling of neglect masked by passive-aggressive agreement. Don’t appease blindly, and don’t escalate into cold warfare.',
      passRatePercent: 34,
      options: [
        DilemmaOption(
          id: 'opt_1',
          text: '“Awesome! Then I’ll book the hotpot table right away!”',
          isOptimal: false,
          score: 10,
          feedback:
              '【Triggered Trap】 Taking it literally will trigger an explosive cold war or door slamming.',
          mechanism:
              'Completely ignores their hurt and subtle plea for consideration, signaling "your feelings don’t matter to me."',
        ),
        DilemmaOption(
          id: 'opt_2',
          text:
              '“Why are you being so passive-aggressive again? Can’t you just say what you want?”',
          isOptimal: false,
          score: 25,
          feedback:
              '【Escalating Conflict】 Criticizing their communication style pushes them into defensive hostility: "I am fine! Do whatever you want!"',
          mechanism:
              'Lecturing them when they already feel unheard forces them to escalate anger to protect wounded self-esteem.',
        ),
        DilemmaOption(
          id: 'opt_3',
          text:
              '“I can sense you’re not really thrilled. Tonight only counts if we both enjoy it. What did you really feel like doing?”',
          isOptimal: true,
          score: 95,
          feedback:
              '【Masterful De-escalation】 Accurately identifies non-verbal subtext, turning "my way" into "our shared joy".',
          mechanism:
              'Actively restores decision balance and gives them safe emotional space to express their true desires.',
        ),
        DilemmaOption(
          id: 'opt_4',
          text: '“Fine, let’s just not eat then, so you don’t get upset.”',
          isOptimal: false,
          score: 30,
          feedback:
              '【Sulking Standoff】 Sulky counter-passive-aggression drops the room climate below freezing.',
          mechanism:
              'Shifts guilt via victim posturing—a destructive low-EQ emotional counterattack.',
        ),
      ],
    ),
    DilemmaModel(
      id: 'dilemma_02',
      title: "Manager's Subtle Disclaimer: 'If You Think It Is Fine, Go Ahead'",
      category: 'Workplace / Upward Management',
      scenario:
          'You present a rush operations proposal to the director. They scan through it casually and remark with a flat tone:',
      spokenText: '“If you think it’s fine, go ahead with your approach.”',
      contextDescription:
          'Goal: Discern whether leadership is delegating authority or disclaiming liability for foreseeable risks.',
      passRatePercent: 28,
      options: [
        DilemmaOption(
          id: 'opt_1',
          text: '“Got it! I will instruct all teams to roll this out immediately!”',
          isOptimal: false,
          score: 15,
          feedback:
              '【High-Risk Misread】 Mistaking an avoidance disclaimer for genuine praise; you will own 100% of any failure.',
          mechanism:
              'Lacks upward alignment. Managers use this phrase when skeptical to avoid signing off on unvetted risk.',
        ),
        DilemmaOption(
          id: 'opt_2',
          text:
              '“Director, regarding the Section 2 conversion forecast, I’ve prepared two risk-hedging alternatives. Could I get 2 minutes of your guidance to align?”',
          isOptimal: true,
          score: 98,
          feedback:
              '【High-EQ Upward Management】 Refocuses on core risks with concrete options, turning ambiguous pressure into collaborative alignment.',
          mechanism:
              'Replaces open-ended doubt with structured choices, honoring managerial authority while sharing risk ownership.',
        ),
        DilemmaOption(
          id: 'opt_3',
          text: '“Do you feel this won’t work? In that case I will start over from scratch.”',
          isOptimal: false,
          score: 40,
          feedback:
              '【Fragile Professionalism】 Prematurely discarding your own work displays lack of confidence and resilience.',
          mechanism:
              'Unsubstantiated self-doubt wastes time and destroys managerial confidence in your autonomy.',
        ),
      ],
    ),
  ];

  static final List<DilemmaModel> _zhDilemmas = [
    DilemmaModel(
      id: 'dilemma_01',
      title: '伴侣的冷战暗号：【随你便吧】',
      category: '伴侣亲密关系',
      scenario: '周五晚上你提议去吃火锅，但伴侣此前暗示过更想看电影，沉默几秒后，对方冷冷回复：',
      spokenText: '“随你便吧，你高兴就好。”',
      contextDescription: '通关目标：识别被动攻击背后的被忽略感，既不妥协式讨好，也不掉入冷战对峙。',
      passRatePercent: 34,
      options: [
        DilemmaOption(
          id: 'opt_1',
          text: '“太好了！那我赶紧订火锅位置去！”',
          isOptimal: false,
          score: 10,
          feedback: '【直接踩雷】按字面意思理解，将直接引发全面冷战或摔门离去。',
          mechanism: '完全无视对方的不满与妥协姿态，向对方传达“我不在乎你的心情”的致命信号。',
        ),
        DilemmaOption(
          id: 'opt_2',
          text: '“你怎么又阴阳怪气的？有什么想法不能直说吗？”',
          isOptimal: false,
          score: 25,
          feedback: '【激化冲突】批评对方沟通模式，导致对方开启防御性反击：“我哪有？随你还不成？”',
          mechanism: '在对方已经感到无力时进行道德指责，迫使对方升级愤怒来保护受挫的自尊。',
        ),
        DilemmaOption(
          id: 'opt_3',
          text: '“我听出你其实有点勉强。只有我们俩都享受今晚才有意义，我其实更想听听你真正想怎么过？”',
          isOptimal: true,
          score: 95,
          feedback: '【完美破局】敏锐捕捉非言语情绪，将“我的高兴”重定义为“我们俩的高兴”。',
          mechanism: '主动把决策天平收回，赋予对方被尊重的发言权，彻底化解委屈与被动退缩。',
        ),
        DilemmaOption(
          id: 'opt_4',
          text: '“那算了，我不吃了，省得你生气。”',
          isOptimal: false,
          score: 30,
          feedback: '【赌气互耗】以退为进的赌气操作，让氛围彻底降至冰点。',
          mechanism: '通过受害者姿态转嫁负罪感，属于典型的低情商情绪反向施压。',
        ),
      ],
    ),
    DilemmaModel(
      id: 'dilemma_02',
      title: '职场领导的隐晦施压：【你觉得没问题就行】',
      category: '职场/向上管理',
      scenario: '你向总监汇报了一份刚赶出的运营方案，领导草草扫了一眼，语气平淡地说：',
      spokenText: '“你觉得没问题就行，按你的来吧。”',
      contextDescription: '通关目标：分辨领导是真正放权还是隐性否定+推卸风险，避免贸然推进背锅。',
      passRatePercent: 28,
      options: [
        DilemmaOption(
          id: 'opt_1',
          text: '“好嘞领导，那我立刻通知各组全力推行！”',
          isOptimal: false,
          score: 15,
          feedback: '【高危误读】将免责托词当成绝对赞赏，一旦出问题将承担全部责任。',
          mechanism: '缺乏向上对齐机制，领导通常在不看好或未深思时使用此话术规避背书。',
        ),
        DilemmaOption(
          id: 'opt_2',
          text: '“领导，您看这里面第2节转化率预期，我还有两个备选方案没底，想占用您两分钟帮我指点下关键风险点。”',
          isOptimal: true,
          score: 98,
          feedback: '【高段位向上管理】主动聚焦核心风险，给领导具体切入抓手，把模糊压力具象化。',
          mechanism: '将开放式质疑降维为具体选择题，既尊重领导的权威，又锁定了共同把关的共识。',
        ),
        DilemmaOption(
          id: 'opt_3',
          text: '“领导您是不是觉得不行？那我回去重写一份。”',
          isOptimal: false,
          score: 40,
          feedback: '【缺乏职业韧性】过早放弃已有工作成果，显得缺乏专业自信与主见。',
          mechanism: '盲目自我怀疑不仅消耗时间成本，还会让管理者对你的独立推进能力失去信心。',
        ),
      ],
    ),
  ];
}
