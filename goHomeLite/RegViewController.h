//
//  RegViewController.h
//  goHomeLite
//
//  Created by 石井嗣 on 2014/12/17.
//  Copyright (c) 2014年 YuZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//gmail
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
//SMS
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>


//@interface RegViewController : UIViewController<CLLocationManagerDelegate,UITextFieldDelegate,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@interface RegViewController : UIViewController<CLLocationManagerDelegate,UITextFieldDelegate,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,SKPSMTPMessageDelegate,MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property NSTimer* timer;

//-(void)LocalNotificationStart;

@end
