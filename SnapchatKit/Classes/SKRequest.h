//
//  SKRequest.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

@interface SKRequest : NSMutableURLRequest

+ (NSDictionary *)parseJSON:(NSData *)jsonData;
+ (NSError *)unknownError;

/** httpHeaders may be nil. */
+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders callback:(RequestBlock)callback;
+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json callback:(RequestBlock)callback;
/** httpHeaders may be nil. */
+ (void)get:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders callback:(RequestBlock)callback;
+ (void)get:(NSString *)endpoint query:(NSDictionary *)json callback:(RequestBlock)callback;

/**
 Automatically adds query parameters:
 - timestamp
 - req_token
 Automatically adds HTTP header fields:
 - User-Agent
 - Accept-Language
 - Accept-Locale
 - Content-Type
 
 @param endpoint The endpoint to post to. Example: @"/loq/login"
 @param token The token to use to generate the req_token query parameter. Defaults to kStaticToken.
 @param params The JSON key-value mapping parameters of the request. Example: ?foo=bar would be @{@"foo": @"bar"}
 @param httpHeaders Additional HTTP header fields to set or override. This parameter may be nil.
 */
- (id)initWithPOSTEndpoint:(NSString *)endpoint token:(NSString *)token query:(NSDictionary *)params headers:(NSDictionary *)httpHeaders;


/**
 Automatically adds HTTP header fields:
 - User-Agent
 - Accept-Language
 - Accept-Locale
 - Content-Type
 
 @param endpoint The endpoint to post to. Example: @"/loq/login"
 @param httpHeaders Additional HTTP header fields to set or override. This parameter may be nil.
 */
- (id)initWithGETEndpoint:(NSString *)endpoint headers:(NSDictionary *)httpHeaders;

@end
