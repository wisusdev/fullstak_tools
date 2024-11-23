import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/config/app.dart';
import 'package:fullstak_tools/app/shared/app_logs.dart';

class PHPService {

    var windowsPath = '$windowsInstallPath\\php';

    var phpVersion = 'php-8.4.1-Win32-vs17-x64';
    var phpFileDownloadExtension = 'zip';
    var phpDownloadnUrl = 'https://windows.php.net/downloads/releases';

    Future<List<Widget>> actions(BuildContext context, Function(String) updateServiceActions) async {

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

    Future<String> getVersion() async {
        if (!await Directory('$windowsPath\\$phpVersion').exists()) {
            return '';
        }

        var process = await Process.start('$windowsPath\\$phpVersion\\php.exe', ['--version'], runInShell: true);

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

    Future<String> install() async {

        var process = await Process.start('powershell', [
            '-Command',
            'Invoke-WebRequest -Uri "$phpDownloadnUrl/$phpVersion.$phpFileDownloadExtension" -OutFile "$phpVersion.$phpFileDownloadExtension"; Expand-Archive -Path "$phpVersion.$phpFileDownloadExtension" -DestinationPath "$windowsPath\\$phpVersion"; if (Test-Path "$windowsPath\\$phpVersion.$phpFileDownloadExtension") { Remove-Item -Path "$windowsPath\\$phpVersion.$phpFileDownloadExtension"; }'
        ], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        }

        // Espera unos segundos adicionales para asegurarse de que la carpeta se haya creado
        await Future.delayed(const Duration(seconds: 10));

        // verificamos si la carpeta se creo cada 2 segundos, pero finalizamos despues de 60 segundos
        int elapsedSeconds = 0;
        const int checkInterval = 2;
        const int timeout = 60;

        while (elapsedSeconds < timeout) {
            if (await Directory('$windowsPath\\$phpVersion').exists()) {
                Log().write('PHP instalado - $output', 'INFO');
                break;
            }

            await Future.delayed(const Duration(seconds: checkInterval));
            elapsedSeconds += checkInterval;
        }

        if (elapsedSeconds >= timeout) {
            Log().write('Error al instalar PHP: No se encontró la carpeta de instalación', 'ERROR');
        }

        return output;
    }

    Future<String> uninstall() async {
        if (!await Directory('$windowsPath\\$phpVersion').exists()) {
            Log().write('Error: El directorio de PHP no existe', 'ERROR');
            return 'Error: El directorio de PHP no existe';
        }

        var process = await Process.start('powershell', [
            '-Command',
            'Remove-Item -Recurse -Force "$windowsPath\\$phpVersion"'
        ], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        } else {
            Log().write('PHP desinstalado', 'INFO');
        }

        return output;
    }
}