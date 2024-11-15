import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Log {
    File? _file;

    Future<void> init() async {
        final directory = await getApplicationCacheDirectory();
        _file = File('${directory.path}/app.log');

        if (!_file!.existsSync()) {
            _file!.createSync();
        }
    }

    Future<void> write(String message, String level) async {
        if (_file == null) {
            await init();
        }

        final timestamp = DateTime.now().toIso8601String();
        _file!.writeAsStringSync('$timestamp: $message\n', mode: FileMode.append);
    }

    Future<String> read() async {
        if (_file == null) {
            await init();
        }

        return _file!.readAsStringSync();
    }

    Future<void> clear() async {
        if (_file == null) {
            await init();
        }

        _file!.writeAsStringSync('');
    }
}