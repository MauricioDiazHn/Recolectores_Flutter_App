import 'package:equatable/equatable.dart';
import '../models/recolecta_item.dart';

abstract class RecolectaState extends Equatable {
  const RecolectaState();

  @override
  List<Object> get props => [];
}

class RecolectaInitial extends RecolectaState {}

class RecolectaLoading extends RecolectaState {}

class RecolectaLoaded extends RecolectaState {
  final List<RecolectaItem> items;

  const RecolectaLoaded({required this.items});

  @override
  List<Object> get props => [items];
}

class RecolectaError extends RecolectaState {
  final String message;

  const RecolectaError({required this.message});

  @override
  List<Object> get props => [message];
}