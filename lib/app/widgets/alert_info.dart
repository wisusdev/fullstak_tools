import 'package:flutter/material.dart';

class AlertInfo extends StatelessWidget {
    const AlertInfo({super.key});

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: const Text('Alerta'),
            content: const Text('Este é um alerta!'),
            actions: <Widget>[
                TextButton(
                    onPressed: () {
                        Navigator.of(context).pop();
                    },
                    child: const Text('Fechar'),
                ),
            ],
        );
    }
}