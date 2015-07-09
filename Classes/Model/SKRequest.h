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

// Misc
+ (NSError *)unknownError;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;


/** @brief Replaces header field values. Useful for changing the user-agent on the fly.
 @discussion Pass \c nil to remove previous overrides. */
+ (void)overrideHeaderValues:(NSDictionary *)headers;

/** @brief Replaces values for specific query keys in the scope of the given endpoint.
 @discussion Pass \c nil to \e queries to remove previous overrides for \e endpoint. This method takes precedence over \c overrideValuesForKeysGlobally: and is used before \c overrideEndpoints:.
 So making a request to \b /bq/add_everyone with this query: @code
 @{@"username": @"ThePantsThief",
   @"acton":    @"add_everyone_duh"
   @"r_u_sure": @YES} @endcode
 having called \c overrideEndpoints: with this dictionary: @code
 @{@"/bq/add_everyone": @"/bq/unfriend_everyone"} @endcode
 and having called \c overrideValuesForKeys:forEndpoint: for the \b /bq/add_everyone endpoint with this dictionary: @code
 @{@"action":   @"unfriend_everyone_pls",
   @"r_u_sure": @NO} @endcode
 would result in this request to \b /bq/unfriend_everyone : @code
 @{@"username": @"ThePantsThief",
   @"acton":    @"unfriend_everyone_pls"
   @"r_u_sure": @NO} @endcode
 without affecting the value of \c \@"action" in any other requests.
 If you \a did want to override that value in \a every request, you would pass @code @{@"action": newValue} @endcode to \c overrideValuesForKeysGlobally:.
 */
+ (void)overrideValuesForKeys:(NSDictionary *)queries forEndpoint:(NSString *)endpoint;

/** @brief Replaces values for specific query keys in every request.
 @discussion Pass \c nil to remove previous overrides. \c overrideValuesForKeys:forEndpoint: takes precedence over this method and affects every request, but otherwise functions the same. */
+ (void)overrideValuesForKeysGlobally:(NSDictionary *)queries;

/** @brief Replaces endpoint \c some_endpoint with \e endpoints[some_endpoint].
 @discussion \c overrideValuesForKeys:forEndpoint: takes precedence over this method. This method will replace all ekeys in a request query with the given values in \c endpoints. */
+ (void)overrideEndpoints:(NSDictionary *)endpoints;

/**
 @param endpoint The endpoint of the request relative to the base URL.
 @param json The parameters for the request.
 @param gauth Optional parameter set to the X-Snapchat-Client-Auth-Token header field.
 @param token The Snapchat auth token returned from logging in. Used to set the req_token parameter for requests.
 */
+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json gauth:(NSString *)gauth token:(NSString *)token callback:(RequestBlock)callback;

/**
 @param endpoint The endpoint of the request relative to the base URL.
 @param json The parameters for the request.
 @param httpHeaders Optional. Sets the corresponding header fields.
 @param token The Snapchat auth token returned from logging in. Used to set the req_token parameter for requests.
 */
+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders token:(NSString *)token callback:(RequestBlock)callback;

+ (void)get:(NSString *)endpoint callback:(RequestBlock)callback;

+ (void)sendEvents:(NSDictionary *)eventData callback:(RequestBlock)callback;

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
- (id)initWithPOSTEndpoint:(NSString *)endpoint token:(NSString *)token query:(NSDictionary *)params headers:(NSDictionary *)httpHeaders ts:(NSString *)timestamp;


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
