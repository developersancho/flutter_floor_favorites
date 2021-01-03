import 'package:floor/floor.dart';
import 'package:flutter_floor_favorites/entity/favorite.dart';

@dao
abstract class FavoriteDao {
  @Query("Select * From favorite where uid=:uid and id=:id")
  Future<Favorite> getFavInFavByUid(String uid, int id);

  @insert
  Future<void> insertFav(Favorite fav);

  @delete
  Future<int> deleteFav(Favorite fav);
}
