package com.jzoom.amaplocation;

import android.app.Activity;
import android.content.Context;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AmapLocationPlugin
 */
public class AmapLocationPlugin implements MethodCallHandler, AMapLocationListener {


  private Registrar registrar;
  private MethodChannel channel;
  private AMapLocationClientOption option;
  private AMapLocationClient locationClient;
  private boolean isLocation;

  public AmapLocationPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
  }

  private Activity getActivity(){
    return registrar.activity();
  }

  private Context getApplicationContext(){
    return registrar.activity().getApplicationContext();
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_amap_location");
    channel.setMethodCallHandler(new AmapLocationPlugin(registrar,channel));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;

    //显然下面的任何方法都应该放在同步块处理

    if ("startup".equals(method)) {
      //启动
      result.success(this.startup((Map) call.arguments));

    } else if("shutdown".equals(method)){
      //关闭
      result.success(this.shutdown());
    } else if("getLocation".equals(method)){
      boolean needsAddress = (boolean) call.arguments;
      this.getLocation(needsAddress,result);
    } else if("startLocation".equals(method)){
      //启动定位,如果还没有启动，那么返回false
      result.success(this.startLocation(this));
    } else if("stopLocation".equals(method)){
      //停止定位
      result.success(this.stopLocation());

    } else {
      result.notImplemented();
    }
  }


  private boolean getLocation(boolean needsAddress, final Result result) {
    synchronized (this){

      if(locationClient==null)return false;

      if(needsAddress!=option.isNeedAddress()){
        option.setNeedAddress(needsAddress);
        locationClient.setLocationOption(option);
      }

      final AMapLocationListener listener = new AMapLocationListener() {
        @Override
        public void onLocationChanged(AMapLocation aMapLocation) {
          result.success(resultToMap(aMapLocation));
          stopLocation();
        }
      };

      startLocation(listener);

      return true;
    }
  }

  private Map resultToMap(AMapLocation a){

    Map map = new HashMap();

    if(a!=null) {

      if (a.getErrorCode() != 0) {
        //错误信息
        Map err = new HashMap();
        err.put("code", a.getErrorCode());
        err.put("description", a.getErrorInfo());
        map.put("error", err);
      }

      Map location = new HashMap();
      location.put("accuracy", a.getAccuracy());
      location.put("altitude", a.getAltitude());
      location.put("speed", a.getSpeed());
      location.put("timestamp", (double) a.getTime() / 1000);
      location.put("latitude", a.getLatitude());
      location.put("longitude", a.getLongitude());
      location.put("locationType", a.getLocationType());
      location.put("provider",a.getProvider());
      map.put("location",location);

      Map regeocode = new HashMap();
      regeocode.put("formattedAddress",a.getAddress());
      regeocode.put("country",a.getCountry());
      regeocode.put("province",a.getProvince());
      regeocode.put("city",a.getCountry());
      regeocode.put("district",a.getDistrict());
      regeocode.put("citycode",a.getCityCode());
      regeocode.put("adcode",a.getAdCode());
      regeocode.put("street",a.getStreet());
      regeocode.put("number",a.getStreetNum());
      regeocode.put("POIName",a.getPoiName());
      regeocode.put("AOIName",a.getAoiName());
      map.put("regeocode",regeocode);


    }

    return map;
  }

  private boolean stopLocation() {
    synchronized (this){
      if(locationClient==null){
        return false;
      }
      locationClient.stopLocation();
      isLocation = false;
      return true;
    }

  }

  private boolean shutdown() {
    synchronized (this){
      if(locationClient!=null){
        locationClient.stopLocation();
        locationClient = null;
        option = null;
        return true;
      }
      return false;
    }


  }

  private boolean startLocation(AMapLocationListener listener){
    synchronized (this){
      if(locationClient==null){
        return false;
      }

      if(listener==this){
        //持续定位


      }else{
        //单次定位

      }

      locationClient.setLocationListener(listener);
      locationClient.startLocation();
      isLocation = true;
      return true;
    }

  }

  private boolean startup(Map arguments) {
    synchronized (this){

      if(locationClient==null){
        //初始化client
        locationClient = new AMapLocationClient(getApplicationContext());
        //设置定位参数
        AMapLocationClientOption option = parseOptions(arguments);
        locationClient.setLocationOption(option);

        //将option保存一下
        this.option = option;

        return true;
      }

      return false;
    }
  }

  private AMapLocationClientOption parseOptions(Map arguments) {
    AMapLocationClientOption option = new AMapLocationClientOption();

    option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);//可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
    option.setGpsFirst(false);//可选，设置是否gps优先，只在高精度模式下有效。默认关闭
    option.setHttpTimeOut(30000);//可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
    option.setInterval(2000);//可选，设置定位间隔。默认为2秒
    option.setNeedAddress(true);//可选，设置是否返回逆地理地址信息。默认是true
    option.setOnceLocation(false);//可选，设置是否单次定位。默认是false
    option.setOnceLocationLatest(false);//可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
    AMapLocationClientOption.setLocationProtocol(AMapLocationClientOption.AMapLocationProtocol.HTTP);//可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
    option.setSensorEnable(false);//可选，设置是否使用传感器。默认是false
    option.setWifiScan(true); //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
    option.setLocationCacheEnable(true); //可选，设置是否使用缓存定位，默认为true
    option.setGeoLanguage(AMapLocationClientOption.GeoLanguage.DEFAULT);//可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言）
    return option;
  }


  @Override
  public void onLocationChanged(AMapLocation aMapLocation) {

    synchronized (this){
      if(channel==null)return;
      Map<String,Object> data = new HashMap<>();
      channel.invokeMethod("updateLocation",resultToMap(aMapLocation));
    }
  }
}
