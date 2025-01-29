class Recolecta {
  final String id;
  final int ordenCompraId;
  final String proveedor;
  final String direccion;
  final DateTime fechaRecolecta;
  final String horaRecolecta;
  final int motoristaId;
  final int idVehiculo;
  final int kmInicial;
  final int kmFinal;
  final int cantidad;
  final String estado;
  final bool isApproved;

  Recolecta({
    required this.id,
    required this.ordenCompraId,
    required this.proveedor,
    required this.direccion,
    required this.fechaRecolecta,
    required this.horaRecolecta,
    required this.motoristaId,
    required this.idVehiculo,
    required this.kmInicial,
    required this.kmFinal,
    required this.cantidad,
    required this.estado,
    this.isApproved = false,
  });

  Recolecta copyWith({
    String? id,
    int? ordenCompraId,
    String? proveedor,
    String? direccion,
    DateTime? fechaRecolecta,
    String? horaRecolecta,
    int? motoristaId,
    int? idVehiculo,
    int? kmInicial,
    int? kmFinal,
    int? cantidad,
    String? estado,
    bool? isApproved,
  }) {
    return Recolecta(
      id: id ?? this.id,
      ordenCompraId: ordenCompraId ?? this.ordenCompraId,
      proveedor: proveedor ?? this.proveedor,
      direccion: direccion ?? this.direccion,
      fechaRecolecta: fechaRecolecta ?? this.fechaRecolecta,
      horaRecolecta: horaRecolecta ?? this.horaRecolecta,
      motoristaId: motoristaId ?? this.motoristaId,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      kmInicial: kmInicial ?? this.kmInicial,
      kmFinal: kmFinal ?? this.kmFinal,
      cantidad: cantidad ?? this.cantidad,
      estado: estado ?? this.estado,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ordenCompraId': ordenCompraId,
      'proveedor': proveedor,
      'direccion': direccion,
      'fechaRecolecta': fechaRecolecta.toIso8601String(),
      'horaRecolecta': horaRecolecta,
      'motoristaId': motoristaId,
      'idVehiculo': idVehiculo,
      'kmInicial': kmInicial,
      'kmFinal': kmFinal,
      'cantidad': cantidad,
      'estado': estado,
      'isApproved': isApproved,
    };
  }

  factory Recolecta.fromJson(Map<String, dynamic> json) {
    return Recolecta(
      id: json['id'],
      ordenCompraId: json['ordenCompraId'],
      proveedor: json['proveedor'],
      direccion: json['direccion'],
      fechaRecolecta: DateTime.parse(json['fechaRecolecta']),
      horaRecolecta: json['horaRecolecta'],
      motoristaId: json['motoristaId'],
      idVehiculo: json['idVehiculo'],
      kmInicial: json['kmInicial'],
      kmFinal: json['kmFinal'],
      cantidad: json['cantidad'],
      estado: json['estado'],
      isApproved: json['isApproved'] ?? false,
    );
  }
} 