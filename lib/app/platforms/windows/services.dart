import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/platforms/windows/apache_service.dart';
import 'package:fullstak_tools/app/platforms/windows/chocolatey_service.dart';
import 'package:fullstak_tools/app/platforms/windows/mysql_service.dart';
import 'package:fullstak_tools/app/platforms/windows/php_service.dart';

class WindowsService {

    final PHPService _phpService = PHPService();

    static List<Map<String, dynamic>> servicesAvailable  = [
        {
            'name': 'PHP',
            'version': 'unknown',
            'icon': Icons.code,
            'color': Colors.grey,
        },
    ];

    getVersion(String service) {

        if (service == 'Chcolatey') {
            return ChocolateyService.getVersion();
        }

        if (service == 'PHP') {
            return _phpService.getVersion();
        }

        if (service == 'Apache') {
            return ApacheService.getVersion();
        }

        if (service == 'MySQL') {
            return MySQLService.getVersion();
        }

        return null;
    }

    getActions(BuildContext context, String service, Function(String) updateServiceActions) {    

        if (service == 'Chcolatey') {
            return ChocolateyService.actions(context, updateServiceActions);
        }

        if (service == 'PHP') {
            return _phpService.actions(context, updateServiceActions);
        }

        return <Widget>[];
    }
}