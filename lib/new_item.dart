import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;


class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _textValue = '';
  var _qtyValue = 1;
  var _catValue = categories[Categories.vegetables];

  void _submitForm() async{
      if(_formKey.currentState!.validate()){
        _formKey.currentState!.save();
        
        final url = Uri.https('shopping-list-flutter-4dd4a-default-rtdb.firebaseio.com','shopping-list.json');
        final response = await http.post(
          url,
          headers: {
            'Content-Type' : 'application/json'
          },
          body: json.encode({
            'name' : _textValue,
            'quantity' : _qtyValue,
            'category' : _catValue!.name,
          })
        );
        if(!context.mounted){
        return;
      }
      Navigator.of(context).pop(GroceryItem(id: json.decode(response.body)['name'], name: _textValue, quantity: _qtyValue, category: _catValue!));
      }
    
      
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                  children: [
            TextFormField(
              initialValue: _textValue,
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text('Grocery Name')
              ),
              onChanged: (value) {
                _textValue = value;
              },
              validator: (value) {
                if(value == null ||value.length<=2){
                    return 'Value must be between 1 and 50 characters';
                }
                return null;
              },
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: _qtyValue.toString(),
                  decoration: const InputDecoration(
                      label: Text('Quantity')
                  ),
                  onChanged: (value) {
                    _qtyValue = int.tryParse(value)==null ? 1 :int.parse(value);
                  },
                  validator: (value) {
                    if(int.tryParse(value!)==null || int.tryParse(value)! <=0){
                      return 'Quantity undefined';
                    }
                    return null;
                  },
                )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _catValue,
                      items: [ 
                      for(final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Row(
                          children: [
                            Container(height: 24, width: 24,color: category.value.color ,),
                            const SizedBox(width: 4),
                            Text(category.value.name)
                          ],
                        ),)
                      ],
                      onChanged: (value) {setState(() {
                        _catValue = value;
                      });}),
                )
              ],
            ),
            const SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, 
                child: const Text('Cancel')),
                ElevatedButton(onPressed: (){
                    _submitForm();
                }, child: const Text('Add Item'))
              ],
            )
                  ],
                ),
          )),
    );
  }
}
