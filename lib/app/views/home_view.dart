import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/widgets/side_menu_drawer.dart';
import 'package:fullstak_tools/app/shared/responsive_layout.dart';

class HomeView extends StatefulWidget {
	const HomeView({super.key});

  	@override
  	State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

	List<Service> services = [
		Service(name: 'Apache', version: '2.4.46', icon: Icons.web, color: Colors.red),
		Service(name: 'PHP', version: '7.4', icon: Icons.code, color: Colors.blue),
		Service(name: 'MySQL', version: '8.0', icon: Icons.storage, color: Colors.orange),
		Service(name: 'Redis', version: '6.0', icon: Icons.memory, color: Colors.redAccent),
		Service(name: 'Nginx', version: '1.18', icon: Icons.network_check, color: Colors.green),
		Service(name: 'MariaDB', version: '10.5', icon: Icons.storage, color: Colors.blueAccent),
		Service(name: 'MongoDB', version: '4.4', icon: Icons.storage, color: Colors.greenAccent),
	];

  	@override
  	Widget build(BuildContext context) {
    	return Scaffold(

      		appBar: AppBar(
        		title: const Text('Inicio'),
      		),

      		body: LayoutBuilder(
				builder: (context, constraints) {

					Widget buildServiceButton(Service service) {
						return ElevatedButton(
							onPressed: () {
								// Aquí puedes agregar la lógica para obtener el estado del servicio
							},
							style: ElevatedButton.styleFrom(
								foregroundColor: Colors.white, 
                                backgroundColor: service.color,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                ),
							),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Icon(service.icon, color: Colors.white),
                                    const SizedBox(height: 10),
							        Text('${service.name} ${service.version}'),
                                ],
                            ),
						);
					}

					int crossAxisCount;

					if (Responsive.isDesktop(context)) {
						crossAxisCount = 6;
					} else if (Responsive.isTablet(context)) {
						crossAxisCount = 4;
					} else {
						crossAxisCount = 2;
					}
				
					Widget runProcess = Expanded(
						child: Container(
							width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.7, desktop: 0.7),
							padding: const EdgeInsets.all(20.0),
							child: GridView.count(
								crossAxisCount: crossAxisCount,
								crossAxisSpacing: 16.0,
								mainAxisSpacing: 16.0,
								children: services.map((service) => buildServiceButton(service)).toList(),
							),
						),
					);

					Widget infoProcess = Container(
						width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.3, desktop: 0.3),
						color: Colors.green,
						child: const Center(
							child: Text('100% Width Column'),
						),
					);

					List<Widget> children = <Widget>[
						runProcess,
						infoProcess
					];

					return Responsive.isMobile(context) ? Column(children: children) : Row(children: children);
        		},
      		),

      		drawer: const SideMenuDrawer(),
    	);
  	}
}

class Service {
	final String name;
  	final String version;
  	final IconData icon;
  	final Color color;

  	Service({
    	required this.name,
    	required this.version,
    	required this.icon,
    	required this.color,
  	});
}