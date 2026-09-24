class DilemmaOption {
  final String id;
  final String text;
  final bool isOptimal;
  final int score;
  final String feedback;
  final String mechanism;

  const DilemmaOption({
    required this.id,
    required this.text,
    required this.isOptimal,
    required this.score,
    required this.feedback,
    required this.mechanism,
  });
}

class DilemmaModel {
  final String id;
  final String title;
  final String category; // '伴侣沟通', '职场破局', '亲情界限'
  final String scenario;
  final String spokenText; // "那随你便吧，你高兴就好"
  final String contextDescription;
  final int passRatePercent; // e.g. 38%
  final List<DilemmaOption> options;

  const DilemmaModel({
    required this.id,
    required this.title,
    required this.category,
    required this.scenario,
    required this.spokenText,
    required this.contextDescription,
    required this.passRatePercent,
    required this.options,
  });
}
