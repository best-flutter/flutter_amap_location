import 'dart:async';

export 'amap_location_option.dart';


import 'package:flutter/services.dart';
import 'amap_location_option.dart';

class AMapLocationQualityReport{
  static final int GPS_STATUS_OK = 0;
  static final int GPS_STATUS_NOGPSPROVIDER = 1;
  static final int GPS_STATUS_OFF = 2;
  static final int GPS_STATUS_MODE_SAVING = 3;
  static final int GPS_STATUS_NOGPSPERMISSION = 4;

  final bool wifiAble;

  final int gpsStatus;

  final int gpsSatellites;

  final String networkType;
  //整数部分为妙，浮点部分为毫秒
  final double netUseTime;

  final String adviseMessage;

}

class AMapLocation{

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


  final int code;
  final String description;


  /**
   * 以下属性为anroid特有
   */
  final String provider;


  AMapLocation({
    this.description,
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
});



  static AMapLocation fromMap(dynamic map){
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
      street: map["street"]



    );
  }

}






class AMapLocationClient {
  static const MethodChannel _channel = const MethodChannel('amap_location');


  static StreamController<AMapLocation> _locationUpdateStreamController = new StreamController.broadcast();


  /**
   * 定位改变监听
   */
  static Stream<AMapLocation> get onLocationUpate => _locationUpdateStreamController.stream;

  /**
   * 直接获取到定位，不必先启用监听
   *
   * @param needsAddress 是否需要详细地址信息
   */
  static Future<AMapLocation> getLocation(bool needsAddress) async {
    final dynamic location = await _channel.invokeMethod('getLocation',needsAddress);
    return AMapLocation.fromMap(location);
  }

  /**
   * 启动系统
   *
   * @param options 启动系统所需选项
   */
  static Future<bool> startup(AMapLocationOption option) async{
    return await _channel.invokeMethod("startup",option.toMap());
  }

  /**
   * 更新选项，如果已经在监听，那么要先停止监听，再调用这个函数
   *
   */
  static Future<bool> updateOption(AMapLocationOption option) async{
    return await _channel.invokeMethod("updateOption",option);
  }

  static Future<bool> shutdown() async{
    return await _channel.invokeMethod("shutdown");
  }

  /**
   * 启动监听位置改变
   */
  static Future<bool> startLocation() async{
    return await _channel.invokeMethod("startLocation");
  }

  /**
   * 停止监听位置改变
   */
  static Future<bool> stopLocation() async{
    return await _channel.invokeMethod("stopLocation");
  }

}
