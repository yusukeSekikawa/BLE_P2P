//
//  ViewController.h
//  BLE_P2P
//
//  Created by ySekikawa on 2012/11/06.
//  Copyright (c) 2012年 y.sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBScanner.h"
#import "CBAdvertizer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#define ENABLE_CAMERA_VOLUME_SHUTTER

@interface ViewController : UITableViewController<CBScannerDelegate,CBAdvertizerDelegate,UITableViewDelegate>
@property (strong, nonatomic) CBScanner *scanner;
@property (strong, nonatomic) CBAdvertizer *advertizer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILabel *peerName;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *connecting;
@property (strong, nonatomic) IBOutlet UIProgressView *power;
@property (strong, nonatomic) IBOutlet UISwitch *localNotificationEnable;
@property (strong, nonatomic) IBOutlet UISwitch *sensorModeEnable;
@property  float              currentVolume;
@property (strong, nonatomic) MPVolumeView *volumeView;
- (IBAction) changeSensorMode:(id)sender;
@end
