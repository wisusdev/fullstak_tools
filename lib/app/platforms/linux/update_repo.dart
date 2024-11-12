import 'dart:io';

Future<String?> solicitarContrasena() async {
    print('Por favor, ingrese su contraseña de administrador:');
    String? contrasena = stdin.readLineSync();
    return contrasena;
}

Future<void> instalarEnLinux() async {
    String? contrasena = await solicitarContrasena();

    print('Actualizando lista de paquetes...');

    var process = await Process.start('sudo', ['-S', 'apt', 'update'], runInShell: true);

    process.stdin.writeln(contrasena);

    await process.stdin.close();

    var output = await process.stdout.transform(const SystemEncoding().decoder).join();
    var error = await process.stderr.transform(const SystemEncoding().decoder).join();

    print(output);
    
    if (error.isNotEmpty) {
        print('Error: $error');
    }
}