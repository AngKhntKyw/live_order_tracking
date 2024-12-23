class MyOrder {
  String id;
  String name;
  String phone;
  String address;
  double latitude;
  double longitude;
  double amount;

  MyOrder({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.amount,
  });

  factory MyOrder.fromJson(Map<String, dynamic> json) => MyOrder(
        id: json['id'] ?? "unknown",
        name: json['name'] ?? "unknown",
        phone: json['phone'] ?? "unknown",
        address: json['address'] ?? "unknown",
        latitude: json['latitude']?.toDouble() ?? 0,
        longitude: json['longitude']?.toDouble() ?? 0,
        amount: json['amount']?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'amount': amount,
      };
}
