/*
 SETTINGS PAGE NEKK

 CAC THANH PHAN 
 -  darkMode
 -  Blocked users
 -  account settings
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  //  Build UI
  @override
  Widget build(BuildContext context) {
    //theme cubit
    final themeCubit = context.watch<ThemeCubit>();

    //is dark mode
    bool isDarkMode = themeCubit.isDarkMode;

    //
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          //dark mode tile
          ListTile(
            title: const Text(
              "Dark Mode",
            ),
            textColor: Theme.of(context).colorScheme.primary,
            trailing: CupertinoSwitch(
                value: isDarkMode,
                onChanged: (value) {
                  themeCubit.toggleTheme();
                }),
          ),
        ],
      ),
    );
  }
}
