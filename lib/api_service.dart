import 'dart:convert';
import 'package:endetech/api_response_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static String _languageCode = 'en'; // Default language

  // --- Language Configuration ---
  static void setLanguage(String langCode) {
    _languageCode = langCode;
  }

  // Helper para manejar las cabeceras
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Accept-Language': _languageCode,
        // TODO: Añadir token de autenticación cuando esté implementado
        // 'Authorization': 'Bearer $token',
      };

  // --- Auth ---
  Future<Map<String, dynamic>> login(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> register(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  // --- Equipos ---
  Future<Map<String, dynamic>> getEquipos(BuildContext context) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/equipos');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createEquipo(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/equipos');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateEquipo(BuildContext context, int id, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/equipos/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteEquipo(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/equipos/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  // --- Mantenimientos ---
  Future<Map<String, dynamic>> getMantenimientos(BuildContext context) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/mantenimientos?with=equipo.organization');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }
  
  Future<Map<String, dynamic>> getMantenimiento(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/mantenimientos/$id?with=equipo.organization');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createMantenimiento(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/mantenimientos');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateMantenimiento(BuildContext context, int id, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/mantenimientos/$id');
    final body = {...data, 'id': id};
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(body));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteMantenimiento(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/mantenimientos/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  // --- Organizaciones ---
  Future<Map<String, dynamic>> getOrganizations(BuildContext context) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/organizations');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> getOrganization(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/organizations/$id');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createOrganization(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/organizations');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrganization(BuildContext context, int id, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/organizations/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteOrganization(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/organizations/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  // --- Tareas ---
  Future<Map<String, dynamic>> getTareas(BuildContext context) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tareas');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createTarea(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tareas');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateTarea(BuildContext context, int id, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tareas/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteTarea(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tareas/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }
  
  // --- Tecnicos ---
  Future<Map<String, dynamic>> getTecnicos(BuildContext context) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tecnicos');
    try {
      final response = await http.get(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> createTecnico(BuildContext context, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tecnicos');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> updateTecnico(BuildContext context, int id, Map<String, dynamic> data) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tecnicos/$id');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(data));
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }

  Future<Map<String, dynamic>> deleteTecnico(BuildContext context, int id) async {
    final handler = ApiResponseHandler(context);
    final url = Uri.parse('$_baseUrl/tecnicos/$id');
    try {
      final response = await http.delete(url, headers: _headers);
      return handler.handleResponse(response);
    } catch (e) {
      return handler.handleConnectionError(e);
    }
  }
}
