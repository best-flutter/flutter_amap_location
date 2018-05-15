import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_location/amap_location.dart';


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  initState() {
    super.initState();

    new AMapLocationOption(
        locationMode:AMapLocationMode.Hight_Accuracy
    );

    print(AMapLocationMode.Hight_Accuracy.toString());
  }


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('高德地图定位'),
        ),
        body: new Center(
          child: new Text('Running on: \n'),
        ),
      ),
    );
  }
}
