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

@implementation SKRequest

+ (NSDictionary *)parseJSON:(NSData *)jsonData {
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}

+ (NSError *)unknownError {
    return [NSError errorWithDomain:@"Unknown" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown error", @""),
                                                                 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown error", @"")}];
}

#pragma mark POST / GET

+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json gauth:(NSString *)gauth token:(NSString *)token callback:(RequestBlock)callback {
    NSParameterAssert(gauth);
    NSDictionary *headers = @{khfClientAuthTokenHeaderField: [NSString stringWithFormat:@"Bearer %@", gauth]};
    [self postTo:endpoint query:json headers:headers token:token callback:callback];
}

+ (void)postTo:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders token:(NSString *)token callback:(RequestBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    
    SKRequest *request = [[SKRequest alloc] initWithPOSTEndpoint:endpoint token:token query:json headers:httpHeaders];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:callback];
    [dataTask resume];
}

+ (void)get:(NSString *)endpoint query:(NSDictionary *)json headers:(NSDictionary *)httpHeaders callback:(RequestBlock)callback {
    
}

+ (void)get:(NSString *)endpoint query:(NSDictionary *)json callback:(RequestBlock)callback {
    
}

#pragma mark Initializers

- (id)initWithPOSTEndpoint:(NSString *)endpoint token:(NSString *)token query:(NSDictionary *)params headers:(NSDictionary *)httpHeaders {
    if (!token) token = kStaticToken;
    
    self = [super init];
    if (self) {
        self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kURL, endpoint]];
        self.HTTPMethod = @"POST";
        
        NSMutableDictionary *json = [params mutableCopy];
        NSString *timestamp = [NSString timestamp];
        
        // HTTP body
        json[@"req_token"] = [NSString hashSCString:token and:timestamp];
        json[@"timestamp"] = @([timestamp longLongValue]);
        NSData *queryData  = [[NSString queryStringWithParams:json] dataUsingEncoding:NSASCIIStringEncoding];
        self.HTTPBody      = queryData;

        // HTTP header fields
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:khfContentType];
        [self setValue:kUserAgent forHTTPHeaderField:khfUserAgent];
        [self setValue:khvLanguage forHTTPHeaderField:khfAcceptLanguage];
        [self setValue:khvLocale forHTTPHeaderField:khfAcceptLocale];
        
        if ([endpoint isEqualToString:kepBlob] || [endpoint isEqualToString:kepChatMedia])
            [self setValue:timestamp forHTTPHeaderField:khfTimestamp];
        
        if (httpHeaders)
            [httpHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
                [self setValue:value forHTTPHeaderField:key];
            }];
    }
    return self;
}

- (id)initWithGETEndpoint:(NSString *)endpoint headers:(NSDictionary *)httpHeaders {
    self = [super init];
    if (self) {
        self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kURL, endpoint]];
        self.HTTPMethod = @"GET";
        
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

@end
