import 'package:equatable/equatable.dart';
import '../models/recolecta_item.dart';

abstract class RecolectaDetailsState extends Equatable {
  const RecolectaDetailsState();

  @override
  List<Object> get props => [];
}

class RecolectaDetailsInitial extends RecolectaDetailsState {}

class RecolectaDetailsLoading extends RecolectaDetailsState {}

class RecolectaDetailsLoaded extends RecolectaDetailsState {
  final List<Map<String, dynamic>> orderData;
  final Map<int, bool> isApprovedMap;
  final Map<int, bool> showDetailsMap;
  final Map<int, Map<String, int>> cantidadesRecogidas;

  const RecolectaDetailsLoaded({
    required this.orderData,
    required this.isApprovedMap,
    required this.showDetailsMap,
    required this.cantidadesRecogidas,
  });

  @override
  List<Object> get props => [orderData, isApprovedMap, showDetailsMap, cantidadesRecogidas];
}

class RecolectaDetailsError extends RecolectaDetailsState {
  final String message;

  const RecolectaDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

class RecolectaDetailsSaveSuccess extends RecolectaDetailsState {}