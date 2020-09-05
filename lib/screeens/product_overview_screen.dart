import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screeens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';

import 'package:shop_app/widgets/product_grid_view.dart';

enum FilterOptions {
  All,
  Favorite,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var showFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions opt) {
              if (opt == FilterOptions.All) {
                setState(() {
                  showFavorite = false;
                });
              }
              if (opt == FilterOptions.Favorite) {
                setState(() {
                  showFavorite = true;
                });
              }
            },
            icon: Icon(Icons.more_horiz),
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('All'), value: FilterOptions.All),
              PopupMenuItem(
                  child: Text('Favorire'), value: FilterOptions.Favorite),
            ],
          ),
          Consumer<CartProvider>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
          ),
        ],
      ),
      body: ProductGridView(showFavorite),
    );
  }
}
