import 'package:cats_dogs_classifier/cnn/home.dart';
import 'package:cats_dogs_classifier/voice/assistenvocal.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('AI Features'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home', icon: Icon(Icons.home)),
              Tab(text: 'CNN', icon: Icon(Icons.image)),
              Tab(text: 'Voice Assistant', icon: Icon(Icons.mic)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),
            Home(),
            Assistenvocal(),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'KARIM BETTACHE \n             & \n ZINEB BENKIRI',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
