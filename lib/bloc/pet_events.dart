import 'package:petapp/bloc/pet_bloc.dart';


class ChangePageEvent extends PetEvent {
  final int page;

  ChangePageEvent(this.page);
}