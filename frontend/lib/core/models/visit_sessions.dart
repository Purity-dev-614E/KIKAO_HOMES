class VisitSessions {
  final String id;
  final String VisitorName;
  final String visitorPhone;
  final String NationalID;
  final String unitNumber;
  final String status;
  final String SecurityId;
  final String? checkInTime;
  final String? checkOutTime;

  VisitSessions({
    required this.id,
    required this.VisitorName,
    required this.visitorPhone,
    required this.NationalID,
    required this.unitNumber,
    required this.status,
    required this.SecurityId,
    this.checkInTime,
    this.checkOutTime,
  });

  factory VisitSessions.fromJson(Map<String, dynamic> json) {
    return VisitSessions(
      id: json['id'],
      VisitorName: json['visitor_name'],
      visitorPhone: json['visitor_phone'],
      NationalID: json['national_id'],
      unitNumber: json['unit_number'],
      status: json['status'],
      SecurityId:json['security_id'],
      checkInTime: json['check_in_at'],
      checkOutTime: json['check_out_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor_name': VisitorName,
      'visitor_phone': visitorPhone,
      'national_id': NationalID,
      'unit_number': unitNumber,
      'status': status,
      'security_id':SecurityId,
      'check_in_at': checkInTime,
      'check_out_at': checkOutTime,
    };
  }
}