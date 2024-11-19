import 'dart:io';

import 'package:fullstak_tools/app/shared/app_logs.dart';

class MySQLService {
    
    static Future<String> getVersion() async {
        var process = await Process.start('mysql', ['--version'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        var versionMatch = RegExp(r'Ver (\d+\.\d+\.\d+)').firstMatch(output);

        if (versionMatch != null) {
            return versionMatch.group(1) ?? '';
        }

        if (error.isNotEmpty) {
            Log().write('Error al obtener la versión de MySQL: $error', 'ERROR');
            return '';
        } else {
            Log().write('Versión de MySQL: $output', 'INFO');
        }

        return output;
    }

    static Future<void> install() async {
        var process = await Process.start('choco', ['install', 'mysql'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al instalar MySQL: $error', 'ERROR');
        } else {
            Log().write('MySQL instalado: $output', 'INFO');
        }
    }

    static Future<void> uninstall() async {
        var process = await Process.start('choco', ['uninstall', 'mysql'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al desinstalar MySQL: $error', 'ERROR');
        } else {
            Log().write('MySQL desinstalado: $output', 'INFO');
        }
    }
}