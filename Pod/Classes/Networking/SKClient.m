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
#import "SKConversation.h"
#import "SKBlob.h"

#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"

#import "SSZipArchive.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Attestation.pb.h"

BOOL SKHasActiveConnection() {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "appspot.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

NSDictionary *SKMakeSignInParams(NSString *gauth, NSString *attest, NSString *ptoken, NSString *clientAuthToken, NSDictionary *deviceTokens, NSString *timestamp) {
    return @{@"googleAuthToken": gauth, @"attestation": attest, @"pushToken": ptoken?:@"e", @"clientAuthToken": clientAuthToken, @"dt": deviceTokens, @"ts": timestamp};
}

NSString *SKMakeCapserSignature(NSDictionary *params, NSString *secret) {
    assert(params.allKeys.count); assert(secret);
    NSArray *sortedKeys = [params.allKeys sortedArrayUsingSelector:@selector(compare:options:)];
    NSMutableString *signature = [NSMutableString string];
    
    for (NSString *key in sortedKeys) {
        [signature appendString:key];
        [signature appendString:params[key]];
    }
    
    return [@"v1:" stringByAppendingString:[NSString hashHMac:signature key:secret].hexadecimalString];
}


@implementation SKClient

@synthesize authToken = _authToken;

#pragma mark Initializers

+ (instancetype)sharedClient {
    static SKClient *sharedSKClient;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedSKClient = [SKClient new];
        [[NSFileManager defaultManager] createDirectoryAtPath:SKTempDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    });
    
    return sharedSKClient;
}

+ (instancetype)clientWithUsername:(NSString *)username authToken:(NSString *)authToken gauth:(NSString *)googleAuthToken {
    SKClient *client         = [self new];
    client.username          = username;
    client->_authToken       = authToken;
    client->_googleAuthToken = googleAuthToken;
    
    return client;
}

- (id)init {
    self = [super init];
    if (self) {
        if (NSClassFromString(@"UIScreen")) {
            id cls = NSClassFromString(@"UIScreen");
            id screen = [cls performSelector:@selector(mainScreen)];
            self.screenSize = [screen bounds].size;
            self.maxVideoSize = self.screenSize;
        } else {
            [self setScreenIdiom:0];
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
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

- (void)setCurrentSession:(SKSession *)currentSession {
    _currentSession = currentSession;
    _username = currentSession.username;
}

- (NSString *)authToken {
    return _authToken ?: SKConsts.staticToken;
}

- (void)setUsername:(NSString *)username {
    _username = [username lowercaseString];
}

- (void)setScreenIdiom:(SKScreenIdiom)idiom {
    switch (idiom) {
        case SKScreenIdiomiPhone4: {
            _screenSize = _maxVideoSize = CGSizeMake(640, 960);
            break;
        }
        case SKScreenIdiomiPhone5: {
            _screenSize = _maxVideoSize = CGSizeMake(640, 1136);
            break;
        }
        case SKScreenIdiomiPhone6: {
            _screenSize = _maxVideoSize = CGSizeMake(750, 1334);
            break;
        }
        case SKScreenIdiomiPhone6Plus: {
            _screenSize = _maxVideoSize = CGSizeMake(1080, 1920);
            break;
        }
    }
}

#pragma mark Convenience

- (void)handleError:(NSError *)error data:(NSData *)data response:(NSURLResponse *)response completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    // Pass data to the man-in-the-middle
    MiddleManBlock callback;
    if (self.middleMan) {
        callback = ^(id json, NSError *error, NSURLResponse *response) {
            [self.middleMan restructureJSON:json error:error response:response completion:completion];
        };
    } else {
        callback = ^(id json, NSError *error, NSURLResponse *response) {
            completion(json, error);
        };
    }
    
    NSInteger code = [(NSHTTPURLResponse *)response statusCode];
    
    if (error) {
        completion(nil, error);
    } else if (data.length) {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        // Could not parse JSON (it's probably HTML)
        if (jsonError) {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([html containsString:@"<html><head>"]) {
                // Invalid request
                callback(nil, [SKRequest errorWithMessage:html.textFromHTML code:code], response);
            } else {
                // ???
                callback(nil, jsonError, response);
            }
        }
        
        else if (json) {
            if (code > 199 && code < 300) {
                // Suceeded with a response
                NSNumber *logged = json[@"logged"] ?: json[@"updates_response"][@"logged"];
                if (logged) {
                    if (logged.integerValue == 1)
                        callback(json, nil, response);
                    else
                        callback(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]], response);
                } else {
                    callback(json, nil, response);
                }
            } else {
                // Failed with a message
                error = [SKRequest errorWithMessage:json[@"message"] code:code];
                callback(nil, error, response);
            }
        }
        else {
            callback(nil, [SKRequest unknownError], response);
        }
    } else if (code > 199 && code < 300) {
        // Succeeded with no response
        callback(nil, nil, response);
    } else {
        callback(nil, [SKRequest unknownError], response);
    }
}

- (void)postTo:(NSString *)endpoint query:(NSDictionary *)query callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(query);
    [SKRequest postTo:endpoint query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error data:data response:response completion:callback];
        });
    }];
}

- (void)get:(NSString *)endpoint callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    [SKRequest get:endpoint callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSInteger code = [(NSHTTPURLResponse *)response statusCode];
                if (code == 200)
                    callback(data, nil);
                else {
                    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([html containsString:@"<html><head>"]) {
                        // Invalid request
                        callback(nil, [SKRequest errorWithMessage:html.textFromHTML code:code]);
                    } else {
                        callback(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
                    }
                }
            } else {
                callback(nil, error);
            }
        });
    }];
}

#pragma mark Signing in

- (BOOL)isSignedIn {
    return self.googleAuthToken && self.authToken && self.username;
}

/** Gauth. */
- (void)getAuthTokenForGmail:(NSString *)gmailAddress password:(NSString *)password callback:(StringBlock)callback {
    NSDictionary *postFields = @{@"google_play_services_version": @"7097038",
                                 @"device_country":  @"us",
                                 @"operatorCountry": @"us",
                                 @"lang":            @"en_US",
                                 @"sdk_version":     @"19",
                                 @"accountType":     @"HOSTED_OR_GOOGLE",
                                 @"Email":           gmailAddress,
                                 @"Passwd":          password,
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
    request.HTTPBody   = [postFieldString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:SKHeaders.contentType];
    [request setValue:@"378c184c6070c26c" forHTTPHeaderField:@"device"];
    [request setValue:@"com.snapchat.android" forHTTPHeaderField:@"app"];
    [request setValue:@"GoogleAuth/1.4 (mako JDQ39)" forHTTPHeaderField:SKHeaders.userAgent];
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
    NSString *dt1i = [[NSUserDefaults standardUserDefaults] stringForKey:SKConsts.deviceToken1i];
    NSString *dt1v = [[NSUserDefaults standardUserDefaults] stringForKey:SKConsts.deviceToken1v];
    
    if (dt1i && dt1v)
        completion(@{SKConsts.deviceToken1i: dt1i, SKConsts.deviceToken1v: dt1v}, nil);
    else
        [SKRequest postTo:SKEPDevice.identifier query:@{} headers:@{SKHeaders.clientAuthToken: @"Bearer "} token:nil callback:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                completion(nil, error);
            } else if (data) {
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (jsonError ) {
                    completion(nil, jsonError);
                } else if (json) {
                    [[NSUserDefaults standardUserDefaults] setObject:json[SKConsts.deviceToken1i] forKey:SKConsts.deviceToken1i];
                    [[NSUserDefaults standardUserDefaults] setObject:json[SKConsts.deviceToken1v] forKey:SKConsts.deviceToken1v];
                    completion(json, nil);
                } else {
                    completion(nil, [SKRequest unknownError]);
                }
            } else {
                completion(nil, [SKRequest unknownError]);
            }
        }];
}

/** ptoken value. */
- (void)getGoogleCloudMessagingIdentifier:(StringBlock)callback {
    NSDictionary *postFields = @{@"X-google.message_id": @"google.rpc1",
                                 @"device":              @(4343470343591528399),
                                 @"sender":              @(191410808405),
                                 @"app_ver":             @(706),
                                 @"gcm_ver":             @(7097038),
                                 @"app":                 @"com.snapchat.android",
                                 @"iat":                 @([[NSDate date] timeIntervalSince1970]),
                                 @"cert":                @"49f6badb81d89a9e38d65de76f09355071bd67e7"};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://android.clients.google.com/c2dm/register3"]];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [[NSString queryStringWithParams:postFields] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"en" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"en_US" forHTTPHeaderField:@"Accept-Locale"];
    [request setValue:@"Android-GCM/1.5 (A116 _Quad KOT49H)" forHTTPHeaderField:SKHeaders.userAgent];
    [request setValue:@"com.snapchat.android" forHTTPHeaderField:@"app"];
    [request setValue:@"AidLogin 4343470343591528399:5885638743641649694" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"7097038" forHTTPHeaderField:@"Gcm-ver"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil, error);
        } else if (data) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            string = [string matchGroupAtIndex:1 forRegex:@"token=([\\w\\.-]+)"];
            callback(string, nil);
        } else {
            callback(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }];
    [dataTask resume];
}

/** Google attestation. */
- (void)getAttestation:(NSString *)username password:(NSString *)password ts:(NSString *)timestamp callback:(StringBlock)callback {
    NSAssert(self.casperAPIKey, @"You must have a valid API key from https://clients.casper.io to sign in.");
    NSAssert(self.casperAPISecret, @"You must have a valid API secret from https://clients.casper.io to sign in.");
    
    NSString *hashString = [[NSString stringWithFormat:@"%@|%@|%@|%@", username, password, timestamp, SKEPAccount.login].sha256HashRaw base64EncodedStringWithOptions:0];
    // Get binary data
    NSData *binaryData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.casper.io/snapchat/attestation/create"]];
    __block NSError *jsonError = nil;
    __block NSDictionary *json = [NSJSONSerialization JSONObjectWithData:binaryData options:0 error:&jsonError];
    
    if (json) {
        // Get bytecode from Google
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SKAttestation.protobufBytecodeURL]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [[json[@"binary"] base64Decode] dataUsingEncoding:NSUTF8StringEncoding];
        [request setValue:SKHeaders.values.protobuf forHTTPHeaderField:SKHeaders.contentType];
        [request setValue:SKHeaders.values.droidGuardUA forHTTPHeaderField:SKHeaders.userAgent];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error && [(NSHTTPURLResponse *)response statusCode] == 200) {
                
                // Send it to Casper.io to build the protobuf
                NSString *bytecodeProtobuf = [data base64EncodedStringWithOptions:0];
                NSDictionary *query = @{@"protobuf": bytecodeProtobuf,
                                        @"nonce": hashString,
                                        @"snapchat_version": SKConsts.snapchatVersion};
                request.URL = [NSURL URLWithString:SKAttestation.protobufPOSTURL];
                request.HTTPBody = [[NSString queryStringWithParams:query URLEscapeValues:YES] dataUsingEncoding:NSUTF8StringEncoding];
                
                // Set headers
                [request setValue:self.casperAPIKey forHTTPHeaderField:SKHeaders.casperAPIKey];
                [request setValue:SKMakeCapserSignature(query, self.casperAPISecret) forHTTPHeaderField:SKHeaders.casperSignature];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:SKHeaders.contentType];
                
                [[session dataTaskWithRequest:request completionHandler:^(NSData *data2, NSURLResponse *response2, NSError *error2) {
                    if (!error2 && [(NSHTTPURLResponse *)response2 statusCode] == 200) {
                        jsonError = nil;
                        json = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:&jsonError];
                        
                        if (json) {
                            
                            // Get the actual attestation from Google
                            [request setValue:SKAttestation.userAgent forHTTPHeaderField:SKHeaders.userAgent];
                            request.URL = [NSURL URLWithString:SKAttestation.attestationURL];
                            request.HTTPBody = [json[@"binary"] base64DecodedData];
                            [request setValue:SKAttestation.userAgent forHTTPHeaderField:SKHeaders.userAgent];
                            [request setValue:SKHeaders.values.protobuf forHTTPHeaderField:SKHeaders.contentType];
                            
                            [[session dataTaskWithRequest:request completionHandler:^(NSData *data3, NSURLResponse *response3, NSError *error3) {
                                if (!error3 && [(NSHTTPURLResponse *)response3 statusCode] == 200) {
                                    jsonError = nil;
                                    json = [NSJSONSerialization JSONObjectWithData:data3 options:0 error:&jsonError];
                                    if (json)
                                        callback(json[@"signedAttestation"], nil);
                                    else
                                        callback(nil, jsonError);
                                } else {
                                    callback(nil, error3);
                                }
                            }] resume];
                            
                        } else {
                            callback(nil, jsonError);
                        }
                    } else {
                        callback(nil, error2);
                    }
                }] resume];
                
            } else {
                callback(nil, error);
            }
        }] resume];
    } else {
        callback(nil, jsonError);
    }
}

- (void)getClientAuthToken:(NSString *)username password:(NSString *)password timestamp:(NSString *)ts callback:(StringBlock)callback {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(ts);
    NSAssert(self.casperAPIKey, @"You must have a valid API key from https://clients.casper.io to sign in.");
    NSAssert(self.casperAPISecret, @"You must have a valid API secret from https://clients.casper.io to sign in.");
    
    // Params
    NSDictionary *query = @{@"username": username, @"password": password, @"timestamp": ts, @"snapchat_version": SKConsts.snapchatVersion};
    
    // Build request
    NSURL *url = [NSURL URLWithString:@"https://api.casper.io/snapchat/clientauth/signrequest"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [[NSString queryStringWithParams:query] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Set headers
    [request setValue:self.casperAPIKey forHTTPHeaderField:SKHeaders.casperAPIKey];
    [request setValue:SKMakeCapserSignature(query, self.casperAPISecret) forHTTPHeaderField:SKHeaders.casperSignature];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if ([json[@"code"] integerValue] == 200)
                callback(json[@"signature"], nil);
            else
                callback(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
        } else {
            callback(nil, error);
        }
    }] resume];
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password gmail:(NSString *)gmailEmail gpass:(NSString *)gmailPassword completion:(DictionaryBlock)completion {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(gmailEmail); NSParameterAssert(gmailPassword); NSParameterAssert(completion);
    
    NSString *timestamp = [NSString timestamp];
    
    // Google auth token
    [self getAuthTokenForGmail:gmailEmail password:gmailPassword callback:^(NSString *gauth, NSError *error1) {
        if (error1 || !gauth) {
            completion(nil, [SKRequest errorWithMessage:@"Could not retrieve Google auth token." code:error1.code?:1]);
        } else {
            
            // Attestation
            [self getAttestation:username password:password ts:timestamp callback:^(NSString *attestation, NSError *error2) {
                if (error2 || !attestation) {
                    completion(nil, [SKRequest errorWithMessage:@"Could not retrieve attestation." code:error2.code?:1]);
                } else {
                    
                    // Push token is optional
                    [self getGoogleCloudMessagingIdentifier:^(NSString *ptoken, NSError *error3) {
                        [self getDeviceToken:^(NSDictionary *dict, NSError *error4) {
                            if (error4 || !dict) {
                                completion(nil, [SKRequest errorWithMessage:@"Could not retrieve Snapchat device token." code:error4.code?:1]);
                            } else {
                                
                                // X-Snapchat-Client-Auth
                                [self getClientAuthToken:username password:password timestamp:timestamp callback:^(NSString *clientAuthToken, NSError *error5) {
                                    if (error5 || !clientAuthToken) {
                                        completion(nil, error5 ?: [SKRequest errorWithMessage:@"Could not retrieve client auth token." code:1]);
                                    } else {
                                        
                                        // Sign in
                                        NSParameterAssert(gauth); NSParameterAssert(attestation); NSParameterAssert(clientAuthToken); NSParameterAssert(dict); NSParameterAssert(timestamp);
                                        [self signInWithData:SKMakeSignInParams(gauth, attestation, ptoken, clientAuthToken, dict, timestamp) username:username password:password completion:completion];
                                    }
                                }];
                            }
                        }];
                    }];
                }
            }];
        }
    }];
}

- (void)signInWithData:(NSDictionary *)loginData username:(NSString *)username password:(NSString *)password completion:(DictionaryBlock)completion {
    NSString *googleAuth        = loginData[@"googleAuthToken"];
    NSString *attestation       = loginData[@"attestation"];
    NSString *ptoken            = loginData[@"pushToken"];
    NSString *clientAuthToken   = loginData[@"clientAuthToken"];
    NSDictionary *devicetTokens = loginData[@"dt"];
    NSString *timestamp         = loginData[@"ts"];
    
    _googleAuthToken   = googleAuth;
    _googleAttestation = attestation;
    _deviceToken1i     = devicetTokens[SKConsts.deviceToken1i];
    _deviceToken1v     = devicetTokens[SKConsts.deviceToken1v];
    
    NSString *req_token = [NSString hashSCString:SKConsts.staticToken and:timestamp];
    NSString *string    = [NSString stringWithFormat:@"%@|%@|%@|%@", username, password, timestamp, req_token];
    NSString *deviceSig = [[[NSString hashHMac:string key:self.deviceToken1v] base64EncodedStringWithOptions:0] substringWithRange:NSMakeRange(0, 20)];
    
    NSDictionary *post = @{@"username": username,
                           @"password": password,
                           @"height":   @(kScreenHeight),
                           @"width":    @(kScreenWidth),
                           @"max_video_width":  @480,
                           @"max_video_height": @640,
                           @"application_id":   @"com.snapchat.android",
                           @"is_two_fa":        @"false",
                           @"ptoken":           ptoken ?: @"ie",
                           @"pre_auth":         @"",
                           @"sflag":            @1,
                           @"dsig":             deviceSig,
                           @"dtoken1i":         self.deviceToken1i,
                           @"attestation":      self.googleAttestation,
                           @"timestamp":        timestamp};
    
    NSDictionary *headers = @{SKHeaders.clientAuthToken: [NSString stringWithFormat:@"Bearer %@", self.googleAuthToken],
                              SKHeaders.clientAuth: clientAuthToken};
    SKRequest *request    = [[SKRequest alloc] initWithPOSTEndpoint:SKEPAccount.login token:nil query:post headers:headers ts:timestamp];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error6) {
        [self handleError:error6 data:data response:response completion:^(NSDictionary *json, NSError *jsonerror) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!jsonerror) {
                    self.currentSession = [SKSession sessionWithJSONResponse:json];
                    _authToken = self.currentSession.authToken;
                    completion(json, nil);
                } else {
                    completion(nil, jsonerror);
                }
            });
        }];
    }] resume];
}

- (void)signInWithUsername:(NSString *)username authToken:(NSString *)authToken gmail:(NSString *)gmailEmail gpass:(NSString *)gmailPassword completion:(DictionaryBlock)completion {
    NSParameterAssert(username); NSParameterAssert(authToken); NSParameterAssert(gmailEmail); NSParameterAssert(gmailPassword);
    
    [self getAuthTokenForGmail:gmailEmail password:gmailPassword callback:^(NSString *gauth, NSError *error) {
        if (!error) {
            _googleAuthToken = gauth;
            _authToken       = authToken;
            self.username    = username;
            [[SKClient sharedClient] updateSession:^(NSError *error2) {
                completion([self.currentSession valueForKey:@"JSON"], error2);
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)restoreSessionWithUsername:(NSString *)username snapchatAuthToken:(NSString *)authToken googleAuthToken:(NSString *)googleAuthToken doGetUpdates:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(authToken); NSParameterAssert(googleAuthToken);
    _username        = username;
    _authToken       = authToken;
    _googleAuthToken = googleAuthToken;
    if (completion)
        [self updateSession:completion];
}

- (void)signOut:(ErrorBlock)completion {
    [SKRequest postTo:SKEPAccount.login query:@{@"username": self.currentSession.username} gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (kVerboseLog) {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (result.length == 0) {
                _currentSession    = nil;
                _username          = nil;
                _authToken         = nil;
                _googleAuthToken   = nil;
                _googleAttestation = nil;
                _deviceToken1i     = nil;
                _deviceToken1v     = nil;
                completion(nil);
            } else {
                completion([SKRequest errorWithMessage:result code:1]);
            }
        }
    }];
}

#pragma mark Misc

- (void)updateSession:(ErrorBlock)completion {
    SKAssertIsSignedIn();
    
    NSDictionary *query = @{@"username": self.username,
                            @"height": @(self.screenSize.height),
                            @"width": @(self.screenSize.width),
                            @"max_video_height": @(self.maxVideoSize.height),
                            @"max_video_width": @(self.maxVideoSize.width),
                            @"include_client_settings": @"true"};
    [self postTo:SKEPUpdate.all query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            _currentSession = [[SKSession alloc] initWithDictionary:json];
            _authToken = self.currentSession.authToken;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

#pragma mark Registration

- (void)registerEmail:(NSString *)email password:(NSString *)password birthday:(NSString *)birthday completion:(DictionaryBlock)completion {
    NSParameterAssert(email); NSParameterAssert(password); NSParameterAssert(birthday); NSParameterAssert(completion);
    NSDictionary *query = @{@"email": email, @"password": password, @"birthday": birthday};
    
    /* If successful, json1 will be something like:
    {
        "auth_token" = ff8788437e471d21f60d83517581cae5;
        "default_username" = username;
        "default_username_status" = 1;
        email = "email@domain.com";
        logged = 1;
        "should_send_text_to_verify_number" = 0;
        "snapchat_phone_number" = "+19372034486";
        "username_suggestions" = (username5, username03, etc);
    } */
    [self postTo:SKEPAccount.registration.start query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            // Continue registration
            if ([json[@"logged"] boolValue]) {
                _authToken = json[@"auth_token"];
                NSDictionary *result = @{@"email": json[@"email"],
                                         @"snapchat_phone_number": json[@"snapchat_phone_number"],
                                         @"username_suggestions": json[@"username_suggestions"]};
                completion(result, nil);
            }
            // Failed for some reason
            else {
                completion(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
            }
            
        }
    }];
}

- (void)registerUsername:(NSString *)username withEmail:(NSString *)registeredEmail gmail:(NSString *)gmail gmailPassword:(NSString *)gpass completion:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(registeredEmail); NSParameterAssert(gmail); NSParameterAssert(gpass); NSParameterAssert(completion);
    NSDictionary *query = @{@"username": registeredEmail,
                            @"selected_username": username};
    
    [self getAuthTokenForGmail:gmail password:gpass callback:^(NSString *gauth, NSError *error) {
        _googleAuthToken = gauth;
        [self postTo:SKEPAccount.registration.username query:query callback:^(NSDictionary *json, NSError *error) {
            if (!error) {
                
                // Continue registration
                self.currentSession = [[SKSession alloc] initWithDictionary:json];
                if (kDebugJSON && !self.currentSession) {
                    completion([SKRequest unknownError]);
                    SKLog(@"Unknown error: %@", json);
                } else {
                    _username = self.currentSession.username;
                    completion(nil);
                }
            }
            // Failed for some reason
            else {
                completion([SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
            }
        }];
    }];
}

- (void)getCaptcha:(ArrayBlock)completion {
    [SKRequest postTo:SKEPAccount.registration.getCaptcha query:@{@"username": self.username} gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Did get captcha ZIP
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            NSString *dataPath   = [NSString stringWithFormat:@"%@sck-captcha.tmp", NSTemporaryDirectory()];
            NSString *imagesPath = [NSString stringWithFormat:@"%@sck-captcha-images/", NSTemporaryDirectory()];
            [data writeToFile:dataPath atomically:YES];
            // Unzip it
            [SSZipArchive unzipFileAtPath:dataPath toDestination:imagesPath completion:^(NSString *path, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSArray *imagesNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesPath error:nil];
                    NSMutableArray *imageData = [NSMutableArray new];
                    for (NSString *path in imagesNames) {
                        NSData *data = [NSData dataWithContentsOfFile:[imagesPath stringByAppendingString:path]];
                        if (data)
                            [imageData addObject:data];
                    }
                    
                    completion(imageData, nil);
                    
                // Error unzipping
                } else if (error) {
                    completion(nil, error);
                } else {
                    completion(nil, [SKRequest errorWithMessage:@"Error unzipping captcha" code:1]);
                }
            }];
        // Failed to get captcha ZIP
        } else {
            completion(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }];
}

- (void)solveCaptchaWithSolution:(NSString *)solution completion:(DictionaryBlock)completion {
    NSParameterAssert(solution);
    NSDictionary *query = @{@"username": self.username,
                            @"captcha_id": [NSString SCIdentifierWith:self.username and:[[NSString timestamp] substringToIndex:13]],
                            @"captcha_solution": solution};
    [self postTo:SKEPAccount.registration.solveCaptcha query:query callback:^(NSDictionary *json, NSError *error) {
        SKLog(@"%@", json);
    }];
}

- (void)sendPhoneVerification:(NSString *)mobile sendText:(BOOL)sms completion:(DictionaryBlock)completion {
    NSParameterAssert(mobile); NSParameterAssert(completion);
    
    NSArray *digits = [mobile allMatchesForRegex:@"\\d"];
    if (digits.count != 10 && digits.count != 11) {
        completion(nil, [SKRequest errorWithMessage:@"Invalid phone number" code:400]);
    }
    
    NSString *countryCode;
    NSMutableString *number = [NSMutableString string];
    for (NSString *digit in digits)
        [number appendString:digit];
    
    if (digits.count == 11) {
        countryCode = digits[0];
        [number deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    else {
        countryCode = @"1";
    }
    
    NSDictionary *query = @{@"username": self.username,
                            @"phoneNumber": number,
                            @"countryCode": countryCode,
                            @"action": @"updatePhoneNumber",
                            @"skipConfirmation": @YES};
    [self postTo:SKEPAccount.registration.verifyPhone query:query callback:^(NSDictionary *json, NSError *error) {
        SKLog(@"%@", json);
    }];
}

- (void)verifyPhoneNumberWithCode:(NSString *)code completion:(ErrorBlock)completion {
    NSParameterAssert(code); NSParameterAssert(completion);
    NSDictionary *query = @{@"action": @"verifyPhoneNumber",
                            @"username": self.username,
                            @"code": code};
    // Hash timestamp with static token before passing as token?
    [SKRequest postTo:SKEPAccount.registration.verifyPhone query:query gauth:self.googleAuthToken token:SKConsts.staticToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleError:error data:data response:response completion:^(NSDictionary *json, NSError *error) {
            SKLog(@"%@", json);
        }];
    }];
}

#pragma mark For categories

- (void)sendEvents:(NSArray *)events data:(NSDictionary *)snapInfo completion:(ErrorBlock)completion {
    if (!completion) completion = ^(id e){};
    if (!events)   events = @[];
    if (!snapInfo) snapInfo = @{};
    NSDictionary *query = @{@"events": events.JSONString,
                            @"json": snapInfo.JSONString,
                            @"username": self.currentSession.username};
    
    [SKRequest postTo:SKEPUpdate.snaps query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data.length == 0 && [(NSHTTPURLResponse *)response statusCode] == 200)
                    completion(nil);
                else if (error) {
                    completion(error);
                } else {
                    completion([SKRequest unknownError]);
                }
            });
    }];
}

@end