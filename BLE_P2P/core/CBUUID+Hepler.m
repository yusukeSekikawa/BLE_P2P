//
//  CBUUID (StringExtraction).m
//  BLE_P2P
//
//  Created by Yusuke Sekikawa on 12/8/12.
//  Copyright (c) 2012 y.sekikawa. All rights reserved.
//

#import "CBUUID+Hepler.h"
@implementation CBUUID (Helper)
- (NSString *)representativeString;
{
    NSData *data = [self data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    return outputString;
}
@end