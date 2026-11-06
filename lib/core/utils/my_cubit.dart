import 'package:bloc/bloc.dart';

class MyCubit<State> extends BlocBase<State> {
  MyCubit(super.initialState);

  @override
  void emit(State state) {
    if (isClosed) return;
    super.emit(state);
  }
}
