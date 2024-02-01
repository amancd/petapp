import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  final String id;
  final String name;
  final int age;
  final double price;
  final String imageUrl;
  final String about;
  bool isAdopted;

  Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.price,
    required this.imageUrl,
    required this.about,
    this.isAdopted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'price': price,
      'imageUrl': imageUrl,
      'about': about,
      'isAdopted': isAdopted,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      price: json['price'] ?? 0.0,
      about: json['about'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isAdopted: json['isAdopted'] ?? false,
    );
  }


  @override
  List<Object?> get props => [id, name, age, price, about, imageUrl, isAdopted];

  Pet copyWith({bool? isAdopted}) {
    return Pet(
      id: id,
      name: name,
      age: age,
      price: price,
      about: about,
      imageUrl: imageUrl,
      isAdopted: isAdopted ?? this.isAdopted,
    );
  }
}
