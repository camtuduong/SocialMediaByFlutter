import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialmediaapp/features/auth/home/presentation/components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Build UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: const Text("Home"),
      ),

      //drawer
      drawer: const MyDrawer(),
    );
  }
}
