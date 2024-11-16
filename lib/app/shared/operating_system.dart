import 'dart:io';

class OperatingSystem {
    
	Future<String> getPlatformInfo() async {
  		if (Platform.isLinux) {
    		var result = await Process.run('cat', ['/etc/os-release']);
      		return getDistroInfo(result.stdout.toString().trim());
  		} else if (Platform.isMacOS) {
    		return 'MacOS';
  		} else if (Platform.isWindows) {
            ProcessResult result = await Process.run('systeminfo', []);
            String output = result.stdout.toString();
            return getWindowsVersion(output);
  		} else if (Platform.isAndroid) {
    		return 'Android';
  		} else if (Platform.isIOS) {
    		return 'iOS';
  		} else {
    		return 'Unknown';
  		}
	}

	String getDistroInfo(String osReleaseInfo) {
		final nameRegex = RegExp(r'^NAME="(.+)"$', multiLine: true);
		final versionRegex = RegExp(r'^VERSION="(.+)"$', multiLine: true);

		final nameMatch = nameRegex.firstMatch(osReleaseInfo);
		final versionMatch = versionRegex.firstMatch(osReleaseInfo);

		String name = 'Desconocido';
		String version = 'Desconocido';

		if (nameMatch != null && nameMatch.groupCount >= 1) {
			name = nameMatch.group(1)!;
		}

		if (versionMatch != null && versionMatch.groupCount >= 1) {
			version = versionMatch.group(1)!;
		}

		return '$name, $version';
	}

    String getWindowsVersion(String systemInfo) {
        final versionRegex = RegExp(r'.*Microsoft Windows (\d+ \w+)', multiLine: true);
        final versionMatch = versionRegex.firstMatch(systemInfo);

        if (versionMatch != null && versionMatch.groupCount >= 1) {
            return 'Windows ${versionMatch.group(1)}';
        }

        return 'Windows';
    }
}