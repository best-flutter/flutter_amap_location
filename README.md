
<p align="center">
    <a href="https://pub.dartlang.org/packages/amap_location">
        <img src="https://img.shields.io/pub/v/amap_location.svg" alt="pub package" />
    </a>
</p>
# flutter_amap_location


![android preview](https://github.com/jzoom/images/raw/master/location1.gif)

![ios preview](https://github.com/jzoom/images/raw/master/location2.gif)

高德地图定位flutter组件。

目前实现直接获取定位和监听定位功能。

注意：随着flutter版本的提升， 本项目也会随之更新，


如果有疑问或者对这个库感兴趣，可以加qq群:854192563一起探讨


## Getting Started

### 集成高德地图定位android版本

1、先申请一个apikey
http://lbs.amap.com/api/android-sdk/guide/create-project/get-key

2、修改 `你的项目目录/app/build.gradle`
在`android/defaultConfig`节点修改`manifestPlaceholders`,新增高德地图key配置

```
android {
    .... 你的代码

    defaultConfig {
        .....
        manifestPlaceholders = [
                AMAP_KEY : "aa9f0cf8574400f2af0078392c556e25", /// 高德地图key
        ]

    }

```


### 集成高德地图定位ios版本

1、申请一个key
http://lbs.amap.com/api/ios-sdk/guide/create-project/get-key

直接在dart文件中设置key

```
import 'package:amap_location/amap_location.dart';
   
   void main(){     
       AMapLocationClient.setApiKey("你的key");
     runApp(new MyApp());
   }
```

2、在info.plist中增加:

注意必须要描述清楚app使用定位的目的，苹果审核的时候要看，
如果写的不清楚，可能会被苹果拒绝上架，作者有过几次惨痛经历 :(

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>要用定位</string>
```


## 怎么用

先导入dart包
修改pubspec.yaml，增加依赖：

```
dependencies:
  amap_location: 
```


在要用的地方导入:

```
import 'package:amap_location/amap_location.dart';
```

先启动一下

```
 await AMapLocationClient.startup(new AMapLocationOption( desiredAccuracy:CLLocationAccuracy.kCLLocationAccuracyHundredMeters  ));

```

直接获取定位:

```
await AMapLocationClient.getLocation(true)
```
监听定位

```

    AMapLocationClient.onLocationUpate.listen((AMapLocation loc){
      if(!mounted)return;
      setState(() {
         ...
      });
    });

    AMapLocationClient.startLocation();

```
停止监听定位
```
AMapLocationClient.stopLocation();

```

不要忘了在app生命周期结束的时候关闭
```
@override
  void dispose() {
    //注意这里关闭
    AMapLocationClient.shutdown();
    super.dispose();
  }
```


## 注意点：

>在android6以上最好手动获取定位权限

在example中以simple_permissions这个库为例:

```
void _checkPersmission() async{
    bool hasPermission = await SimplePermissions.checkPermission(Permission.WhenInUseLocation);
    if(!hasPermission){
      bool requestPermissionResult = await SimplePermissions.requestPermission(Permission.WhenInUseLocation);
      if(!requestPermissionResult){
        Alert.alert(context,title: "申请定位权限失败");
        return;
      }
    }
    AMapLocationClient.onLocationUpate.listen((AMapLocation loc) {
      if (!mounted) return;
      setState(() {
        location = getLocationStr(loc);
      });
    });

    AMapLocationClient.startLocation();
  }
```




## 特性

* IOS
* Android
* 直接获取定位
* 监听定位改变


## 下个版本

* 地理围栏监听



