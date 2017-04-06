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

@interface SKIPCRequest ()
@property (nonatomic, readonly) Class IPC;
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
    SKIPCRequest *req = [self new];
    req.needsAuth     = YES;
    req.endpoint      = endpoint;
    req.params        = params;
    req.method        = method;
    req.additionalHeaders = @{};
    
    return req;
}

+ (instancetype)endpoint:(NSString *)endpoint params:(NSDictionary *)params {
    SKIPCRequest *req = [self new];
    req.endpoint      = endpoint;
    req.params        = params;
    req.method        = SCAPIRequestMethodPOST;
    req.additionalHeaders = @{};

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
        [OBJCIPC sendMessageToSpringBoardWithMessageName:kMarco dictionary:@{} replyHandler:^(NSDictionary *response) {
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

#pragma mark Private

- (void)setUploadData:(NSData *)uploadData {
    _uploadData = uploadData;
    self.multipart = YES;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.endpoint   = [decoder decodeObjectForKey:@"endpoint"];
        self.params     = [decoder decodeObjectForKey:@"params"];
        self.uploadData = [decoder decodeObjectForKey:@"data"];
        self.method     = [decoder decodeIntegerForKey:@"method"];
        self.needsAuth  = [decoder decodeBoolForKey:@"auth"];
        self.force      = [decoder decodeBoolForKey:@"force"];
        self.multipart  = [decoder decodeBoolForKey:@"multipart"];

        self.additionalHeaders = [decoder decodeObjectForKey:@"headers"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.endpoint   forKey:@"endpoint"];
    [aCoder encodeObject:self.params     forKey:@"params"];
    [aCoder encodeObject:self.uploadData forKey:@"data"];
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
    copy->_uploadData  = self.uploadData;
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
