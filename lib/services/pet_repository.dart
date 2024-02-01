import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/pet_model.dart';

class PetRepository {
  Future<List<Pet>> fetchPets() async {
    try {
      String jsonData = await rootBundle.loadString('assets/pets_data.json');
      final List<dynamic> jsonList = json.decode(jsonData);
      final List<Pet> petList = jsonList.map((json) => Pet.fromJson(json)).toList();
      return petList;
    } catch (e) {
      throw Exception('Failed to fetch pets. Error: $e');
    }
  }

  Future<List<Pet>> searchPets(String query) async {
    try {
      String jsonData = await rootBundle.loadString('assets/pets_data.json');
      final List<dynamic> jsonList = json.decode(jsonData);
      final List<Pet> searchResult = jsonList
          .where((pet) => pet['name'].toLowerCase().contains(query.toLowerCase()))
          .map((json) => Pet.fromJson(json))
          .toList();
      return searchResult;
    } catch (e) {
      throw Exception('Failed to search pets. Error: $e');
    }
  }

  Future<List<Pet>> fetchAdoptedPets(List<String> adoptedPetIds) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Pet> adoptedPets = [];

      for (String petId in adoptedPetIds) {
        String jsonData = prefs.getString('pet_$petId') ?? '{}';
        Map<String, dynamic> jsonMap = json.decode(jsonData);
        adoptedPets.add(Pet.fromJson(jsonMap));
      }

      return adoptedPets;
    } catch (e) {
      throw Exception('Failed to fetch adopted pets. Error: $e');
    }
  }


  Future<void> updatePet(Pet updatedPet) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String petId = updatedPet.id;
      bool isAdopted = prefs.getBool('adopted_$petId') ?? false;

      if (isAdopted) {
        
      } else {
        throw Exception('Pet with id $petId is not adopted.');
      }
    } catch (e) {
      throw Exception('Failed to update pet. Error: $e');
    }
  }


  Future<void> updatePetAdoptionStatus(String petId, bool isAdopted) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('adopted_$petId', isAdopted);
    } catch (e) {
      throw Exception('Failed to update pet adoption status. Error: $e');
    }
  }
}
