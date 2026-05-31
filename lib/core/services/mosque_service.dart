import 'dart:convert';
import 'package:http/http.dart' as http;

/// Data class for a mosque returned by the backend.
class Mosque {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? rating;
  double distance;

  Mosque({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating,
    this.distance = 0.0,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) => Mosque(
        name: json['name'] as String,
        address: json['address'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        rating: json['rating'] != null
            ? (json['rating'] as num).toDouble()
            : null,
      );
}

/// Communicates with the FastAPI `/api/mosques/nearby` endpoint.
class MosqueService {
  static const String _baseUrl = 'https://theory-bulk-region-paragraph.trycloudflare.com';
  final http.Client _client;

  MosqueService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch mosques near [lat], [lng] within [radiusMetres].
  Future<List<Mosque>> fetchNearby({
    required double lat,
    required double lng,
    int radiusMetres = 3000,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/mosques/nearby').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radiusMetres.toString(),
      },
    );
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch mosques: ${response.statusCode}');
    }
    final data = json.decode(response.body);
    return (data as List).map((e) => Mosque.fromJson(e)).toList();
  }

  void dispose() => _client.close();
}
