#import "AmapLocationPlugin.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>


/*
static NSDictionary* DesiredAccuracy = @{@"kCLLocationAccuracyBest":@(kCLLocationAccuracyBest),
                                         @"kCLLocationAccuracyNearestTenMeters":@(kCLLocationAccuracyNearestTenMeters),
                                         @"kCLLocationAccuracyHundredMeters":@(kCLLocationAccuracyHundredMeters),
                                         @"kCLLocationAccuracyKilometer":@(kCLLocationAccuracyKilometer),
                                         @"kCLLocationAccuracyThreeKilometers":@(kCLLocationAccuracyThreeKilometers),
                                         
                                         };*/


@interface AmapLocationPlugin()<AMapLocationManagerDelegate>

@property (nonatomic, retain)  AMapLocationManager *locationManager;
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (nonatomic, weak) FlutterMethodChannel* channel;

@end

@implementation AmapLocationPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"amap_location"
                                     binaryMessenger:[registrar messenger]];
    AmapLocationPlugin* instance = [[AmapLocationPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = call.method;
    
    if ([@"startup" isEqualToString:method]) {
        //启动系统
        result(@([self startup:call.arguments]));
    }else if([@"shutdown" isEqualToString:method]){
        //关闭系统
        result(@([self shutdown]));
    }else if([@"getLocation" isEqualToString:method]){
        //进行单次定位请求
        [self getLocation: [call.arguments boolValue] result:result];
        
    }else if([@"stopLocation" isEqualToString:method]){
        //停止监听位置改变
        result(@([self stopLocation]));
    }else if([@"startLocation" isEqualToString:method]){
        //开始监听位置改变
        result(@([self startLocation]));
    }else if( [@"updateOption" isEqualToString:method] ){
        
        result(@([self updateOption:call.arguments]));
        
    }else if([@"setApiKey" isEqualToString:method]){
        [AMapServices sharedServices].apiKey = call.arguments;

        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

-(double)getDesiredAccuracy:(NSString*)str{
    
    if([@"kCLLocationAccuracyBest" isEqualToString:str]){
        return kCLLocationAccuracyBest;
    }else if([@"kCLLocationAccuracyNearestTenMeters" isEqualToString:str]){
        return kCLLocationAccuracyNearestTenMeters;
    }else if([@"kCLLocationAccuracyHundredMeters" isEqualToString:str]){
        return kCLLocationAccuracyHundredMeters;
    }
    else if([@"kCLLocationAccuracyKilometer" isEqualToString:str]){
        return kCLLocationAccuracyKilometer;
    }
    else{
        return kCLLocationAccuracyThreeKilometers;
    }

    
}

-(BOOL)updateOption:(NSDictionary*)args{
    if(self.locationManager){
     
        //设置期望定位精度
        [self.locationManager setDesiredAccuracy:[ self getDesiredAccuracy: args[@"desiredAccuracy"]]];
        
        NSLog(@"%@",args);
        
        [self.locationManager setPausesLocationUpdatesAutomatically:[args[@"pausesLocationUpdatesAutomatically"] boolValue]];
        
        [self.locationManager setDistanceFilter: [args[@"distanceFilter"] doubleValue]];
        
        //设置在能不能再后台定位
        [self.locationManager setAllowsBackgroundLocationUpdates:[args[@"allowsBackgroundLocationUpdates"] boolValue]];
        
        //设置定位超时时间
        [self.locationManager setLocationTimeout:[args[@"locationTimeout"] integerValue]];
        
        //设置逆地理超时时间
        [self.locationManager setReGeocodeTimeout:[args[@"reGeocodeTimeout"] integerValue]];
        
        //定位是否需要逆地理信息
        [self.locationManager setLocatingWithReGeocode:[args[@"locatingWithReGeocode"] boolValue]];
        
        ///检测是否存在虚拟定位风险，默认为NO，不检测。 \n注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的error给出虚拟定位风险提示；连续定位通过 amapLocationManager:didFailWithError: 方法的error给出虚拟定位风险提示。error格式为error.domain==AMapLocationErrorDomain; error.code==AMapLocationErrorRiskOfFakeLocation;
        [self.locationManager setDetectRiskOfFakeLocation: [args[@"detectRiskOfFakeLocation"] boolValue ]];
        
        return YES;

    }
    return NO;
}

-(BOOL)startLocation{
    if(self.locationManager){
        [self.locationManager startUpdatingLocation];
        return YES;
    }
    return NO;
}

-(BOOL)stopLocation{
    if(self.locationManager){
        [self.locationManager stopUpdatingLocation];
        return YES;
    }
    return NO;
}

-(void)getLocation:(BOOL)withReGeocode result:(FlutterResult)result{
    
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error){
        
        if (error != nil && error.code == AMapLocationErrorLocateFailed)
        {
            //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"定位错误:{%ld - %@};", (long)error.code, error.localizedDescription);
            result(@{ @"code":@(error.code),@"description":error.localizedDescription });
            return;
        }
        else if (error != nil
                 && (error.code == AMapLocationErrorReGeocodeFailed
                     || error.code == AMapLocationErrorTimeOut
                     || error.code == AMapLocationErrorCannotFindHost
                     || error.code == AMapLocationErrorBadURL
                     || error.code == AMapLocationErrorNotConnectedToInternet
                     || error.code == AMapLocationErrorCannotConnectToHost))
        {
            //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
            NSLog(@"逆地理错误:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        else if (error != nil && error.code == AMapLocationErrorRiskOfFakeLocation)
        {
            //存在虚拟定位的风险：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"存在虚拟定位的风险:{%ld - %@};", (long)error.code, error.localizedDescription);
            result(@{ @"code":@(error.code),@"description":error.localizedDescription });
            return;
        }
        else
        {
            //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
        }
        
        NSMutableDictionary* md = [[NSMutableDictionary alloc]initWithDictionary: [AmapLocationPlugin location2map:location]  ];
        if (regeocode)
        {
            
            [md addEntriesFromDictionary:[AmapLocationPlugin regeocode2map:regeocode]];
                    }
        else
        {
            md[@"code"]=@(error.code);
            md[@"description"]=error.localizedDescription;
        }
        
        result(md);
        
    };
    [self.locationManager requestLocationWithReGeocode:withReGeocode completionBlock:self.completionBlock];
    
 //   [self.locationManager startUpdatingLocation];
}


+(NSDictionary*)regeocode2map:(AMapLocationReGeocode *)regeocode{
    return @{@"formattedAddress":regeocode.formattedAddress,
             @"country":regeocode.country,
             @"province":regeocode.province,
             @"city":regeocode.city,
             @"district":regeocode.district,
             @"citycode":regeocode.citycode,
             @"adcode":regeocode.adcode,
             @"street":regeocode.street,
             @"number":regeocode.number,
             @"POIName":regeocode.POIName,
             @"AOIName":regeocode.AOIName,
             };
}

+(NSDictionary*)location2map:(CLLocation *)location{
    
    return @{@"latitude": @(location.coordinate.latitude),
             @"longitude": @(location.coordinate.longitude),
             @"accuracy": @((location.horizontalAccuracy + location.verticalAccuracy)/2),
             @"altitude": @(location.altitude),
             @"speed": @(location.speed),
             @"timestamp": @(location.timestamp.timeIntervalSince1970),};
    
}


-(BOOL)startup:(NSDictionary*)args{
    if(self.locationManager)return NO;
    
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];

    return [self updateOption:args];
}


-(BOOL)shutdown{
    if(self.locationManager){
        //停止定位
        [self.locationManager stopUpdatingLocation];
        [self.locationManager setDelegate:nil];
        self.locationManager = nil;
        
        return YES;
    }
    return NO;
    
}
/**
 *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 *  @param reGeocode 逆地理信息。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    
    NSMutableDictionary* md = [[NSMutableDictionary alloc]initWithDictionary: [AmapLocationPlugin location2map:location]  ];
    if(reGeocode){
        [md addEntriesFromDictionary:[ AmapLocationPlugin regeocode2map:reGeocode ]];
    }
    
    [self.channel invokeMethod:@"updateLocation" arguments:md];
    
}



/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
}


/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"定位错误:{%ld - %@};", (long)error.code, error.localizedDescription);

    
    
    [self.channel invokeMethod:@"updateLocation" arguments:@{ @"code":@(error.code),@"description":error.localizedDescription }];

    

    
}
@end
