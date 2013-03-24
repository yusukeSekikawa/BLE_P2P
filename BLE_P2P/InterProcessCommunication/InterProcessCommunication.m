//
//  InterProcessCommunication.m
//  BLE_P2P
//
//  Created by ysekikawa on 3/24/13.
//  Copyright (c) 2013 y.sekikawa. All rights reserved.
//

#import "InterProcessCommunication.h"

@implementation InterProcessCommunication
//PasteBoadを使ったプロセス間通信サンプル
// メッセージをポストする
+ (void)postPasteBoadMsg{
    NSString *pastboardContents = [UIPasteboard pasteboardWithName:@"com.ysekikawa.BLECOM" create:YES].string;
    NSInteger index=[pastboardContents integerValue]+1;;
    NSString *newPastboardContents=[NSString stringWithFormat:@"%d",index];
    [[UIPasteboard pasteboardWithName:@"com.ysekikawa.BLECOM" create:YES] setString:newPastboardContents];
    NSLog(@"postPasteBoadMsg");
}
#if 0
// メッセージをを取得する
// メッセージを受け取りたいアプリケーションで以下のメソッドを実装する
- (void)watchPasteBoard
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIPasteboard *customPasteboad=[UIPasteboard pasteboardWithName:@"com.ysekikawa.BLECOM" create:YES];
        NSString *pastboardContents = customPasteboad.string;
        while (1){
            if (![pastboardContents isEqualToString:customPasteboad.string])
            {
                pastboardContents = customPasteboad.string;
                NSLog(@"Pasteboard Changed.Contents: %@", pastboardContents);
            }
            [NSThread sleepForTimeInterval:0.05];
        }
    });
}
#endif
@end
