class CafeModel {
  final String id;
  final String name;
  final String address;
  final String whatsapp;
  final String wifiName;
  final String wifiPassword;

  CafeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.whatsapp,
    required this.wifiName,
    required this.wifiPassword,
  });

  factory CafeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CafeModel(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      wifiName: data['wifi_name'] ?? '',
      wifiPassword: data['wifi_password'] ?? '',
    );
  }
}