class EnquiriesModel {
  String? sId;
  String? user;
  String? name;
  String? email;
  String? phone;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? iV;

  EnquiriesModel({
    this.sId,
    this.user,
    this.name,
    this.email,
    this.phone,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  EnquiriesModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user'] = user;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
} 