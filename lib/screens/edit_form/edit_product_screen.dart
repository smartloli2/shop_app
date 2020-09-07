import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

// class EditProduct {
//   String id;
//   String title = '';
//   double price = 0.0;
//   String description = '';
//   String imageUrl = '';

//   EditProduct({
//     this.id,
//     this.description,
//     this.price,
//     this.imageUrl,
//     this.title,
//   });
// }

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Editing product
  Product _editProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0.0,
    imageUrl: '',
  );

  // Focus nodes
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  // Text editing controllers
  final _imageUrlTextController = TextEditingController();
  // Global keys
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Init state
  @override
  void initState() {
    _imageUrlTextController.addListener(_updateImageUrl);
    super.initState();
  }

  bool _isInit = true;

  Map<String, String> _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      String prodId = ModalRoute.of(context).settings.arguments as String;

      if (prodId != null) {
        _editProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(prodId);

        _initValues = {
          'title': _editProduct.title,
          'price': _editProduct.price.toString(),
          'description': _editProduct.description,
          'imageUrl': '',
        };
        _imageUrlTextController.text = _editProduct.imageUrl;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  // Dispose state
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlTextController.removeListener(_updateImageUrl);
    _imageUrlTextController.dispose();

    super.dispose();
  }

  // UmageURL listener
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_editProduct.imageUrl.startsWith('http:') &&
          !_editProduct.imageUrl.startsWith('https:')) setState(() {});
    }
  }

  // Submit form
  void _saveForm() {
    final isValidate = _formKey.currentState.validate();
    if (!isValidate) {
      return;
    }
    _formKey.currentState.save();
    if (_editProduct.id != null) {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      Provider.of<ProductsProvider>(context, listen: false)
          .addProduct(_editProduct);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(_priceFocusNode),
                onSaved: (value) {
                  _editProduct = Product(
                    title: value,
                    description: _editProduct.description,
                    price: _editProduct.price,
                    imageUrl: _editProduct.imageUrl,
                    id: _editProduct.id,
                    isFavorite: _editProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please provide a correct value';
                  }
                  if (double.tryParse(value) < 0) {
                    return 'Price should be greater than zero';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(_descriptionFocusNode),
                onSaved: (value) {
                  _editProduct = Product(
                    id: _editProduct.id,
                    isFavorite: _editProduct.isFavorite,
                    title: _editProduct.title,
                    description: _editProduct.description,
                    price: double.parse(value),
                    imageUrl: _editProduct.imageUrl,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.length < 10) {
                    return 'Description should be at least 10 characters';
                  }
                  return null;
                },
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  _editProduct = Product(
                    id: _editProduct.id,
                    isFavorite: _editProduct.isFavorite,
                    title: _editProduct.title,
                    description: value,
                    price: _editProduct.price,
                    imageUrl: _editProduct.imageUrl,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlTextController.text.isEmpty
                        ? Text('Enter image URL')
                        : FittedBox(
                            child: Image.network(_imageUrlTextController.text),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a image URL';
                        }
                        if (!value.startsWith('http:') &&
                            !value.startsWith('https:')) {
                          return 'Please provide a correct URL';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.url,
                      focusNode: _imageUrlFocusNode,
                      controller: _imageUrlTextController,
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          isFavorite: _editProduct.isFavorite,
                          title: _editProduct.title,
                          description: _editProduct.description,
                          price: _editProduct.price,
                          imageUrl: value,
                        );
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
