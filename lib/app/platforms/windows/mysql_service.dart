import 'dart:io';

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
            print('Error: $error');
            return '';
        }

        return output;
    }

    static Future<void> install() async {

        print('Instalando MySQL...');

        var process = await Process.start('choco', ['install', 'mysql'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }

    static Future<void> uninstall() async {

        print('Desinstalando MySQL...');

        var process = await Process.start('choco', ['uninstall', 'mysql'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }
}