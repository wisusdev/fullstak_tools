import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/shared/operating_system.dart';

class LampView extends StatefulWidget {
    const LampView({super.key});

    @override
    State<LampView> createState() => _LampViewState();
}

class _LampViewState extends State<LampView> {

    String platformInfo = 'Loading...';

    @override
    void initState(){
        super.initState();
        _loadPlatformInfo();
    }

    Future<void> _loadPlatformInfo() async {
        String info = await OperatingSystem().getPlatformInfo();
        print(info);
        setState(() {
            platformInfo = info;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Check LAMP'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children:  <Widget>[
                        Text(platformInfo),
                    ],
                ),
            ),
        );
    }
}