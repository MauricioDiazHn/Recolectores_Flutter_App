import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:recolectores_app_flutter/src/sample_feature/api_constants.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'dart:convert';
import '../models/recolecta_item.dart';
import 'recolecta_event.dart';
import 'recolecta_state.dart';

class RecolectaBloc extends Bloc<RecolectaEvent, RecolectaState> {
  RecolectaBloc() : super(RecolectaInitial()) {
    on<FetchItems>(_mapFetchItemsToState);
    on<SubmitKmInicial>(_mapSubmitKmInicialToState);
    on<SubmitKmFinal>(_mapSubmitKmFinalToState);
    on<CheckMileageStatus>(_mapCheckMileageStatusToState);
  }

  void _mapFetchItemsToState(FetchItems event, Emitter<RecolectaState> emit) async {
    emit(RecolectaLoading());
    try {
      final url = Uri.parse('$baseUrl/recolectaenc/${event.motoristaId}');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${event.token}',
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final items = data.map((item) => RecolectaItem.fromJson(item)).toList();
        emit(RecolectaLoaded(items: items));
      } else {
        emit(RecolectaError(message: 'Error al cargar datos: ${response.body}'));
      }
    } catch (e) {
      emit(RecolectaError(message: 'Error: $e'));
    }
  }

  void _mapSubmitKmInicialToState(SubmitKmInicial event, Emitter<RecolectaState> emit) async {
    try {
      final url = Uri.parse('$baseUrl/recolectaenc/updateKmInicialAndStatus');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };
      final body = json.encode({
        'MotoristaId': event.motoristaId,
        'KmInicial': event.kmInicial,
        'Estado': event.estado,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Actualización exitosa: ${response.body}");
      } else {
        emit(RecolectaError(message: 'Error al actualizar: ${response.body}'));
      }
    } catch (e) {
      emit(RecolectaError(message: 'Error: $e'));
    }
  }

  void _mapSubmitKmFinalToState(SubmitKmFinal event, Emitter<RecolectaState> emit) async {
    try {
      final url = Uri.parse('$baseUrl/recolectaenc/updateKmFinalAndStatus');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };
      final body = json.encode({
        'MotoristaId': event.motoristaId,
        'KmFinal': event.kmFinal,
        'Estado': event.estado,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Actualización exitosa: ${response.body}");
      } else {
        emit(RecolectaError(message: 'Error al actualizar: ${response.body}'));
      }
    } catch (e) {
      emit(RecolectaError(message: 'Error: $e'));
    }
  }

  void _mapCheckMileageStatusToState(CheckMileageStatus event, Emitter<RecolectaState> emit) async {
    emit(RecolectaLoading());
    try {
      final hasCurrentMileage = await _hasEnteredCurrentMileage(event.motoristaId);
      final hasFinalized = await _hasFinalizedRecolecta(event.motoristaId);

      if (!hasCurrentMileage) {
        emit(RecolectaError(message: 'Debe ingresar el kilometraje inicial.'));
      } else if (!hasFinalized) {
        emit(RecolectaError(message: 'Debe finalizar la recolecta.'));
      } else {
        emit(RecolectaLoaded(items: []));
      }
    } catch (e) {
      emit(RecolectaError(message: 'Error: $e'));
    }
  }

  Future<bool> _hasEnteredCurrentMileage(int motoristaId) async {
    final url = Uri.parse('$baseUrl/recolectaenc/$motoristaId/currentMileage?checkFinalMileage=false');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as bool;
        return data;
      } else {
        throw Exception('Error al verificar el kilometraje actual: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> _hasFinalizedRecolecta(int motoristaId) async {
    final url = Uri.parse('$baseUrl/recolectaenc/$motoristaId/currentMileage?checkFinalMileage=true');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as bool;
        return data;
      } else {
        throw Exception('Error al verificar el estado de finalización: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}