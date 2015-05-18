//
//  SKClient.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient.h"
#import "SKSession.h"
#import "SKRequest.h"

#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"
#import "NSString+SnapchatKit.h"

NSString * const kAttestationURLString     = @"https://www.googleapis.com/androidcheck/v1/attestations/attest?alt=JSON&key=AIzaSyDqVnJBjE5ymo--oBJt3On7HQx9xNm1RHA";
NSString * const kAttestationBase64Request = @"ClMKABIUY29tLnNuYXBjaGF0LmFuZHJvaWQaIC8cqvyh7TDQtOOIY+76vqDoFXEfpM95uCJRmoJZ2VpYIgAojKq/AzIECgASADoECAEQAUD4kP+pBRIA";

@implementation SKClient

#pragma mark Initializers

+ (instancetype)sharedClient
{
    static SKClient *sharedSKClient;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedSKClient = [SKClient new];
    });
    
    return sharedSKClient;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _googleAuthToken   = [aDecoder decodeObjectForKey:@"googleAuthToken"];
        _googleAttestation = [aDecoder decodeObjectForKey:@"googleAttestation"];
        _deviceToken1i     = [aDecoder decodeObjectForKey:@"deviceToken1i"];
        _deviceToken1v     = [aDecoder decodeObjectForKey:@"deviceToken1v"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.googleAuthToken   forKey:@"googleAuthToken"];
    [aCoder encodeObject:self.googleAttestation forKey:@"googleAttestation"];
    [aCoder encodeObject:self.deviceToken1i     forKey:@"deviceToken1i"];
    [aCoder encodeObject:self.deviceToken1v     forKey:@"deviceToken1v"];
}

#pragma mark Signing in

/** Gauth. */
- (void)getAuthTokenForGmail:(NSString *)gmailAddress password:(NSString *)password callback:(StringBlock)callback {
    NSDictionary *postFields = @{@"google_play_services_version": @"7097038",
                                 @"Email":           gmailAddress,
                                 @"Passwd":          password,
                                 @"device_country":  @"us",
                                 @"operatorCountry": @"us",
                                 @"lang":            @"en_US",
                                 @"sdk_version":     @"19",
                                 @"accountType":     @"HOSTED_OR_GOOGLE",
                                 @"service":         @"audience:server:client_id:694893979329-l59f3phl42et9clpoo296d8raqoljl6p.apps.googleusercontent.com",
                                 @"source":          @"android",
                                 @"androidId":       @"378c184c6070c26c",
                                 @"app":             @"com.snapchat.android",
                                 @"client_sig":      @"49f6badb81d89a9e38d65de76f09355071bd67e7",
                                 @"callerPkg":       @"com.snapchat.android",
                                 @"callerSig":       @"49f6badb81d89a9e38d65de76f09355071bd67e7"};
    
    NSString *postFieldString = [NSString queryStringWithParams:postFields];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://android.clients.google.com/auth"]];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [postFieldString dataUsingEncoding:NSASCIIStringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:@"378c184c6070c26c" forHTTPHeaderField:@"device"];
    [request setValue:@"com.snapchat.android" forHTTPHeaderField:@"app"];
    [request setValue:@"GoogleAuth/1.4 (mako JDQ39)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil, error);
        } else if (data) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            string = [string matchGroupAtIndex:1 forRegex:@"Auth=([\\w\\.-]+)"];
            callback(string, nil);
        } else {
            callback(nil, [SKRequest unknownError]);
        }
        
    }];
    
    [dataTask resume];
}

/** Snapchat device token. */
- (void)getDeviceToken:(DictionaryBlock)completion {
    [SKRequest postTo:kepDeviceToken query:@{} headers:@{khfClientAuthTokenHeaderField: @"Bearer "} callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        } else if (data) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError)
                completion(nil, jsonError);
            else if (json)
                completion(json, nil);
            else
                completion(nil, [SKRequest unknownError]);
        } else {
            completion(nil, [SKRequest unknownError]);
        }
    }];
}

/** Google account attestation. */
- (void)getAttestation:(StringBlock)completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kAttestationURLString]];
    NSData *binaryRequest = [[NSData alloc] initWithBase64EncodedString:kAttestationBase64Request options:0];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody   = binaryRequest;
    [request setValue:@"application/x-protobuf" forHTTPHeaderField:@"content-type"];
    [request setValue:@"" forHTTPHeaderField:@"Accept"];
    [request setValue:@"" forHTTPHeaderField:@"Expect"];
    [request setValue:@"SafetyNet/7329000 (A116 _Quad KOT49H); gzi" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        } else if (data) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError)
                completion(nil, jsonError);
            else if (json)
                completion(json[@"signedAttestation"], nil);
            else
                completion(nil, [SKRequest unknownError]);
        } else {
            completion(nil, [SKRequest unknownError]);
        }
    }];
    
    [dataTask resume];
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password gmail:(NSString *)gmailEmail gpass:(NSString *)gmailPassword completion:(DictionaryBlock)completion {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(gmailEmail); NSParameterAssert(gmailPassword); NSParameterAssert(completion);
    
    [self getAuthTokenForGmail:gmailEmail password:gmailPassword callback:^(NSString *gauth, NSError *error) {
        if (error || !gauth) {
            NSLog(@"Error retrieving Google auth token.");
            completion(nil, nil);
        } else {
            
            [self getAttestation:^(NSString *attestation, NSError *error) {
                if (error || !attestation) {
                    NSLog(@"Error retrieving Google attestation.");
                    completion(nil, nil);
                } else {
                    
                    [self getDeviceToken:^(NSDictionary *dict, NSError *error) {
                        if (error || dict) {
                            NSLog(@"Error retrieving Snapchat device token.");
                            completion(nil, nil);
                        } else {
                            
                            _googleAuthToken = gauth;
                            _googleAttestation = attestation;
                            _deviceToken1i = dict[@"dtoken1i"];
                            _deviceToken1v = dict[@"dtoken1v"];
                            
                            
                            NSString *timestamp = [NSString timestamp];
                            NSString *req_token = [NSString hashSCString:kStaticToken and:timestamp];
                            NSString *string    = [NSString stringWithFormat:@"%@|%@|%@|%@", username, password, timestamp, req_token];
                            NSString *deviceSig = [[NSString hashHMac:string key:self.deviceToken1v] substringWithRange:NSMakeRange(0, 20)];
                            
                            NSDictionary *headers = @{khfClientAuthTokenHeaderField: [NSString stringWithFormat:@"Bearer %@", gauth]};
                            NSDictionary *post    = @{@"username": username,
                                                      @"password": password,
                                                      @"height":   @(kScreenHeight),
                                                      @"height":   @(kScreenWidth),
                                                      @"max_video_width":  @480,
                                                      @"max_video_height": @640,
                                                      @"application_id":   @"com.snapchat.android",
                                                      @"ptoken":           @"ie",
                                                      @"dsig":             deviceSig,
                                                      @"dtoken1i":         self.deviceToken1i,
                                                      @"attestation":      attestation};
                            
                            [SKRequest postTo:kepLogin query:post headers:headers callback:^(NSData *data, NSURLResponse *response, NSError *error) {
                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                self.currentSession = [SKSession sessionWithJSONResponse:json];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(json, error);
                                });
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

@end
