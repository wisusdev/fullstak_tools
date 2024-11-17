import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/shared/app_logs.dart';
import 'package:url_launcher/url_launcher.dart';

class ChocolateyService {
    
    static Future<List<Widget>> actions(BuildContext context, Function(String) updateServiceActions) async {
        List<Widget> actions = [];

        Widget installButton = IconButton(
            icon: const Icon(Icons.download),
            color: Colors.white,
            onPressed: () async {
                await install();
                updateServiceActions('Chcolatey');
            },
        );

        Widget uninstallButton = IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: () async {
                await uninstall();
                updateServiceActions('Chcolatey');
            },
        );

        Widget siteLink = IconButton(
            icon: const Icon(Icons.link),
            color: Colors.white,
            onPressed: () async {
                final Uri url = Uri.parse('https://community.chocolatey.org/packages');
                if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
                    throw 'Could not launch $url';
                }
            },
        );

        String version = await getVersion();
        if (version == '') {
            actions.add(installButton);
        } else {
            actions.add(uninstallButton);
        }

        actions.add(siteLink);
        return actions;
    }

    static Future<String> getVersion() async {

        // Validate if folder exists
        if (!await Directory('C:\\ProgramData\\chocolatey').exists()) {
            return '';
        }
        
        var process = await Process.start('C:\\ProgramData\\chocolatey\\bin\\choco.exe', ['--version'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        var versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(output);

        if (versionMatch != null) {
            return versionMatch.group(1) ?? '';
        }

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
            return '';
        }

        return output;
    }

    static Future<String> install() async {
        Log().write('Installing Chocolatey', 'INFO');

        var process = await Process.start(
            'powershell',
            [
                '-Command',
                'Start-Process',
                'powershell',
                '-ArgumentList',
                '"Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://chocolatey.org/install.ps1\'))"',
                '-Verb',
                'runAs'
            ],
            runInShell: true,
        );

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        } else {
            Log().write('Chocolatey installed successfully: $output', 'INFO');
        }

        return output;
    }

    static Future<String> uninstall() async {
        Log().write('Uninstalling Chocolatey', 'WARNING');
        String output = await deleteChocolateyFolder();

        // Verificar si la carpeta aún existe y volver a intentar eliminarla
        await Future.delayed(const Duration(seconds: 2)); // Esperar 2 segundos
        
        if (await Directory('C:\\ProgramData\\chocolatey').exists()) {
            Log().write('Retrying to delete Chocolatey folder', 'WARNING');
            output = await deleteChocolateyFolder();
        }

        return output;
    }

    static Future<String> deleteChocolateyFolder() async {
        var process = await Process.start(
            'powershell',
            [
                '-Command',
                'Start-Process',
                'powershell',
                '-ArgumentList',
                '"Remove-Item -Path \'C:\\ProgramData\\chocolatey\' -Recurse -Force"',
                '-Verb',
                'runAs'
            ],
            runInShell: true,
        );

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        } else {
            Log().write('Chocolatey folder deleted successfully', 'INFO');
        }

        return output;
    }
}