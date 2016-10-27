//
//  UserDefaultsUtil.h
//  TSG-Phone
//
//  Created by lsq on 16/7/22.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsUtil : NSObject
+(void)saveInKeyChain:(NSDictionary*)dict;
+(id)loadInUserDefault:(NSString*)key ;
+(void)deleteInUserDefault :(NSString*)key ;

+(void)saveInUserDefault:(NSDictionary*)dict;
+(id)loadInKeyChain:(NSString*)key ;
+(void)deleteInKeyChain ;
@end
