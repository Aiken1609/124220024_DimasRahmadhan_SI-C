import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<String>> _favoriteIds;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _favoriteIds = _fetchFavorites();
  }

  Future<List<String>> _fetchFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.lightBlue,
      ),
      body: FutureBuilder<List<String>>(
        future: _favoriteIds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final favoriteIds = snapshot.data!;
            if (favoriteIds.isEmpty) {
              return Center(child: Text('No favorites yet.'));
            }
            return ListView.builder(
              itemCount: favoriteIds.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Map<String, dynamic>>(
                  future:
                      _apiService.fetchRestaurantDetails(favoriteIds[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error');
                    } else {
                      final restaurant = snapshot.data!;
                      return ListTile(
                        title: Text(restaurant['name']),
                        subtitle: Text(restaurant['city']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final favorites =
                                prefs.getStringList('favorites') ?? [];
                            favorites.remove(favoriteIds[index]);
                            await prefs.setStringList('favorites', favorites);
                            setState(() {
                              _favoriteIds = _fetchFavorites();
                            });
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
