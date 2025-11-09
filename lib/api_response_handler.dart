import 'dart:convert';
import 'package:endetech/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiResponseHandler {
  final AppStrings strings;

  ApiResponseHandler(BuildContext context) : strings = AppStrings.of(context);

  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode == 204) {
      return {'success': true, 'data': {'message': strings.operationSuccessful}};
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
        'message': responseData['message'] ?? strings.unknownApiError,
      };
    }
  }

  Map<String, dynamic> handleConnectionError(dynamic error) {
    // Log the error for debugging purposes if needed
    // print(error);
    return {'success': false, 'message': strings.connectionError};
  }
}
