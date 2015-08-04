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
#import "NSDictionary+SnapchatKit.h"
#import "NSData+SnapchatKit.h"

@implementation SKRequest

#pragma mark Request overrides

static NSDictionary        *headerOverrides;
static NSDictionary        *globalParamOverrides;
static NSMutableDictionary *scopeParamOverrides;
static NSMutableDictionary *scopeHeaderOverrides;
static NSDictionary        *endpointOverrides;

+ (void)overrideHeaderValuesGlobally:(NSDictionary *)headers {
    NSParameterAssert([headers isKindOfClass:[NSDictionary class]] || !headers);
    headerOverrides = headers;
}

+ (void)overrideHeaderValues:(NSDictionary *)headers forEndpoint:(NSString *)endpoint {
    NSParameterAssert([headers isKindOfClass:[NSDictionary class]] || !headers); NSParameterAssert(endpoint);
    if (!scopeHeaderOverrides)
        scopeHeaderOverrides = [NSMutableDictionary dictionary];
    
    scopeHeaderOverrides[endpoint] = headers;
}

+ (void)overrideValuesForKeys:(NSDictionary *)queries forEndpoint:(NSString *)endpoint {
    NSParameterAssert([queries isKindOfClass:[NSDictionary class]] || !queries); NSParameterAssert(endpoint);
    if (!scopeParamOverrides)
        scopeParamOverrides = [NSMutableDictionary dictionary];
    
    scopeParamOverrides[endpoint] = queries;
}

+ (void)overrideValuesForKeysGlobally:(NSDictionary *)queries {
    NSParameterAssert([queries isKindOfClass:[NSDictionary class]] || !queries);
    globalParamOverrides = queries;
}

+ (void)overrideEndpoints:(NSDictionary *)endpoints {
    endpointOverrides = endpoints;
}

void SKRequestApplyOverrides(NSString **endpoint, NSDictionary **params) {
    if (params != NULL) {
        *params = [*params dictionaryByReplacingValuesForKeys:globalParamOverrides];
        *params = [*params dictionaryByReplacingValuesForKeys:scopeParamOverrides[*endpoint]];
    }
    if (*endpoint) {
        *endpoint = endpointOverrides[*endpoint] ?: *endpoint;
    }
}

NSDictionary * SKRequestApplyHeaderOverrides(NSDictionary *httpHeaders, NSString *endpoint) {
    if (!httpHeaders) return @{};
    httpHeaders = [httpHeaders dictionaryByReplacingValuesForKeys:headerOverrides];
    httpHeaders = [httpHeaders dictionaryByReplacingValuesForKeys:scopeHeaderOverrides[endpoint]];
    return httpHeaders;
}

#pragma mark Convenience

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
    NSDictionary *headers = @{SKHeaders.clientAuthToken: [NSString stringWithFormat:@"Bearer %@", gauth]};
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
    SKRequest *request = [[SKRequest alloc] initWithURLString:SKConsts.eventsURL eventData:eventData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:callback];
    [dataTask resume];
}

#pragma mark Initializers

- (id)initWithHeaderFields:(NSDictionary *)httpHeaders {
    self = [super init];
    if (self) {
        // HTTP header fields
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:SKHeaders.contentType];
        [self setValue:SKConsts.userAgent forHTTPHeaderField:SKHeaders.userAgent];
        [self setValue:SKHeaders.values.language forHTTPHeaderField:SKHeaders.acceptLanguage];
        [self setValue:SKHeaders.values.locale forHTTPHeaderField:SKHeaders.acceptLocale];
        
        if (httpHeaders)
            [httpHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
                [self setValue:value forHTTPHeaderField:key];
            }];
    }
    
    return self;
}

- (id)initWithPOSTEndpoint:(NSString *)endpoint token:(NSString *)token query:(NSDictionary *)params headers:(NSDictionary *)httpHeaders ts:(NSString *)timestamp {
    if (!token) token = SKConsts.staticToken;
    httpHeaders = SKRequestApplyHeaderOverrides(httpHeaders, endpoint);
    
    self = [self initWithHeaderFields:httpHeaders];
    if (self) {
        SKRequestApplyOverrides(&endpoint, &params);
        
        self.URL = [NSURL URLWithString:[SKConsts.baseURL stringByAppendingPathComponent:endpoint]];
        self.HTTPMethod = @"POST";
        
        NSMutableDictionary *json = [params mutableCopy];
        if (!timestamp) timestamp = [NSString timestamp];
        
        // HTTP body
        if (!json[@"req_token"]) json[@"req_token"] = [NSString hashSCString:token and:timestamp];
        if (!json[@"timestamp"]) json[@"timestamp"] = @([timestamp longLongValue]);
        
        // Set HTTPBody
        // Only for uploading snaps here
        if ([endpoint isEqualToString:SKEPSnaps.upload]) {
            
            NSMutableData *body = [NSMutableData data];
            
            for (NSString *key in json.allKeys) {
                if ([key isEqualToString:@"data"]) {
                    [body appendData:[NSData boundaryWithKey:key forDataValue:json[key]]];
                } else {
                    [body appendData:[NSData boundaryWithKey:key forStringValue:(NSString *)json[key]]];
                }
            }
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", SKConsts.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            self.HTTPBody = body;
        } else {
            NSData *queryData = [[NSString queryStringWithParams:json] dataUsingEncoding:NSUTF8StringEncoding];
            self.HTTPBody     = queryData;
        }

        if ([endpoint isEqualToString:SKEPSnaps.loadBlob] || [endpoint isEqualToString:SKEPChat.media])
            [self setValue:timestamp forHTTPHeaderField:SKHeaders.timestamp];
    }
    
    return self;
}

- (id)initWithGETEndpoint:(NSString *)endpoint headers:(NSDictionary *)httpHeaders {
    httpHeaders = SKRequestApplyHeaderOverrides(httpHeaders, endpoint);
    
    self = [self initWithHeaderFields:httpHeaders];
    if (self) {
        SKRequestApplyOverrides(&endpoint, NULL);
        self.URL = [NSURL URLWithString:[SKConsts.baseURL stringByAppendingPathComponent:endpoint]];
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
