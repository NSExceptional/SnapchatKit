//
//  SKRequestBuilder.m
//  Pods
//
//  Created by Tanner on 4/6/17.
//
//

#import "SKRequestBuilder.h"
#import "SKIPCRequest.h"


#define BuilderOptionIMP(type, name, code)- (TBURLRequestBuilder *(^)(type))name {\
return ^(type name) { code return self; };\
}

#define BuilderOptionAutoIMP(type, name, propname) BuilderOptionIMP(type, name, {\
_##propname = name;\
})


@implementation SKRequestBuilder

+ (SKRequestBuilder *)make:(void (^)(SKRequestBuilder *))configurationBlock {
    SKRequestBuilder *builder = [self new];
    configurationBlock(builder);
    return builder;
}

BuilderOptionAutoIMP(NSString *, endpoint, getEndpoint);
BuilderOptionAutoIMP(NSDictionary *, params, getParams);
BuilderOptionAutoIMP(NSDictionary *, uploadData, getUploadData);
BuilderOptionAutoIMP(NSDictionary *, additionalHeaders, getAdditionalHeaders);
BuilderOptionAutoIMP(BOOL, needsAuth, getNeedsAuth);

- (SKIPCRequest *)IPCRequest {
    SKIPCRequest *request = [SKIPCRequest endpoint:self.getEndpoint params:self.getParams];
    request.needsAuth = self.getNeedsAuth;
    request.uploadData = self.getUploadData;
    request.additionalHeaders = self.getAdditionalHeaders;
    request.method = SCAPIRequestMethodPOST;

    return request;
}

@end
