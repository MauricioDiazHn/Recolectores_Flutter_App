import 'package:equatable/equatable.dart';
import 'package:recolectores_app_flutter/src/models/recolecta_item.dart';

abstract class RecolectaDetailsEvent extends Equatable {
  const RecolectaDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchOrderData extends RecolectaDetailsEvent {
  final List<RecolectaItem> items;

  const FetchOrderData({required this.items});

  @override
  List<Object> get props => [items];
}

class SubmitOrderData extends RecolectaDetailsEvent {
  final List<RecolectaItem> items;
  final Map<int, Map<String, int>> cantidadesRecogidas;
  final String comentario;
  final bool isApproved;

  const SubmitOrderData({
    required this.items,
    required this.cantidadesRecogidas,
    required this.comentario,
    required this.isApproved,
  });

  @override
  List<Object> get props => [items, cantidadesRecogidas, comentario, isApproved];
}