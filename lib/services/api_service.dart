import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/media_response.dart';

class ApiService {
  static const String baseUrl =
      'https://wad-project-cvgx.onrender.com/';

  Future<MediaResponse> getMedia() async {
    final response = await http.get(
      Uri.parse('$baseUrl/'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return MediaResponse.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to load media: ${response.statusCode}',
      );
    }
  }
}