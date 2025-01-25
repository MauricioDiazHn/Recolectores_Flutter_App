import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../models/recolecta_state.dart';
import '../models/recolecta_event.dart';
import '../repositories/recolecta_repository.dart';

class RecolectaBloc extends Bloc<RecolectaEvent, RecolectaState> {
  final RecolectaRepository repository;

  RecolectaBloc({required this.repository}) : super(RecolectaInitial()) {
    on<LoadRecolectaDetails>(_onLoadRecolectaDetails);
    on<UpdateRecolectaCantidad>(_onUpdateRecolectaCantidad);
    on<ToggleRecolectaApproval>(_onToggleRecolectaApproval);
    on<SaveRecolectaChanges>(_onSaveRecolectaChanges);
  }

  Future<void> _onLoadRecolectaDetails(
    LoadRecolectaDetails event,
    Emitter<RecolectaState> emit,
  ) async {
    try {
      emit(RecolectaLoading());
      final orderData = await repository.fetchOrderData(event.encabezadoId);
      emit(RecolectaLoaded(orderData: orderData));
    } catch (e) {
      emit(RecolectaError(message: e.toString()));
    }
  }

  void _onUpdateRecolectaCantidad(
    UpdateRecolectaCantidad event,
    Emitter<RecolectaState> emit,
  ) {
    // Implementar lógica de actualización de cantidad
  }

  void _onToggleRecolectaApproval(
    ToggleRecolectaApproval event,
    Emitter<RecolectaState> emit,
  ) {
    // Implementar lógica de toggle approval
  }

  Future<void> _onSaveRecolectaChanges(
    SaveRecolectaChanges event,
    Emitter<RecolectaState> emit,
  ) async {
    // Implementar lógica de guardado
  }
} 