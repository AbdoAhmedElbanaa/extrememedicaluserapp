class UserDeviceModel {
  final String? deviceId;
  final String? deviceName;
  final String? deviceVersion;
  final String? endWarranty;
  final String? imageUrl;
  final String? installingDate;
  final String? ntcVer;
  final String? pcbVer;
  final String? serialNo;
  final String? ssr;
  final String? swVer;
  final String? uiVer;

  UserDeviceModel({
    this.deviceId,
    this.deviceName,
    this.deviceVersion,
    this.endWarranty,
    this.imageUrl,
    this.installingDate,
    this.ntcVer,
    this.pcbVer,
    this.serialNo,
    this.ssr,
    this.swVer,
    this.uiVer,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceVersion': deviceVersion,
      'endWarranty': endWarranty,
      'imageUrl': imageUrl,
      'installingDate': installingDate,
      'ntcVer': ntcVer,
      'pcbVer': pcbVer,
      'serialNo': serialNo,
      'ssr': ssr,
      'swVer': swVer,
      'uiVer': uiVer,
    };
  }

  factory UserDeviceModel.fromMap(Map<String, dynamic> map) {
    return UserDeviceModel(
      deviceId: map['deviceId'],
      deviceName: map['deviceName'],
      deviceVersion: map['deviceVersion'],
      endWarranty: map['endWarranty'],
      imageUrl: map['imageUrl'],
      installingDate: map['installingDate'],
      ntcVer: map['ntcVer'],
      pcbVer: map['pcbVer'],
      serialNo: map['serialNo'],
      ssr: map['ssr'],
      swVer: map['swVer'],
      uiVer: map['uiVer'],
    );
  }
}

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
  final UserDeviceModel? device;

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
    this.device,
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
      'device': device?.toMap(),
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
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      device: map['device'] != null ? UserDeviceModel.fromMap(Map<String, dynamic>.from(map['device'] as Map)) : null,
    );
  }
}
