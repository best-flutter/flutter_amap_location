import 'dart:async';

export 'amap_location_option.dart';

import 'package:flutter/services.dart';
import 'amap_location_option.dart';

class AMapLocationQualityReport {

  static const int ok = 0;
  static const int noGpsProvider = 1;
  static const int off = 2;
  static const int modeSaving = 3;
  static const int noGpsPermission = 4;

  final bool wifiAble;

  final int gpsStatus;

  final int gpsSatellites;

  final String networkType;

  //整数部分为秒，浮点部分为毫秒
  final double netUseTime;

  final String adviseMessage;

  AMapLocationQualityReport({
    this.wifiAble,
    this.gpsSatellites,
    this.gpsStatus,
    this.adviseMessage,
    this.netUseTime,
    this.networkType,
  });
}

class AMapLocation {
  final double accuracy;
  final double altitude;
  final double speed;
  final double timestamp;
  final double latitude;
  final double longitude;

  final String formattedAddress;
  final String country;
  final String province;
  final String city;
  final String district;
  final String citycode;
  final String adcode;
  final String street;
  final String number;
  final String POIName;
  final String AOIName;

//    这个参数很重要，在anroid和ios下的判断标准不一样
//    android下: 0  定位成功。
//      1  一些重要参数为空，如context；请对定位传递的参数进行非空判断。
//      2  定位失败，由于仅扫描到单个wifi，且没有基站信息。
//      3  获取到的请求参数为空，可能获取过程中出现异常。
//      4  请求服务器过程中的异常，多为网络情况差，链路不通导致，请检查设备网络是否通畅。
//      5  返回的XML格式错误，解析失败。
//      6  定位服务返回定位失败，如果出现该异常，请将errorDetail信息通过API@autonavi.com反馈给我们。
//      7  KEY建权失败，请仔细检查key绑定的sha1值与apk签名sha1值是否对应。
//      8  Android exception通用错误，请将errordetail信息通过API@autonavi.com反馈给我们。
//      9  定位初始化时出现异常，请重新启动定位。
//      10     定位客户端启动失败，请检查AndroidManifest.xml文件是否配置了APSService定位服务
//      11     定位时的基站信息错误，请检查是否安装SIM卡，设备很有可能连入了伪基站网络。
//      12     缺少定位权限，请在设备的设置中开启app的定位权限。
//
//   ios下:
//   typedef NS_ENUM(NSInteger, AMapLocationErrorCode)
//      {
//      AMapLocationErrorUnknown = 1,               ///<未知错误
//      AMapLocationErrorLocateFailed = 2,          ///<定位错误
//      AMapLocationErrorReGeocodeFailed  = 3,      ///<逆地理错误
//      AMapLocationErrorTimeOut = 4,               ///<超时
//      AMapLocationErrorCanceled = 5,              ///<取消
//      AMapLocationErrorCannotFindHost = 6,        ///<找不到主机
//      AMapLocationErrorBadURL = 7,                ///<URL异常
//      AMapLocationErrorNotConnectedToInternet = 8,///<连接异常
//      AMapLocationErrorCannotConnectToHost = 9,   ///<服务器连接失败
//      AMapLocationErrorRegionMonitoringFailure=10,///<地理围栏错误
//      AMapLocationErrorRiskOfFakeLocation = 11,   ///<存在虚拟定位风险
//      };
  final int code;

  /// 描述
  final String description;

  ///这个字段用来判断有没有定位成功，在ios下，有可能获取到了经纬度，但是详细地址没有获取到，
  /// 这个情况下，值也为true
  final bool success;

  /// 以下属性为anroid特有
  final String provider;

  final int locationType;

  AMapLocation(
      {this.description,
      this.code,
      this.timestamp,
      this.speed,
      this.altitude,
      this.longitude,
      this.latitude,
      this.accuracy,
      this.adcode,
      this.AOIName,
      this.city,
      this.citycode,
      this.country,
      this.district,
      this.formattedAddress,
      this.number,
      this.POIName,
      this.provider,
      this.province,
      this.street,
      this.locationType,
      this.success});

  static AMapLocation fromMap(dynamic map) {
    return new AMapLocation(
        description: map["description"],
        code: map["code"],
        timestamp: map["timestamp"],
        speed: map["speed"],
        altitude: map["altitude"],
        longitude: map["longitude"],
        latitude: map["latitude"],
        accuracy: map["accuracy"],
        adcode: map["adcode"],
        AOIName: map["AOIName"],
        city: map["city"],
        citycode: map["citycode"],
        country: map["country"],
        district: map["district"],
        formattedAddress: map["formattedAddress"],
        number: map["number"],
        POIName: map["POIName"],
        provider: map["provider"],
        province: map["province"],
        street: map["street"],
        locationType: map["locationType"],
        success: map["success"]);
  }

  /// 是否成功，单纯从经纬度来判断
  bool isSuccess() {
    //code > 0 ,有可能是逆地理位置有错误，那么这个时候仍然是成功的
    return success;
  }

  /// 是否有详细地址
  bool hasAddress() {
    return formattedAddress != null;
  }
}

class AMapLocationClient {
  static const MethodChannel _channel = const MethodChannel('amap_location');

  static StreamController<AMapLocation> _locationUpdateStreamController =
      new StreamController.broadcast();

  /// 定位改变监听
  static Stream<AMapLocation> get onLocationUpate =>
      _locationUpdateStreamController.stream;

  /// 设置ios的key，android可以直接在配置文件中设置
  static Future<bool> setApiKey(String key) async {
    return await _channel.invokeMethod("setApiKey", key);
  }

  /// 直接获取到定位，不必先启用监听
  /// @param needsAddress 是否需要详细地址信息
  static Future<AMapLocation> getLocation(bool needsAddress) async {
    final dynamic location =
        await _channel.invokeMethod('getLocation', needsAddress);
    return AMapLocation.fromMap(location);
  }

  /// 启动系统
  /// @param options 启动系统所需选项
  static Future<bool> startup(AMapLocationOption option) async {
    _channel.setMethodCallHandler(handler);
    return await _channel.invokeMethod("startup", option.toMap());
  }

  /// 更新选项，如果已经在监听，那么要先停止监听，再调用这个函数
  static Future<bool> updateOption(AMapLocationOption option) async {
    return await _channel.invokeMethod("updateOption", option);
  }

  static Future<bool> shutdown() async {
    return await _channel.invokeMethod("shutdown");
  }

  /// 启动监听位置改变
  static Future<bool> startLocation() async {
    return await _channel.invokeMethod("startLocation");
  }

  /// 停止监听位置改变
  static Future<bool> stopLocation() async {
    return await _channel.invokeMethod("stopLocation");
  }

  static Future<dynamic> handler(MethodCall call) {
    String method = call.method;

    switch (method) {
      case "updateLocation":
        {
          Map args = call.arguments;
          _locationUpdateStreamController.add(AMapLocation.fromMap(args));
        }
        break;
    }
    return new Future.value("");
  }
}
