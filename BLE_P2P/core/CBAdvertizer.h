//
//  CBAdvertizer.h
//  BLE_P2P
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@class CBAdvertizer;

@protocol CBAdvertizerDelegate <NSObject>
- (void)advertizerDidChangeStatus:(CBAdvertizer*)advertizer;
- (void)advertizer:(CBAdvertizer*)advertizer didReceiveData:(NSDictionary*)userInfo;
- (void)advertizerDidSubscribed:(CBAdvertizer*)advertizer;
- (void)advertizerDidUnSubscribed:(CBAdvertizer*)advertizer;
@end

@interface CBAdvertizer : NSObject<CBPeripheralManagerDelegate>

- (id)initWithDelegate:(id<CBAdvertizerDelegate>)delegate;
- (void)startAdvertize;
- (void)stopAdvertize;
- (void)notifyStr:(NSString*)msg;
- (void)notifyData:(NSData*)data;
- (void)initManager;

@property (nonatomic, strong) id<CBAdvertizerDelegate> delegate;
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, strong) CBMutableCharacteristic *read_characteristic;
@property (nonatomic, strong) CBMutableCharacteristic *write_characteristic;
@property (nonatomic, strong) CBMutableCharacteristic *notify_characteristic;

@end
