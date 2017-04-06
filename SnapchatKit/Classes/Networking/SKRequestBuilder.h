//
//  SKRequestBuilder.h
//  Pods
//
//  Created by Tanner on 4/6/17.
//
//

#import <Foundation/Foundation.h>
@class SKIPCRequest;

#define BuilderOption(type, name, propname) \
@property (nonatomic, readonly) SKRequestBuilder *(^name)(type); \
@property (nonatomic) type propname


@interface SKRequestBuilder : NSObject

+ (instancetype)make:(void(^)(SKRequestBuilder *make))configurationBlock;

/// Replaces endpoint
BuilderOption(NSString *, fullURL, getFullURL);
/// Replaces fullURL
BuilderOption(NSString *, endpoint, getEndpoint);
BuilderOption(NSDictionary *, params, getParams);
BuilderOption(NSDictionary *, additionalHeaders, getAdditionalHeaders);
BuilderOption(BOOL, authenticate, needsAuth);
BuilderOption(BOOL, multipart, isMultipart);

/// Defaults to POST
@property (nonatomic, readonly) SKIPCRequest *IPCRequest;

@end

#undef BuilderOption
