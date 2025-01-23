import 'package:equatable/equatable.dart';

abstract class RecolectaEvent extends Equatable {
  const RecolectaEvent();

  @override
  List<Object> get props => [];
}

class FetchItems extends RecolectaEvent {
  final int motoristaId;
  final String token;

  const FetchItems({required this.motoristaId, required this.token});

  @override
  List<Object> get props => [motoristaId, token];
}

class SubmitKmInicial extends RecolectaEvent {
  final int motoristaId;
  final int kmInicial;
  final String estado;

  const SubmitKmInicial({required this.motoristaId, required this.kmInicial, required this.estado});

  @override
  List<Object> get props => [motoristaId, kmInicial, estado];
}

class SubmitKmFinal extends RecolectaEvent {
  final int motoristaId;
  final int kmFinal;
  final String estado;

  const SubmitKmFinal({required this.motoristaId, required this.kmFinal, required this.estado});

  @override
  List<Object> get props => [motoristaId, kmFinal, estado];
}

class CheckMileageStatus extends RecolectaEvent {
  final int motoristaId;

  const CheckMileageStatus({required this.motoristaId});

  @override
  List<Object> get props => [motoristaId];
}