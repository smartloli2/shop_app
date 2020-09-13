import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  final String token;
  final String userId;
  List<Product> _items = [
    /*
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  Products(this.token, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  // Fetch products
  Future<void> fetchAndSetProducts([bool filteredByUser = false]) async {
    // Get products
    final String filterString =
        filteredByUser ? 'orderBy="createdBy"&equalTo="$userId"' : '';
    var url =
        'https://flutter-shop-apps.firebaseio.com/products.json?auth=$token&$filterString';
    try {
      // Try get products
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      // print(extractedData);

      if (response.statusCode >= 400) {
        throw Exception('Bad request 400+');
      }

      // Get user favotites
      url =
          'https://flutter-shop-apps.firebaseio.com/userFavorites/$userId.json?auth=$token';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw Exception('Bad request 400+');
    }
  }

  // Add product
  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shop-apps.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'createdBy': userId,
          },
        ),
      );

      var newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    return;
  }

  // Update product
  Future<void> updateProduct(String id, Product newProd) async {
    final _prodIndex = _items.indexWhere((prod) => prod.id == id);

    final url =
        'https://flutter-shop-apps.firebaseio.com/products/$id.json?auth=$token';
    await http.patch(
      url,
      body: json.encode({
        'description': newProd.description,
        'title': newProd.title,
        'price': newProd.price,
        'imageUrl': newProd.imageUrl,
      }),
    );

    if (_prodIndex >= 0) {
      _items[_prodIndex] = newProd;
      notifyListeners();
    } else {
      print('...');
    }
  }

  // Delete product (optimistic updating)
  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-apps.firebaseio.com/products/$id.json?auth=$token';
    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);

    var exProduct = _items[existingProdIndex];

    _items.removeAt(existingProdIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProdIndex, exProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    exProduct = null;
    //_items.removeWhere((element) => element.id == id);
  }
}
