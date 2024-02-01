import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_model.dart';

class PetPreferences {
  static Future<List<Pet>> getAdoptedPets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? adoptedPetsJson = prefs.getStringList('adopted_pets');

    if (adoptedPetsJson != null) {
      List<Pet> adoptedPets = [];

      for (String jsonStr in adoptedPetsJson) {
        try {
          Map<String, dynamic> petMap = json.decode(jsonStr);
          adoptedPets.add(Pet.fromJson(petMap));
        } catch (e) {
          print('Error decoding pet JSON: $e');
        }
      }

      return adoptedPets;
    } else {
      return [];
    }
  }

  static Future<void> saveAdoptedPets(List<Pet> adoptedPets) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> adoptedPetsJson = adoptedPets.map((pet) => json.encode(pet.toJson())).toList();
    await prefs.setStringList('adopted_pets', adoptedPetsJson);
  }
}
