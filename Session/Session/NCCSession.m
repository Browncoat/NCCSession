// NCCSession.m
//
// Copyright (c) 2013-2014 NCCCoreDataClient (http://coredataclient.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NCCSession.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import "NCCKeychainManager.h"

#define SESSION_USER_ID @"ncc_session_user_id"

@implementation NCCSession

static NCCSession *_sharedSession;
static NCCKeychainManager *_keychainManager;
static NSString *uuid;
static NSString *bundleShortVersion;

#pragma mark - Lifecycle

+ (instancetype)createSessionWithUserId:(NSString *)userId userInfo:(NSDictionary *)userInfo service:(NSString *)service;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedSession) {
            _sharedSession = [[self alloc] init];
        }
    });
    
    [_sharedSession setUserId:userId userInfo:userInfo service:service];
    
    return _sharedSession;
}

/*
+ (BOOL)updateUserId:(NSString *)userId userInfo:(NSDictionary *)userInfo service:(NSString *)service
{
    NCCSession *session = _sharedSession;
    [session updateUserId:userId userInfo:userInfo service:service];
    
    return [self save];
}
*/
+ (instancetype)sharedSession
{
    return _sharedSession;
}

- (void)setUserId:(NSString *)userId userInfo:(NSDictionary *)userInfo service:(NSString *)service
{
    _userId = userId;
    _userInfo = userInfo;
    if (service) {
        _keychainManager = [NCCKeychainManager managerWithService:service];
    }
    
    if (![self save]) {
        NSLog(@"ERROR Saving NCCSession");
    }
}

#pragma mark - Clear

+ (void)invalidateSession
{
    if (_sharedSession) {
        [_keychainManager deleteCredentialsForUser:_sharedSession.userId];
        [_sharedSession setUserId:nil userInfo:nil service:nil];
    }
}

#pragma mark - Save

- (BOOL)save
{
    BOOL success = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_userId forKey:SESSION_USER_ID];
    [userDefaults synchronize];
    if (self.userInfo) {
        success = [_keychainManager saveCredentials:self.userInfo forUser:_userId];
    }
    
    return success;
}

+ (instancetype)sessionWithService:(NSString *)service userId:(NSString *)userId
{
    NCCSession *session = nil;
    
    if (userId) {
        _keychainManager = [NCCKeychainManager managerWithService:service];
        NSDictionary *sessionCredentials = [_keychainManager credentialsForUser:userId];
        if (sessionCredentials) {
            session = [NCCSession createSessionWithUserId:userId userInfo:sessionCredentials service:service];
        }
    }
    
    return session;
}

+ (instancetype)sessionWithService:(NSString *)service;
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_USER_ID];
    
    return [self sessionWithService:service userId:userId];
}

#pragma mark - Getters / Setters
+ (NSString *)uuid
{
    if (!uuid) {
        uuid = [NSString uuid];
    }
    
    return uuid;
}

+ (NSString *)bundleShortVersion
{
    if (!bundleShortVersion) {
        bundleShortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    
    return bundleShortVersion;
}

#pragma mark - Helpers

+ (BOOL)isValid
{
    if (_sharedSession) {
        return (_sharedSession.userInfo != nil);
    }
    
    return NO;
}

@end
