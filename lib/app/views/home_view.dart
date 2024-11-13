import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:fullstak_tools/app/platforms/windows/services.dart';
import 'package:fullstak_tools/app/shared/operating_system.dart';
import 'package:fullstak_tools/app/widgets/list_tile_service.dart';
import 'package:fullstak_tools/app/widgets/side_menu_drawer.dart';
import 'package:fullstak_tools/app/shared/responsive_layout.dart';
import 'package:xterm/xterm.dart';

class HomeView extends StatefulWidget {
	const HomeView({super.key});

  	@override
  	State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

    String sistemVersion = '';

	List<WindowsService> services = [
		WindowsService(name: 'Apache', version: 'unknown', icon: Icons.dns, color: Colors.grey),
		WindowsService(name: 'PHP', version: 'unknown', icon: Icons.code, color: Colors.grey),
		WindowsService(name: 'MySQL', version: 'unknown', icon: Icons.storage, color: Colors.grey),
	];

    late final Pty pty;

    final terminal = Terminal(
        maxLines: 10000,
    );

	@override
	void initState() {
		super.initState();
        _loadPlatformInfo();

		for (var service in services) {

			var version = WindowsService.getVersion(service.name);

			if (version != null) {
				version.then((value) {
					setState(() {
						service.version = value;
                        service.color = Colors.green;
					});
				});
			}
		}

        WidgetsBinding.instance.endOfFrame.then(
            (_) {
                if (mounted) _startPty();
            },
        );
	}

    void _startPty() {
        pty = Pty.start(
            shell,
            columns: terminal.viewWidth,
            rows: terminal.viewHeight,
        );

        pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);

        pty.exitCode.then((code) {
            terminal.write('the process exited with exit code $code');
        });

        terminal.onOutput = (data) {
            pty.write(const Utf8Encoder().convert(data));
        };

        terminal.onResize = (w, h, pw, ph) {
            pty.resize(h, w);
        };
    }

    Future<void> _loadPlatformInfo() async {
        String version = await OperatingSystem().getPlatformInfo();

        setState(() {
            sistemVersion = version;
        });
    }

    final terminalController = TerminalController();

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

					Widget buildListService(WindowsService service) {
                        return ListTileService(
                            serviceColor: service.color,
                            serviceIcon: service.icon,
                            serviceName: service.name,
                            serviceVersion: service.version,
                            serviceActions: WindowsService.getActions(context, service.name),
                        );
					}

					Widget runProcess = Expanded(
						child: Container(
							width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.4, desktop: 0.3),
							padding: const EdgeInsets.all(20.0),
							child: ListView(
								children: services.map((service) => buildListService(service)).toList(),
							),
						),
					);

					Widget infoProcess = Container(
						width: Responsive.containerMaxWidthSize(context, constraints, mobile: 1, tablet: 0.6, desktop: 0.7),
                        decoration: const BoxDecoration(
                            color: Colors.black,
                        ),
						child: TerminalView(
                            terminal,
                            controller: terminalController,
                            autofocus: true,
                            backgroundOpacity: 0.7,
                            onSecondaryTapDown: (details, offset) async {
                                final selection = terminalController.selection;
                                
                                if (selection != null) {
                                    final text = terminal.buffer.getText(selection);
                                    terminalController.clearSelection();
                                    await Clipboard.setData(ClipboardData(text: text));
                                } else {
                                    final data = await Clipboard.getData('text/plain');
                                    final text = data?.text;
                                    
                                    if (text != null) {
                                        terminal.paste(text);
                                    }
                                }
                            },
                        ),
					);



					List<Widget> children = <Widget>[
						runProcess,
                        Responsive.isMobile(context) ? Expanded(child: infoProcess) : infoProcess,
					];

					return Responsive.isMobile(context) ? Column(children: children) : Row(children: children);
        		},
      		),

      		drawer: const SideMenuDrawer(),
    	);
  	}
}

String get shell {
    if (Platform.isMacOS || Platform.isLinux) {
        return Platform.environment['SHELL'] ?? 'bash';
    }

    if (Platform.isWindows) {
        return 'cmd.exe';
    }

    return 'sh';
}