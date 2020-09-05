import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductGridView extends StatelessWidget {
  final showFavotite;

  ProductGridView(this.showFavotite);

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context);
    final items = showFavotite ? products.favoriteItems : products.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: items.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: items[i],
        child: ProductItem(
            //items[i].id,
            //items[i].title,
            //items[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
