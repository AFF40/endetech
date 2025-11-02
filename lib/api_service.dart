import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //TODO: Mover a un archivo de configuración
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // Helper para manejar las cabeceras
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        // TODO: Añadir token de autenticación cuando esté implementado
        // 'Authorization': 'Bearer $token',
      };

  // Helper genérico para manejar las respuestas de la API
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 204) {
        return {'success': true, 'data': {'message': 'Operación exitosa'}};
    }

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': responseData};
    } else {
      if (response.statusCode == 422) {
        final errors = responseData['errors'];
        final errorMessage = errors.values.first[0];
        return {'success': false, 'message': errorMessage};
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Ocurrió un error desconocido.'
      };
    }
  }
  
  Map<String, dynamic> _handleConnectionError(error) {
      return {'success': false, 'message': 'No se pudo conectar al servidor. Revisa tu conexión a internet.'};
  }

  // --- Auth ---
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  // --- Equipos ---
  Future<Map<String, dynamic>> getEquipos() async {
    final url = Uri.parse('$_baseUrl/equipos');
    try {
      final response = await http.get(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createEquipo(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/equipos');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateEquipo(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/equipos/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteEquipo(int id) async {
    final url = Uri.parse('$_baseUrl/equipos/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  // --- Mantenimientos ---
  Future<Map<String, dynamic>> getMantenimientos() async {
    final url = Uri.parse('$_baseUrl/mantenimientos');
    try {
      final response = await http.get(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }
  
  Future<Map<String, dynamic>> getMantenimiento(int id) async {
    final url = Uri.parse('$_baseUrl/mantenimientos/$id');
    try {
      final response = await http.get(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createMantenimiento(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/mantenimientos');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateMantenimiento(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/mantenimientos/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteMantenimiento(int id) async {
    final url = Uri.parse('$_baseUrl/mantenimientos/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  // --- Organizaciones ---
  Future<Map<String, dynamic>> getOrganizations() async {
    final url = Uri.parse('$_baseUrl/organizations');
    try {
      final response = await http.get(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createOrganization(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/organizations');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrganization(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/organizations/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteOrganization(int id) async {
    final url = Uri.parse('$_baseUrl/organizations/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  // --- Tareas ---
  Future<Map<String, dynamic>> getTareas() async {
    final url = Uri.parse('$_baseUrl/tareas');
    try {
      final response = await http.get(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createTarea(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/tareas');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateTarea(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/tareas/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteTarea(int id) async {
    final url = Uri.parse('$_baseUrl/tareas/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }
  
  // --- Tecnicos ---
  Future<Map<String, dynamic>> getTecnicos() async {
    final url = Uri.parse('$_baseUrl/tecnicos');
    try {
      final response = await http.get(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createTecnico(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/tecnicos');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateTecnico(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/tecnicos/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteTecnico(int id) async {
    final url = Uri.parse('$_baseUrl/tecnicos/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return await _handleResponse(response);
    } catch (e) {
      return _handleConnectionError(e);
    }
  }
}
