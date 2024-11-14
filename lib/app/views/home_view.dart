
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

	@override
	void initState() {
		super.initState();

        _loadPlatformInfo();

		for (var service in WindowsService.servicesAvailable) {

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
                        return ListTileService(
                            serviceColor: service['color'],
                            serviceIcon: service['icon'],
                            serviceName: service['name'],
                            serviceVersion: service['version'],
                            serviceActions: WindowsService.getActions(context, service['name']),
                        );
					}

					Widget runProcess = Expanded(
						child: Container(
							width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.4, desktop: 0.3),
							padding: const EdgeInsets.all(20.0),
							child: ListView(
								children: WindowsService.servicesAvailable.map((service) => buildListService(service)).toList(),
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