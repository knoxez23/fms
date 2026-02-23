import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

class FarmNavState {
  final int index;

  const FarmNavState(this.index);
}

@injectable
class FarmNavCubit extends Cubit<FarmNavState> {
  FarmNavCubit() : super(const FarmNavState(0));

  void select(int index) => emit(FarmNavState(index));
}
