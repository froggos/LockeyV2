import 'package:flutter/material.dart';
import 'package:lockey_app/store/storage.dart';
import 'package:lockey_app/models/category.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _Categories();
}

class _Categories extends State<Categories> {
  final TextEditingController _categoryNameController = TextEditingController();
  final List<Category> _categoryList = [];

  Future<void> _loadCategories() async {
    final actualList = await LockeyStorage.getCategories();

    setState(() {
      _categoryList.addAll(actualList);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 17,
          right: 17,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: "Nombre de nueva categoria",
                        filled: true,
                        fillColor: const Color(0xFF4A5782),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                        )),
                    controller: _categoryNameController,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 17),
            SizedBox(
              height: MediaQuery.of(context).size.height - 300,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5782),
                  borderRadius: BorderRadius.circular(40),
                ),
                // child: ListView.builder(
                //   padding: const EdgeInsets.all(12),
                //
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
