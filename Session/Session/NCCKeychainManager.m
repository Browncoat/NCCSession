// NCCKeychainManager.m
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

#import "NCCKeychainManager.h"
#import <Security/Security.h>

@implementation NCCKeychainManager
{
    NSString *_service;
}

+ (instancetype)managerWithService:(NSString *)service
{
    return [[[self class] alloc] initWithService:service];
}

- (instancetype)initWithService:(NSString *)service
{
    if (self = [super init]) {
        _service = service;
    }
    
    return self;
}

- (NSMutableDictionary *)dictionaryForKey:(NSString *)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* dict = @{(__bridge id)kSecClass:(__bridge id)(kSecClassGenericPassword),
                           (__bridge id)kSecAttrService:_service,
                           (__bridge id)kSecAttrAccount:keyData,
                           (__bridge id)kSecReturnAttributes:(__bridge id)kCFBooleanTrue,
                           (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleWhenUnlocked};

    return [NSMutableDictionary dictionaryWithDictionary:dict];
}

- (BOOL)saveCredentials:(NSDictionary *)credentials forUser:(NSString *)username
{
    NSMutableDictionary *dict = [self dictionaryForKey:username];
    
    NSData* credentialsData = [NSKeyedArchiver archivedDataWithRootObject:credentials];
    [dict setObject:credentialsData forKey:(__bridge id)kSecValueData];
    
    // Try to save to keychain
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) dict, NULL);
    BOOL success = NO;
    if (errSecSuccess == status) {
        success = YES;
    } else if (errSecDuplicateItem == status) {
        success = [self updateCredentials:credentials forUser:username];
    } else {
        NSLog(@"Unable to add password for username %@, error:%d", username, (int)status);
    }
    
    return success;
}

- (BOOL)updateCredentials:(NSDictionary *)credentials forUser:(NSString *)username
{
    NSMutableDictionary *dict = [self dictionaryForKey:username];
    [dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    BOOL success = NO;
    
    CFDictionaryRef attributes = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dict, (CFTypeRef *)&attributes);
    if (errSecSuccess == status) {
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)attributes];
        [query setObject:[dict objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        
        NSData *credentialsData = [NSKeyedArchiver archivedDataWithRootObject:credentials];
        NSMutableDictionary *updates = [NSMutableDictionary dictionary];
        [updates setObject:credentialsData forKey:(__bridge id)kSecValueData];
        
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updates);
        if (errSecSuccess != status) {
            NSLog(@"Unable to update password for username %@, error:%d", username, (int)status);
        }
        
        success = (errSecSuccess == status);
    }
    
    return success;
}

- (BOOL)deleteCredentialsForUser:(NSString *)username
{
    NSMutableDictionary *dict = [self dictionaryForKey:username];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) dict);
    if (errSecSuccess != status) {
        NSLog(@"Unable to delete username %@, error:%d", username, (int)status);
    }
    
    return (errSecSuccess == status);
}

- (NSDictionary *)credentialsForUser:(NSString *)username
{
    NSMutableDictionary *dict = [self dictionaryForKey:username];
    [dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [dict setObject: (__bridge id)kCFBooleanTrue forKey: (__bridge id) kSecReturnData];
    
    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dict, (CFTypeRef *)&result);
    if (errSecSuccess != status) {
        NSLog(@"Unable to get credentials for username %@, error:%d", username, (int)status);
    }
    
    NSDictionary *resultsDict = (__bridge NSDictionary *)result;
    
    NSDictionary *credentials = [NSKeyedUnarchiver unarchiveObjectWithData:resultsDict[(__bridge id)kSecValueData]];
    
    return credentials;
}

- (BOOL)removeAllCredentialsForServer
{
    NSDictionary* dict = @{(__bridge id)kSecClass:(__bridge id)(kSecClassInternetPassword),
                           (__bridge id)kSecAttrServer:_service,
                           (__bridge id)kSecReturnAttributes:(__bridge id)kCFBooleanTrue,
                           (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleWhenUnlocked,
                           (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue};

    // Remove any old values from the keychain
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) dict);
    if (errSecSuccess != status) {
        NSLog(@"Unable to delete all credentials for service %@, error:%d", _service, (int)status);
    }
    
    return (errSecSuccess == status);
}
/*
- (void)getAllCredentialsForServer:(NSString*)server
{
    NSDictionary* dict = @{(__bridge id)kSecClass:(__bridge id)(kSecClassInternetPassword),
                           (__bridge id)kSecAttrServer:_service,
                           (__bridge id)kSecReturnAttributes:(__bridge id)kCFBooleanTrue,
                           (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleWhenUnlocked,
                           (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue};
    
    NSDictionary* found = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) dict, (__bridge CFDictionaryRef*) &found);
    if (errSecSuccess != status) {
        NSLog(@"Unable to find all credentials for service %@, error:%d", _service, (int)status);
    }
    
    return (errSecSuccess == status);
    
    // Found
    NSString* user = (NSString*) [found objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString* pass = [[NSString alloc] initWithData:[found objectForKey:(__bridge id)(kSecValueData)] encoding:NSUTF8StringEncoding];
    
}
*/
@end
