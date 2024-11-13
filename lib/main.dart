import 'package:flutter/material.dart';
import 'package:fullstak_tools/app/views/home_view.dart';
import 'package:fullstak_tools/app/views/xterminal_view.dart';

void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  	const MyApp({super.key});

	@override
  	Widget build(BuildContext context) {
		return MaterialApp(
	  		title: 'Flutter Demo',
	  		
			theme: ThemeData(
				primarySwatch: Colors.blue,
	  		),
	  		
			home: const HomeView(),

            routes: {
                '/home': (context) => const HomeView(),
                '/terminal': (context) => const XTerminalView(),
            },
		);
  	}
}