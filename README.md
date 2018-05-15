# flutter_amap_location

高德地图定位flutter组件。
目前实现直接获取定位和监听定位功能。
注意：随着flutter版本的提升， 本项目也会随之更新，

## Getting Started

### 集成高德地图定位android版本

1、先申请一个apikey
http://lbs.amap.com/api/android-sdk/guide/create-project/get-key

2、在AndroidManifest.xml中增加
```
 <meta-data
            android:name="com.amap.api.v2.apikey"
            android:value="你的Key" />
```

3、增加对应的权限：

```
    <!-- Normal Permissions 不需要运行时注册 -->
    <!-- 获取运营商信息，用于支持提供运营商信息相关的接口 -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <!-- 用于访问wifi网络信息，wifi信息会用于进行网络定位 -->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <!-- 这个权限用于获取wifi的获取权限，wifi信息会用来进行网络定位 -->
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
    <uses-permission android:name="android.permission.CHANGE_CONFIGURATION"/>

    <!-- 请求网络 -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- 不是SDK需要的权限，是示例中的后台唤醒定位需要的权限 -->
    <uses-permission android:name="android.permission.WAKE_LOCK"/>

    <!-- 需要运行时注册的权限 -->
    <!-- 用于进行网络定位 -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <!-- 用于访问GPS定位 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <!-- 用于提高GPS定位速度 -->
    <uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS"/>
    <!-- 写入扩展存储，向扩展卡写入数据，用于写入缓存定位数据 -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <!-- 读取缓存数据 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

    <!-- 用于读取手机当前的状态 -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE"/>

    <!-- 更改设置 -->
    <uses-permission android:name="android.permission.WRITE_SETTINGS"/>
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

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>要用定位</string>
```


## 怎么用

先导入dart包
修改pubspec.yaml，增加依赖：

```
dependencies:
  amap_location: "^0.0.1"
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


## 特性

* IOS
* Android
* 直接获取定位
* 监听定位改变


## 下个版本

* 地理围栏监听



