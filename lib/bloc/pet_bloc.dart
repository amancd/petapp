import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petapp/bloc/pet_events.dart';
import 'package:petapp/services/pet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_model.dart';

abstract class PetEvent {}

class LoadPetsEvent extends PetEvent {}

class SearchPetEvent extends PetEvent {
  final String query;

  SearchPetEvent(this.query);
}

class LoadAdoptedPetsEvent extends PetEvent {
  final List<String> adoptedPetIds;

  LoadAdoptedPetsEvent({required this.adoptedPetIds, required List<Map<String, dynamic>> adoptedPets});
}


class AdoptPetEvent extends PetEvent {
  final Pet pet;
  final PetRepository petRepository;

  AdoptPetEvent(this.pet, this.petRepository);
}


abstract class PetState {}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<Pet> petList;
  final List<Pet> adoptedPets;
  final int currentPage; 

  PetLoaded(this.petList, {required this.currentPage, List<Pet>? adoptedPets})
      : adoptedPets = adoptedPets ?? const [];
}

class PetError extends PetState {
  final String errorMessage;

  PetError(this.errorMessage);
}


class PetBloc extends Bloc<PetEvent, PetState> {
  final PetRepository petRepository;

  PetBloc(this.petRepository) : super(PetLoading()) {
    on<LoadPetsEvent>(_handleLoadPetsEvent);
    on<SearchPetEvent>(_handleSearchPetEvent);
    on<AdoptPetEvent>(_handleAdoptPetEvent);
    on<ChangePageEvent>(_handleChangePageEvent);
    on<LoadAdoptedPetsEvent>(_handleLoadAdoptedPetsEvent);
  }

  void _handleLoadPetsEvent(LoadPetsEvent event, Emitter<PetState> emit) async {
    try {
      emit(PetLoading());
      final petList = await petRepository.fetchPets();
      emit(PetLoaded(petList, currentPage: 0));
    } catch (e) {
      emit(PetError('Failed to fetch pets. Error: $e'));
    }
  }

  void _handleSearchPetEvent(SearchPetEvent event, Emitter<PetState> emit) async {
    try {
      emit(PetLoading());
      final searchResult = await petRepository.searchPets(event.query);
      emit(PetLoaded(searchResult, currentPage: 0));
    } catch (e) {
      emit(PetError('Failed to search pets. Error: $e'));
    }
  }

  void _handleLoadAdoptedPetsEvent(LoadAdoptedPetsEvent event, Emitter<PetState> emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      List<Pet> adoptedPets = [];

      for (String petId in event.adoptedPetIds) {
        String jsonData = prefs.getString('pet_$petId') ?? '{}';
        Map<String, dynamic> jsonMap = json.decode(jsonData);
        adoptedPets.add(Pet.fromJson(jsonMap));
      }

      emit(PetLoaded(
        (state as PetLoaded).petList,
        currentPage: (state as PetLoaded).currentPage,
        adoptedPets: adoptedPets,
      ));
    } catch (e) {
      emit(PetError('Failed to load adopted pets. Error: $e'));
    }
  }



  void _handleAdoptPetEvent(AdoptPetEvent event, Emitter<PetState> emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      
      await prefs.setString('pet_${event.pet.id}', json.encode(event.pet.toJson()));

      emit(PetLoaded(
        (state as PetLoaded).petList,
        currentPage: (state as PetLoaded).currentPage,
        adoptedPets: (state as PetLoaded).adoptedPets + [event.pet],
      ));
    } catch (e) {
      emit(PetError('Failed to adopt pet. Error: $e'));
    }
  }


  void _handleChangePageEvent(ChangePageEvent event, Emitter<PetState> emit) {
    emit(PetLoaded((state as PetLoaded).petList, currentPage: event.page));
  }
}
