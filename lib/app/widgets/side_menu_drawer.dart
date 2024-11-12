import 'package:flutter/material.dart';

class SideMenuDrawer extends StatelessWidget {
    const SideMenuDrawer({super.key});

    @override
    Widget build(BuildContext context) {
        // Drawer es un widget que muestra un panel lateral que normalmente se usa para proporcionar navegación a través de la aplicación.
        return Drawer(
            // ListView crea un scrollable, linear array de widgets.
            child: ListView(
                // padding es un espacio alrededor del contenido. EdgeInsets.zero es un espacio de 0 en todos los lados.
                padding: EdgeInsets.zero,

                // children es una lista de widgets que se mostrarán en el ListView.
                children: [
                    // DrawerHeader es un widget que muestra un encabezado en un Drawer.
                    const DrawerHeader(
                        // decoration es una propiedad que controla la apariencia de un widget.
                        decoration: BoxDecoration(
                            color: Colors.blue,
                        ),
                        // child es un widget que se muestra en el DrawerHeader. En este caso, es un Text. 
                        child: Text('Menú', style: TextStyle(color: Colors.white)),
                    ),
                    // ListTile es un widget que muestra un elemento en un ListView.
                    ListTile(
                        // title es un widget que se muestra en la parte superior de un ListTile.
                        title: const Text('Inicio'),
                        // onTap es una devolución de llamada que se llama cuando el usuario toca el ListTile.
                        onTap: () {
                            // Navigator.pop es una función que elimina la ruta actual de la pila de rutas y navega a la ruta anterior.
                            Navigator.pop(context);
                        },
                    ),
                    ListTile(
                        title: const Text('Configuración'),
                        onTap: () {
                            Navigator.pop(context);
                        },
                    ),
                ],
            ),
        );
    }
}