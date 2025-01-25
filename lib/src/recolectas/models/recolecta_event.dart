import 'package:equatable/equatable.dart';

abstract class RecolectaEvent extends Equatable {
  const RecolectaEvent();

  @override
  List<Object> get props => [];
}

class LoadRecolectaDetails extends RecolectaEvent {
  final int encabezadoId;

  const LoadRecolectaDetails(this.encabezadoId);

  @override
  List<Object> get props => [encabezadoId];
}

class UpdateRecolectaCantidad extends RecolectaEvent {
  final int ordenId;
  final String producto;
  final int cantidad;

  const UpdateRecolectaCantidad({
    required this.ordenId,
    required this.producto,
    required this.cantidad,
  });

  @override
  List<Object> get props => [ordenId, producto, cantidad];
}

class ToggleRecolectaApproval extends RecolectaEvent {
  final int ordenId;
  final bool isApproved;

  const ToggleRecolectaApproval({
    required this.ordenId,
    required this.isApproved,
  });

  @override
  List<Object> get props => [ordenId, isApproved];
}

class SaveRecolectaChanges extends RecolectaEvent {
  final String comentario;

  const SaveRecolectaChanges({required this.comentario});

  @override
  List<Object> get props => [comentario];
} 