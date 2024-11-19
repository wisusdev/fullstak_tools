import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/platforms/windows/apache_service.dart';
import 'package:fullstak_tools/app/platforms/windows/chocolatey_service.dart';
import 'package:fullstak_tools/app/platforms/windows/mysql_service.dart';
import 'package:fullstak_tools/app/platforms/windows/php_service.dart';

class WindowsService {

    static List<Map<String, dynamic>> servicesAvailable  = [
        {
            'name': 'Chcolatey',
            'version': 'unknown',
            'icon': Icons.cloud_download,
            'color': Colors.grey,
        },
        {
            'name': 'PHP',
            'version': 'unknown',
            'icon': Icons.code,
            'color': Colors.grey,
        },
    ];

    static getVersion(String service) {

        if (service == 'Chcolatey') {
            return ChocolateyService.getVersion();
        }

        if (service == 'PHP') {
            return PHPService.getVersion();
        }

        if (service == 'Apache') {
            return ApacheService.getVersion();
        }

        if (service == 'MySQL') {
            return MySQLService.getVersion();
        }

        return null;
    }

    static getActions(BuildContext context, String service, Function(String) updateServiceActions) {    

        if (service == 'Chcolatey') {
            return ChocolateyService.actions(context, updateServiceActions);
        }

        if (service == 'PHP') {
            return PHPService.actions(context, updateServiceActions);
        }

        return <Widget>[];
    }
}