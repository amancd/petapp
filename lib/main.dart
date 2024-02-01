import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petapp/pages/home_page.dart';
import 'package:petapp/services/pet_repository.dart';
import 'package:petapp/theme/theme.dart';
import 'package:provider/provider.dart';

import 'bloc/pet_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration.zero);
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeNotifier(),
    child: MyApp(),
  ),);
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final PetRepository petRepository = PetRepository();
    return MultiBlocProvider(providers: [
        BlocProvider(
        create: (context) => PetBloc(petRepository)..add(LoadPetsEvent()),
    ),
    ], child: MaterialApp(
      title: 'Home Page',
      theme: Provider.of<ThemeNotifier>(context).currentTheme,
      home: HomePage(petRepository: petRepository),
      ),
    );
  }
}


