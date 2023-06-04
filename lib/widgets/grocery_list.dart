import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/new_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';


class GroceryList extends StatefulWidget{
  const GroceryList({super.key});

  

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var isLoading = true;
  Widget loadRes = const Center(child: CircularProgressIndicator());
  List<GroceryItem> groceries = [];
  void _addItem() async {
    final item = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                  return const NewItem();
              }));
    setState(() {
      groceries.add(item);
    });
    
      
  }
  void _getItems() async{
    try{
final url = Uri.https('shopping-list-flutter-4dd4a-default-rtdb.firebaseio.com','shopping-list.json');
    final response = await http.get(url);
    setState(() {
      isLoading = false;
    });
    final Map<String,dynamic> listData = json.decode(response.body);
    final List<GroceryItem> listItems = [];
    for(final entry in listData.entries){
      final category = categories.entries.firstWhere((element) => element.value.name == entry.value['category'] ).value;
      listItems.add(GroceryItem(id: entry.key, name: entry.value['name'], quantity: entry.value['quantity'],category: category));
    }

    setState(() {
       groceries = listItems;
    });
    if(response.body == 'null'){
      
    }
    } catch(error){
      print(error);
      setState(() {
        loadRes = const Center(child: Text('Something went wrong...'),);
      });
    }
    
    
        
 
  }
  void _deleteItem(GroceryItem item) async{
         final url = Uri.https('shopping-list-flutter-4dd4a-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
         final response = await http.delete(url);

        setState(() {
          groceries.remove(item);
        });
         
  }
  @override
  void initState(){
    super.initState();
    _getItems();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem,
             icon: const Icon(Icons.add))
          ],
          ),
        body: isLoading ? loadRes : groceries.isEmpty ? const Center(child: Text('There are currently no items in the list...')) :ListView.builder(
      itemCount: groceries.length,
      itemBuilder: (ctx,index){
      return Dismissible(
        key: ValueKey(groceries[index].id),
        onDismissed: (dir){
          _deleteItem(groceries[index]);
            
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 24,
                width:24,
                color: groceries[index].category.color
              ),
              const SizedBox(width: 16,),
              Text(groceries[index].name),
              const Spacer(),
              Text(groceries[index].quantity.toString())
            ],
          ),
        ),
      );
    })
      );
  }
}