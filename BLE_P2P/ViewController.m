//
//  ViewController.m
//  BLE_P2P
//
//  Created by ySekikawa on 2012/11/06.
//  Copyright (c) 2012年 y.sekikawa. All rights reserved.
//

#import "ViewController.h"
#import "CBUUID+Hepler.h"
#import "AJNotificationView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "InterProcessCommunication.h"
#ifdef ENABLE_CAMERA_VOLUME_SHUTTER
#import "HIDManager.h"
#endif
@interface ViewController ()

@end

@implementation ViewController
#pragma mark ACTION
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int selectedRow     = [indexPath row];
    int selectedSection = [indexPath section];
    
    NSString *selectorName=[NSString stringWithFormat:@"action_%0.2d_%0.2d",selectedSection+1,selectedRow+1];
    SEL selector= NSSelectorFromString(selectorName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:selector]){[self performSelector:selector];}
#pragma clang diagnostic pop
}
/* vibrate peer by Writing 0x01 to Servie:1802 Characteristic:2A06*/
- (void)action_02_01 {
    DNSLogMethod
    uint8_t byteData=0x01;
    NSData *data=[NSData dataWithBytes:&byteData length:1];
    [self.scanner writeDataforService:@"1802" characteristic:@"2A06" data:data];
}
/* sound peer by Writing 0x01 to Servie:1802 Characteristic:2A06*/
- (void)action_02_02 {
    DNSLogMethod
    uint8_t byteData=0x02;
    NSData *data=[NSData dataWithBytes:&byteData length:1];
    [self.scanner writeDataforService:@"1802" characteristic:@"2A06" data:data];
}

- (void)action_03_01 {
    DNSLogMethod
    [self.scanner forgetAndRetry];
}
- (void)action_03_04 {
    DNSLogMethod
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"photo:"]];
}
#pragma Helper
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)motionBegan:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
    DNSLogMethod
	if (motion == UIEventSubtypeMotionShake)
	{
        uint8_t byteData=0x01;
        [self.advertizer notifyData:[NSData dataWithBytes:&byteData length:1]];
	}
}
- (double)normalizedRSSI:(NSNumber*)rssi{
    double normalized_rssi=(128.0+[rssi integerValue]+50.0)/128.0;
    if(normalized_rssi>1){
        normalized_rssi=1;
    }
    if(normalized_rssi<0){
        normalized_rssi=0;
    }
    return normalized_rssi;
}
- (void)presentLocalNoification{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.alertBody = @"Button Pressed";
    localNotif.alertAction = @"Open";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

#pragma mark AJNotificationView
- (void)presentAJNoification:(NSString*)msg{
    [AJNotificationView showNoticeInView:self.view
                                    type:AJNotificationTypeBlue
                                   title:msg
                         linedBackground:AJLinedBackgroundTypeAnimated
                               hideAfter:2.0f
                                response:^{
                                    NSLog(@"Response block");
                                }
     ];
}

#pragma mark VolumeListener
- (void)setVolumeNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
}

- (void)makePlayer{
    DNSLogMethod
    CGRect frame = CGRectMake(-100, -100, 100, 100);
    //CGRect frame = CGRectMake(100, 100, 100, 100);
    self.volumeView = [[MPVolumeView alloc] initWithFrame:frame];
    [self.volumeView sizeToFit];
    [self.view addSubview:self.volumeView];
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 category = kAudioSessionCategory_AmbientSound;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    AudioSessionSetActive(true);
    //AudioSessionSetActive(false);
    
    [self setVolumeNotification];
    [self.volumeView removeFromSuperview];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    //[MPMusicPlayerController applicationMusicPlayer].play;
}
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    DNSLogMethod;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
}
- (void)volumeChanged:(NSNotification *)notification{
    DNSLogMethod;
    if ([[[notification userInfo]objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"]isEqualToString:@"ExplicitVolumeChange"]) {
        if([MPMusicPlayerController applicationMusicPlayer].volume>self.currentVolume || [MPMusicPlayerController applicationMusicPlayer].volume==1.0){
            NSLog(@"Volume Up");
        }else{
            NSLog(@"Volume Down");
            uint8_t byteData=-0x02;
            [self.advertizer notifyData:[NSData dataWithBytes:&byteData length:1]];
        }
        self.currentVolume=[MPMusicPlayerController applicationMusicPlayer].volume;
    }
}

- (void)FMPButtonPressed:(uint8_t)byteData{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self presentAJNoification:@"Button Pressed"];
    }else{
        if(self.localNotificationEnable.on){
            [self presentLocalNoification];
        }else{
#ifdef ENABLE_CAMERA_VOLUME_SHUTTER
            if(byteData==0x01)
                [HIDManager volumeUp];
            else
                [HIDManager volumeDown];
#endif
        }
        [InterProcessCommunication postPasteBoadMsg];
    }
}

#pragma CBAdvertizer delegate

-(void)advertizerDidChangeStatus:(CBAdvertizer *)advertizer{
    if(advertizer.manager.state==CBPeripheralManagerStatePoweredOn){
        [self.advertizer initManager];
        [self.advertizer startAdvertize];
    };
}

- (void)advertizerDidSubscribed:(CBAdvertizer *)advertizer{
    DNSLogMethod;
}

- (void)advertizerDidUnSubscribed:(CBAdvertizer *)advertizer{
    DNSLogMethod;
}

- (void)advertizer:(CBAdvertizer *)advertizer didReceiveData:(NSDictionary *)userInfo{
    if([userInfo objectForKey:kCBInfoDataKey]){
        NSData *_data=[userInfo objectForKey:kCBInfoDataKey];
        uint8_t byteData=0x01;
        [_data getBytes:&byteData];
        if(byteData==0x01){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            }else{
                [self presentLocalNoification];
            }
        }else{
            AudioServicesPlaySystemSound(1005);
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            }else{
                [self presentLocalNoification];
            }
        }
    }
}

#pragma CBScanner delegate

- (void)scannerDidChangeStatus:(CBScanner *)scanner{
    DNSLogMethod
    if(scanner.peripheral.isConnected){
        self.peerName.text=scanner.peerName;
        [self.connecting stopAnimating];
        self.power.progress=[self normalizedRSSI:scanner.peripheral.RSSI];
    }else{
        self.peerName.text=@"Searching...";
        [self.connecting startAnimating];
        self.power.progress=0.0;
    }
}
- (void)scanner:(CBScanner*)scanner didReadData:(NSDictionary*)userInfo{
    DNSLogMethod
    if([[userInfo objectForKey:kCBInfoCharacteristicUUIDKey] isEqual:[CBUUID UUIDWithString:@"2A06"]]){
        NSData *_data=[userInfo objectForKey:kCBInfoDataKey];
        uint8_t byteData;
        [_data getBytes:&byteData];
        [self FMPButtonPressed:byteData];
    }
}
#pragma Main
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)startBLE {
    self.advertizer = [[CBAdvertizer alloc] initWithDelegate:self];
    self.scanner = [[CBScanner alloc] initWithDelegate:self];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startBLE];    
    //[self setVolumeNotification];
    [self makePlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma IBAction
- (IBAction) changeSensorMode:(id)sender{
    if(self.sensorModeEnable.on){
        [self.advertizer startAdvertize];
    }else{
        [self.advertizer stopAdvertize];
    }
}

#pragma mark Interprocess Communication

@end
