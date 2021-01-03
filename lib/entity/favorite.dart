import 'package:floor/floor.dart';

@entity
class Favorite {
  @primaryKey
  final int id;
  final String uid, name, imageUrl;

  Favorite({this.id, this.uid, this.name, this.imageUrl});
}
