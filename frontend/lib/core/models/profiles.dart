class Profiles{
  final String id;
  final String fullName;
  final String role;
  final String unitNumber;
  final String phoneNumber;
  final String email;

  Profiles({
    required this.id,
    required this.fullName,
    required this.role,
    required this.unitNumber,
    required this.phoneNumber,
    required this.email
  });

 factory Profiles.fromJson(Map<String, dynamic> json){
   return Profiles(
     id: json['id'] ?? '',
     fullName: json['full_name'] ?? '',
     role: json['role'] ?? '',
     unitNumber: json['unit_number'] ?? '',
     phoneNumber: json['phone'] ?? '',
       email: json['email'] ?? ''
   );
 }

  Map<String,dynamic> toJson(){
    return {
      'id':id,
      'full_name':fullName,
      'role':role,
      'unit_number':unitNumber,
      'phone':phoneNumber,
      'email':email
    };
  }

}

