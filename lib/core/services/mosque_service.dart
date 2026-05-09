import 'api_client.dart';

/// Data class for a mosque returned by the backend.
class Mosque {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? rating;

  const Mosque({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating,
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
  final ApiClient _api;

  MosqueService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Fetch mosques near [lat], [lng] within [radiusMetres].
  Future<List<Mosque>> fetchNearby({
    required double lat,
    required double lng,
    int radiusMetres = 3000,
  }) async {
    final data = await _api.get('/api/mosques/nearby', queryParams: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radiusMetres.toString(),
    });

    return (data as List).map((e) => Mosque.fromJson(e)).toList();
  }
}
