import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'place.g.dart';

@HiveType(typeId: 3)
class PlaceModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String category; // 'food', 'cafe', 'shopping', 'experience', 'hotel'

  @HiveField(3)
  late String city;

  @HiveField(4)
  late String address;

  @HiveField(5)
  late double latitude;

  @HiveField(6)
  late double longitude;

  @HiveField(7)
  late String priceLevel; // '$', '$$', '$$$'

  @HiveField(8)
  late double rating;

  @HiveField(9)
  late String imageUrl;

  @HiveField(10)
  late List<String> linkedResourceIds; // Reels and links associated with this place

  @HiveField(11)
  late bool isSaved;

  @HiveField(12)
  late bool isVisited;

  @HiveField(13)
  late String notes;

  PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.priceLevel = '\$',
    this.rating = 4.5,
    this.imageUrl = '',
    List<String>? linkedResourceIds,
    this.isSaved = false,
    this.isVisited = false,
    this.notes = '',
  }) : linkedResourceIds = linkedResourceIds ?? [];

  IconData get categoryVectorIcon {
    switch (category.toLowerCase()) {
      case 'cafe':
        return Icons.local_cafe;
      case 'food':
        return CupertinoIcons.heart_circle_fill;
      case 'shopping':
        return CupertinoIcons.bag_fill;
      case 'hotel':
        return CupertinoIcons.bed_double_fill;
      case 'experience':
        return CupertinoIcons.sparkles;
      default:
        return CupertinoIcons.placemark_fill;
    }
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'cafe':
        return '☕';
      case 'food':
        return '🍜';
      case 'shopping':
        return '🛍️';
      case 'hotel':
        return '🏨';
      case 'experience':
        return '🎡';
      default:
        return '📍';
    }
  }
}

/// Curated public starter places (§13 of Master Prompt)
List<PlaceModel> get defaultCuratedPlaces => [
      PlaceModel(
        id: 'place_rameshwaram',
        name: 'The Rameshwaram Cafe',
        category: 'food',
        city: 'Bengaluru',
        address: '12th Main Rd, Indiranagar, Bengaluru',
        latitude: 12.9716,
        longitude: 77.5946,
        priceLevel: '\$',
        rating: 4.8,
        imageUrl:
            'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=400&q=80',
        notes: 'Famous Ghee Podi Idli & Filter Coffee seen in viral reels',
        isSaved: true,
      ),
      PlaceModel(
        id: 'place_third_wave',
        name: 'Third Wave Coffee Roasters',
        category: 'cafe',
        city: 'Bengaluru',
        address: '4th Block, Koramangala, Bengaluru',
        latitude: 12.9352,
        longitude: 77.6245,
        priceLevel: '\$\$',
        rating: 4.6,
        imageUrl:
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=400&q=80',
        notes: 'Work-friendly space, artisanal coffee, quiet corners',
        isSaved: true,
      ),
      PlaceModel(
        id: 'place_commercial_st',
        name: 'Commercial Street Bazaar',
        category: 'shopping',
        city: 'Bengaluru',
        address: 'Tasker Town, Shivaji Nagar, Bengaluru',
        latitude: 12.9822,
        longitude: 77.6083,
        priceLevel: '\$',
        rating: 4.4,
        imageUrl:
            'https://images.unsplash.com/photo-1472851294608-062f824d29cc?auto=format&fit=crop&w=400&q=80',
        notes: 'Budget fashion, accessories, and street food lane',
        isSaved: false,
      ),
      PlaceModel(
        id: 'place_cubbon_park',
        name: 'Cubbon Park Weekend Walk',
        category: 'experience',
        city: 'Bengaluru',
        address: 'Kasturba Road, Bengaluru',
        latitude: 12.9763,
        longitude: 77.5929,
        priceLevel: 'Free',
        rating: 4.9,
        imageUrl:
            'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=400&q=80',
        notes: 'Lush greenery, pet meetings, cycling and picnic spots',
        isSaved: false,
      ),
    ];

