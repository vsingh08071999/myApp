import 'package:flutter/material.dart';
import 'package:newapplication/scanner/scannerHomeScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Column(
        children: [
          RaisedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ScannerHomeScreen()));
            },
            color: Colors.red,
            child: Text("NextPage"),
          )
        ],
      ),
    );
  }
}
