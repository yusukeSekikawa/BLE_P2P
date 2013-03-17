//
//  CBAdvertizer.m
//  BLE_P2P
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBAdvertizer.h"
#import "CBUUID+Hepler.h"

@implementation CBAdvertizer

- (void)logState {
	if (self.manager.state == CBPeripheralManagerStateUnsupported) {
		NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBPeripheralManagerStateUnauthorized) {
		NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBPeripheralManagerStatePoweredOff) {
		NSLog(@"Bluetooth is currently powered off.");
	}
	else if (self.manager.state == CBPeripheralManagerStateResetting) {
		NSLog(@"Bluetooth is currently resetting.");
	}
	else if (self.manager.state == CBPeripheralManagerStatePoweredOn) {
		NSLog(@"Bluetooth is currently powered on.");
	}
	else if (self.manager.state == CBPeripheralManagerStateUnknown) {
		NSLog(@"Bluetooth is an unknown status.");
	}
	else {
		NSLog(@"Unknown status code.");
	}
	
	if (self.manager.isAdvertising){
		NSLog(@"Now, advertising.");
    }else{
		NSLog(@"NOT advertising.");
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)dataRecieved:(NSData*)data{
}
-(void)disconnectedWithPeer{
}


- (id)initWithDelegate:(id<CBAdvertizerDelegate>)delegate{    
   	self.delegate = delegate;
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //	[self initManager];
    return [super init];
}

- (BOOL)isBLEAvailable {
	return (self.manager.state == CBPeripheralManagerStatePoweredOn);
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification {
	//[self stopAdvertize];
}


- (void)initManager{
    //BLEの使用可否をチェック
    if (![self isBLEAvailable])
        return;
    
    /* Battery Service(primary)の作成 */
    CBUUID* primaly_service_UUID_01=[CBUUID UUIDWithString:@"180f"];
    CBMutableService *service_01=[[CBMutableService alloc] initWithType:primaly_service_UUID_01 primary:YES];
    // Battery Level Characteristic(Read)の作成
    self.read_characteristic=
    [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"2A19"]
                                      properties:CBCharacteristicPropertyRead
                                           value:nil
                                     permissions:CBAttributePermissionsReadable];
    //ServiceにCharacteristicの情報を設定
    [service_01 setCharacteristics:@[self.read_characteristic]];
    //PeripheralにServiceの情報を設定
    [self.manager addService:service_01];
    
    /* Immediate Alert Service(primary)の作成 */
    CBUUID* primaly_service_UUID_02=[CBUUID UUIDWithString:@"1802"];
    CBMutableService *service_02=[[CBMutableService alloc] initWithType:primaly_service_UUID_02 primary:YES];
    // Alert Level Characteristic(Write)の作成
    self.write_characteristic=
    [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"2A06"]
                                      properties:CBCharacteristicPropertyWrite
                                           value:nil
                                     permissions:CBAttributePermissionsWriteable];
    //ServiceにCharacteristicの情報を設定
    [service_02 setCharacteristics:@[self.write_characteristic]];
    //PeripheralにServiceの情報を設定
    [self.manager addService:service_02];
    
    
    /* Original Alert Service(primary)の作成 */
    CBUUID* primaly_service_UUID_03=[CBUUID UUIDWithString:@"ff01"];
    CBMutableService *service_03=[[CBMutableService alloc] initWithType:primaly_service_UUID_03 primary:YES];
    // Alert Level Characteristic(Notify)の作成
    self.notify_characteristic=
    [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"2A06"]
                                      properties:CBCharacteristicPropertyNotifyEncryptionRequired
                                           value:nil
                                     permissions:CBAttributePermissionsReadEncryptionRequired];
    //ServiceにCharacteristicの情報を設定
    [service_03 setCharacteristics:@[self.notify_characteristic]];
    //PeripheralにServiceの情報を設定
    [self.manager addService:service_03];
}

- (void)startAdvertize{
    //BLEの使用可否をチェック
    if (![self isBLEAvailable])
        return;
    // アドバタイズするデータの作成
    NSArray *serviceUUIDs=@[
    [CBUUID UUIDWithString:@"1802"],
    [CBUUID UUIDWithString:@"ff01"]];
    NSDictionary *adDict=[NSDictionary dictionaryWithObjectsAndKeys:
                          serviceUUIDs,			CBAdvertisementDataServiceUUIDsKey,
                          kCBAdvBLEB2P,         CBAdvertisementDataLocalNameKey,
                          nil];
    
    // アドバタイズ開始
    [self.manager startAdvertising:adDict];
    NSLog(@"startAdvertize,%@",adDict);
}

- (void)stopAdvertize {
    [self.manager stopAdvertising];
}
- (void)notifyStr:(NSString*)msg{
    //通知する文字列をNSDataに変換
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    //Centralにデータを通知する
    BOOL ret=[self.manager updateValue:data forCharacteristic:self.notify_characteristic onSubscribedCentrals:nil];
    NSLog(@"notify msg:%@,ret:%d",msg,ret);
}
- (void)notifyData:(NSData*)data{
    //Centralにデータを通知する
    BOOL ret=[self.manager updateValue:data forCharacteristic:self.notify_characteristic onSubscribedCentrals:nil];
    NSLog(@"notify data:%@,ret:%d",data,ret);
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)manager{
	[self logState];
    [self.delegate advertizerDidChangeStatus:self];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)manager error:(NSError *)error{
    DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager didAddService:(CBService *)service error:(NSError *)error{
    DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    DNSLogMethod
    [self.delegate advertizerDidSubscribed:self];
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    DNSLogMethod
    [self.delegate advertizerDidUnSubscribed:self];
}

- (uint8_t)currentBatteryLevel{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float battery_float = 256*[UIDevice currentDevice].batteryLevel;
    uint8_t battery_byte = (uint8_t)battery_float;
    return battery_byte;
}
- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"ReceiveReadRequest.Service:%@,Characteristic:%@",
          request.characteristic.service.UUID,
          request.characteristic.UUID);
    
    if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]] &&
       [request.characteristic.service.UUID isEqual:[CBUUID UUIDWithString:@"180f"]]){
        uint8_t _byteData=[self currentBatteryLevel];        
        //Read要求に対して返信するデータを設定する
        request.value = [NSData dataWithBytes:&_byteData length:1];
        
        //リクエストに返信する
        [self.manager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        //リクエストに対してはどのような場合でも確実に返信する必要がある
        [self.manager respondToRequest:request withResult:CBATTErrorAttributeNotFound];
    }
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveWriteRequests:(NSArray *)requests{
    for(CBATTRequest * request in requests){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  request.characteristic.UUID, kCBInfoCharacteristicUUIDKey,
                                  request.value, kCBInfoDataKey,
                                  nil];
        [self.delegate advertizer:self didReceiveData:userInfo];
        NSLog(@"ReceiveWriteRequest.Service:%@,Characteristic:%@,request.value%@",
              request.characteristic.service.UUID,
              request.characteristic.UUID,
              request.value);

        //リクエストに返信する
        [self.manager respondToRequest:request withResult:CBATTErrorSuccess];        
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager*)manager{
}

#pragma iOS6 Book

@end
