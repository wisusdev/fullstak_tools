import 'dart:io';

import 'package:fullstak_tools/app/shared/app_logs.dart';

class ApacheService {

    static Future<String> getVersion() async {
        var process = await Process.start('httpd', ['-v'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        var versionMatch = RegExp(r'Apache/(\d+\.\d+\.\d+)').firstMatch(output);

        if (versionMatch != null) {
            return versionMatch.group(1) ?? '';
        }

        if (error.isNotEmpty) {
            Log().write('Error al obtener la versión de Apache: $error', 'ERROR');
            return '';
        }

        return output;
    }

    static Future<void> install() async {
        var process = await Process.start('choco', ['install', 'apache'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al instalar Apache: $error', 'ERROR');
        } else {
            Log().write('Apache instalado: $output', 'INFO');
        }
    }

    static Future<void> uninstall() async {
        var process = await Process.start('choco', ['uninstall', 'apache'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al desinstalar Apache: $error', 'ERROR');
        } else {
            Log().write('Apache desinstalado: $output', 'INFO');
        }
    }

    static Future<void> start() async {

        var process = await Process.start('httpd', ['-k', 'start'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al iniciar Apache: $error', 'ERROR');
        } else {
            Log().write('Apache iniciado: $output', 'INFO');
        }
    }

    static Future<void> stop() async {
        var process = await Process.start('httpd', ['-k', 'stop'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al detener Apache: $error', 'ERROR');
        } else {
            Log().write('Apache detenido: $output', 'INFO');
        }
    }

    static Future<void> restart() async {
        var process = await Process.start('httpd', ['-k', 'restart'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error al reiniciar Apache: $error', 'ERROR');
        } else {
            Log().write('Apache reiniciado: $output', 'INFO');
        }
    }
}