import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Groceries extends StatefulWidget {
  const Groceries({super.key});

  @override
  State<Groceries> createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'my-flutter-project-aa34b-default-rtdb.firebaseio.com',
        'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to Fetch Data';
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<GroceryItem> loadedItems = [];
      final Map<String, dynamic> listData = json.decode(response.body);
      for (final groceryItem in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (item) => item.value.title == groceryItem.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: groceryItem.key,
            name: groceryItem.value['name'],
            quantity: groceryItem.value['quantity'],
            category: category));
      }
      setState(() {
        _isLoading = false;
        _groceryItems = loadedItems;
      });
    } catch (error) {
      setState(() {
        _error = "Somethingwent Wrong, buddy !";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(
        context, MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void handleDismissedItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'my-flutter-project-aa34b-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    print(response);

    if (response.statusCode >= 400) {
      var snackBarCon = const SnackBar(
          duration: Duration(seconds: 3),
          content: Text('Grocery Could not be deleted...'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarCon);
      setState(() {
        _groceryItems.insert(index, item);
      });
    } else {
      var snackBarCon = const SnackBar(
          duration: Duration(seconds: 3), content: Text('Grocery Deleted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarCon);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyContentMessage = const Padding(
      padding: EdgeInsets.all(15),
      child: Center(
        child: Text(
          'No Groceries Found, Please Add some using the icon in the top right corner of your screen !',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
    if (_isLoading) {
      emptyContentMessage = const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      emptyContentMessage = Center(child: Text(_error!));
    }
    return (Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: _groceryItems.isEmpty
            ? emptyContentMessage
            : ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder: (ctx, index) => Dismissible(
                      background: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.6)),
                      key: ValueKey(_groceryItems[index]),
                      onDismissed: (direction) =>
                          handleDismissedItem(_groceryItems[index]),
                      child: ListTile(
                        title: Text(_groceryItems[index].name),
                        leading: Container(
                            width: 24,
                            height: 24,
                            color: _groceryItems[index].category.color),
                        trailing:
                            Text(_groceryItems[index].quantity.toString()),
                      ),
                    ))));
  }
}
