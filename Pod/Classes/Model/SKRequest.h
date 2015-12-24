//
//  SKRequest.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

@interface SKRequest : NSMutableURLRequest

// Internal use //
+ (NSError *)unknownError;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;


/** @brief Replaces header field values. Useful for changing the user-agent on the fly.
 @discussion Pass \c nil to remove previous overrides. [SKRequest overrideHeaderValues:forEndpoint:] takes precedence over this method and affects every request, but otherwise functions the same.
 @param headers A dictionary of header-value key-value pairs, i.e. @code @{@"User-Agent": @"iOS 2.0"} @endcode */
+ (void)overrideHeaderValuesGlobally:(NSDictionary *)headers;

/** @brief Replaces header field values for a specific endpoint.
 @discussion Pass \c nil to \c headers to remove previous overrides for a given endpoint. See [SKRequest overrideHeaderValues:] for more information.
 This method takes precedence over [SKRequest overrideHeaderValuesGlobally:] and is used before [SKRequest overrideEndpoints:], so make sure to override the original endpoint.
 @param headers A dictionary of header-value key-value pairs, i.e. @code @{@"User-Agent": @"iOS 2.0"} @endcode
 @param endpoint The endpoint whose header values you wish to override. */
+ (void)overrideHeaderValues:(NSDictionary *)headers forEndpoint:(NSString *)endpoint;

/** @brief Replaces values for specific query keys in the scope of the given endpoint.
 @discussion Pass \c nil to \e queries to remove previous overrides for \e endpoint.
 This method takes precedence over [SKRequest overrideValuesForKeysGlobally:] and is used before [SKRequest overrideEndpoints:], so make sure to override the original endpoint.
 So making a request to \b /bq/add_everyone with this query: @code
 @{@"username": @"ThePantsThief",
   @"acton":    @"add_everyone_duh"
   @"r_u_sure": @YES} @endcode
 having called [SKRequest overrideEndpoints:] with this dictionary: @code
 @{@"/bq/add_everyone": @"/bq/unfriend_everyone"} @endcode
 and having called \c overrideValuesForKeys:forEndpoint: for the \b /bq/add_everyone endpoint with this dictionary: @code
 @{@"action":   @"unfriend_everyone_pls",
   @"r_u_sure": @NO} @endcode
 would result in this request to \b /bq/unfriend_everyone : @code
 @{@"username": @"ThePantsThief",
   @"acton":    @"unfriend_everyone_pls"
   @"r_u_sure": @NO} @endcode
 without affecting the value of \c \@"action" in any other requests.
 If you \a did want to override that value in \a every request, you would pass @code @{@"action": newValue} @endcode to [SKRequest overrideValuesForKeysGlobally:].
 */
+ (void)overrideValuesForKeys:(NSDictionary *)queries forEndpoint:(NSString *)endpoint;

/** @brief Replaces values for specific query keys in every request.
 @discussion Pass \c nil to remove previous overrides. [SKRequest overrideValuesForKeys:forEndpoint:] takes precedence over this method and affects every request, but otherwise functions the same. */
+ (void)overrideValuesForKeysGlobally:(NSDictionary *)queries;

/** @brief Replaces endpoint \c some_endpoint with \e endpoints[some_endpoint].
 @discussion [SKRequest overrideValuesForKeys:forEndpoint:] and [SKRequest overrideHeaderValues:forEndpoint:] take precedence over this method.
 This method will replace all ekeys in a request query with the given values in \c endpoints. */
+ (void)overrideEndpoints:(NSDictionary *)endpoints;

/**
 @param endpoint The endpoint of the request relative to the base URL.
 @param json The parameters for the request.
 @param httpHeaders Optional. Sets the corresponding header fields.
 */
+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders callback:(RequestBlock)callback;

+ (void)get:(NSString *)endpoint headers:(NSDictionary *)httpHeaders callback:(RequestBlock)callback;

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
 @param params The JSON key-value mapping parameters of the request. Example: ?foo=bar would be @{@"foo": @"bar"}
 @param httpHeaders Additional HTTP header fields to set or override. This parameter may be nil.
 */
- (id)initWithPOSTEndpoint:(NSString *)endpoint query:(NSDictionary *)params headers:(NSDictionary *)httpHeaders;


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
