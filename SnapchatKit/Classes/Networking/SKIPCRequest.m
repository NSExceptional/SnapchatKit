//
//  SKIPCRequest.m
//
//  Created by Tanner on 1/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "SKIPCRequest.h"

NSString * const kQueryName             = @"com.pantsthief.SKICPRequestSignerQuery";
NSString * const kRegisterForDelegation = @"com.pantsthief.IPCRegistration";
NSString * const kSnapchatBundleID      = @"com.toyopagroup.picaboo";

@implementation SKIPCRequest

+ (instancetype)authForEndpoint:(NSString *)endpoint params:(NSDictionary *)params method:(SCAPIRequestMethod)method {
    SKIPCRequest *req = [self new];
    req.needsAuth     = YES;
    req.endpoint      = endpoint;
    req.params        = params;
    req.method        = method;
    
    return req;
}

+ (instancetype)endpoint:(NSString *)endpoint params:(NSDictionary *)params {
    SKIPCRequest *req = [self new];
    req.endpoint      = endpoint;
    req.params        = params;
    req.method        = SCAPIRequestMethodPOST;
    
    return req;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.endpoint = [decoder decodeObjectForKey:@"endpoint"];
        self.params   = [decoder decodeObjectForKey:@"params"];
        self.uploadData = [decoder decodeObjectForKey:@"data"];
        self.method = [decoder decodeIntegerForKey:@"method"];
        self.needsAuth = [decoder decodeBoolForKey:@"auth"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.endpoint forKey:@"endpoint"];
    [aCoder encodeObject:self.params forKey:@"params"];
    [aCoder encodeObject:self.uploadData forKey:@"data"];
    [aCoder encodeInteger:self.method forKey:@"method"];
    [aCoder encodeBool:self.needsAuth forKey:@"auth"];
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    SKIPCRequest *copy = [[self class] new];
    copy->_endpoint    = self.endpoint;
    copy->_params      = self.params;
    copy->_uploadData  = self.uploadData;
    copy->_method      = self.method;
    copy->_needsAuth   = self.needsAuth;
    
    return copy;
}

#pragma mark Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@, auth=%@, method=%@>\nParams: %@",
            NSStringFromClass(self.class), self.endpoint, @(self.needsAuth), @(self.method), self.params];
}

@end
