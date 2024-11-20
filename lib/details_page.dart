import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DetailsPage extends StatefulWidget {
  final String restaurantId;

  DetailsPage({required this.restaurantId});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>> _restaurantDetails;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _restaurantDetails =
        ApiService().fetchRestaurantDetails(widget.restaurantId);
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.restaurantId);
    });
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favorites.remove(widget.restaurantId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.red),
      );
    } else {
      favorites.add(widget.restaurantId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Added to favorites'), backgroundColor: Colors.green),
      );
    }

    await prefs.setStringList('favorites', favorites);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _restaurantDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final restaurant = snapshot.data!;

            // Mengambil URL gambar dari respons API
            final imageUrl = restaurant['pictureId'] != null
                ? 'https://restaurant-api.dicoding.dev/images/small/${restaurant['pictureId']}'
                : 'https://restaurant-api.dicoding.dev/images/small/default.jpg'; // Default jika tidak ada pictureId

            return SingleChildScrollView(
              // Membungkus seluruh konten dengan SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan gambar restoran
                    Image.network(imageUrl,
                        loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }, errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }),
                    SizedBox(height: 16),
                    // Nama restoran
                    Text(restaurant['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    // Detail lainnya
                    Text('City: ${restaurant['city']}'),
                    Text('Address: ${restaurant['address']}'),
                    Text('Rating: ${restaurant['rating']}'),
                    SizedBox(height: 16),
                    // Deskripsi restoran
                    Text(restaurant['description']),
                    SizedBox(height: 16),
                    // Tombol favorite
                    IconButton(
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
