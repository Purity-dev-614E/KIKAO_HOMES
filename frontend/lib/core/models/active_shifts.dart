class ActiveShifts {
  final String id;
  final String securityId;


  ActiveShifts({
    required this.id,
    required this.securityId,
  });
  factory ActiveShifts.fromJson(Map<String, dynamic> json) {
    return ActiveShifts(
      id: json['id'],
      securityId: json['security_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'security_id': securityId,
    };
  }
}