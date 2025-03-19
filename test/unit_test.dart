// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/to/unit-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:recolectores_app_flutter/src/recolectas/recolectas_view.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recolectores_app_flutter/src/services/secure_storage_service.dart';

// Generate mocks
@GenerateMocks([http.Client])
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {
  @override
  Future<void> write({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    required String key,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    required String? value,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => super.noSuchMethod(
    Invocation.method(#write, [], {
      #key: key,
      #value: value,
      #aOptions: aOptions,
      #iOptions: iOptions,
      #lOptions: lOptions,
      #mOptions: mOptions,
      #wOptions: wOptions,
      #webOptions: webOptions,
    }),
    returnValue: Future.value(),
  );

  @override
  Future<String?> read({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    required String key,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => super.noSuchMethod(
    Invocation.method(#read, [], {
      #key: key,
      #aOptions: aOptions,
      #iOptions: iOptions,
      #lOptions: lOptions,
      #mOptions: mOptions,
      #wOptions: wOptions,
      #webOptions: webOptions,
    }),
    returnValue: Future.value(null),
  );

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => super.noSuchMethod(
    Invocation.method(#deleteAll, [], {
      #aOptions: aOptions,
      #iOptions: iOptions,
      #lOptions: lOptions,
      #mOptions: mOptions,
      #wOptions: wOptions,
      #webOptions: webOptions,
    }),
    returnValue: Future.value(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('RecolectaItem Tests', () {
    test('should create RecolectaItem from JSON', () {
      final json = {
        'idlinea': 1,
        'ordenCompraId': 100,
        'proveedor': 'Test Proveedor',
        'direccion': 'Test Dirección',
        'fechaRecolecta': '2024-01-01T00:00:00',
        'horaRecolecta': '10:00',
        'fechaAsignacion': '2024-01-01T00:00:00',
        'fechaAceptacion': '2024-01-01T00:00:00',
        'motoristaId': 1,
        'idVehiculo': 1,
        'kmInicial': 100,
        'kmFinal': 200,
        'tiempoEnSitio': 30,
        'evaluacionProveedor': 5,
        'comentario': 'Test Comentario',
        'cantidad': 10,
        'estado': 'En Ruta',
        'fechaRegistro': '2024-01-01T00:00:00',
        'tc': 'TC001',
        'tituloTC': 'Título TC'
      };

      final recolecta = RecolectaItem.fromJson(json);

      expect(recolecta.idRecolecta, 1);
      expect(recolecta.ordenCompraId, 100);
      expect(recolecta.proveedor, 'Test Proveedor');
      expect(recolecta.direccion, 'Test Dirección');
      expect(recolecta.horaRecolecta, '10:00');
      expect(recolecta.motoristaId, 1);
      expect(recolecta.kmInicial, 100);
      expect(recolecta.kmFinal, 200);
      expect(recolecta.estado, 'En Ruta');
    });

    test('should handle null values in JSON', () {
      final json = {
        'idlinea': null,
        'ordenCompraId': null,
        'proveedor': null,
        'direccion': null,
        'fechaRecolecta': null,
        'horaRecolecta': null,
        'motoristaId': null,
        'idVehiculo': null,
        'kmInicial': null,
        'kmFinal': null,
        'comentario': null,
        'cantidad': null,
        'estado': null,
        'fechaRegistro': null,
        'tc': null,
        'tituloTC': null
      };

      final recolecta = RecolectaItem.fromJson(json);

      expect(recolecta.idRecolecta, 0);
      expect(recolecta.ordenCompraId, 0);
      expect(recolecta.proveedor, '');
      expect(recolecta.direccion, '');
      expect(recolecta.horaRecolecta, '');
      expect(recolecta.motoristaId, 0);
      expect(recolecta.kmInicial, 0);
      expect(recolecta.kmFinal, 0);
      expect(recolecta.estado, '');
    });

    test('should handle missing fields in JSON', () {
      final json = {
        'idlinea': 1,
        'proveedor': 'Test Proveedor'
      };

      final recolecta = RecolectaItem.fromJson(json);

      expect(recolecta.idRecolecta, 1);
      expect(recolecta.proveedor, 'Test Proveedor');
      expect(recolecta.ordenCompraId, 0);
      expect(recolecta.direccion, '');
      expect(recolecta.horaRecolecta, '');
      expect(recolecta.motoristaId, 0);
      expect(recolecta.kmInicial, 0);
      expect(recolecta.kmFinal, 0);
      expect(recolecta.estado, '');
    });
  });

  group('SecureStorageService Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageService storageService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      SecureStorageService.reset(); // Reset singleton
      storageService = SecureStorageService(storage: mockStorage);
    });

    test('should save and retrieve token', () async {
      // Setup
      when(mockStorage.write(
        key: 'user_token',
        value: 'test_token',
      )).thenAnswer((_) => Future.value());
      
      when(mockStorage.read(
        key: 'user_token',
      )).thenAnswer((_) => Future.value('test_token'));

      // Execute
      await storageService.saveToken('test_token');
      final token = await storageService.getToken();

      // Verify
      expect(token, 'test_token');
      verify(mockStorage.write(
        key: 'user_token',
        value: 'test_token',
      )).called(1);
    });

    test('should check session validity', () async {
      final now = DateTime.now();
      final validDate = now.subtract(const Duration(days: 5));
      final invalidDate = now.subtract(const Duration(days: 8));

      // Setup for valid date test
      when(mockStorage.read(
        key: 'last_login',
      )).thenAnswer((_) => Future.value(validDate.toIso8601String()));
      
      bool isValid = await storageService.isSessionValid();
      expect(isValid, true);

      // Setup for invalid date test
      when(mockStorage.read(
        key: 'last_login',
      )).thenAnswer((_) => Future.value(invalidDate.toIso8601String()));
      
      isValid = await storageService.isSessionValid();
      expect(isValid, false);
    });

    test('should clear all storage', () async {
      when(mockStorage.deleteAll())
          .thenAnswer((_) => Future.value());

      await storageService.clearAll();
      verify(mockStorage.deleteAll()).called(1);
    });
  });

  group('Business Logic Tests', () {
    List<RecolectaItem> testItems = [];

    setUp(() {
      // Configurar datos de prueba
      testItems = [
        RecolectaItem(
          idRecolecta: 1,
          ordenCompraId: 100,
          proveedor: 'Proveedor 1',
          direccion: 'Dirección 1',
          fechaRecolecta: DateTime.now(),
          horaRecolecta: '10:00',
          motoristaId: 1,
          idVehiculo: 1,
          kmInicial: 100,
          kmFinal: 200,
          comentario: '',
          cantidad: 1,
          estado: 'En Ruta',
          fechaRegistro: DateTime.now(),
          tc: '',
          tituloTC: ''
        ),
        RecolectaItem(
          idRecolecta: 2,
          ordenCompraId: 101,
          proveedor: 'Proveedor 1',
          direccion: 'Dirección 2',
          fechaRecolecta: DateTime.now(),
          horaRecolecta: '11:00',
          motoristaId: 1,
          idVehiculo: 1,
          kmInicial: 200,
          kmFinal: 300,
          comentario: '',
          cantidad: 1,
          estado: 'Recolectada',
          fechaRegistro: DateTime.now(),
          tc: '',
          tituloTC: ''
        ),
        RecolectaItem(
          idRecolecta: 3,
          ordenCompraId: 102,
          proveedor: 'Proveedor 2',
          direccion: 'Dirección 3',
          fechaRecolecta: DateTime.now(),
          horaRecolecta: '12:00',
          motoristaId: 1,
          idVehiculo: 1,
          kmInicial: 300,
          kmFinal: 400,
          comentario: '',
          cantidad: 1,
          estado: 'Fallida',
          fechaRegistro: DateTime.now(),
          tc: '',
          tituloTC: ''
        ),
      ];
    });

    test('should group items by provider correctly', () {
      Map<String, List<RecolectaItem>> groupedItems = {};
      for (var item in testItems) {
        if (!groupedItems.containsKey(item.proveedor)) {
          groupedItems[item.proveedor] = [];
        }
        groupedItems[item.proveedor]!.add(item);
      }

      expect(groupedItems.length, 2); // Debe haber 2 proveedores
      expect(groupedItems['Proveedor 1']?.length, 2); // Proveedor 1 tiene 2 items
      expect(groupedItems['Proveedor 2']?.length, 1); // Proveedor 2 tiene 1 item
    });

    test('should correctly identify collection states', () {
      var proveedor1Items = testItems.where((item) => item.proveedor == 'Proveedor 1').toList();
      var proveedor2Items = testItems.where((item) => item.proveedor == 'Proveedor 2').toList();

      // Verificar estados para Proveedor 1
      bool algunaEnRuta = proveedor1Items.any((item) => item.estado.toLowerCase() == 'en ruta');
      bool todasRecolectadas = proveedor1Items.every((item) => item.estado.toLowerCase() == 'recolectada');

      expect(algunaEnRuta, true); // Proveedor 1 tiene una recolecta en ruta
      expect(todasRecolectadas, false); // No todas las recolectas están completadas

      // Verificar estados para Proveedor 2
      bool algunaFallida = proveedor2Items.any((item) => 
        ['incompleta', 'fallida'].contains(item.estado.toLowerCase())
      );

      expect(algunaFallida, true); // Proveedor 2 tiene una recolecta fallida
    });

    test('should validate mileage values', () {
      // Prueba para valores de kilometraje válidos
      var item = testItems[0];
      expect(item.kmFinal > item.kmInicial, true);

      // Crear item con kilometraje inválido
      var itemInvalid = RecolectaItem(
        idRecolecta: 4,
        ordenCompraId: 103,
        proveedor: 'Proveedor 3',
        direccion: 'Dirección 4',
        fechaRecolecta: DateTime.now(),
        horaRecolecta: '13:00',
        motoristaId: 1,
        idVehiculo: 1,
        kmInicial: 500,
        kmFinal: 400, // Kilometraje final menor que el inicial
        comentario: '',
        cantidad: 1,
        estado: 'En Ruta',
        fechaRegistro: DateTime.now(),
        tc: '',
        tituloTC: ''
      );

      expect(itemInvalid.kmFinal < itemInvalid.kmInicial, true);
      // Esta condición debería ser validada en la UI antes de guardar
    });
  });
}
