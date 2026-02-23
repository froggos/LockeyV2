import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lockey_app/models/category.dart';
import 'package:lockey_app/models/password.dart';
import 'package:lockey_app/store/storage.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final List<Category> _defaultCategories = [];

  String _enteredAccountName = '';
  String _enteredSite = '';
  Category? _selectedCategory;

  bool _isCapitalChecked = true;
  bool _isLowerChecked = true;
  bool _isNumbersChecked = true;
  bool _isSpecialChecked = true;
  double _passwordLength = 15;

  String _generatePassword() {
    String caracteres =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+{}[]";

    if (!_isCapitalChecked) {
      caracteres = caracteres.replaceAll(RegExp(r'[A-Z]'), '');
    }

    if (!_isLowerChecked) {
      caracteres = caracteres.replaceAll(RegExp(r'[a-z]'), '');
    }

    if (!_isNumbersChecked) {
      caracteres = caracteres.replaceAll(RegExp(r'[0-9]'), '');
    }

    if (!_isSpecialChecked) {
      caracteres = caracteres.replaceAll(RegExp(r'[!@#\$%^&*()_+{}\[\]]'), '');
    }

    if (caracteres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un tipo de caracter'),
        ),
      );

      return '';
    }

    final random = Random.secure();

    return String.fromCharCodes(Iterable.generate(_passwordLength.toInt(),
        (_) => caracteres.codeUnitAt(random.nextInt(caracteres.length))));
  }

  void _savePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPassword = Password(
        accountName: _enteredAccountName,
        password: _passwordTextController.text,
        site: _enteredSite,
        category: _selectedCategory,
      );

      final navigator = Navigator.of(context);

      final generatedId = await LockeyStorage.savePassword(newPassword);

      final savedPassword = Password(
          id: generatedId,
          accountName: newPassword.accountName,
          password: newPassword.password,
          site: newPassword.site,
          category: newPassword.category,
      );

      navigator.pop(savedPassword);
    }
  }

  Future<void> _loadCategories() async {
    final actualList = await LockeyStorage.getCategories();

    setState(() {
      _defaultCategories.addAll(actualList);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadCategories();

    if (_passwordTextController.text.isEmpty) {
      _passwordTextController.text = _generatePassword();
    }
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Generar contraseña'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 17,
          right: 17,
          top: 17,
          bottom: bottomInset > 0 ? bottomInset + 16 : 80,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
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
                        ),
                      ),
                      controller: _passwordTextController,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordTextController.text = _generatePassword();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre';
                  }

                  return null;
                },
                maxLength: 50,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nombre de cuenta',
                  filled: true,
                  fillColor: const Color(0xFF252C41),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFF252C41)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFF252C41)),
                  ),
                ),
                onSaved: (value) {
                  _enteredAccountName = value!;
                },
              ),
              const SizedBox(height: 7),
              TextFormField(
                maxLength: 50,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Sitio',
                  filled: true,
                  fillColor: const Color(0xFF252C41),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFF252C41)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFF252C41)),
                  ),
                ),
                onSaved: (value) {
                  _enteredSite = value!;
                },
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(
                  hintText: 'Selecciona una categoria',
                  filled: true,
                  fillColor: const Color(0xFF252C41),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFF252C41)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFF252C41)),
                  ),
                ),
                initialValue: null,
                items: _defaultCategories.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (Category? newCategory) {
                  setState(() {
                    _selectedCategory = newCategory;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Longitud',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  showValueIndicator: ShowValueIndicator.onDrag,
                  activeTrackColor: const Color(0xFF52618E),
                ),
                child: Slider(
                  value: _passwordLength,
                  onChanged: (newLength) {
                    setState(() {
                      _passwordLength = newLength;
                      _passwordTextController.text = _generatePassword();
                    });
                  },
                  label: _passwordLength.toStringAsFixed(0),
                  min: 10,
                  max: 30,
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Mayúsculas (ABC)",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                value: _isCapitalChecked,
                onChanged: (value) {
                  setState(() {
                    _isCapitalChecked = value ?? false;
                    _passwordTextController.text = _generatePassword();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Minúsculas (abc)",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                value: _isLowerChecked,
                onChanged: (value) {
                  setState(() {
                    _isLowerChecked = value ?? false;
                    _passwordTextController.text = _generatePassword();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Números (123)",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                value: _isNumbersChecked,
                onChanged: (value) {
                  setState(() {
                    _isNumbersChecked = value ?? false;
                    _passwordTextController.text = _generatePassword();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Especiales ({}[]!@#)",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                value: _isSpecialChecked,
                onChanged: (value) {
                  setState(() {
                    _isSpecialChecked = value ?? false;
                    _passwordTextController.text = _generatePassword();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ElevatedButton(
          onPressed: _savePassword,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Guardar'),
        ),
      ),
    );
  }
}
