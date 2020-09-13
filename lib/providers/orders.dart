import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double price;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.products,
    @required this.price,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String token;
  String userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders(this.token, this.userId, this._orders);

  // Add new order
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-shop-apps.firebaseio.com/orders/$userId.json?auth=$token';

    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'price': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map(
                (cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                },
              )
              .toList(),
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        products: cartProducts,
        price: total,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Fetch orders
  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-shop-apps.firebaseio.com/orders/$userId.json?auth=$token';
    final List<OrderItem> loadedOrders = [];

    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) return;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          price: orderData['price'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              price: item['price'],
              quantity: item['quantity'],
              title: item['title'],
            );
          }).toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
    //print(response.body);
  }
}
