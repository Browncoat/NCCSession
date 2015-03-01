//
//  AppDelegate.h
//  Session
//
//  Created by Nathaniel Potter on 11/3/14.
//  Copyright (c) 2014 Nathaniel Potter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

#define SERVICE @"com.browncoatapps"
#define SESSION_TOKEN_NAME @"session_token"
#define SESSION_ID_NAME @"session_id"
#define APP_ID_NAME @"app_id"
#define API_KEY_NAME @"app_key"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *user;

@end

