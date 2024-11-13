import 'dart:io';

class ChocolateyService {

    static Future<String> getVersion() async {
        var process = await Process.start('choco', ['--version'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        var versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(output);

        if (versionMatch != null) {
            return versionMatch.group(1) ?? '';
        }

        if (error.isNotEmpty) {
            print('Error: $error');
            return '';
        }

        return output;
    }

    static Future<String> install() async {

        print('Instalando Chocolatey...');

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
            print('Error: $error');
        }

        print(output);

        return output;
    }
}