import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_location/amap_location.dart';
import 'package:async_loader/async_loader.dart';

void main(){
  runApp(new MaterialApp(home: new Home(),routes:{
    "/location/get":(BuildContext context)=>new LocationGet(),
    "/location/listen":(BuildContext content)=>new LocationListen()
  },));
}

class _LocationGetState extends State{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('直接获取定位'),
        ),
        body:new Center(child:new AsyncLoader(
          renderLoad:()=>new CircularProgressIndicator(),
          initState: () async=>await AMapLocationClient.getLocation(true),
          renderSuccess: ({data}){
            AMapLocation loc = data;
            return new Text("定位成功");
          },
          renderError: ([error]){
            return new Text("定位失败");
          },
          
          
        )
        )
    );

  }

  @override
  void initState() {
    super.initState();
  }
}


class LocationGet extends StatefulWidget{

  @override
  State<StatefulWidget> createState()=>new _LocationGetState();


}


class _LocationListenState extends State{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('监听定位改变'),
        ),
        body:null
    );

  }

  @override
  void initState() {

    super.initState();
  }
}

class LocationListen extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>new _LocationListenState();

}


class _HomeState extends State<Home>{

  @override
  void initState() {
    //启动客户端
    AMapLocationClient.startup(new AMapLocationOption());
    super.initState();
  }


  List<Widget> render(BuildContext context,List children){
    return ListTile.divideTiles(context:context,tiles: children.map((dynamic data){
      return buildListTile(context, data["title"], data["subtitle"],data["url"]);
    })).toList();
  }


  Widget buildListTile(BuildContext context,String title,String subtitle,String url){
    return new ListTile(
      onTap: (){
        Navigator.of(context).pushNamed(url);
      },
      isThreeLine: true,
      dense: false,
      leading:null ,
      title: new Text(title),
      subtitle: new Text(subtitle),
      trailing: new Icon(Icons.arrow_right,color: Colors.blueAccent,),
    );
  }


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('高德地图定位'),
        ),
        body: new Scrollbar(child: new ListView(
          children: render(context, [
            {"title":"直接获取定位","subtitle":"不需要先启用监听就可以直接获取定位","url":"/location/get"},
            {"title":"监听定位","subtitle":"启动定位改变监听","url":"/location/listen"}
          ]),

        ))
    );

  }

}

class Home extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }

}


