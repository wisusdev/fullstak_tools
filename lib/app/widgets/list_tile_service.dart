import 'package:flutter/material.dart';

class ListTileService extends StatelessWidget {

    final Color serviceColor;
    final IconData serviceIcon;
    final String serviceName;
    final String serviceVersion;
    final List<Map<String, dynamic>> serviceActions;

    const ListTileService({
        super.key,
        required this.serviceColor,
        required this.serviceIcon,
        required this.serviceName,
        required this.serviceVersion,
        required this.serviceActions,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
			margin: const EdgeInsets.only(bottom: 10.0),
            
			child: ListTile(
                tileColor: serviceColor,

                shape: RoundedRectangleBorder(
				    borderRadius: BorderRadius.circular(10.0),
			    ),

                leading: Icon(serviceIcon, color: Colors.white),

                title: Text(
                    serviceName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                ),

                subtitle: Text(
                    serviceVersion,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                ),

                trailing: _buildDropdownButton(context),

            )
        );
    }

    Widget _buildDropdownButton(BuildContext context) {
        return PopupMenuButton<Map<String, dynamic>>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'Opciones',
            itemBuilder: (BuildContext context) {
                return serviceActions.map((Map<String, dynamic> action) {
                    return PopupMenuItem<Map<String, dynamic>>(
                        value: action,
                        child: ListTile(
                            leading: Icon(action['icon'], color: Colors.black),
                            title: Text(action['label']),
                        ),
                    );
                }).toList();
            },
            onSelected: (Map<String, dynamic> selectedAction) {
                selectedAction['onPressed']?.call();
            },
        );
    }
}