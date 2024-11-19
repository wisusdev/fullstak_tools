import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/shared/app_logs.dart';

class PHPService {

    static Future<List<Widget>> actions(BuildContext context, Function(String) updateServiceActions) async {

        List<Widget> actions = [];

        Widget downloadButton = IconButton(
            icon: const Icon(Icons.download),
            color: Colors.white,
            onPressed: () async {
                await install();
                updateServiceActions('PHP');
            },
        );

        Widget uninstallButton = IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: () async {
                await uninstall();
                updateServiceActions('PHP');
            },
        );

        String version = await getVersion();
        
        if (version == '') {
            actions.add(downloadButton);
        } else {
            actions.add(uninstallButton);
        }

        return actions;
    }

    static Future<String> getVersion() async {
        var process = await Process.start('php', ['--version'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        var versionMatch = RegExp(r'PHP (\d+\.\d+\.\d+)').firstMatch(output);
        
        if (versionMatch != null) {
            return versionMatch.group(1) ?? '';
        }

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
            return '';
        }

        return output;
    }

    static Future<void> install() async {

        Log().write('Instalando PHP...', 'INFO');

        var process = await Process.start('choco', ['install', 'php'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        }

        Log().write('PHP instalado - $output', 'INFO');
    }

    static Future<void> uninstall() async {

        Log().write('Desinstalando PHP...', 'INFO');

        var process = await Process.start('choco', ['uninstall', 'php'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        }

        Log().write('PHP desinstalado - $output', 'INFO');
    }
}