//
//  UpYun.m
//
//  Created by nickcheng on 14-6-20.
//  Copyright (c) 2014年 nickcheng.com. All rights reserved.
//

#import "DDUpYun.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"

@implementation DDUpYun

{
    NSString *_bucket;
    NSTimeInterval _expiresIn;
    NSMutableDictionary *_params;
    NSString *_passcode;
    NSString *_policy;
    NSString *_signature;
    UpYunUploadProgressBlock _progressBlock;
}

@synthesize bucket = _bucket;
@synthesize expiresIn = _expiresIn;
@synthesize params = _params;
@synthesize passcode = _passcode;
@synthesize progressBlock = _progressBlock;
@synthesize policy = _policy;
@synthesize signature = _signature;

#pragma mark -
#pragma mark Init

- (id)initWithBucket:(NSString *)bucket andPassCode:(NSString *)passcode {
    //
    if((self = [super init]) == nil) return nil;
    
    // Custom initialization
    _bucket = bucket;
    _passcode = passcode;
    
    _expiresIn = 600;
    _params = [NSMutableDictionary dictionary];
    _progressBlock = nil;
    
    return self;
}

- (id)initWithBucket:(NSString *)bucket andPolicy:(NSString *)policy andSignature:(NSString *)signature {
    _bucket = bucket;
    _policy = policy;
    _signature = signature;
    
    _expiresIn = 600;
    _params = [NSMutableDictionary dictionary];
    _progressBlock = nil;
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)uploadFileWithPath:(NSString *)path completion:(UpYunCompletionBlock)completionBlock {
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        NSError *error = [[NSError alloc] initWithDomain:UPYUN_ERROR_DOMAIN code:400 userInfo:nil];
        completionBlock(NO, nil, error);
        return;
    }
    NSString *saveKey = [path substringFromIndex:range.location];
    
    [self uploadFileWithPath:path useSaveKey:saveKey completion:completionBlock];
}

- (void)uploadFileWithPath:(NSString *)path useSaveKey:(NSString *)saveKey completion:(UpYunCompletionBlock)completionBlock {
    if (![_policy isEqual:nil] || ![_signature isEqual:nil]) {
        _policy = [self policyWithSaveKey:saveKey andBucket:self.bucket];
        NSString *str = [NSString stringWithFormat:@"%@&%@", _policy, self.passcode];
        _signature = str.MD5Digest.stringByEscapingForURLQuery.lowercaseString;
    }
    
    NSDictionary *dic = @{
                          @"policy": _policy,
                          @"signature": _signature,
                          @"file": path
                          };
    [self upload:dic completion:completionBlock];
}

- (void)uploadFileWithData:(NSData *)data useSaveKey:(NSString *)saveKey completion:(UpYunCompletionBlock)completionBlock
{
    if ([_policy isEqual:nil] || [_signature isEqual:nil])
    {
        _policy = [self policyWithSaveKey:saveKey andBucket:self.bucket];
        NSString *str = [NSString stringWithFormat:@"%@&%@", _policy, self.passcode];
        _signature = str.MD5Digest.stringByEscapingForURLQuery.lowercaseString;
    }
    
    NSString *policy = _policy.length > 0 ? _policy : @"";
    NSString *signature = _signature.length > 0 ? _signature : @"";
    NSData *tmpData = data.length > 0 ? data : [NSData data];
    NSDictionary *dic = @{@"policy": policy, @"signature": signature, @"file": tmpData};
    [self upload:dic completion:completionBlock];
}

- (void)uploadFileWithData:(NSData *)data useSaveKey:(NSString *)saveKey progress:(UploadProgressBlock)progressBlock completion:(UpYunCompletionBlock)completionBlock
{
    if ([_policy isEqual:nil] || [_signature isEqual:nil])
    {
        _policy = [self policyWithSaveKey:saveKey andBucket:self.bucket];
        NSString *str = [NSString stringWithFormat:@"%@&%@", _policy, self.passcode];
        _signature = str.MD5Digest.stringByEscapingForURLQuery.lowercaseString;
    }
    
    NSString *policy = _policy.length > 0 ? _policy : @"";
    NSString *signature = _signature.length > 0 ? _signature : @"";
    NSData *tmpData = data.length > 0 ? data : [NSData data];
    NSDictionary *dic = @{@"policy": policy, @"signature": signature, @"file": tmpData};
    [self upload:dic progress:progressBlock completion:completionBlock];
}

#pragma mark -
#pragma mark Private Methods

- (NSString *)policyWithSaveKey:(NSString *)saveKey andBucket:(NSString *)bucket
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"bucket"] = bucket;
    dic[@"expiration"] = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] + self.expiresIn];
    dic[@"save-key"] = saveKey;
    for (NSString *key in self.params.keyEnumerator) {
        dic[key] = self.params[key];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json.base64EncodedString;
}

- (void)upload:(NSDictionary *)dic completion:(UpYunCompletionBlock)completionBlock
{
    NSString *policy = dic[@"policy"];
    NSString *signature = dic[@"signature"];
    id file = dic[@"file"];
    
    NSMutableData *post = [NSMutableData data];
    NSURL *myWebserverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/", UPYUN_API_DOMAIN, self.bucket]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myWebserverURL];
    
    [request setTimeoutInterval: 60.0];
    [request setCachePolicy: NSURLRequestUseProtocolCachePolicy];
    [request setHTTPMethod:@"POST"];
    
    // Set your own boundary string only if really obsessive.
    // We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
    NSString *stringBoundary = @"0xKhTmLbOuNdArY";
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary]
   forHTTPHeaderField:@"Content-Type"];
    
    [post appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    // Adds post data
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"policy"]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[policy dataUsingEncoding:NSUTF8StringEncoding]];
    [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"signature"]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[signature dataUsingEncoding:NSUTF8StringEncoding]];
    [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    
    // Adds files to upload
    if (file)
    {
        [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
        [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", @"pic"]
                          dataUsingEncoding:NSASCIIStringEncoding]];
        [post appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"application/octet-stream"] dataUsingEncoding:NSASCIIStringEncoding]];
        
        if ([file isKindOfClass:[NSString class]]) {
            [post appendData:[NSData dataWithContentsOfFile:file]];
        } else {
            [post appendData:file];
        }
    }
    
    // Only add the boundary if this is not the last item in the post body
    [post appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)post.length];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:post];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    ((AFJSONResponseSerializer *)manager.responseSerializer).acceptableContentTypes = [NSSet setWithArray:@[ @"text/html", @"application/json", @"text/plain",@"text/javascript"]];
    
    __weak DDUpYun *weakSelf = self;
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (weakSelf.uploadProgressBlock) {
            weakSelf.uploadProgressBlock(uploadProgress.fractionCompleted);
        }
        
        if (weakSelf.progressBlock) {
            weakSelf.progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSData *responseData = [NSJSONSerialization isValidJSONObject:responseObject] ? [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] : nil;
        
        if (0 != error.code)
        {
            if (completionBlock) {
                completionBlock(NO, nil, error);
            }
        }
        else
        {
            NSDictionary *dic = responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] : @{};
            NSString *message = dic[@"message"];
            if ([@"ok" isEqualToString:message])
            {
                if (weakSelf.progressBlock) {
                    weakSelf.progressBlock(0, post.length, post.length);
                }
                
                if (completionBlock) {
                    completionBlock(YES, dic, nil);
                }
            }
            else
            {
                if (completionBlock)
                {
                    NSError *err = [NSError errorWithDomain:UPYUN_ERROR_DOMAIN code:[dic[@"code"] intValue] userInfo:dic];
                    completionBlock(NO, nil, err);
                }
            }
        }
    }];
    
    [uploadTask resume];
}

- (void)upload:(NSDictionary *)dic progress:(UploadProgressBlock)progressBlock completion:(UpYunCompletionBlock)completionBlock
{
    NSString *policy = dic[@"policy"];
    NSString *signature = dic[@"signature"];
    id file = dic[@"file"];
    
    NSMutableData *post = [NSMutableData data];
    NSURL *myWebserverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/", UPYUN_API_DOMAIN, self.bucket]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myWebserverURL];
    
    [request setTimeoutInterval: 60.0];
    [request setCachePolicy: NSURLRequestUseProtocolCachePolicy];
    [request setHTTPMethod:@"POST"];
    
    // Set your own boundary string only if really obsessive.
    // We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
    NSString *stringBoundary = @"0xKhTmLbOuNdArY";
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary]
   forHTTPHeaderField:@"Content-Type"];
    
    [post appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    // Adds post data
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"policy"]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[policy dataUsingEncoding:NSUTF8StringEncoding]];
    [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"signature"]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[signature dataUsingEncoding:NSUTF8StringEncoding]];
    [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    
    // Adds files to upload
    if (file)
    {
        [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
        [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", @"pic"]
                          dataUsingEncoding:NSASCIIStringEncoding]];
        [post appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"application/octet-stream"] dataUsingEncoding:NSASCIIStringEncoding]];
        
        if ([file isKindOfClass:[NSString class]]) {
            [post appendData:[NSData dataWithContentsOfFile:file]];
        } else {
            [post appendData:file];
        }
    }
    
    // Only add the boundary if this is not the last item in the post body
    [post appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)post.length];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:post];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    ((AFJSONResponseSerializer *)manager.responseSerializer).acceptableContentTypes = [NSSet setWithArray:@[ @"text/html", @"application/json", @"text/plain", @"text/javascript"]];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.fractionCompleted);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSData *responseData = [NSJSONSerialization isValidJSONObject:responseObject] ? [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] : nil;
        
        if (0 != error.code)
        {
            if (completionBlock) {
                completionBlock(NO, nil, error);
            }
        }
        else
        {
            NSDictionary *dic = responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil] : @{};
            NSString *message = dic[@"message"];
            if ([@"ok" isEqualToString:message])
            {
                if (completionBlock) {
                    completionBlock(YES, dic, nil);
                }
            }
            else
            {
                if (completionBlock)
                {
                    NSError *err = [NSError errorWithDomain:UPYUN_ERROR_DOMAIN code:[dic[@"code"] intValue] userInfo:dic];
                    completionBlock(NO, nil, err);
                }
            }
        }
    }];
    
    [uploadTask resume];
}

@end

@implementation NSString (Utilities)

static const char sam_base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)base64EncodedString  {
    //
    if ([self length] == 0) {
        return nil;
    }
    NSData *base64Data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    //
    const uint8_t *input = base64Data.bytes;
    NSInteger length = base64Data.length;
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] = sam_base64EncodingTable[(value >> 18) & 0x3F];
        output[index + 1] = sam_base64EncodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? sam_base64EncodingTable[(value >> 6) & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? sam_base64EncodingTable[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


- (NSString *)MD5Digest {
    //
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *md5Data = [NSData dataWithBytes:cstr length:self.length];
    
    //
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(md5Data.bytes, (CC_LONG)md5Data.length, digest);
    
    //
    NSMutableString *ms = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat: @"%02x", (int)digest[i]];
    }
    return [ms copy];
}

- (NSString *)stringByEscapingForURLQuery {
    NSString *result = self;
    
    static CFStringRef leaveAlone = CFSTR(" ");
    static CFStringRef toEscape = CFSTR("\n\r:/=,!$&'()*+;[]@#?%");
    
    CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, leaveAlone,
                                                                     toEscape, kCFStringEncodingUTF8);
    
    if (escapedStr) {
        NSMutableString *mutable = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
        CFRelease(escapedStr);
        
        [mutable replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutable length])];
        result = mutable;
    }
    return result;  
}

@end
