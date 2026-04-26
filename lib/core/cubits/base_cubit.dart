import 'dart:async';
import '../utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

abstract class BaseCubit<T> extends Cubit<T> {
  final String scopeId = const Uuid().v4();
  BaseCubit(super.initialState) {
    activateScope();
  }

  String get cubitName => runtimeType.toString();

  void activateScope() {
    logger.debug('activateScope: $scopeId [$cubitName]');
  }

  @override
  void emit(T state) {
    if (isClosed) return;
    super.emit(state);
  }

  @override
  Future<void> close() async {
    logger.debug('closeScope: $scopeId [$cubitName]');
    super.close();
  }
}
