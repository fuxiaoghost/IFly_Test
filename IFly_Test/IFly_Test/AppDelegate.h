//
//  AppDelegate.h
//  IFly_Test
//
//  Created by Dawn on 14-3-9.
//  Copyright (c) 2014年 Dawn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IFlySpeechRecognizerDelegate,IFlySpeechUserDelegate>

@property (retain, nonatomic) UIWindow *window;

@end
