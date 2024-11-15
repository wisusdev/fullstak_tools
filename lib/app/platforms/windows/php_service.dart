import 'dart:io';

import 'package:flutter/material.dart';

class PHPService {

    static Future<List<Widget>> actions(BuildContext context) async {

        List<Widget> actions = [];

        Widget downloadButton = IconButton(
            icon: const Icon(Icons.download),
            color: Colors.white,
            onPressed: () {
                install();
            },
        );

        Widget uninstallButton = IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: () {
                uninstall();
            },
        );

    
        String version = await getVersion();
        
        if (version == '') {
            actions.add(downloadButton);
        }

        actions.add(uninstallButton);

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
            print('Error: $error');
            return '';
        }

        return output;
    }

    static Future<void> install() async {

        print('Instalando PHP...');

        var process = await Process.start('choco', ['install', 'php'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }

    static Future<void> uninstall() async {

        print('Desinstalando PHP...');

        var process = await Process.start('choco', ['uninstall', 'php'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }
}