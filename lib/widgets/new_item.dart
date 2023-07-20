import 'package:flutter/material.dart';
import 'package:grocery_app/models/category.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'dart:convert';
import '../data/categories.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.meat]!;
  var isSending = false;
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSending = true;
      });
      final url = Uri.https(
          'my-flutter-project-aa34b-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title
          }));

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }
      // Navigator.pop(context);
      Navigator.pop(
          context,
          GroceryItem(
              id: resData['name'],
              name: _enteredName,
              quantity: _enteredQuantity,
              category: _selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 250,
                    decoration:
                        const InputDecoration(label: Text('Your Grocery Item')),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1) {
                        return "Must be a valid Positive Number...";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLength: 100,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length >= 50) {
                              return "Must be an integer";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              label: Text('Quantity Here')),
                          initialValue: _enteredQuantity.toString(),
                          onSaved: (value) {
                            _enteredQuantity = int.parse(value!);
                          },
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                    value: category.value,
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 16,
                                            height: 16,
                                            color: category.value.color),
                                        const SizedBox(width: 6),
                                        Text(category.value.title)
                                      ],
                                    ))
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            }),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: isSending
                              ? null
                              : () {
                                  _formKey.currentState!.reset();
                                },
                          child: const Text("Reset")),
                      ElevatedButton(
                          onPressed: isSending ? null : _saveItem,
                          child: isSending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator())
                              : const Text("Add Item"))
                    ],
                  )
                ],
              ))),
    );
  }
}
