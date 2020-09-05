import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';

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

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        products: cartProducts,
        price: total,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
