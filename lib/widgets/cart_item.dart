import 'package:flutter/material.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({this.id, this.price, this.title, this.quantity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: Text(
                  '\$${price.toStringAsFixed(2)}',
                ),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text('${(price * quantity).toStringAsFixed(2)}'),
          trailing: Text('$quantity x'),
        ),
      ),
    );
  }
}
