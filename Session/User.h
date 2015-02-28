//
//  User.h
//  Session
//
//  Created by Nathaniel Potter on 2/28/15.
//  Copyright (c) 2015 Nathaniel Potter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (instancetype)userWithId:(NSString *)uid;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

- (void)save;
- (void)delete;

@end
