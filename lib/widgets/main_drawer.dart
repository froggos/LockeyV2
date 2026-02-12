import 'package:flutter/material.dart';
import 'package:lockey_app/screens/categories.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  void _categoriesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Categories(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 18,
                ),
                Text(
                  'Configuracion',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  onTap: () => _categoriesScreen(context),
                  leading: Icon(
                    Icons.category,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Categorias'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Icon(
                    Icons.copy,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Copia de seguridad'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Icon(
                    Icons.app_registration,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Parametros'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
