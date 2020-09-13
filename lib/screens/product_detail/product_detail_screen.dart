import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_detail';

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context).settings.arguments;
    final product = Provider.of<Products>(context).findById(id);

    return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(product.imageUrl, fit: BoxFit.cover)),
              SizedBox(height: 10),
              Text(
                '\$${product.price}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  '${product.description}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ));
  }
}
