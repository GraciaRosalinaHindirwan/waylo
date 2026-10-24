class AiRecommendation {
  final int destinationId;
  final String reason;

  AiRecommendation({
    required this.destinationId,
    required this.reason,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      destinationId: json['id'] as int,
      reason: json['reason'] as String,
    );
  }
}