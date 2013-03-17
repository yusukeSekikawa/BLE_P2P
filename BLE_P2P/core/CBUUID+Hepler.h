//
//  CBUUID+Helper.h
//  BLE_P2P
//
//  Created by Yusuke Sekikawa on 12/8/12.
//  Copyright (c) 2012 y.sekikawa. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
/* Product Info */
//CASIO G-SHOCK GB-6900AA(http://g-shock.jp/ble/products/)
//CASIO G-SHOCK GB-5600AA(http://g-shock.jp/ble/products/)
//Logitec LBT-MPVRU01 (http://www.pro.logitec.co.jp/pro/g/gLBT-MPVRU01BK/)
//Logitec LBT-MPVRU02 (http://www.pro.logitec.co.jp/pro/g/gLBT-MPVRU02PN/)
//Logitec LBT-MPVRU03 (http://www.pro.logitec.co.jp/pro/g/gLBT-MPVRU03BK/)
//Logitec LBT-MPVRU04 (http://www.pro.logitec.co.jp/pro/g/gLBT-MPVRU04BU/)
//Softbank IZCONY  http://www.softbankselection.jp/onlineshop/product/detail/003865.html
/* Supported Device Name */
#define kCBAdvDataLocalNameGSHOCK5600A  @"CASIO GB-5600A*"
#define kCBAdvDataLocalNameGSHOCK6900A  @"CASIO GB-6900A*"
#define kCBAdvDataLocalNameLBTVRU01     @"LBT-VRU01"
#define kCBAdvDataLocalNameLBTVRU02     @"LBT-VRU02"
#define kCBAdvDataLocalNameLBTVRU03     @"LBT-VRU03"
#define kCBAdvDataLocalNameLBTVRU04     @"LBT-VRU04"
#define kCBAdvDataLocalNameLSBPX01PRXM  @"IZCONY"
#define kCBAdvBLEB2P                    @"BLEB2P"


/*
 kCBAdvDataLocalName = IZCONY;
 kCBAdvDataServiceUUIDs =     (
 "Unknown (<1803>)",
 "Unknown (<1802>)",
 "Unknown (<1804>)",
 "Unknown (<180f>)"
 );
 */

/* Keys */
#define kCBInfoStringKey                @"kCBInfoStringKey"
#define kCBInfoRSSIKey                  @"kCBInfoRSSIKey"
#define kCBInfoCharacteristicUUIDKey    @"kCBInfoCharacteristicUUIDKey"
#define kCBInfoDataKey                  @"kCBInfoDataKey"
#define kCBInfoServiceUUIDKey           @"kCBInfoCharacteristicUUIDKey"

@interface CBUUID (Helper)
- (NSString *)representativeString;
@end
