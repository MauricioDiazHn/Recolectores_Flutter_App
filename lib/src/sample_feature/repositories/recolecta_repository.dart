import 'dart:convert';
import 'package:http/http.dart' as http;

class RecolectaRepository {
  final String token;

  RecolectaRepository({required this.token});

  Future<List<Map<String, dynamic>>> fetchOrderData(int encabezadoId) async {
    final url = '/recolectaenc/recolectadet/$encabezadoId';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final productos = (item['productos'] as List<dynamic>);
          return {
            'orden': item['ordenCompraId'],
            'cantidad': productos.fold<int>(
                0, (sum, producto) => sum + (producto['cantidad'] as int)),
            'nombreProyecto': item['nombreProyecto'],
            'comprador': item['comprador'],
            'productos': productos.map((producto) => {
                  'nombre': producto['nombre'],
                  'cantidad': producto['cantidad'],
                  'cantIngresada': producto['cantIngresada'],
                }).toList(),
          };
        }).toList();
      } else {
        throw Exception('Error al obtener los detalles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Agregar más métodos del repositorio aquí
} 