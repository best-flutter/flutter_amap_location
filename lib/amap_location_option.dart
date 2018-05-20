import 'dart:io';

/**
 * android网络传输http还是https协议
 */
enum AMapLocationProtocol { HTTP, HTTPS }

/**
 * android 逆地理位置信息的语言
 */
enum GeoLanguage { DEFAULT, ZH, EN }

/**
 * android 定位模式
 */
enum AMapLocationMode { Battery_Saving, Device_Sensors, Hight_Accuracy }

/**
 * ios定位精度
 */
enum CLLocationAccuracy {
  kCLLocationAccuracyBest,
  kCLLocationAccuracyNearestTenMeters,
  kCLLocationAccuracyHundredMeters,
  kCLLocationAccuracyKilometer,
  kCLLocationAccuracyThreeKilometers
}

class AMapLocationOption {
  /**
   * 以下属性为android特有
   */

  //可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
  final AMapLocationMode locationMode;

  //可选，设置是否gps优先，只在高精度模式下有效。默认关闭
  final bool gpsFirst;

  //可选，设置网络请求超时时间(ms)。默认为30秒。在仅设备模式下无效
  final int httpTimeOut;

  //可选，设置定位间隔(ms)。默认为2秒
  final int interval;

  //可选，设置是否返回逆地理地址信息。默认是true
  final bool needsAddress;

  //可选，设置是否单次定位。默认是false
  final bool onceLocation;

  //可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
  final bool onceLocationLatest;

  //可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
  final AMapLocationProtocol locationProtocal;

  //可选，设置是否使用传感器。默认是false
  final bool sensorEnable;

  //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
  final bool wifiScan;

  //可选，设置是否使用缓存定位，默认为true
  final bool locationCacheEnable;

  /**
   * 以下属性为ios特有
   */
  ///设定期望的定位精度。单位米，默认为 kCLLocationAccuracyBest。
  ///定位服务会尽可能去获取满足desiredAccuracy的定位结果，但不保证一定会得到满足期望的结果。
  ///\n注意：设置为kCLLocationAccuracyBest或kCLLocationAccuracyBestForNavigation时，
  ///单次定位会在达到locationTimeout设定的时间后，将时间内获取到的最高精度的定位结果返回。
  final CLLocationAccuracy desiredAccuracy;

  ///指定定位是否会被系统自动暂停。默认为NO。
  final bool pausesLocationUpdatesAutomatically;

  ///是否允许后台定位。默认为NO。只在iOS 9.0及之后起作用。设置为YES的时候必须保证
  /// Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
  /// 由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
  final bool allowsBackgroundLocationUpdates;

  ///指定单次定位超时时间,默认为10s。最小值是2s。
  /// 注意单次定位请求前设置。
  /// 注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)后开始计算。
  final int locationTimeout;

  ///指定单次定位逆地理超时时间,默认为5s。最小值是2s。注意单次定位请求前设置。
  final int reGeocodeTimeout;

  ///连续定位是否返回逆地理信息，默认NO。
  final bool locatingWithReGeocode;

  ///检测是否存在虚拟定位风险，默认为NO，不检测。
  /// \n注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的
  /// error给出虚拟定位风险提示；
  /// 连续定位通过 amapLocationManager:didFailWithError: 方法的
  /// error给出虚拟定位风险提示。
  /// error格式为error.domain==AMapLocationErrorDomain;
  /// error.code==AMapLocationErrorRiskOfFakeLocation;
  final bool detectRiskOfFakeLocation;

  ///设定定位的最小更新距离。单位米，默认为 kCLDistanceFilterNone，表示只要检测到设备位置发生变化就会更新位置信息。
  final double distanceFilter;

  static final double kCLDistanceFilterNone = -1.0;

  /**
   * 以下为通用属性
   */
  //可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言)
  final GeoLanguage geoLanguage;

  AMapLocationOption({
    this.locationMode: AMapLocationMode.Hight_Accuracy,
    this.gpsFirst: false,
    this.httpTimeOut: 10000, //30有点长，特殊情况才需要这么长，改成10
    this.interval: 2000,
    this.needsAddress: true,
    this.onceLocation: false,
    this.onceLocationLatest: false,
    this.locationProtocal: AMapLocationProtocol.HTTP,
    this.sensorEnable: false,
    this.wifiScan: true,
    this.locationCacheEnable: true,
    this.allowsBackgroundLocationUpdates: false,
    this.desiredAccuracy:
        CLLocationAccuracy.kCLLocationAccuracyBest, //精度越高，时间越久
    this.locatingWithReGeocode: false,
    this.locationTimeout: 5, //注意这里的单位为秒
    this.pausesLocationUpdatesAutomatically: false,
    this.reGeocodeTimeout: 5, //注意ios的时间单位是秒
    this.detectRiskOfFakeLocation: false,
    this.distanceFilter: -1.0,
    this.geoLanguage: GeoLanguage.DEFAULT,
  });

  String getLocationProtocal() {
    return locationProtocal == AMapLocationProtocol.HTTP ? "HTTP" : "HTTPS";
  }

  String getGeoLanguage() {
    switch (geoLanguage) {
      case GeoLanguage.DEFAULT:
        return "DEFAULT";
      case GeoLanguage.EN:
        return "EN";
      case GeoLanguage.ZH:
        return "ZH";
    }
  }

  String getLocationMode() {
    switch (locationMode) {
      case AMapLocationMode.Hight_Accuracy:
        return "Hight_Accuracy";
      case AMapLocationMode.Battery_Saving:
        return "Battery_Saving";
      case AMapLocationMode.Device_Sensors:
        return "Device_Sensors";
    }
  }

  String getDesiredAccuracy() {
    switch (desiredAccuracy) {
      case CLLocationAccuracy.kCLLocationAccuracyBest:
        return "kCLLocationAccuracyBest";
      case CLLocationAccuracy.kCLLocationAccuracyHundredMeters:
        return "kCLLocationAccuracyHundredMeters";
      case CLLocationAccuracy.kCLLocationAccuracyKilometer:
        return "kCLLocationAccuracyKilometer";
      case CLLocationAccuracy.kCLLocationAccuracyNearestTenMeters:
        return "kCLLocationAccuracyNearestTenMeters";
      case CLLocationAccuracy.kCLLocationAccuracyThreeKilometers:
        return "kCLLocationAccuracyThreeKilometers";
    }
  }

  Map toMap() {
    if (Platform.isAndroid) {
      return {
        "locationMode": getLocationMode(),
        "gpsFirst": gpsFirst,
        "httpTimeOut": httpTimeOut,
        "interval": interval,
        "needsAddress": needsAddress,
        "onceLocation": onceLocation,
        "onceLocationLatest": onceLocationLatest,
        "locationProtocal": getLocationProtocal(),
        "sensorEnable": sensorEnable,
        "wifiScan": wifiScan,
        "locationCacheEnable": locationCacheEnable,
        "geoLanguage": getGeoLanguage()
      };
    } else {
      return {
        "allowsBackgroundLocationUpdates": allowsBackgroundLocationUpdates,
        "desiredAccuracy": getDesiredAccuracy(),
        "locatingWithReGeocode": locatingWithReGeocode,
        "locationTimeout": locationTimeout,
        "pausesLocationUpdatesAutomatically":
            pausesLocationUpdatesAutomatically,
        "reGeocodeTimeout": reGeocodeTimeout,
        "detectRiskOfFakeLocation": detectRiskOfFakeLocation,
        "distanceFilter": distanceFilter,
        "geoLanguage": getGeoLanguage()
      };
    }
  }
}
