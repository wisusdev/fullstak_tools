import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class Log {
    File? _file;

    final StreamController<String> _logController = StreamController<String>.broadcast();

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

        final now = DateTime.now().toLocal();
        final formattedDate = '${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}';
        final logMessage = '#[$formattedDate] $level: $message';

        _file!.writeAsStringSync(logMessage, mode: FileMode.append);
        _logController.add(await read()); // Emitir todos los logs actuales
    }

    Stream<String> logStream() async* {
        if (_file == null) {
            await init();
        }
        yield await read(); // Emitir los logs iniciales
        yield* _logController.stream;
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
        _logController.add('');
    }

    Future<String> getLogFilePath() async {
        if (_file == null) {
            await init();
        }
        return _file!.path;
    }
}