class TodayCheckInResponse {
  final int checkIns;
  final int checkOuts;

  TodayCheckInResponse({
    required this.checkIns,
    required this.checkOuts,
  });

  factory TodayCheckInResponse.fromJson(Map<String, dynamic> json) {
    return TodayCheckInResponse(
      checkIns: _parseInt(json['check_ins']),
      checkOuts: _parseInt(json['check_outs']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
