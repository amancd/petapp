import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:petapp/bloc/pet_bloc.dart';
import 'package:petapp/models/pet_model.dart';
import 'package:petapp/services/pet_repository.dart';
import 'package:petapp/util/helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsPage extends StatefulWidget {
  final PetRepository petRepository;
  final Pet pet;
  final String heroTag;

  DetailsPage({required this.pet, required this.petRepository, required this.heroTag});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool adopted = false;
  ConfettiController? _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadAdoptionStatus();
  }

  Future<void> _loadAdoptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adopted = prefs.getBool('adopted_${widget.pet.id}') ?? false;
    });
  }

  Future<void> _saveAdoptionStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adopted_${widget.pet.id}', status);
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  void _showAdoptionConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Adoption Confirmation',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Text('You have successfully adopted ${widget.pet.name}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        );
      },
    );
  }

  void _onAdoptMePressed() async {
    final adoptedPets = await PetPreferences.getAdoptedPets();

    if (!adoptedPets.any((pet) => pet.id == widget.pet.id)) {
      context.read<PetBloc>().add(AdoptPetEvent(widget.pet, widget.petRepository));

      adoptedPets.add(Pet.fromJson(widget.pet.toJson()));

      await PetPreferences.saveAdoptedPets(adoptedPets);

      _showAdoptionConfirmation();
      _confettiController?.play();
      setState(() {
        adopted = true;
      });

      await _saveAdoptionStatus(true);
    }
  }


  void _openImageGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGallery.builder(
          itemCount: 1,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.pet.imageUrl),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Hero(
              tag: widget.heroTag,
              child: Image.network(
                widget.pet.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.5 - 30,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      color: brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          widget.pet.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.pet.about,
                          style: const TextStyle(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildInfoContainer('Name', widget.pet.name.split(' ')[0], Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFF1F1F1)
                                : const Color(0xFF282828),),
                            const SizedBox(width: 8),
                            _buildInfoContainer('Age', widget.pet.age.toString(), Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFF1F1F1)
                                : const Color(0xFF282828),),
                            const SizedBox(width: 8),
                            _buildInfoContainer('Category', widget.pet.name.split(' ').last, Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFF1F1F1)
                                : const Color(0xFF282828),),
                            const SizedBox(width: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoContainer('Price', '\$${widget.pet.price}', Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFF1F1F1)
                            : const Color(0xFF282828),),
                        const SizedBox(width: 8),
                        ConfettiWidget(
                          confettiController: _confettiController!,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          emissionFrequency: 0.02,
                          numberOfParticles: 20,
                          gravity: 0.1,
                          colors: const [Colors.blue, Colors.pink, Colors.yellow],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 30,
            left: 16,
            child: _buildIconButton(Icons.arrow_back, () {
              Navigator.pop(context);
            }, Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF1F1F1)
                : const Color(0xFF282828),),
          ),
          Positioned(
            top: 30,
            right: 16,
            child: _buildIconButton(Icons.zoom_in, _openImageGallery, Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF1F1F1)
                : const Color(0xFF282828),),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _onAdoptMePressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: adopted ? Colors.grey : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(adopted ? 'Already Adopted' : 'Adopt Me'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value, Color buttonColor) {
    return Container(
      color: buttonColor,
      padding: const EdgeInsets.all(12),
      child: Text('$label: $value',),
    );
  }

  Widget _buildIconButton(IconData icon, Function() onPressed, Color buttonColor) {
    return Container(
      width: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: buttonColor,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
