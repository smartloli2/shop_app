import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth/auth-screen.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/edit_product_form/edit_product_screen.dart';
import 'package:shop_app/screens/orders/order_screen.dart';
import 'package:shop_app/screens/product_detail/product_detail_screen.dart';
import 'package:shop_app/screens/overview/product_overview_screen.dart';
import 'package:shop_app/screens/splash/splash-screen.dart';
import 'package:shop_app/screens/user_products/user_products_screen.dart';
import 'package:shop_app/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('', '', []),
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts != null ? previousProducts.items : [],
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders('', '', []),
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: appTheme(),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            OrderScreen.routeName: (_) => OrderScreen(),
            UserProductScreen.routeName: (_) => UserProductScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
            AuthScreen.routeName: (_) => AuthScreen(),
          },
        );
      }),
    );
  }
}
