import 'dart:io';

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
            print('Error: $error');
            return '';
        }

        return output;
    }

    static Future<void> install() async {

        print('Instalando Apache...');

        var process = await Process.start('choco', ['install', 'apache'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }

    static Future<void> uninstall() async {

        print('Desinstalando Apache...');

        var process = await Process.start('choco', ['uninstall', 'apache'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }

    static Future<void> start() async {

        print('Iniciando Apache...');

        var process = await Process.start('httpd', ['-k', 'start'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }

    static Future<void> stop() async {

        print('Parando Apache...');

        var process = await Process.start('httpd', ['-k', 'stop'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }

    static Future<void> restart() async {

        print('Reiniciando Apache...');

        var process = await Process.start('httpd', ['-k', 'restart'], runInShell: true);

        await process.stdin.close();

        var output = await process.stdout.transform(const SystemEncoding().decoder).join();
        var error = await process.stderr.transform(const SystemEncoding().decoder).join();

        if (error.isNotEmpty) {
            print('Error: $error');
        }

        print(output);
    }
}