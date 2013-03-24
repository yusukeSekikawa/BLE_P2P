//
//  simpleCameraViewViewController.m
//  BLE_P2P
//
//  Created by ysekikawa on 3/24/13.
//  Copyright (c) 2013 y.sekikawa. All rights reserved.
//

#import "simpleCameraViewViewController.h"

@interface simpleCameraViewViewController ()

@end

@implementation simpleCameraViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)takePicture{
    if(self.ipc){
        self.ipc.showsCameraControls = NO;
        [self.ipc takePicture];
    }
    NSLog(@"call takePicture");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"add notification %@",@"pasteboardChanged");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChanged:) name:UIPasteboardChangedNotification object:nil];
}


- (void)showPicker:(BOOL)animated{
    if([UIImagePickerController
        isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.ipc = [[UIImagePickerController alloc] init];
        self.ipc.delegate = self;
        self.ipc.sourceType = UIImagePickerControllerSourceTypeCamera;  // 画像の取得先をカメラに設定
        self.ipc.allowsEditing = NO;
        self.ipc.showsCameraControls = YES;
        [self presentViewController:self.ipc animated:YES completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showPicker:NO];
    [self watchPasteBoardChange];
    
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)watchPasteBoardChange
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIPasteboard *customPasteboad=[UIPasteboard pasteboardWithName:@"com.ysekikawa.BLECOM" create:YES];
        NSString *pastboardContents = customPasteboad.string;
        while (1){
            if (![pastboardContents isEqualToString:customPasteboad.string])
            {
                pastboardContents = customPasteboad.string;
                [self takePicture];
                NSLog(@"Pasteboard Changed.Contents: %@", pastboardContents);
            }
            [NSThread sleepForTimeInterval:0.05];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    
    self.ipc.showsCameraControls = YES;
    [self dismissModalViewControllerAnimated:YES];  // モーダルビューを閉じる
    UIImageWriteToSavedPhotosAlbum(
                                   image,
                                   self,
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    ;
}

-(void)savingImageIsFinished:(UIImage*)image
    didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    
    UIAlertView *alert
    = [[UIAlertView alloc] initWithTitle:nil
                                 message:@"save done"
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK",nil];
    [alert show];
}

@end
