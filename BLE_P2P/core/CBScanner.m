//
//  CBScanner.m
//  BLE_P2P
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBScanner.h"
#import "CBUUID+Hepler.h"

#define CBScannerFilterServices



@implementation CBScanner


#pragma mark - Instance method

- (void)logState {
	if (self.manager.state == CBCentralManagerStateUnsupported) {
		NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBCentralManagerStateUnauthorized) {
		NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBCentralManagerStatePoweredOff) {
		NSLog(@"Bluetooth is currently powered off.");
	}
	else if (self.manager.state == CBCentralManagerStateResetting) {
		NSLog(@"Bluetooth is currently resetting.");
	}
	else if (self.manager.state == CBCentralManagerStatePoweredOn) {
		NSLog(@"Bluetooth is currently powered on.");
	}
	else if (self.manager.state == CBCentralManagerStateUnknown) {
		NSLog(@"Bluetooth is an unknown status.");
	}
	else {
		NSLog(@"Unknown status code.");
	}
}

- (id)initWithDelegate:(id<CBScannerDelegate>)delegate {
	self = [super init];
    
	if (self) {
		self.delegate   = delegate;
		self.manager    = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didEnterBackgroundNotification:)
                                              name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(willEnterForeground:)
                                              name:UIApplicationWillEnterForegroundNotification
                                              object:nil];

	}
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(readRSSI) userInfo:nil repeats:YES];
    return self;
}
- (BOOL)isBLEAvailable {
	return (self.manager.state == CBCentralManagerStatePoweredOn);
}


- (void)didEnterBackgroundNotification:(NSNotification*)notification {
	DNSLogMethod
}

- (void)willEnterForeground:(NSNotification*)notification {
	DNSLogMethod
}

- (BOOL)isAvailable {
    return (self.manager.state == CBCentralManagerStatePoweredOn);
}

-(void)connectedWithPeer:(BOOL)result{
    DNSLogMethod
}

- (void)startScan {
#ifdef CBScannerAllowDuplicates
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
#else
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey]; 
#endif
    
    NSArray *savedUUID=[self loadUUID];
    if(savedUUID!=nil){
        NSLog(@"Paired device UUID loaded.Retrieve peripheral");
        [self.manager retrievePeripherals:savedUUID];
    }else{
        NSLog(@"Not Paired Scan for peripheral");
        [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"180f"],[CBUUID UUIDWithString:@"1802"],[CBUUID UUIDWithString:@"ff01"]] options:options];
    }
    //DNSLogMethod
}

- (void)stopScan {
    [self.manager stopScan];
    DNSLogMethod
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DNSLogMethod
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)manager {
    [self logState];
    
    //BLEの状態が変化し、使用可能な状態になった
	if([self isBLEAvailable])
        [self startScan];
	
	if ([self.delegate respondsToSelector:@selector(scannerDidChangeStatus:)])
		[self.delegate scannerDidChangeStatus:self];
}


- (void) centralManager:(CBCentralManager*)manager
  didDiscoverPeripheral:(CBPeripheral *)aPeripheral
      advertisementData:(NSDictionary *)advertisementData
                   RSSI:(NSNumber *)RSSI {
	DNSLogMethod
    NSArray *services = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSArray *hashedServices = [advertisementData objectForKey:CBAdvertisementDataOverflowServiceUUIDsKey];
    
    NSString *localName=[advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSArray *suppoertedDevices=@[
    kCBAdvDataLocalNameGSHOCK5600A,
    kCBAdvDataLocalNameGSHOCK6900A,
    kCBAdvDataLocalNameLBTVRU01,
    kCBAdvDataLocalNameLBTVRU02,
    kCBAdvDataLocalNameLBTVRU03,
    kCBAdvDataLocalNameLBTVRU04,
    kCBAdvDataLocalNameLSBPX01PRXM,
    ];
    
    BOOL targetFound=NO;
    if([suppoertedDevices containsObject:localName]){
        NSLog(@"Peer discovered %@,aPeripheral.UUID:%@",advertisementData,aPeripheral.UUID);
        targetFound=YES;
    }else{
        /* For iOS */
        if([services containsObject:[CBUUID UUIDWithString:@"ff01"]]){
            /* Peripheralがフォアグラウンド */
            //serviceUUIDsには、PeripheralがアドバタイズするUUIDが格納されている
            NSLog(@"iOS in foreground discovered%@,aPeripheral.UUID:%@",advertisementData,aPeripheral.UUID);
            targetFound=YES;
        }else if([hashedServices containsObject:[CBUUID UUIDWithString:@"ff01"]]){
            /* Peripheralがバックグラウンド */
            //hashedServiceUUIDsには、scanForPeripheralsWithServices:で指定したUUIDの中でPeripheralがアドバタイズするUUIDが格納されている
            NSLog(@"iOS in background discovered%@,aPeripheral.UUID:%@",advertisementData,aPeripheral.UUID);
            targetFound=YES;
        }else{
            NSLog(@"Unknown Services found %@",advertisementData);
        }
    }
    if(targetFound){
        //[self stopScan];
        if(localName){
            self.peerName=localName;
        }else{
            self.peerName=kCBAdvBLEB2P;
            ;
        }
        self.peripheral=aPeripheral;
        [self.manager connectPeripheral:self.peripheral options:nil];
        //[self.manager connectPeripheral:aPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    DNSLogMethod
    //[self.manager stopScan];
    [self.peripheral setDelegate:self];
    if ([self.delegate respondsToSelector:@selector(scannerDidChangeStatus:)])
		[self.delegate scannerDidChangeStatus:self];
    [aPeripheral discoverServices:
     @[
     [CBUUID UUIDWithString:@"26eb0005-b012-49a8-b1f8-394fb2032b0f"],//G-SHOCK Original Service
     [CBUUID UUIDWithString:@"ff01"],//BLEP2P Service
     [CBUUID UUIDWithString:@"1802"],//Immediate Alert Service
     //[CBUUID UUIDWithString:@"1804"],//Tx Power Service
     //[CBUUID UUIDWithString:@"1803"],//Link Loss Service
     [CBUUID UUIDWithString:@"180f"],//Battery Service
     ]];
}


/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    DNSLogMethod
    [self startScan];
    if ([self.delegate respondsToSelector:@selector(scannerDidChangeStatus:)])
		[self.delegate scannerDidChangeStatus:self];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void) centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    DNSLogMethod
    NSArray *services=aPeripheral.services;
    NSLog(@"services count:%d,%@",[services count],error);
    for (CBService *aService in services)
    {
        NSLog(@"Service found with UUID: %@",aService.UUID);
        [aPeripheral discoverCharacteristics:nil forService:aService];
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DNSLogMethod
    // Notifyの設定
    for (CBCharacteristic *aChar in service.characteristics)
    {
        if(aChar.properties & (CBCharacteristicPropertyNotify|CBCharacteristicPropertyNotifyEncryptionRequired)){
            NSLog(@"Subscribe to Service:%@,Characteristic%@",service.UUID,aChar.UUID);
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }else{
            NSLog(@"Characteristics Discovered.Service:%@,Characteristic%@",service.UUID,aChar.UUID);
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // 受信したデータの取り出し
    NSData * updatedValue = characteristic.value;
    NSLog(@"UpdateValue.Service:%@,Characteristic:%@,request.value%@",
          characteristic.service.UUID,
          characteristic.UUID,
          characteristic.value);
    
#if 0
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]]){
        uint8_t _data = 0;
        [updatedValue getBytes:&_data];
        switch (_data) {
            case 0x02:
                NSLog(@"D Button pressed");
                //写真撮影処理
                break;
            default:
                break;
        }
    }
#else
    // 受信したデータの取り出し
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              characteristic.UUID,kCBInfoCharacteristicUUIDKey,
                              characteristic.service.UUID,kCBInfoServiceUUIDKey,
                              updatedValue,kCBInfoDataKey,
                              aPeripheral.RSSI,kCBInfoRSSIKey,
                              nil];
    if ([self.delegate respondsToSelector:@selector(scanner:didReadData:)])
        [self.delegate scanner:self didReadData:userInfo];
#endif
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"RSSI%@,%d",peripheral.RSSI,peripheral.isConnected);
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(!error){
        //[self.manager stopScan];
        NSLog(@"Set notification Sccess:%@,%@",characteristic.service.UUID,characteristic.UUID);
        [self saveUUID:peripheral];
    }else{
        NSLog(@"Set notification Failed:%@,%@,%@",characteristic.service.UUID,characteristic.UUID,error);
    }
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral{
    DNSLogMethod;
    //[peripheral discoverServices:nil];
}


#pragma Interaction
-(CBService *) findServiceFromUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)aPeripheral {
    for(int i = 0; i < aPeripheral.services.count; i++) {
        CBService *service = [aPeripheral.services objectAtIndex:i];
        //NSLog(@"CBService %@",[service UUID]);
        if ([UUID isEqual:service.UUID]) return service;
    }
    return nil; //Service not found on this peripheral
}
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *characteristic = [service.characteristics objectAtIndex:i];
        //NSLog(@"CBCharacteristic %@",[c UUID]);
        if ([UUID isEqual:characteristic.UUID]) return characteristic;
    }
    return nil; //Characteristic not found on this service
}
-(void) setNotifyValueForService:(NSString*)serviceUUIDStr characteristicUUID:(NSString*)characteristicUUIDStr peripheral:(CBPeripheral *)aPeripheral enable:(bool)enable{
    CBUUID *serviceUUID = [CBUUID UUIDWithString:serviceUUIDStr];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristicUUIDStr];
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:aPeripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",serviceUUIDStr,aPeripheral.UUID);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ ",characteristicUUIDStr,serviceUUIDStr);
        return;
    }
    [aPeripheral setNotifyValue:enable forCharacteristic:characteristic];
}
-(void) writeValueForService:(NSString*)serviceUUIDStr characteristicUUID:(NSString*)characteristicUUIDStr peripheral:(CBPeripheral *)aPeripheral data:(NSData*)data writeType:(CBCharacteristicWriteType)writeType{
    DNSLogMethod
    if (!aPeripheral.isConnected) {
        NSLog(@"Error:NOT Connected.");
        return;
    }
    CBUUID *serviceUUID = [CBUUID UUIDWithString:serviceUUIDStr];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristicUUIDStr];
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:aPeripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",serviceUUID,aPeripheral.UUID);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ ",characteristicUUIDStr,serviceUUID);
        return;
    }
    [aPeripheral writeValue:data forCharacteristic:characteristic type:writeType];
}
-(void) readValueForService:(NSString*)serviceUUIDStr characteristicUUID:(NSString*)characteristicUUIDStr peripheral:(CBPeripheral *)aPeripheral{
    DNSLogMethod
    if (!aPeripheral.isConnected) {
        NSLog(@"Error:NOT Connected.");
        return;
    }
    CBUUID *serviceUUID = [CBUUID UUIDWithString:serviceUUIDStr];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristicUUIDStr];
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:aPeripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",serviceUUIDStr,aPeripheral.UUID);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ ",characteristicUUIDStr,serviceUUIDStr);
        return;
    }
    [aPeripheral readValueForCharacteristic:characteristic];
}

- (BOOL)writeDataforService:(NSString*)service characteristic:(NSString*)characteristic data:(NSData*)data{
    if(!self.peripheral) return NO;
    
    if([self.peerName isEqualToString:kCBAdvBLEB2P] || [self.peerName isEqualToString:@"iPhone"] || [self.peerName isEqualToString:@"iPad"])
        [self writeValueForService:service characteristicUUID:characteristic peripheral:self.peripheral data:data writeType:CBCharacteristicWriteWithResponse];
    else{
        [self writeValueForService:service characteristicUUID:characteristic peripheral:self.peripheral data:data writeType:CBCharacteristicWriteWithoutResponse];
    }
    return YES;
}

- (BOOL)readDataforService:(NSString*)service characteristic:(NSString*)characteristic{
    if(!self.peripheral) return NO;
    [self readValueForService:service characteristicUUID:characteristic peripheral:self.peripheral];
    return YES;
}
- (void)readRSSI{
    if(!self.peripheral) return;
    if(!self.peripheral.isConnected) return;
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive) return;
    [self.peripheral readRSSI];
}
- (void)forgetAndRetry{
    DNSLogMethod
    [self stopScan];
    if(self.peripheral)
        [self.manager cancelPeripheralConnection:self.peripheral];
    
    self.peripheral.delegate=nil;
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"peripheralUUID"];
    [self startScan];
}

#pragma mark Save/Load UUID
- (void) centralManager:(CBCentralManager *)central
 didRetrievePeripherals:(NSArray *)retrievedPeripherals
{
    DNSLogMethod
    if([retrievedPeripherals count]<1){
        [self forgetAndRetry];
        return;
    }
    CBPeripheral *firstPeripheral=[retrievedPeripherals objectAtIndex:0];
    NSLog(@"Retrieved peripheral: %u,%@,%@,%@", [retrievedPeripherals count], retrievedPeripherals,firstPeripheral.description,firstPeripheral.UUID);
    self.peerName=firstPeripheral.name;
    if(firstPeripheral){
        self.peripheral=[retrievedPeripherals objectAtIndex:0];
        [self.manager connectPeripheral:firstPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}
#pragma Load and Save Peripheral UUIDs
- (void)saveUUID:(CBPeripheral*)aPeripheral{
    NSString *UUIDStr = (__bridge NSString *)
    CFUUIDCreateString(kCFAllocatorDefault, aPeripheral.UUID);
    NSLog(@"saveUUID:%@",UUIDStr);
    [[NSUserDefaults standardUserDefaults]setObject:UUIDStr forKey:@"peripheralUUID"];
}
- (NSArray*)loadUUID{
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"peripheralUUID"];
    if([savedValue length]<1){
        return nil;
    }
    NSLog(@"savedValue %@",savedValue);
    CFUUIDRef uuidRef = CFUUIDCreateFromString(NO, (__bridge CFStringRef)savedValue);
    return [NSArray arrayWithObject:(__bridge id)uuidRef];
}

#pragma FOR iOS6 BOOK
// Notifyを無効にする
- (BOOL)disable_notify{
    if(!self.peripheral) return NO;
    [self setNotifyValueForService:@"26eb0005-b012-49a8-b1f8-394fb2032b0f" characteristicUUID:@"2A06" peripheral:self.peripheral enable:NO];
    return YES;
}
//バイブを鳴らす
- (void)vibrate{
    if(!self.peripheral) return;
    uint8_t byteData=0x01;
    NSData *data=[NSData dataWithBytes:&byteData length:1];
    [self writeValueForService: @"1802" characteristicUUID:@"2A06" peripheral:self.peripheral data:data writeType:CBCharacteristicWriteWithoutResponse];
}
//音を鳴らす
- (void)sound{
    if(!self.peripheral) return;
    uint8_t byteData=0x02;
    NSData *data=[NSData dataWithBytes:&byteData length:1];
    [self writeValueForService: @"1802" characteristicUUID:@"2A06" peripheral:self.peripheral data:data writeType:CBCharacteristicWriteWithoutResponse];
}
@end
