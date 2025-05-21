class SubscriptionModel {
  final String id;
  final String name;
  final String description;
  final int days;
  final int price;
  final List<String> benefits;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.price,
    required this.benefits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      days: json['days'],
      price: json['price'],
      benefits: List<String>.from(json['benefits']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
