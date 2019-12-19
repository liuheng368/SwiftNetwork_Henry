//
//  DDUpYun.h
//  shop
//
//  Created by jiangzhenfeng on 15/4/27.
//  Copyright (c) 2015年 DaDa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UPYUN_API_DOMAIN @"http://v0.api.upyun.com/"
#define UPYUN_ERROR_DOMAIN @"upyun.com"

typedef void (^UpYunCompletionBlock)(BOOL success, NSDictionary *result, NSError *error);
typedef void (^UpYunUploadProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^UploadProgressBlock)(double progress);

@interface DDUpYun : NSObject

@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, assign) NSTimeInterval expiresIn;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSString *passcode;
@property (nonatomic, strong) NSString *policy;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, copy) UpYunUploadProgressBlock progressBlock;
@property (nonatomic, copy) UploadProgressBlock uploadProgressBlock;

- (id)initWithBucket:(NSString *)bucket andPassCode:(NSString *)passcode;
- (id)initWithBucket:(NSString *)bucket andPolicy:(NSString *)policy andSignature:(NSString *)signature;

- (void)uploadFileWithPath:(NSString *)path completion:(UpYunCompletionBlock)completionBlock;
- (void)uploadFileWithPath:(NSString *)path useSaveKey:(NSString *)saveKey completion:(UpYunCompletionBlock)completionBlock;

- (void)uploadFileWithData:(NSData *)data useSaveKey:(NSString *)saveKey completion:(UpYunCompletionBlock)completionBlock;
- (void)uploadFileWithData:(NSData *)data useSaveKey:(NSString *)saveKey progress:(UploadProgressBlock)progressBlock completion:(UpYunCompletionBlock)completionBlock;

@end

@interface NSString (Utilities)

- (NSString *)base64EncodedString;
- (NSString *)MD5Digest;
- (NSString *)stringByEscapingForURLQuery;

@end

