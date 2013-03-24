//
//  simpleCameraViewViewController.h
//  BLE_P2P
//
//  Created by ysekikawa on 3/24/13.
//  Copyright (c) 2013 y.sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface simpleCameraViewViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImagePickerController *ipc;

@end
