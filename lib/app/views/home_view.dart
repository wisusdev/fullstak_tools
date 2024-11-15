import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/platforms/windows/services.dart';
import 'package:fullstak_tools/app/shared/operating_system.dart';
import 'package:fullstak_tools/app/widgets/list_tile_service.dart';
import 'package:fullstak_tools/app/widgets/side_menu_drawer.dart';
import 'package:fullstak_tools/app/shared/responsive_layout.dart';

class HomeView extends StatefulWidget {
	const HomeView({super.key});

  	@override
  	State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

    String sistemVersion = '';
    List<Map<String, dynamic>> servicesAvailable =[];

	@override
	void initState() {
		super.initState();

        if(Platform.isWindows) servicesAvailable = WindowsService.servicesAvailable;
        

        _loadPlatformInfo();

		for (var service in servicesAvailable) {

			var version = WindowsService.getVersion(service['name']);

			if (version != null) {
				version.then((value) {
					setState(() {
						service['version'] = value;
                        service['color'] = Colors.green;
					});
				});
			}
		}
	}

    Future<void> _loadPlatformInfo() async {
        String version = await OperatingSystem().getPlatformInfo();

        setState(() {
            sistemVersion = version;
        });
    }

    Future<List<Widget>> getSystemServiceAction(BuildContext context, String service) async{
        if(Platform.isWindows) {
            return await WindowsService.getActions(context, service); 
        }

        return [];
    }

  	@override
  	Widget build(BuildContext context) {
    	return Scaffold(

      		appBar: AppBar(
        		title: Text(sistemVersion, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.yellow[200],
                elevation: 4.0
      		),

      		body: LayoutBuilder(
				builder: (context, constraints) {

					Widget buildListService(service) {
                        return FutureBuilder<List<Widget>>(
                            future: getSystemServiceAction(context, service['name']),
                            builder: (context, snapshot) {
                                List<Widget> actions;

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                    actions = [const CircularProgressIndicator(color: Colors.white,)];
                                } else if (snapshot.hasError) {
                                    actions = [Text('Error: ${snapshot.error}')];
                                } else {
                                    actions = snapshot.data ?? [];
                                }

                                return ListTileService(
                                    serviceColor: service['color'],
                                    serviceIcon: service['icon'],
                                    serviceName: service['name'],
                                    serviceVersion: service['version'],
                                    serviceActions: actions,
                                );
                            },
                        );
                    }

					Widget runProcess = Expanded(
						child: Container(
							width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.4, desktop: 0.3),
							padding: const EdgeInsets.all(20.0),
							child: ListView(
								children: servicesAvailable.map((service) => buildListService(service)).toList(),
							),
						),
					);

					Widget logsInfo = Container(
						width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.6, desktop: 0.7),
                        decoration: const BoxDecoration(
                            color: Colors.black,
                        ),
						child: ListView(
                            children: const [
                                Text('Logs', style: TextStyle(color: Colors.white)),
                            ],
                        ),
					);

					List<Widget> children = <Widget>[
						runProcess,
                        Responsive.isMobile(context) ? Expanded(child: logsInfo) : logsInfo,
					];

					return Responsive.isMobile(context) ? Column(children: children) : Row(children: children);
        		},
      		),

      		drawer: const SideMenuDrawer(),
    	);
  	}
}