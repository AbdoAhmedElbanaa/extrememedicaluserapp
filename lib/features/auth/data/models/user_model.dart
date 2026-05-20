class UserModel {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? clinicName;
  final String? firstName;
  final String? lastName;
  final String? address;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.clinicName,
    this.firstName,
    this.lastName,
    this.address,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'clinicName': clinicName,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      clinicName: map['clinicName'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
