//
//  SKIPCRequest.m
//
//  Created by Tanner on 1/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "SKIPCRequest.h"
#import "objcipc.h"


NSString * const kQueryName             = @"com.pantsthief.SKICPRequestSignerQuery";
NSString * const kRegisterForDelegation = @"com.pantsthief.IPCRegistration";
NSString * const kSnapchatBundleID      = @"com.toyopagroup.picaboo";

NSString * const kQueryKey              = @"query";
NSString * const kResponseKey           = @"response";
NSString * const kURLRequestKey         = @"URLRequest";
NSString * const kMarco                 = @"com.pantsthief.SKICPTestQuery";
NSString * const kPolo                  = @"com.pantsthief.SKICPTestResponse";

NSString * SKStringFromMethod(SCAPIRequestMethod method) {
    switch (method) {
        case SCAPIRequestMethodGET:
            return @"GET";
        case SCAPIRequestMethodPOST:
            return @"POST";
        case SCAPIRequestMethodDELETE:
            return @"DELETE";
        case SCAPIRequestMethodPUT:
            return @"PUT";
    }
    
    return nil;
}

@interface SKIPCRequest ()
@property (nonatomic, readonly) Class IPC;
@end
@interface SKClient : NSObject
+ (instancetype)sharedClient;
@property (nonatomic, readonly) NSString *username;
@end

@implementation SKIPCRequest

static Class _IPC;
- (Class)IPC {
    if (!_IPC) {
        _IPC = NSClassFromString(@"OBJCIPC");
    }

    return _IPC;
}

+ (Class)IPC {
    if (!_IPC) {
        _IPC = NSClassFromString(@"OBJCIPC");
    }

    return _IPC;
}

+ (instancetype)authForEndpoint:(NSString *)endpoint params:(NSDictionary *)params method:(SCAPIRequestMethod)method {
    SKIPCRequest *req = [self endpoint:endpoint params:params];
    req.needsAuth     = YES;
    req.method        = method;

    return req;
}

+ (instancetype)endpoint:(NSString *)endpoint params:(NSDictionary *)params {
    SKIPCRequest *req = [self new];
    req.method        = SCAPIRequestMethodPOST;
    req.endpoint      = endpoint;
    req.params        = params;
    req.params        = params ?: @{};
    req.additionalHeaders = @{};

    // Get timestamp
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    req.timestamp = [NSString stringWithFormat:@"%llu", (unsigned long long)round(now)];

    // Get username from shared client
    Class SKClient = NSClassFromString(@"SKClient");
    if (SKClient) {
        id shared = [SKClient sharedClient];
        req.username = [shared username];
    }

    return req;
}

#pragma mark Public

+ (BOOL)testIPC {
    if (self.IPC) {
        return [[self.IPC sendMessageToSpringBoardWithMessageName:kMarco dictionary:@{}][kPolo] boolValue];
    }

    return NO;
}

+ (void)testIPC:(void(^)(BOOL success))callback {
    if (self.IPC) {
        [self.IPC sendMessageToSpringBoardWithMessageName:kMarco dictionary:@{} replyHandler:^(NSDictionary *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback([response[kPolo] boolValue]);
            });
        }];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NO);
    });;
}

- (void)sendAsync:(void(^)(SKIPCResponse *object))callback {
    if (self.IPC) {
        [self.IPC sendMessageToSpringBoardWithMessageName:kQueryName
                                               dictionary:@{kQueryKey: self}
                                             replyHandler:^(NSDictionary *object) {

                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     NSLog(@"Received reply from Snapchat: %@", object);
                                                     callback(object[kResponseKey]);
                                                 });
                                             }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = @"Class OBJCIPC not found, cannot communicate with Snapchat";
            callback([SKIPCResponse errorMessage:message]);
        });
    }
}

- (SKIPCResponse *)sendSync {
    if (self.IPC) {
        NSDictionary *object = [self.IPC sendMessageToSpringBoardWithMessageName:kQueryName
                                                                      dictionary:@{kQueryKey: self}];
        NSLog(@"Received reply from Snapchat: %@", object);
        return object[kResponseKey];
    } else {
        NSString *message = @"Class OBJCIPC not found, cannot communicate with Snapchat";
        return [SKIPCResponse errorMessage:message];
    }
}

- (void)setFullURL:(NSString *)fullURL {
    NSParameterAssert(fullURL);
    _fullURL  = fullURL;
    _endpoint = nil;
}

- (void)setEndpoint:(NSString *)endpoint {
    NSParameterAssert(endpoint);
    _endpoint = endpoint;
    _fullURL  = nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.fullURL    = [decoder decodeObjectForKey:@"url"];
        self.endpoint   = [decoder decodeObjectForKey:@"endpoint"];
        self.params     = [decoder decodeObjectForKey:@"params"];
        self.method     = [decoder decodeIntegerForKey:@"method"];
        self.needsAuth  = [decoder decodeBoolForKey:@"auth"];
        self.force      = [decoder decodeBoolForKey:@"force"];
        self.multipart  = [decoder decodeBoolForKey:@"multipart"];

        self.additionalHeaders = [decoder decodeObjectForKey:@"headers"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fullURL    forKey:@"url"];
    [aCoder encodeObject:self.endpoint   forKey:@"endpoint"];
    [aCoder encodeObject:self.params     forKey:@"params"];
    [aCoder encodeInteger:self.method    forKey:@"method"];
    [aCoder encodeBool:self.needsAuth    forKey:@"auth"];
    [aCoder encodeBool:self.force        forKey:@"force"];
    [aCoder encodeBool:self.multipart    forKey:@"multipart"];
    [aCoder encodeObject:self.additionalHeaders forKey:@"headers"];
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    SKIPCRequest *copy = [[self class] new];
    copy->_endpoint    = self.endpoint;
    copy->_params      = self.params;
    copy->_method      = self.method;
    copy->_needsAuth   = self.needsAuth;
    copy->_force       = self.force;
    copy->_multipart   = self.multipart;
    copy->_additionalHeaders = self.additionalHeaders.copy;
    
    return copy;
}

#pragma mark Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@, auth=%@, method=%@>\nParams: %@",
            NSStringFromClass(self.class), self.endpoint, @(self.needsAuth), @(self.method), self.params];
}

@end
