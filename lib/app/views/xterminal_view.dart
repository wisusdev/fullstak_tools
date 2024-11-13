import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:fullstak_tools/app/widgets/side_menu_drawer.dart';
import 'package:xterm/xterm.dart';

class XTerminalView extends StatefulWidget {
    const XTerminalView({super.key});

    @override
    State<XTerminalView> createState() => _XTerminalViewState();
}

class _XTerminalViewState extends State<XTerminalView> {
    
    late final Pty pty;

    final terminal = Terminal(maxLines: 10000);

    final terminalController = TerminalController();

    @override
    void initState() {
        super.initState();

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

    String get shell {
        if (Platform.isMacOS || Platform.isLinux) {
            return Platform.environment['SHELL'] ?? 'bash';
        }

        if (Platform.isWindows) {
            return 'cmd.exe';
        }

        return 'sh';
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(

            appBar: AppBar(
                title: const Text('Terminal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.yellow[200],
                elevation: 4.0
            ),

            body: LayoutBuilder(
				builder: (context, constraints) {
                    return Column(
                        children: [
                            Expanded(
                                child: Container(
                                    width: constraints.maxWidth,
                                    color: Colors.black,
                                    child: TerminalView(
                                        terminal,
                                        controller: terminalController,
                                        autofocus: true,
                                        backgroundOpacity: 0.7,
                                        textStyle: const TerminalStyle(fontSize: 15),
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
                                ),
                            ),
                        ],
                    );
                },
            ),

            drawer: const SideMenuDrawer(),
        );
    }
}