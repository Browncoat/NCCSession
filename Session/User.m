//
//  User.m
//  Session
//
//  Created by Nathaniel Potter on 2/28/15.
//  Copyright (c) 2015 Nathaniel Potter. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"
#include "NCCSession.h"

#define USERS @"users"
#define UID @"uid"
#define USERNAME @"username"
#define FIRSTNAME @"firstName"
#define LASTNAME @"lastName"
#define PASSWORD @"password"

@implementation User

+ (instancetype)userWithId:(NSString *)uid
{
    NCCSession *session = [NCCSession sessionWithService:SERVICE userId:uid];
    
    NSArray *users = [self allUsers];
    User *user = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", uid]].lastObject;
    
    user.username = [session userInfo][USERNAME];
    user.password = [session userInfo][SESSION_TOKEN_NAME];
    
    return user;
}

+ (instancetype)user
{
    User *user = [[[self class] alloc] init];
    user.uid = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    return user;
}

+ (NSArray *)allUsers
{
    NSArray *usersData = [[self userDefaults] objectForKey:USERS];
    NSMutableArray *users = [NSMutableArray array];
    for (NSData *userData in usersData) {
        [users addObject:[NSKeyedUnarchiver unarchiveObjectWithData:userData]];
    }
    
    return users;
}

+ (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (void)save
{
    NSMutableArray *users = [NSMutableArray arrayWithArray:[User allUsers]];
    User *previousUser = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.uid]].lastObject;
    [users removeObject:previousUser];
    [users addObject:self];
    
    NSMutableArray *usersData = [NSMutableArray array];
    for (User *user in users) {
        [usersData addObject:[NSKeyedArchiver archivedDataWithRootObject:user]];
    }
    
    [[User userDefaults] setObject:usersData forKey:USERS];
    [[User userDefaults] synchronize];
    
    [self createSession];
}

- (NSDictionary *)dictionaryForSave
{
    return @{USERNAME:self.username,
             FIRSTNAME:self.firstName,
             LASTNAME:self.lastName};
}

- (void)createSession
{
    NSString *token = self.password;
    NSString *userId = self.uid;
    [NCCSession createSessionWithUserId:userId userInfo:@{SESSION_TOKEN_NAME:token,
                                                          USERNAME:self.username} service:SERVICE];
}

- (void)delete
{
    NSMutableArray *users = [NSMutableArray arrayWithArray:[User allUsers]];
    User *user = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.uid]].lastObject;
    [users removeObject:user];
    
    NSMutableArray *usersData = [NSMutableArray array];
    for (User *user in users) {
        [usersData addObject:[NSKeyedArchiver archivedDataWithRootObject:user]];
    }
    
    [[User userDefaults] setObject:usersData forKey:USERS];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _firstName = [coder decodeObjectForKey:FIRSTNAME];
        _lastName = [coder decodeObjectForKey:LASTNAME];
        _uid = [coder decodeObjectForKey:UID];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.firstName forKey:FIRSTNAME];
    [coder encodeObject:self.lastName forKey:LASTNAME];
    [coder encodeObject:self.uid forKey:UID];
}

@end
