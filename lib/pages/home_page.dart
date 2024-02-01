import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petapp/bloc/pet_bloc.dart';
import 'package:petapp/bloc/pet_events.dart';
import 'package:petapp/models/pet_model.dart';
import 'package:petapp/navigation/navigation.dart';
import 'package:petapp/pages/details_page.dart';
import 'package:petapp/services/pet_repository.dart';

class HomePage extends StatefulWidget {
  final PetRepository petRepository;
  HomePage({super.key, required this.petRepository});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => PetBloc(widget.petRepository)..add(LoadPetsEvent()),
        child: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state is PetLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PetLoaded) {
              const itemsPerPage = 4;
              final totalPages = (state.petList.length / itemsPerPage).ceil();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Pet',
                        filled: true,
            fillColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFf6f6f6)
                : const Color(0xFF282828),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            context.read<PetBloc>().add(SearchPetEvent(''));
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.clear, color: Colors.grey),
                          ),
                        ),
                      ),
                      onChanged: (query) {
                        context.read<PetBloc>().add(SearchPetEvent(query));
                      },
                    ),
                  ),
                    for (int page = 0; page < totalPages; page++)
                      if (page == state.currentPage)
                        Expanded(
                          child: ListView.builder(
                              itemCount: state.petList.length,
                              itemBuilder: (context, index) {

                                if (index >= page * itemsPerPage &&
                                    index < (page + 1) * itemsPerPage) {
                                  return PetCard(
                                    pet: state.petList[index],
                                    petRepository: widget.petRepository,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (int page = 0; page < totalPages; page++)
                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<PetBloc>()
                                          .add(ChangePageEvent(page));
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              side: const BorderSide(
                                                  color: Colors.red))),
                                      backgroundColor: MaterialStateProperty.all(
                                        page == state.currentPage
                                            ? Colors.cyan.shade800
                                            : Theme.of(context).brightness == Brightness.light
                                            ? const Color(0xFFf6f6f6)
                                            : const Color(0xFF282828),
                                      ),
                                      side: MaterialStateProperty.all(
                                        const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: Center(
                                        child: Text(
                                          '${page + 1}',
                                          style: TextStyle(
                                            color: page == state.currentPage
                                                ? Colors.white
                                                : Theme.of(context).brightness == Brightness.light
                                                ? Colors.black54
                                                : Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 12.0),
                              ],
                            ),
                          ),
                        ),
                      ],
              );
            } else if (state is PetError) {
              return Center(
                child: Text('Error: ${state.errorMessage}'),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      drawer: Navigation(),
    );
  }
}

class PetCard extends StatelessWidget {
  final Pet pet;
  final PetRepository petRepository;

  const PetCard({super.key, required this.pet, required this.petRepository});

  @override
  Widget build(BuildContext context) {
    List<Color> lightColors = [
      Colors.lightBlue,
      const Color(0xFFf6a530),
      const Color(0xFFf1a5a5),
      Colors.orange,
    ];

    List<Color> darkColors = [
      Color(0xFF282828),
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
              heroTag: 'pet_image_${pet.id}',
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
                  tag: 'pet_image_${pet.id}',
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
