//
//  SKIPCRequest.h
//
//  Created by Tanner on 1/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, SCAPIRequestMethod) {
    SCAPIRequestMethodGET,
    SCAPIRequestMethodPOST,
    SCAPIRequestMethodDELETE,
    SCAPIRequestMethodPUT
};

extern NSString * const kQueryName;
extern NSString * const kRegisterForDelegation;
extern NSString * const kSnapchatBundleID;

@interface SKIPCRequest : NSObject<NSCopying, NSCoding>

/// needsAuth == YES
+ (instancetype)authForEndpoint:(NSString *)endpoint params:(NSDictionary *)params method:(SCAPIRequestMethod)method;
/// needsAuth == NO, method == SCAPIRequestMethodPOST
+ (instancetype)endpoint:(NSString *)endpoint params:(NSDictionary *)params;

@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSData *uploadData;
@property (nonatomic) SCAPIRequestMethod method;
@property (nonatomic) BOOL needsAuth;

@end
