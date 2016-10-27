//
//  UserDefaultsUtil.m
//  TSG-Phone
//
//  Created by lsq on 16/7/22.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "UserDefaultsUtil.h"
static NSString * const KEY_IN_KEYCHAIN = @"com.tsg.ios.TSG.allinfo";

@implementation UserDefaultsUtil

#pragma mark - userdefault
+(void)saveInUserDefault:(NSDictionary*)dict{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *keys = [dict allKeys];
    for (NSString *o in keys) {
        [userDefaults setObject:dict[o] ?: @"" forKey:o];
    }
    [userDefaults synchronize];
}
+(id)loadInUserDefault:(NSString*)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}
+(void)deleteInUserDefault :(NSString*)key {
    [UserDefaultsUtil saveInUserDefault:@{@"":key}];
}

#pragma mark - keychain
+(void)saveInKeyChain:(NSDictionary*)dict{
    NSMutableDictionary* ret = [UserDefaultsUtil loadDictInKeyChain];
    NSMutableDictionary *newDict = [NSMutableDictionary new];
    
    NSEnumerator *allKeys1 = [ret keyEnumerator];
    for(NSString *key in allKeys1) {
        NSString *value = [ret objectForKey:key];
        newDict[key] = value;
    }
    NSEnumerator *allKeys = [dict keyEnumerator];
    for(NSString *key in allKeys) {
        NSString *value = [dict objectForKey:key];
        newDict[key] = value;
    }

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:KEY_IN_KEYCHAIN];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:newDict] forKey:(__bridge_transfer id)kSecValueData];
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}
+(id)loadInKeyChain:(NSString*)key {
    id ret = [UserDefaultsUtil loadDictInKeyChain];
    return ret[key];
}
+(id)loadDictInKeyChain{
    NSMutableDictionary *ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:KEY_IN_KEYCHAIN];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", KEY_IN_KEYCHAIN, e);
        } @finally {
        }
    }
    return ret;
}
+(void)deleteInKeyChain  {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:KEY_IN_KEYCHAIN];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

@end
