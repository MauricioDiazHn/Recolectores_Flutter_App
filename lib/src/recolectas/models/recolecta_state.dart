import 'package:equatable/equatable.dart';

abstract class RecolectaState extends Equatable {
  const RecolectaState();

  @override
  List<Object> get props => [];
}

class RecolectaInitial extends RecolectaState {}

class RecolectaLoading extends RecolectaState {}

class RecolectaLoaded extends RecolectaState {
  final List<Map<String, dynamic>> orderData;
  final Map<int, bool> isApprovedMap;
  final Map<int, Map<String, int>> cantidadesRecogidas;

  const RecolectaLoaded({
    required this.orderData,
    this.isApprovedMap = const {},
    this.cantidadesRecogidas = const {},
  });

  @override
  List<Object> get props => [orderData, isApprovedMap, cantidadesRecogidas];
}

class RecolectaError extends RecolectaState {
  final String message;

  const RecolectaError({required this.message});

  @override
  List<Object> get props => [message];
} 