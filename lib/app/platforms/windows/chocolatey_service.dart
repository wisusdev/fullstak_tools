import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/shared/app_logs.dart';
import 'package:url_launcher/url_launcher.dart';

class ChocolateyService {

    static List<Widget> actions(BuildContext context) {

        List<Widget> actions = [];

        Widget installButton = IconButton(
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

        Widget siteLink = IconButton(
            icon: const Icon(Icons.link),
            color: Colors.white,
            onPressed: () async {
                final Uri url = Uri.parse('https://community.chocolatey.org/packages');
                
                if(!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
                    throw 'Could not launch $url';
                }
            },
        );

        if (getVersion() == '') {
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

        Log().write('powershell -Command "Start-Process powershell -ArgumentList \"Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://chocolatey.org/install.ps1\'))\" -Verb runAs"', 'INFO');

        var process = await Process.start(
            'powershell',
            [
                '-Command',
                'Start-Process',
                'powershell',
                '-ArgumentList',
                '"Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://chocolatey.org/install.ps1\'))"',
                '-Verb', // -Verb runAs is used to run the process as administrator
                'runAs'
            ],
            runInShell: true,
        );

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        }

        return output;
    }

    static Future<String> uninstall() async {
        Log().write('Uninstalling Chocolatey', 'INFO');

        // Delete Chocolatey folder
        var process = await Process.start(
            'powershell',
            [
                '-Command',
                'Start-Process powershell -ArgumentList "Remove-Item -Path \'C:\\ProgramData\\chocolatey\' -Recurse -Force" -Verb runAs'
            ],
            runInShell: true,
        );

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        }

        Log().write('Chocolatey uninstalled successfully: $output', 'INFO');

        return '';
    }
}