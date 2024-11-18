import 'dart:io';

import 'package:fullstak_tools/app/shared/app_logs.dart';

Future<String?> solicitarContrasena() async {
    String? contrasena = stdin.readLineSync();
    return contrasena;
}

Future<void> instalarEnLinux() async {
    String? contrasena = await solicitarContrasena();

    var process = await Process.start('sudo', ['-S', 'apt', 'update'], runInShell: true);

    process.stdin.writeln(contrasena);

    await process.stdin.close();

    var output = await process.stdout.transform(const SystemEncoding().decoder).join();
    var error = await process.stderr.transform(const SystemEncoding().decoder).join();
    
    if (error.isNotEmpty) {
        Log().write('Error al actualizar el repositorio en Linux: $error', 'ERROR');
    } else {
        Log().write('Repositorio actualizado en Linux: $output', 'INFO');
    }
}