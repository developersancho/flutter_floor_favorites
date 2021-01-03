import 'package:floor/floor.dart';
import 'package:flutter_floor_favorites/dao/favorite_dao.dart';
import 'package:flutter_floor_favorites/entity/favorite.dart';

// need imports
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // generate code

@Database(version: 1, entities: [Favorite])
abstract class AppDatabase extends FloorDatabase {
  FavoriteDao get favoriteDao;
}
