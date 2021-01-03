import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_floor_favorites/const/const.dart';
import 'package:flutter_floor_favorites/dao/favorite_dao.dart';
import 'package:flutter_floor_favorites/database/database.dart';
import 'package:flutter_floor_favorites/entity/favorite.dart';
import 'package:flutter_floor_favorites/model/product.dart';
import 'package:flutter/services.dart' as rootBundle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database =
      await $FloorAppDatabase.databaseBuilder("favorite.db").build();
  final dao = database.favoriteDao;

  runApp(MyApp(dao: dao));
}

class MyApp extends StatelessWidget {
  final FavoriteDao dao;

  MyApp({this.dao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', dao: dao),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FavoriteDao dao;

  MyHomePage({Key key, this.title, this.dao}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: readJsonData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                var items = snapshot.data as List<Product>;
                return ListView.builder(
                    itemCount: items == null ? 0 : items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  child: Image(
                                    image: NetworkImage(items[index].imageUrl),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Text(
                                          items[index].name,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "\$${items[index].price}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            FutureBuilder(
                                              future: checkFav(items[index]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return IconButton(
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        var item = snapshot.data
                                                            as Favorite;
                                                        await widget.dao
                                                            .deleteFav(item);
                                                        // refresh
                                                        setState(() {});
                                                      });
                                                } else {
                                                  return IconButton(
                                                      icon: Icon(
                                                        Icons.favorite_border,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        Favorite fav = Favorite(
                                                            id: items[index].id,
                                                            uid: UID,
                                                            name: items[index]
                                                                .name,
                                                            imageUrl:
                                                                items[index]
                                                                    .imageUrl);
                                                        await widget.dao
                                                            .insertFav(fav);
                                                        // refresh
                                                        setState(() {});
                                                      });
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                flex: 6,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Future<List<Product>> readJsonData() async {
    final rawData = await rootBundle.rootBundle
        .loadString("assets/data/my_product_json.json");
    final list = json.decode(rawData) as List<dynamic>;
    return list.map((model) => Product.fromJson(model)).toList();
  }

  Future<Favorite> checkFav(Product item) async {
    return await widget.dao.getFavInFavByUid(UID, item.id);
  }
}
