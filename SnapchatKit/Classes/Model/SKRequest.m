//
//  SKRequest.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKRequest.h"
#import "SnapchatKit-Constants.h"
#import "NSString+SnapchatKit.h"
#import "NSData+SnapchatKit.h"

@implementation SKRequest

+ (NSDictionary *)parseJSON:(NSData *)jsonData {
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [NSError errorWithDomain:@"SnapchatKit" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

+ (NSError *)unknownError {
    return [NSError errorWithDomain:@"Unknown" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown error", @""),
                                                                 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown error", @"")}];
}

#pragma mark POST / GET

+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json gauth:(NSString *)gauth token:(NSString *)token callback:(RequestBlock)callback {
    NSDictionary *headers = @{khfClientAuthTokenHeaderField: [NSString stringWithFormat:@"Bearer %@", gauth]};
    [self postTo:endpoint query:json headers:headers token:token callback:callback];
}

+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders token:(NSString *)token callback:(RequestBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    
    SKRequest *request = [[SKRequest alloc] initWithPOSTEndpoint:endpoint token:token query:json headers:httpHeaders ts:nil];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:callback];
    [dataTask resume];
}

+ (void)get:(NSString *)endpoint callback:(RequestBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    SKRequest *request = [[SKRequest alloc] initWithGETEndpoint:endpoint headers:nil];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:callback];
    [dataTask resume];
}

+ (void)sendEvents:(NSDictionary *)eventData callback:(RequestBlock)callback {
    NSParameterAssert(eventData); NSParameterAssert(callback);
    SKRequest *request = [[SKRequest alloc] initWithURLString:kEventsURL eventData:eventData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:callback];
    [dataTask resume];
}

#pragma mark Initializers

- (id)initWithHeaderFields:(NSDictionary *)httpHeaders {
    self = [super init];
    if (self) {
        // HTTP header fields
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:khfContentType];
        [self setValue:kUserAgent forHTTPHeaderField:khfUserAgent];
        [self setValue:khvLanguage forHTTPHeaderField:khfAcceptLanguage];
        [self setValue:khvLocale forHTTPHeaderField:khfAcceptLocale];
        
        if (httpHeaders)
            [httpHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
                [self setValue:value forHTTPHeaderField:key];
            }];
    }
    
    return self;
}

- (id)initWithPOSTEndpoint:(NSString *)endpoint token:(NSString *)token query:(NSDictionary *)params headers:(NSDictionary *)httpHeaders ts:(NSString *)timestamp {
    if (!token) token = kStaticToken;
    
    self = [self initWithHeaderFields:httpHeaders];
    if (self) {
        self.URL = [NSURL URLWithString:[kURL stringByAppendingPathComponent:endpoint]];
        self.HTTPMethod = @"POST";
        
        NSMutableDictionary *json = [params mutableCopy];
        if (!timestamp) timestamp = [NSString timestamp];
        
        // HTTP body
        if (!json[@"req_token"]) json[@"req_token"] = [NSString hashSCString:token and:timestamp];
        if (!json[@"timestamp"]) json[@"timestamp"] = @([timestamp longLongValue]);
        
        // Set HTTPBody
        // Only for uploading snaps here
        if ([endpoint isEqualToString:kepUpload]) {
            NSMutableString *bodyString = [NSMutableString string];
            [bodyString appendString:[NSString boundaryWithName:@"media_id" contentString:json[@"media_id"]]];
            [bodyString appendString:[NSString boundaryWithName:@"username" contentString:json[@"username"]]];
            [bodyString appendString:[NSString boundaryWithName:@"type" contentString:[json[@"type"] stringValue]]];
            [bodyString appendString:[NSString boundaryWithName:@"timestamp" contentString:[json[@"timestamp"] stringValue]]];
            [bodyString appendString:[NSString boundaryWithName:@"req_token" contentString:json[@"req_token"]]];
            [bodyString appendString:[NSString boundaryWithName:@"features_map" contentString:json[@"features_map"]]];
            
            NSMutableData *body = [NSMutableData data];
            [body appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData boundaryWithData:json[@"data"]]];
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            self.HTTPBody = body;
        } else {
            NSData *queryData = [[NSString queryStringWithParams:json] dataUsingEncoding:NSUTF8StringEncoding];
            self.HTTPBody     = queryData;
        }

        if ([endpoint isEqualToString:kepBlob] || [endpoint isEqualToString:kepChatMedia])
            [self setValue:timestamp forHTTPHeaderField:khfTimestamp];
    }
    
    return self;
}

- (id)initWithGETEndpoint:(NSString *)endpoint headers:(NSDictionary *)httpHeaders {
    self = [self initWithHeaderFields:httpHeaders];
    if (self) {
        self.URL = [NSURL URLWithString:[kURL stringByAppendingPathComponent:endpoint]];
        self.HTTPMethod = @"GET";
    }
    
    return self;
}

- (id)initWithURLString:(NSString *)url eventData:(NSDictionary *)eventData {
    self = [self init];
    if (self) {
        self.URL = [NSURL URLWithString:url];
        self.HTTPMethod = @"POST";
        NSData *queryData  = [[NSString queryStringWithParams:eventData] dataUsingEncoding:NSUTF8StringEncoding];
        self.HTTPBody      = queryData;
    }
    
    return self;
}

@end
