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

#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"

#import "SSZipArchive.h"

NSString * const kAttestationURLString     = @"https://www.googleapis.com/androidcheck/v1/attestations/attest?alt=JSON&key=AIzaSyDqVnJBjE5ymo--oBJt3On7HQx9xNm1RHA";
NSString * const kAttestationBase64Request = @"ClMKABIUY29tLnNuYXBjaGF0LmFuZHJvaWQaIC8cqvyh7TDQtOOIY+76vqDoFXEfpM95uCJRmoJZ2VpYIgAojKq/AzIECgASADoECAEQAUD4kP+pBRIA";

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

- (void)setCurrentSession:(SKSession *)currentSession {
    _currentSession = currentSession;
    _username = currentSession.username;
}

- (NSString *)authToken {
    return _authToken ?: kStaticToken;
}

- (void)setUsername:(NSString *)username {
    _username = [username lowercaseString];
}

#pragma mark Convenience

- (void)handleError:(NSError *)error data:(NSData *)data response:(NSURLResponse *)response completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
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
                completion(nil, [SKRequest errorWithMessage:html.textFromHTML code:code]);
            } else {
                // ???
                completion(nil, jsonError);
            }
        }
        
        else if (json) {
            if (code > 199 && code < 300) {
                // Suceeded with a response
                NSNumber *logged = json[@"logged"] ?: json[@"updates_response"][@"logged"];
                if (logged) {
                    if (logged.integerValue == 1)
                        completion(json, nil);
                    else
                        completion(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
                }
            } else {
                // Failed with a message
                error = [SKRequest errorWithMessage:json[@"message"] code:code];
                completion(nil, error);
            }
        }
        else {
            completion(nil, [SKRequest unknownError]);
        }
    } else if (code > 199 && code < 300) {
        // Succeeded with no response
        completion(nil, nil);
    } else {
        completion(nil, [SKRequest unknownError]);
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
                if ([(NSHTTPURLResponse *)response statusCode] == 200)
                    callback(data, nil);
                else
                    callback(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
            } else {
                callback(nil, error);
            }
        });
    }];
}

#pragma mark Signing in

- (BOOL)isSignedIn {
    return self.googleAuthToken && self.authToken && self.currentSession && self.username;
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
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:khfContentType];
    [request setValue:@"378c184c6070c26c" forHTTPHeaderField:@"device"];
    [request setValue:@"com.snapchat.android" forHTTPHeaderField:@"app"];
    [request setValue:@"GoogleAuth/1.4 (mako JDQ39)" forHTTPHeaderField:khfUserAgent];
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
    [SKRequest postTo:kepDeviceToken query:@{} headers:@{khfClientAuthTokenHeaderField: @"Bearer "} token:nil callback:^(NSData *data, NSURLResponse *response, NSError *error) {
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

/** Attestation, courtesy of @c casper.io. */
- (void)getAttestationWithUsername:(NSString *)username password:(NSString *)password ts:(NSString *)ts callback:(StringBlock)completion {
    NSString *hashString     = [NSString stringWithFormat:@"%@|%@|%@|%@", username, password, ts, kepLogin];
    NSString *nonce          = [hashString.sha256HashRaw base64EncodedStringWithOptions:0];
    
    NSDictionary *query = @{@"nonce": nonce,
                            @"authentication": kAttestationAuth,
                            @"apk_digest": kAPKDigest9_8,
                            @"timestamp": ts};
    NSData *queryData  = [[NSString queryStringWithParams:query] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kAttestationURLCasper]];
    request.HTTPMethod  = @"POST";
    request.HTTPBody    = queryData;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        } else if (data) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError)
                completion(nil, jsonError);
            else if ([json[@"code"] integerValue] == 200)
                completion(json[@"signedAttestation"], nil);
            else
                completion(nil, [SKRequest unknownError]);
        } else {
            completion(nil, [SKRequest unknownError]);
        }
    }];
    
    [dataTask resume];
}

/** Google account attestation. */
- (void)getAttestationOld:(StringBlock)completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kAttestationURLString]];
    NSData *binaryRequest = [[NSData alloc] initWithBase64EncodedString:kAttestationBase64Request options:0];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody   = binaryRequest;
    [request setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-type"];
    [request setValue:kUserAgentForAttestation forHTTPHeaderField:@"User-Agent"];
//    [request setValue:@"" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"" forHTTPHeaderField:@"Expect"];
//    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
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
    
    [self getAuthTokenForGmail:gmailEmail password:gmailPassword callback:^(NSString *gauth, NSError *error1) {
        if (error1 || !gauth) {
            completion(nil, [SKRequest errorWithMessage:@"Could not retrieve Google auth token." code:error1.code?:1]);
        } else {
            NSString *timestamp = [NSString timestamp];
            [self getAttestationWithUsername:username password:password ts:timestamp callback:^(NSString *attestation, NSError *error2) {
                if (error2 || !attestation) {
                    completion(nil, [SKRequest errorWithMessage:@"Could not retrieve attestation." code:error2.code?:1]);
                } else {
                    [self getDeviceToken:^(NSDictionary *dict, NSError *error3) {
                        if (error3 || !dict) {
                            completion(nil, [SKRequest errorWithMessage:@"Could not retrieve Snapchat device token." code:error3.code?:1]);
                        } else {
                            
                            _googleAuthToken   = gauth;
                            _googleAttestation = attestation;
                            _deviceToken1i     = dict[@"dtoken1i"];
                            _deviceToken1v     = dict[@"dtoken1v"];
                            
                            NSString *req_token = [NSString hashSCString:kStaticToken and:timestamp];
                            NSString *string    = [NSString stringWithFormat:@"%@|%@|%@|%@", username, password, timestamp, req_token];
                            NSString *deviceSig = [[NSString hashHMac:string key:self.deviceToken1v] substringWithRange:NSMakeRange(0, 20)];
                            
                            NSDictionary *post = @{@"username": username,
                                                   @"password": password,
                                                   @"height":   @(kScreenHeight),
                                                   @"width":    @(kScreenWidth),
                                                   @"max_video_width":  @480,
                                                   @"max_video_height": @640,
                                                   @"application_id":   @"com.snapchat.android",
                                                   @"ptoken":           @"ie",
                                                   @"sflag":            @1,
                                                   @"dsig":             deviceSig,
                                                   @"dtoken1i":         self.deviceToken1i,
                                                   @"attestation":      self.googleAttestation,
                                                   @"timestamp":        timestamp};
                            
                            NSDictionary *headers = @{khfClientAuthTokenHeaderField: [NSString stringWithFormat:@"Bearer %@", self.googleAuthToken]};
                            SKRequest *request    = [[SKRequest alloc] initWithPOSTEndpoint:kepLogin token:nil query:post headers:headers ts:timestamp];
                            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                            
                            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error4) {
                                [self handleError:error4 data:data response:response completion:^(NSDictionary *json, NSError *jsonerror) {
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
                            }];
                            [dataTask resume];
                            
//                            [SKRequest postTo:kepLogin query:post gauth:gauth token:nil callback:^(NSData *data, NSURLResponse *response, NSError *error4) {
//                                [self handleError:error4 data:data response:response completion:^(NSDictionary *json, NSError *jsonerror) {
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        if (!jsonerror) {
//                                            self.currentSession = [SKSession sessionWithJSONResponse:json];
//                                            _authToken = self.currentSession.authToken;
//                                            completion(json, nil);
//                                        } else {
//                                            completion(nil, jsonerror);
//                                        }
//                                    });
//                                }];
//                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)signOut {
    [SKRequest postTo:kepLogout query:@{@"username": self.currentSession.username} gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (kVerboseLog) {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (result.length == 0)
                SKLog(@"Signed out");
            else
                SKLog(@"%@", result);
            
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
                            @"max_video_width": @(self.maxVideoSize.width)};
    [self postTo:kepAllUpdates query:query callback:^(NSDictionary *json, NSError *error) {
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
    [self postTo:kepRegister query:query callback:^(NSDictionary *json, NSError *error) {
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

- (void)registerUsername:(NSString *)username withEmail:(NSString *)registeredEmail gmail:(NSString *)gmail gmailPassword:(NSString *)gpass completion:(BooleanBlock)completion {
    NSParameterAssert(username); NSParameterAssert(registeredEmail); NSParameterAssert(gmail); NSParameterAssert(gpass); NSParameterAssert(completion);
    NSDictionary *query = @{@"username": registeredEmail,
                            @"selected_username": username};
    
    [self getAuthTokenForGmail:gmail password:gpass callback:^(NSString *gauth, NSError *error) {
        _googleAuthToken = gauth;
        [self postTo:kepRegisterUsername query:query callback:^(NSDictionary *json, NSError *error) {
            if (!error) {
                
                // Continue registration
                self.currentSession = [[SKSession alloc] initWithDictionary:json];
                if (kDebugJSON && !self.currentSession) {
                    SKLog(@"Unknown error: %@", json);
                } else {
                    _username = self.currentSession.username;
                    completion(YES, nil);
                }
            }
            // Failed for some reason
            else {
                completion(NO, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
            }
        }];
    }];
}

- (void)getCaptcha:(ArrayBlock)completion {
    [SKRequest postTo:kepCaptchaGet query:@{@"username": self.username} gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    [self postTo:kepCaptchaSolve query:query callback:^(NSDictionary *json, NSError *error) {
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
    [self postTo:kepPhoneVerify query:query callback:^(NSDictionary *json, NSError *error) {
        SKLog(@"%@", json);
    }];
}

- (void)verifyPhoneNumberWithCode:(NSString *)code completion:(BooleanBlock)completion {
    NSParameterAssert(code); NSParameterAssert(completion);
    NSDictionary *query = @{@"action": @"verifyPhoneNumber",
                            @"username": self.username,
                            @"code": code};
    // Hash timestamp with static token before passing as token?
    [SKRequest postTo:kepPhoneVerify query:query gauth:self.googleAuthToken token:kStaticToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleError:error data:data response:response completion:^(NSDictionary *json, NSError *error) {
            SKLog(@"%@", json);
        }];
    }];
}

#pragma mark For categories

- (void)sendEvents:(NSArray *)events data:(NSDictionary *)snapInfo completion:(ErrorBlock)completion {
    if (!events)   events = @[];
    if (!snapInfo) snapInfo = @{};
    NSDictionary *query = @{@"events": events.JSONString,
                            @"json": snapInfo.JSONString,
                            @"username": self.currentSession.username};
    
    [SKRequest postTo:kepUpdateSnaps query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
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