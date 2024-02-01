import 'package:flutter/material.dart';
import 'package:petapp/constants/constants.dart';
import 'package:petapp/pages/history_page.dart';
import 'package:petapp/pages/home_page.dart';
import 'package:petapp/services/pet_repository.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/theme.dart';

class Navigation extends StatelessWidget {
  Navigation({Key? key}) : super(key: key);

  final PetRepository petRepository = PetRepository();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildHeader(context, Theme.of(context).brightness == Brightness.light
                  ? Colors.cyan.shade700
                  : Colors.black26,),
              buildMenuItems(context, petRepository, Theme.of(context).brightness == Brightness.light
                  ? flightcolor
                  : fdarkcolor,),
            ],
          ),
        ));
  }
}

Widget buildHeader(BuildContext context, Color bgcolor) {
  return Material(
    child: InkWell(
      child: Container(
        color: bgcolor,
        padding: EdgeInsets.only(
          top: 15 + MediaQuery
              .of(context)
              .padding
              .top,
          bottom: 20,),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,  // Set the color of the border
                  width: 6.0,           // Set the width of the border
                ),
              ),
              child: const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage("assets/logo.jpg"),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Pet App',
              style: TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20,),
            const Center(
              child: Text(
                "\"Adopt A Pet! 🐶\"",
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    ),
  );
}


Widget buildMenuItems(BuildContext context, petRepository, Color fcolor) {
  return Container(
    padding: const EdgeInsets.only(top: 30, right: 20, left: 30, bottom: 20),
    child: Wrap(
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ListTile(
          leading: Icon(Icons.home, color: fcolor),
          title: Text("Home", style: TextStyle(color: fcolor)),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomePage(petRepository: petRepository)),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.history, color: fcolor),
          title: Text("History",
              style: TextStyle(color: fcolor)),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HistoryPage()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.sunny, color: fcolor),
          title: Text("Theme", style: TextStyle(color: fcolor)),
          onTap: () {
            // Open a bottom sheet or dialog with theme options
            _showThemeOptions(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.share, color: fcolor),
          title: Text("Share", style: TextStyle(color: fcolor)),
          onTap: () {
            _shareResult();
          },
        ),
      ],
    ),
  );
}

void _showThemeOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text("Light Theme"),
              onTap: () {
                _toggleTheme(context, lightTheme);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text("Dark Theme"),
              onTap: () {
                _toggleTheme(context, darkTheme);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _toggleTheme(BuildContext context, ThemeData newTheme) {
  final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
  themeNotifier.updateTheme(newTheme);
  Navigator.of(context).pop();
}


void _shareResult() {
  String playStoreLink = 'https://play.google.com/store/apps/details?id=com.atomdyno.petapp';
  String message = 'Download Pet App on Play Store: $playStoreLink';

  Share.share(message);
}

