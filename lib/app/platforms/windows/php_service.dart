import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/config/app.dart';
import 'package:fullstak_tools/app/shared/app_logs.dart';

class PHPService {

    final String phpVersion;
    var windowsPath = '$windowsInstallPath\\php';
    var phpFileDownloadExtension = 'zip';
    var phpDownloadnUrl = 'https://windows.php.net/downloads/releases';

    PHPService({
        this.phpVersion = 'php-8.4.1-Win32-vs17-x64',
    });

    Future<List<Map<String, dynamic>>> actions(BuildContext context, Function(String) updateServiceActions) async {

        List<Map<String, dynamic>> actions = [];

        Map<String, dynamic> downloadButton = {
            'icon': Icons.download,
            'label': 'Instalar',
            'onPressed': () async {
                await install();
                updateServiceActions('PHP');
            }
        };

        Map<String, dynamic> uninstallButton = {
            'icon': Icons.delete,
            'label': 'Desinstalar',
            'onPressed': () async {
                await uninstall();
                updateServiceActions('PHP');
            }
        };

        Map<String, dynamic> openFolderButton = {
            'icon': Icons.folder_open,
            'label': 'Abrir carpeta de instalación',
            'onPressed': () async {
                await openFolder();
            }
        };

        Map<String, dynamic> addToPathButton = {
            'icon': Icons.add,
            'label': 'Agregar al PATH',
            'onPressed': () async {
                await addToPath();
            }
        };

        String version = await getVersion();
        
        if (version == '') {
            actions.add(downloadButton);
        } else {
            actions.add(addToPathButton);
            actions.add(openFolderButton);
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
                Log().write('$phpVersion instalado', 'INFO');
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
            Log().write('$phpVersion desinstalado', 'INFO');
        }

        return output;
    }

    Future<String> openFolder() async {
        if (!await Directory('$windowsPath\\$phpVersion').exists()) {
            Log().write('Error: El directorio de PHP no existe', 'ERROR');
            return 'Error: El directorio de PHP no existe';
        }

        var process = await Process.start('explorer', ['$windowsPath\\$phpVersion'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
        }

        return output;
    }

    Future<String> addToPath() async {

        if (!await Directory('$windowsPath\\$phpVersion').exists()) {
            Log().write('Error: El directorio de PHP no existe', 'ERROR');
            return 'Error: El directorio de PHP no existe';
        }

        var process = await Process.start('powershell', [
            '-Command',
            '[Environment]::SetEnvironmentVariable("PATH", [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User) + ";$windowsPath\\$phpVersion", [EnvironmentVariableTarget]::User)'
        ], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            Log().write('Error: $error', 'ERROR');
            return 'Error: $error';
        }

        // Verificamos si la carpeta se agrego al PATH
        var processCheck = await Process.start('powershell', [
            '-Command',
            '[System.Environment]::GetEnvironmentVariable(\'Path\', \'User\')'
        ], runInShell: true);

        var pathOutput = await processCheck.stdout.transform(const SystemEncoding().decoder).join();
        var pathError = await processCheck.stderr.transform(const SystemEncoding().decoder).join();

        if (pathError.isNotEmpty) {
            Log().write('Error al verificar el PATH: $pathError', 'ERROR');
            return 'Error al verificar el PATH: $pathError';
        }

        if (pathOutput.contains('$windowsPath\\$phpVersion')) {
            Log().write('$phpVersion agregado al PATH', 'INFO');
        } else {
            Log().write('Error: No se pudo agregar $phpVersion al PATH', 'ERROR');
            return 'Error: No se pudo agregar $phpVersion al PATH';
        }

        return output;
    }
}