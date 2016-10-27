//
//  NSString+STRegex.h
//  TSG-Phone
//
//  Created by lsq on 16/7/27.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (STRegex)

///////////////////////////// 正则表达式相关  ///////////////////////////////

/**
 @brief     邮箱验证 */
- (BOOL)isValidEmail;

/**
 @brief     手机号码验证 
 */
- (BOOL)isValidPhoneNum;

/**
 @brief     车牌号验证 
 */
- (BOOL)isValidCarNo;

/**
 @brief     网址验证 
 */
- (BOOL)isValidUrl;

/**
 @brief     邮政编码 
 */
- (BOOL)isValidPostalcode;

/**
 @brief     纯汉字 
 */
- (BOOL)isValidChinese;



/**
 @brief     是否符合IP格式，xxx.xxx.xxx.xxx
 */
- (BOOL)isValidIP;

/** 
 @brief     身份证验证 refer to http://blog.csdn.net/afyzgh/article/details/16965107*/
- (BOOL)isValidIdCardNum;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     containDigtal   包含数字
 @param     containLetter   包含字母
 @param     containOtherCharacter   其他字符
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/** 
 @brief     去掉两端空格和换行符
 */
- (NSString *)stringByTrimmingBlank;

/**
 @brief     去掉html格式
 */
- (NSString *)removeHtmlFormat;

/**
 @brief     工商税号
 */
- (BOOL)isValidTaxNo;

/**
 @brief     正则表达式 判断字符串内容是否是有效数字
 @param     string 需要验证的字符串
 @return    字符串内容是否是有效数字
 */
- (BOOL)isValidNumber;

@end
