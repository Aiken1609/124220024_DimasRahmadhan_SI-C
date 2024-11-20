import 'dart:convert';
import 'package:http/http.dart' as http;

class Restaurant {
  final String id;
  final String name;
  final String city;
  final String pictureId;

  Restaurant({
    required this.id,
    required this.name,
    required this.city,
    required this.pictureId,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      pictureId: json['pictureId'],
    );
  }
}

class ApiService {
  final String baseUrl = 'https://restaurant-api.dicoding.dev';

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List restaurants = data['restaurants'];
      return restaurants.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<Map<String, dynamic>> fetchRestaurantDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/detail/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['restaurant'];
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }
}
