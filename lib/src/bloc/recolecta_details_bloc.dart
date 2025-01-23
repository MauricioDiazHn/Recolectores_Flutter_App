import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:recolectores_app_flutter/src/sample_feature/api_constants.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'dart:convert';
import '../models/recolecta_item.dart';
import 'recolecta_details_event.dart';
import 'recolecta_details_state.dart';

class RecolectaDetailsBloc extends Bloc<RecolectaDetailsEvent, RecolectaDetailsState> {
  RecolectaDetailsBloc() : super(RecolectaDetailsInitial());

  @override
  Stream<RecolectaDetailsState> mapEventToState(RecolectaDetailsEvent event) async* {
    if (event is FetchOrderData) {
      yield* _mapFetchOrderDataToState(event);
    } else if (event is SubmitOrderData) {
      yield* _mapSubmitOrderDataToState(event);
    }
  }

  Stream<RecolectaDetailsState> _mapFetchOrderDataToState(FetchOrderData event) async* {
    yield RecolectaDetailsLoading();
    try {
      List<Map<String, dynamic>> allOrdenes = [];

      for (var item in event.items) {
        final ordenes = await _fetchOrderData(item.idRecolecta);
        allOrdenes.addAll(ordenes);
      }

      Map<int, bool> isApprovedMap = {};
      Map<int, bool> showDetailsMap = {};
      Map<int, Map<String, int>> cantidadesRecogidas = {};

      for (var ordenData in allOrdenes) {
        final int orden = ordenData['orden'];
        int cantIngresada = ordenData['cantIngresada'] ?? ordenData['cantidad'];

        isApprovedMap[orden] = event.items.first.estado.toLowerCase() == 'parcial';
        showDetailsMap[orden] = false;
        
        cantidadesRecogidas[orden] = {
          'cantidad': cantIngresada,
        };
        for (var producto in ordenData['productos']) {
          cantidadesRecogidas[orden]![producto['nombre']] = producto['cantidad'];
        }
      }

      yield RecolectaDetailsLoaded(
        orderData: allOrdenes,
        isApprovedMap: isApprovedMap,
        showDetailsMap: showDetailsMap,
        cantidadesRecogidas: cantidadesRecogidas,
      );
    } catch (e) {
      yield RecolectaDetailsError(message: 'Error al inicializar los datos: $e');
    }
  }

  Stream<RecolectaDetailsState> _mapSubmitOrderDataToState(SubmitOrderData event) async* {
    yield RecolectaDetailsLoading();
    try {
      for (var item in event.items) {
        final url = Uri.parse('$baseUrl/recolectaenc/${item.idRecolecta}');
        final token = UserSession.token; // Recuperar el token
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

        final body = jsonEncode({
          'Estado': event.isApproved ? 'Aprobado' : 'Pendiente',
          'Comentario': event.comentario,
          'FechaAceptacion': DateTime.now().toIso8601String()
        });

        final response = await http.put(
          url,
          headers: headers,
          body: body,
        );

        List<Map<String, dynamic>> detalles = [];

        // Iterar sobre los datos recogidos para preparar el JSON
        event.cantidadesRecogidas.forEach((ordenCompraId, productos) {
          productos.forEach((nombre, cantidad) {
            detalles.add({
              'ordenCompraId': ordenCompraId,
              'nombre': nombre,
              'cantidad': cantidad,
              'estado': event.isApproved ? 'Recolectado' : 'Pendiente'
            });
          });
        });

        final url2 = Uri.parse('$baseUrl/detalles/update');

        final body2 = jsonEncode(detalles);

        final response2 = await http.put(
          url2,
          headers: headers,
          body: body2,
        );

        if (response.statusCode != 200 && response2.statusCode != 200) {
          yield RecolectaDetailsError(message: 'Error al guardar cambios para idRecolecta: ${item.idRecolecta} - ${response.body}');
          return; // Salir si hay un error
        }
      }

      yield RecolectaDetailsSaveSuccess();
    } catch (e) {
      yield RecolectaDetailsError(message: 'Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrderData(int encabezadoId) async {
    final String token = UserSession.token!;
    final String url = '$baseUrl/recolectaenc/recolectadet/$encabezadoId';

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
          int cantidadTotal = 0;
          for (var producto in productos) { // Itera sobre la lista de productos
            cantidadTotal += producto['cantidad'] as int;
          }

          return {
            'orden': item['ordenCompraId'],
            'cantidad': cantidadTotal, // Almacena la suma total
            'nombreProyecto': item['nombreProyecto'],
            'cantIngresada': item['cantIngresada'],
            'productos': productos.map((producto) {
              return {
                'nombre': producto['nombre'],
                'cantidad': producto['cantidad'],
              };
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
}