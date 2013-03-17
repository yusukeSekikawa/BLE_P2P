//
//  HIDManager.m
//  BLE_P2P
//
//  Created by Yusuke Sekikawa on 1/3/13.
//  Copyright (c) 2013 y.sekikawa. All rights reserved.
//

//Some Useful Informations
//http://huntanswer.com/question/tag/system/
//http://stackoverflow.com/questions/11493846/system-wide-tap-simulation-on-ios
//http://code.google.com/p/iphone-tweaks/source/browse/trunk/KeyMouseRelay/KeyMouseRelay.mm?r=67
//https://github.com/ajerez/AJNotificationView
//http://www.cocoacontrols.com
//http://stackoverflow.com/questions/10274405/use-gsevent-to-send-touch-event-but-its-inviald
//http://www.ifans.com/forums/threads/using-graphicsservices-to-send-keyboard-mouse-events-hooked-into-springboard.296966/
//http://stackoverflow.com/questions/11002340/how-to-make-a-dialog-in-ios-which-allows-jumping-directly-to-settings-screen
//http://stackoverflow.com/questions/2010812/adding-a-uiwindow-in-xcode-iphone-sdk/2021481#2021481
//http://stackoverflow.com/questions/12247052/how-to-use-springboard-services-framework-to-use-sbslaunchapplicationwithidentif
//http://stackoverflow.com/questions/10274405/use-gsevent-to-send-touch-event-but-its-inviald
//http://hid-support.googlecode.com/svn-history/r47/trunk/hidspringboard/Tweak.xm
//http://nacho4d-nacho4d.blogspot.jp/2012/01/catching-keyboard-events-in-ios.html
//http://stackoverflow.com/questions/4656214/iphone-backgrounding-to-poll-for-events
//http://stackoverflow.com/questions/12504222/using-volume-buttons-to-toggle-airplane-mode-on-iphone

#import "HIDManager.h"
#include <objc/runtime.h>
#include <mach/mach_port.h>
#include <mach/mach_init.h>
#include <dlfcn.h>
#import "GSEvent.h"

@implementation HIDManager
+(void)volumeUp{
    [self performSelector:@selector(_volumeUp)];
}
+(void)_volumeUp{
    volumeUp();
}
+(void)volumeDown{
    [self performSelector:@selector(_volumeUp)];
}
+(void)_volumeDown{
    volumeUp();
}
+(void)homeDown{
    [self performSelector:@selector(_emulateHomeButtonDown)];
}
+(void)homeUp{
    [self performSelector:@selector(_emulateHomeButtonUp)];
}
+(void) _emulateHomeButtonUp{
    emulateHomeButton(NO);
}
+(void) _emulateHomeButtonDown{
    emulateHomeButton(YES);
}

+(void)touchDisplay:(CGPoint)point touch:(int)touch{
    //postMouseEvent(point.x,point.y,touch);
}
+(void)lounchAPP{
    //lounchAPP();
}

+(void)listenVolumeButton{
    listenVolumeButton();
}
static void volumeUp(){
    //dlsym(RTLD_SELF, "getstring");;
    uint64_t (*GSCurrentEventTimestamp)() = (uint64_t(*)())dlsym(RTLD_SELF, "GSCurrentEventTimestamp");
    void (*GSSendSystemEvent)(const GSEventRecord* record) = (void(*)(const GSEventRecord* record)) dlsym(RTLD_SELF, "GSSendSystemEvent");
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    record.timestamp = GSCurrentEventTimestamp();
    record.type = kGSEventVolumeUpButtonDown;
    GSSendSystemEvent(&record);
    record.type = kGSEventVolumeUpButtonUp;
    GSSendSystemEvent(&record);
}
static void volumeDown(){
    //dlsym(RTLD_SELF, "getstring");;
    uint64_t (*GSCurrentEventTimestamp)() = (uint64_t(*)())dlsym(RTLD_SELF, "GSCurrentEventTimestamp");
    void (*GSSendSystemEvent)(const GSEventRecord* record) = (void(*)(const GSEventRecord* record)) dlsym(RTLD_SELF, "GSSendSystemEvent");
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    record.timestamp = GSCurrentEventTimestamp();
    record.type = kGSEventVolumeDownButtonDown;
    GSSendSystemEvent(&record);
    record.type = kGSEventVolumeDownButtonDown;
    GSSendSystemEvent(&record);
}

static void emulateHomeButton(BOOL down){
    uint64_t (*GSCurrentEventTimestamp)() = (uint64_t(*)())dlsym(RTLD_SELF, "GSCurrentEventTimestamp");
    void (*GSSendSystemEvent)(const GSEventRecord* record) = (void(*)(const GSEventRecord* record)) dlsym(RTLD_SELF, "GSSendSystemEvent");
    
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    
    if(down)
        record.type = kGSEventMenuButtonDown;
    else
        record.type = kGSEventMenuButtonUp;

    record.timestamp = GSCurrentEventTimestamp();
    //FixRecord(&record);
    GSSendSystemEvent(&record);
}

static void hoge(GSEventRef event);

static void listenEvent(){
    NSLog(@"GSEventRegisterEventCallBack");
    void (*GSEventRegisterEventCallBack)(void(*callback)(GSEventRef event)) = (void(*)(void(*callback)(GSEventRef event))) dlsym(RTLD_SELF, "GSEventRegisterEventCallBack");
    GSEventRegisterEventCallBack(*hoge);
}
void hoge(GSEventRef event){
    NSLog(@"hoge hoge");
}
static void listenVolumeButton(){
    NSLog(@"GSEventRegisterEventCallBack");
    void (*GSEventRegisterEventCallBack)(void(*callback)(GSEventRef event)) = (void(*)(void(*callback)(GSEventRef event))) dlsym(RTLD_SELF, "GSEventRegisterEventCallBack");
    GSEventRegisterEventCallBack(*hoge);
}


#if 0
// iPad support
static int is_iPad = 0;
// Screen dimension
static float screen_width = 0;
static float screen_height = 0;
static void lounchAPP(){
#if 1
    void(*GSEventSendApplicationOpenURL)(CFURLRef url, mach_port_t port) = (void(*)(CFURLRef url, mach_port_t port)) dlsym(RTLD_SELF, "GSEventSendApplicationOpenURL");
    
    mach_port_t (*GSGetPurpleApplicationPort)() = (mach_port_t(*)())dlsym(RTLD_SELF, "GSGetPurpleApplicationPort");
    
    mach_port_t port = GSGetPurpleApplicationPort();
    NSURL *cameraAPP=[NSURL URLWithString:@"maps://"];
    //CFURLRef cameraAPPref=(__bridge CFURLRef)cameraAPP;
    CFURLRef cameraAPPref=CFBridgingRetain(cameraAPP);
    GSEventSendApplicationOpenURL(cameraAPPref,port);
    CFBridgingRelease(cameraAPPref);
    
#else
    
    int(*SBSLaunchApplicationWithIdentifier)(CFStringRef displayIdentifier, Boolean suspended) = (int(*)(CFStringRef displayIdentifier, Boolean suspended)) dlsym(RTLD_SELF, "SBSLaunchApplicationWithIdentifier");
    
    SBSLaunchApplicationWithIdentifier(CFSTR("com.apple.preferences"), false);
#endif
}
static void sendGSEvent(GSEventRecord *eventRecord, CGPoint point){
    mach_port_t (*GSGetPurpleApplicationPort)() = (mach_port_t(*)())dlsym(RTLD_SELF, "GSGetPurpleApplicationPort");
    mach_port_t port = GSGetPurpleApplicationPort();
    
    CAWindowServer *server=[CAWindowServer serverIfRunning];
    
    if (server){
        NSArray *displays=[server displays];
        if (displays != nil && [displays count] != 0){
            CAWindowServerDisplay *display=[displays objectAtIndex:0];
            if (display) {
                if (is_iPad) {
                    CGPoint point2;
                    point2.x = screen_height - 1 - point.y;
                    point2.y = point.x;
                    port = [display clientPortAtPosition:point2];
                    // NSLog(@"display port iPad: %x", (int) port_);
                } else {
                    port = [display clientPortAtPosition:point];
                    // NSLog(@"display port non-wildcat: %x", (int) port_);
                }
            }
        }
    }
    

    
    if (port) {
        // FixRecord(eventRecord);
        GSSendEvent(eventRecord, port);
    }
}

static void postMouseEvent(float x, float y, int click){
    mach_port_t (*GSGetPurpleApplicationPort)() = (mach_port_t(*)())dlsym(RTLD_SELF, "GSGetPurpleApplicationPort");
    mach_port_t port = GSGetPurpleApplicationPort();
    uint64_t (*GSCurrentEventTimestamp)() = (uint64_t(*)())dlsym(RTLD_SELF, "GSCurrentEventTimestamp");
    
    void (*GSSendEvent)(const GSEventRecord* record, mach_port_t port) = (void(*)(const GSEventRecord* record, mach_port_t port)) dlsym(RTLD_SELF, "GSSendEvent");

    
    static int prev_click = 0;
    
    if (!click && !prev_click) return;
    
    CGPoint location = CGPointMake(x, y);
    
    // structure of touch GSEvent
    struct GSTouchEvent {
        GSEventRecord record;
        GSHandInfo    handInfo;
    };
    
    GSEventRecord record;

    struct GSTouchEvent touchEven;
    struct GSTouchEvent *event=&touchEven;
    
    // set up GSEvent
    record.type = kGSEventHand;
    record.windowLocation = location;
    record.timestamp = GSCurrentEventTimestamp();
    record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);
    
    if (!prev_click) {
        event->handInfo.type = kGSHandInfoTypeTouchDown;
    }
    if (click) {
        event->handInfo.type = kGSHandInfoTypeTouchDragged;
        //event->handInfo.type = kGSHandInfoTypeTouchMoved;
    }else{
        event->handInfo.type = kGSHandInfoTypeTouchUp;
    }
    
    event->handInfo.pathInfosCount = 1;
    bzero(&event->handInfo.pathInfos[0], sizeof(GSPathInfo));
    event->handInfo.pathInfos[0].pathIndex     = 1;
    event->handInfo.pathInfos[0].pathIdentity  = 2;
    event->handInfo.pathInfos[0].pathProximity = click ? 0x03 : 0x00;;
    event->handInfo.pathInfos[0].pathLocation  = location;
    
    // send GSEvent
    //sendGSEvent( (GSEventRecord*) event, location);
    
    GSSendEvent(&record, port);

    prev_click = click;
}
#endif
@end
