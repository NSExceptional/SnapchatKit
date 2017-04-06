//
//  SKIPCResponse.m
//  Pods
//
//  Created by Tanner on 4/6/17.
//
//

#import "SKIPCResponse.h"
#import "SKIPCRequest.h"


@implementation SKIPCResponse

+ (instancetype)response:(NSDictionary *)object error:(NSError *)error {
    SKIPCResponse *response = [self new];
    response->_object       = object;
    response->_request      = object[kURLRequestKey];
    response->_error        = error;

    if ((!object || !response->_request) && !error) {
        response->_error = [self errorWithMessage:@"Could not communicate with Snapchat.app"];
    }

    return response;
}

+ (instancetype)errorMessage:(NSString *)message {
    return [self response:nil error:[self errorWithMessage:message]];
}

+ (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"SnapchatKit"
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                      NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

@end
