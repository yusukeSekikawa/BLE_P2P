//
//  screenCapture.m
//  BLE_P2P
//
//  Created by ysekikawa on 3/24/13.
//  Copyright (c) 2013 y.sekikawa. All rights reserved.
//

#import "screenCapture.h"
typedef struct __IOSurface *IOSurfaceRef;
UIKIT_EXTERN CGImageRef UICreateCGImageFromIOSurface(IOSurfaceRef);

@implementation screenCapture
- (void) savingImageIsFinished:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo{
    NSLog(@"%@",_error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"End"message:@"image save completed"delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
    [alert show];
}
+(UIImage*)getSurfaceWighScale:(float)scale{
    //http://iphone-tora.sakura.ne.jp/uiimage.html
    IOSurfaceRef surface = (__bridge IOSurfaceRef)([UIWindow performSelector:@selector(createScreenIOSurface)]);
    CGImageRef ref = UICreateCGImageFromIOSurface(surface);
    UIImage *img=[UIImage imageWithCGImage:ref];
    CFRelease(surface);
    CGImageRelease(ref);
    
    if(scale==1){
        return  img;
        
    }else{
        UIImage *resized_img;
        float widthPer = .5;
        float heightPer = .5;
        
        CGSize sz = CGSizeMake(img.size.width*widthPer,
                               img.size.height*heightPer);
        UIGraphicsBeginImageContext(sz);
        [img drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
        resized_img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resized_img;
    }
}
@end
