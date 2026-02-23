import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

class OnboardingState {
  final int currentPage;

  const OnboardingState({required this.currentPage});

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }

  factory OnboardingState.initial() => const OnboardingState(currentPage: 0);
}

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  void setPage(int index) {
    emit(state.copyWith(currentPage: index));
  }
}
