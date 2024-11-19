import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/platforms/windows/services.dart';
import 'package:fullstak_tools/app/shared/app_logs.dart';
import 'package:fullstak_tools/app/shared/operating_system.dart';
import 'package:fullstak_tools/app/widgets/list_tile_service.dart';
import 'package:fullstak_tools/app/widgets/side_menu_drawer.dart';
import 'package:fullstak_tools/app/shared/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatefulWidget {
	const HomeView({super.key});

  	@override
  	State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

    String sistemVersion = '';
    List<Map<String, dynamic>> servicesAvailable =[];
    final Log _log = Log();
    final ScrollController _scrollController = ScrollController();

    Stream<String> get logStream => _log.logStream();

	@override
	void initState() {
		super.initState();
        _log.init(); // Inicializar el log al iniciar el estado

        if(Platform.isWindows) servicesAvailable = WindowsService.servicesAvailable;
        
        _loadPlatformInfo();

		for (var service in servicesAvailable) {

			var version = WindowsService.getVersion(service['name']);
            
			if (version != null) {
				version.then((value) {
                    _log.write('Service ${service['name']} version: $value', 'INFO');
					setState(() {
						service['version'] = value != '' ? value : 'Not installed';
                        service['color'] = value != '' ? Colors.green : Colors.grey;
					});
				});
			}
		}
	}

    Future<void> _loadPlatformInfo() async {
        String version = await OperatingSystem().getPlatformInfo();
        if (mounted) {
            setState(() {
                sistemVersion = version;
            });
        }
    }

    Future<void> _clearLogs() async {
        await _log.clear();
        if (mounted) {
            setState(() {});
        }
    }

    Future<void> _showLogFilePath() async {
        String path = await _log.getLogFilePath();
        if (mounted) {
            showDialog(
                context: context,
                builder: (context) {
                    return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                        ),
                        title: const Text('Log file path'),
                        content: Text(path),
                        actions: [
                            TextButton(
                                onPressed: () {
                                    Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                            ),
                            TextButton(
                                onPressed: () {
                                    OperatingSystem().copyToClipboard(path);
                                },
                                child: const Text('Copy Path'),
                            )
                        ],
                    );
                },
            );
        }
    }

    Future<List<Widget>> getSystemServiceAction(BuildContext context, String service) async {
        if (Platform.isWindows) {
            return await WindowsService.getActions(context, service, _updateServiceActions);
        }
        return [];
    }

    Future<void> _reloadLogs() async {
        await _log.init();
        if (mounted) {
            setState(() {});
        }
    }

    void _scrollToBottom() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
        });
    }

    void _updateServiceActions(String serviceName) async {
        var version = await WindowsService.getVersion(serviceName);
        
        print('Service $serviceName version: $version');

        setState(() {
            var service = servicesAvailable.firstWhere((service) => service['name'] == serviceName);
            service['version'] = version != '' ? version : 'Not installed';
            service['color'] = version != '' ? Colors.green : Colors.grey;
        });
    }

  	@override
  	Widget build(BuildContext context) {
    	return Scaffold(

      		// AppBar con título y acciones
      		appBar: AppBar(
        		title: Text(sistemVersion, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.yellow[200],
                elevation: 4.0,
                actions: [
                    // Botón para recargar logs
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                            _reloadLogs();
                        },
                    ),
                    // Botón para limpiar logs
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                            _clearLogs();
                        },
                    ),
                    // Botón para mostrar la ruta del archivo de logs
                    IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () {
                            _showLogFilePath();
                        },
                    ),
                ],
      		),

      		// LayoutBuilder para construir la interfaz de usuario de manera responsiva
      		body: LayoutBuilder(
				builder: (context, constraints) {

					// Función para construir el widget ListTileService para cada servicio
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

					// Widget que muestra la lista de servicios disponibles
					Widget runProcess = Expanded(
						child: Container(
							width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.4, desktop: 0.3),
							padding: const EdgeInsets.all(20.0),
							child: ListView(
								children: servicesAvailable.map((service) => buildListService(service)).toList(),
							),
						),
					);

					// Widget que muestra los logs en tiempo real
					Widget logsInfo = Container(
						width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.6, desktop: 0.7),
                        decoration: const BoxDecoration(
                            color: Colors.black,
                        ),
						child: StreamBuilder<String>(
                            // Escucha el stream de logs
                            stream: logStream,
                            builder: (context, snapshot) {
                                // Muestra un indicador de carga mientras se espera por datos
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(color: Colors.white,));
                                // Muestra un mensaje de error si ocurre un error
                                } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                // Muestra un mensaje si no hay datos disponibles
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('No logs available', style: TextStyle(color: Colors.white)));
                                // Muestra los logs en una lista si hay datos disponibles
                                } else {
                                    // Divide los logs en líneas utilizando '#' como delimitador y elimina saltos de línea adicionales
                                    List<String> logLines = snapshot.data!.split('#').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

                                    // Desplaza automáticamente la lista de logs hacia abajo cuando se actualizan los datos
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                                    // Construye una lista de widgets para cada línea de log
                                    return ListView.builder(
                                        controller: _scrollController,
                                        itemCount: logLines.length,
                                        itemBuilder: (context, index) {
                                            String logLine = logLines[index];

                                            Color textColor = Colors.white;

                                            if (logLine.contains('ERROR')) {
                                                textColor = Colors.red;
                                            } else if (logLine.contains('WARNING')) {
                                                textColor = Colors.yellow;
                                            } else if (logLine.contains('INFO')) {
                                                textColor = Colors.green;
                                            } else if (logLine.contains('DEBUG')) {
                                                textColor = Colors.blue;
                                            }

                                            // Retorna un widget SelectableText con el texto de la línea de log
                                            return SelectableText.rich(
                                                TextSpan(
                                                    text: logLine, 
                                                    style: GoogleFonts.getFont('Ubuntu Mono', color: textColor, fontSize: 16.0)
                                                ),
                                            );
                                        },
                                    );
                                }
                            },
                        ),
					);

					// Lista de widgets hijos que se muestran en la interfaz
					List<Widget> children = <Widget>[
						runProcess,
                        Responsive.isMobile(context) ? Expanded(child: logsInfo) : logsInfo,
					];

					// Retorna una columna o fila dependiendo del tamaño de la pantalla
					return Responsive.isMobile(context) ? Column(children: children) : Row(children: children);
        		},
      		),

      		// Drawer lateral con el menú
      		drawer: const SideMenuDrawer(),
    	);
  	 }
}