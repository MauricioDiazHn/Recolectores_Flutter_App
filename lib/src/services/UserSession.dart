import 'secure_storage_service.dart';

class UserSession {
  static String? token;
  static int? motoristaId;
  static String? fullName;
  static String? userName;
  static bool hasShownMileageDialog = false;

  static final SecureStorageService _storage = SecureStorageService();

  static Future<void> initSession() async {
    try {
      final storedToken = await _storage.getToken();
      final userData = await _storage.getUserData();
      final dialogShown = await _storage.getMileageDialogShown();

      if (storedToken != null && userData != null) {
        token = storedToken;
        motoristaId = userData['motoristaId'];
        fullName = userData['fullName'];
        userName = userData['userName'];
        hasShownMileageDialog = dialogShown;
      }
    } catch (e) {
      print('Error initializing session: $e');
    }
  }

  static Future<void> saveSession(
    String newToken,
    int newMotoristaId,
    String newFullName,
    String newUserName,
  ) async {
    try {
      // Guardar en memoria
      token = newToken;
      motoristaId = newMotoristaId;
      fullName = newFullName;
      userName = newUserName;
      hasShownMileageDialog = false;

      // Guardar en almacenamiento seguro
      await _storage.saveToken(newToken);
      await _storage.saveUserData(
        motoristaId: newMotoristaId,
        fullName: newFullName,
        userName: newUserName,
      );
      await _storage.setMileageDialogShown(false);
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  static Future<void> clearSession() async {
    try {
      token = null;
      motoristaId = null;
      fullName = null;
      userName = null;
      hasShownMileageDialog = false;

      await _storage.clearAll();
    } catch (e) {
      print('Error clearing session: $e');
      rethrow;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      return await _storage.hasToken();
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<void> setMileageDialogShown(bool shown) async {
    try {
      hasShownMileageDialog = shown;
      await _storage.setMileageDialogShown(shown);
    } catch (e) {
      print('Error setting mileage dialog status: $e');
    }
  }
}