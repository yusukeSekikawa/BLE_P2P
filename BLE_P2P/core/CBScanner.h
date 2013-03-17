//
//  CBScanner.h
//  BLE_P2P
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

// #define CBScannerAllowDuplicates

@class CBScanner;

@protocol CBScannerDelegate <NSObject>
- (void)scanner:(CBScanner*)scanner didReadData:(NSDictionary*)userInfo;
- (void)scannerDidChangeStatus:(CBScanner*)scanner;
@end

@interface CBScanner : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) id<CBScannerDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString *peerName;

- (id)initWithDelegate:(id<CBScannerDelegate>)delegate;
- (void)startScan;
- (void)stopScan;
- (BOOL)isAvailable;
- (BOOL)writeDataforService:(NSString*)service characteristic:(NSString*)characteristic data:(NSData*)data ;
- (BOOL)readDataforService:(NSString*)service characteristic:(NSString*)characteristic;
- (void)forgetAndRetry;
@end
