
class RecolectaItem {
  final int idRecolecta;
  final int ordenCompraId;
  final String proveedor;
  final String direccion;
  final DateTime fechaRecolecta;
  final String horaRecolecta;
  final DateTime? fechaAsignacion;
  final DateTime? fechaAceptacion;
  final int motoristaId;
  final int idVehiculo;
  final int kmInicial;
  final int kmFinal;
  final int? tiempoEnSitio;
  final int? evaluacionProveedor;
  final String comentario;
  final int cantidad;
  final String estado;
  final DateTime fechaRegistro;
  final String tc;
  final String tituloTC;

  RecolectaItem({
    required this.idRecolecta,
    required this.ordenCompraId,
    required this.proveedor,
    required this.direccion,
    required this.fechaRecolecta,
    required this.horaRecolecta,
    this.fechaAsignacion,
    this.fechaAceptacion,
    required this.motoristaId,
    required this.idVehiculo,
    required this.kmInicial,
    required this.kmFinal,
    this.tiempoEnSitio,
    this.evaluacionProveedor,
    required this.comentario,
    required this.cantidad,
    required this.estado,
    required this.fechaRegistro,
    required this.tc,
    required this.tituloTC,
  });

  factory RecolectaItem.fromJson(Map<String, dynamic> json) {
    return RecolectaItem(
      idRecolecta: json['idlinea'] ?? 0, // Valor por defecto si es null
      ordenCompraId: json['ordenCompraId'] ?? 0, // Valor por defecto si es null
      proveedor: json['proveedor'] ?? '', // Valor por defecto si es null
      direccion: json['direccion'] ?? '', // Valor por defecto si es null
      fechaRecolecta: json['fechaRecolecta'] != null
          ? DateTime.parse(json['fechaRecolecta'])
          : DateTime.now(), // Valor por defecto si es null
      horaRecolecta:
          json['horaRecolecta'] ?? '', // Valor por defecto si es null
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : null, // Valor por defecto si es null
      fechaAceptacion: json['fechaAceptacion'] != null
          ? DateTime.parse(json['fechaAceptacion'])
          : null, // Valor por defecto si es null
      motoristaId: json['motoristaId'] ?? 0, // Valor por defecto si es null
      idVehiculo: json['idVehiculo'] ?? 0, // Valor por defecto si es null
      kmInicial: json['kmInicial'] ?? 0, // Valor por defecto si es null
      kmFinal: json['kmFinal'] ?? 0, // Valor por defecto si es null
      tiempoEnSitio: json['tiempoEnSitio'] ?? 0, // Valor por defecto si es null
      evaluacionProveedor:
          json['evaluacionProveedor'] ?? 0, // Valor por defecto si es null
      comentario: json['comentario'] ?? '', // Valor por defecto si es null
      cantidad: json['cantidad'] ?? 0, // Valor por defecto si es null
      estado: json['estado'] ?? '', // Valor por defecto si es null
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(), // Valor por defecto si es null
      tc: json['tc'] ?? '', // Valor por defecto si es null
      tituloTC: json['tituloTC'] ?? '', // Valor por defecto si es null
    );
  }
}