package com.jzoom.amaplocation;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

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
 * FlutterAmapLocationPlugin
 */
public class AmapLocationPlugin implements MethodCallHandler, AMapLocationListener {


    private Registrar registrar;
    private MethodChannel channel;
    private AMapLocationClientOption option;
    private AMapLocationClient locationClient;
    private boolean isLocation;
    //备份至
    private boolean onceLocation;

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
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "amap_location");
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
        } else if("updateOption".equals(method)){
            result.success(this.updateOption((Map) call.arguments));
        } else if("setApiKey".equals(method)){
            result.success(false);
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

            option.setOnceLocation(true);

            final AMapLocationListener listener = new AMapLocationListener() {
                @Override
                public void onLocationChanged(AMapLocation aMapLocation) {
                    //恢复原来的值
                    option.setOnceLocation(onceLocation);
                    result.success(resultToMap(aMapLocation));
                    stopLocation();
                }
            };

            startLocation(listener);

            return true;
        }
    }

    private static final String TAG = "AmapLocationPugin";

    private Map resultToMap(AMapLocation a){

        Map map = new HashMap();

        if(a!=null) {

            if (a.getErrorCode() != 0) {
                //错误信息

                map.put("description", a.getErrorInfo());
                map.put("success",false);

            }else{
                map.put("success",true);


                map.put("accuracy", a.getAccuracy());
                map.put("altitude", a.getAltitude());
                map.put("speed", a.getSpeed());
                map.put("timestamp", (double) a.getTime() / 1000);
                map.put("latitude", a.getLatitude());
                map.put("longitude", a.getLongitude());
                map.put("locationType", a.getLocationType());
                map.put("provider",a.getProvider());


                map.put("formattedAddress",a.getAddress());
                map.put("country",a.getCountry());
                map.put("province",a.getProvince());
                map.put("city",a.getCity());
                map.put("district",a.getDistrict());
                map.put("citycode",a.getCityCode());
                map.put("adcode",a.getAdCode());
                map.put("street",a.getStreet());
                map.put("number",a.getStreetNum());
                map.put("POIName",a.getPoiName());
                map.put("AOIName",a.getAoiName());

            }

            map.put("code", a.getErrorCode());

            Log.d(TAG,"定位获取结果:"+a.getLatitude() + " code："+a.getErrorCode() + " 省:"+a.getProvince());






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
                AMapLocationClientOption option = new AMapLocationClientOption();
                parseOptions(option,arguments);
                locationClient.setLocationOption(option);

                //将option保存一下
                this.option = option;

                return true;
            }

            return false;
        }
    }

    private boolean updateOption(Map arguments){
        synchronized (this){
            if(locationClient==null)return false;

            parseOptions(option,arguments);
            locationClient.setLocationOption(option);

            return true;
        }
    }

    /**
     * this.locationMode : AMapLocationMode.Hight_Accuracy,
     this.gpsFirst:false,
     this.httpTimeOut:10000,             //30有点长，特殊情况才需要这么长，改成10
     this.interval:2000,
     this.needsAddress : true,
     this.onceLocation : false,
     this.onceLocationLatest : false,
     this.locationProtocal : AMapLocationProtocol.HTTP,
     this.sensorEnable : false,
     this.wifiScan : true,
     this.locationCacheEnable : true,

     this.allowsBackgroundLocationUpdates : false,
     this.desiredAccuracy : CLLocationAccuracy.kCLLocationAccuracyBest,
     this.locatingWithReGeocode : false,
     this.locationTimeout : 10000,     //30有点长，特殊情况才需要这么长，改成10
     this.pausesLocationUpdatesAutomatically : false,
     this.reGeocodeTimeout : 5000,


     this.geoLanguage : GeoLanguage.DEFAULT,
     * @param arguments
     * @return
     */
    private void parseOptions(AMapLocationClientOption option,Map arguments) {
        //  AMapLocationClientOption option = new AMapLocationClientOption();
        onceLocation = (Boolean) arguments.get("onceLocation");
        option.setLocationMode(AMapLocationClientOption.AMapLocationMode.valueOf((String) arguments.get("locationMode")));//可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        option.setGpsFirst( (Boolean)arguments.get("gpsFirst") );//可选，设置是否gps优先，只在高精度模式下有效。默认关闭
        option.setHttpTimeOut(  (Integer) arguments.get("httpTimeOut"));//可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
        option.setInterval((Integer) arguments.get("interval"));//可选，设置定位间隔。默认为2秒
        option.setNeedAddress((Boolean) arguments.get("needsAddress"));//可选，设置是否返回逆地理地址信息。默认是true
        option.setOnceLocation(onceLocation);//可选，设置是否单次定位。默认是false
        option.setOnceLocationLatest((Boolean) arguments.get("onceLocationLatest"));//可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
        AMapLocationClientOption.setLocationProtocol(AMapLocationClientOption.AMapLocationProtocol.valueOf((String) arguments.get("locationProtocal")));//可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
        option.setSensorEnable((Boolean) arguments.get("sensorEnable"));//可选，设置是否使用传感器。默认是false
        option.setWifiScan((Boolean) arguments.get("wifiScan")); //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
        option.setLocationCacheEnable((Boolean) arguments.get("locationCacheEnable")); //可选，设置是否使用缓存定位，默认为true
        option.setGeoLanguage(AMapLocationClientOption.GeoLanguage.valueOf((String) arguments.get("geoLanguage")));//可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言）

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
