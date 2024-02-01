import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petapp/bloc/pet_bloc.dart';
import 'package:petapp/models/pet_model.dart';
import 'package:petapp/pages/details_page.dart';
import 'package:petapp/services/pet_repository.dart';

import '../util/helper.dart';

class HistoryPetCard extends StatelessWidget {
  final Pet pet;
  final PetRepository petRepository;

  const HistoryPetCard({
    super.key,
    required this.pet,
    required this.petRepository,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> lightColors = [
      Colors.lightBlue,
      const Color(0xFFf6a530),
      const Color(0xFFf1a5a5),
      Colors.orange,
    ];

    List<Color> darkColors = [
      const Color(0xFF282828),
    ];

    ThemeData currentTheme = Theme.of(context);
    List<Color> containerColors =
    currentTheme.brightness == Brightness.light ? lightColors : darkColors;
    int petId = int.tryParse(pet.id) ?? 0;
    Color selectedColor = containerColors[petId % containerColors.length];
    Color borderColor =
    currentTheme.brightness == Brightness.light ? Colors.white : Colors.teal;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
              pet: pet,
              petRepository: petRepository,
              heroTag: 'history_${pet.id}',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: selectedColor,
            child: Center(
              child: ListTile(
                title: Text(
                  pet.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                subtitle: Text(
                  'Age: ${pet.age}   Price: \$${pet.price}',
                  style: const TextStyle(color: Colors.white),
                ),
                leading: Hero(
                  tag: 'history_${pet.id}', 
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: borderColor,
                        width: 6.0,
                      ),
                    ),
                    child: Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.light
            ? Colors.lightBlue
            : Colors.white,),
        title: const Text('Adopted Pets', style: TextStyle(fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<Pet>>(
        future: PetPreferences.getAdoptedPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Pet> adoptedPets = snapshot.data ?? [];
            return _buildAdoptedPetsList(adoptedPets);
          }
        },
      ),
    );
  }

  Widget _buildAdoptedPetsList(List<Pet> adoptedPets) {
    if (adoptedPets.isEmpty) {
      return const Center(child: Text('No adopted pets yet.'));
    }

    return ListView.builder(
      itemCount: adoptedPets.length,
      itemBuilder: (context, index) {
        Pet pet = adoptedPets[index];
        return HistoryPetCard(
          pet: pet,
          petRepository: context.read<PetBloc>().petRepository,
        );
      },
    );
  }
}
