//
//  User.m
//  Session
//
//  Created by Nathaniel Potter on 2/28/15.
//  Copyright (c) 2015 Nathaniel Potter. All rights reserved.
//

#import "User.h"

#define USERS @"users"

@implementation User

+ (instancetype)userWithId:(NSString *)uid
{
    User *user = [[User users] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", uid]].lastObject;
    
    return user;
}

+ (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

+ (NSMutableArray *)users
{
    NSMutableArray *users = [NSMutableArray arrayWithArray:[[self userDefaults] objectForKey:USERS]];
    
    return users;
}

- (void)save
{
    NSMutableArray *users = [User users];
    User *user = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.uid]].lastObject;
    if (user) {
        self.uid = user.uid;
        [users removeObject:user];
    } else {
        self.uid = [[NSUUID UUID] UUIDString];
    }
    
    [users addObject:self];
    
    [[User userDefaults] setObject:users forKey:USERS];
}

- (void)delete
{
    NSMutableArray *users = [User users];
    User *user = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.uid]].lastObject;
    [users removeObject:user];
    
    [[User userDefaults] setObject:users forKey:USERS];
}

@end
