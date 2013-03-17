//
//  HIDManager.h
//  GSHOCK
//
//  Created by Yusuke Sekikawa on 1/3/13.
//  Copyright (c) 2013 y.sekikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
// used interface from CAWindowServer & CAWindowServerDisplay
@interface CAWindowServer : NSObject
+ (id)serverIfRunning;
- (id)displays;
@end


@interface CAWindowServerDisplay : NSObject
- (unsigned int)clientPortAtPosition:(struct CGPoint)fp8;
@end

@interface HIDManager : NSObject
+(void)volumeUp;
+(void)volumeDown;
+(void)lounchAPP;
+(void)homeDown;
+(void)homeUp;
+(void)touchDisplay:(CGPoint)point touch:(int)touch;
+(void)listenVolumeButton;
@end
