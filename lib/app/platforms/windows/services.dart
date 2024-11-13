import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/platforms/windows/apache_service.dart';
import 'package:fullstak_tools/app/platforms/windows/mysql_service.dart';
import 'package:fullstak_tools/app/platforms/windows/php_service.dart';

class WindowsService {

	final String name;
  	String version;
  	final IconData icon;
  	Color color;

  	WindowsService({
    	required this.name,
    	required this.version,
    	required this.icon,
    	required this.color,
  	});

    static getVersion(String service) {

        if (service == 'PHP') {
            return PHPService.getVersion();
        }

        if (service == 'Apache') {
            return ApacheService.getVersion();
        }

        if (service == 'MySQL') {
            return MySQLService.getVersion();
        }
    }

    static getActions(BuildContext context, String service) {    
        if (service == 'PHP') {
            return PHPService.actions(context);
        }

        return <Widget>[];
    }
}