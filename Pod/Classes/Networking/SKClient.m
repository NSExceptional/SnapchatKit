//
//  SKClient.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient.h"
#import "SKSession.h"
#import "SKConversation.h"
#import "SKBlob.h"

#import "SnapchatKit-Constants.h"
#import "SSZipArchive.h"
#import <SystemConfiguration/SCNetworkReachability.h>


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

BOOL SKShouldUseStaticToken(NSString *endpiont) {
    static NSSet *staticTokenEndpoints = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticTokenEndpoints = [NSSet setWithArray:@[SKEPAccount.registration.start, SKEPAccount.registration.solveCaptcha,
                                                     SKEPAccount.registration.suggestUsername, SKEPAccount.registration.username,
                                                     SKEPAccount.registration.verifyPhone]];
    });
    
    return [staticTokenEndpoints containsObject:endpiont];
}


@implementation SKClient
@synthesize authToken = _authToken;

#pragma mark Initializers

static SKClient *sharedSKClient;
+ (instancetype)sharedClient {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedSKClient = [SKClient new];
        [[NSFileManager defaultManager] createDirectoryAtPath:SKTempDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    });
    
    return sharedSKClient;
}

- (id<SKCasperCache>)cache {
    if (!_cache) {
        _cache = [SKCasperCache new];
    }
    
    return _cache;
}

+ (void)setSharedClient:(SKClient *)client {
    NSParameterAssert(client);
    sharedSKClient = client;
}

+ (instancetype)clientWithUsername:(NSString *)username authToken:(NSString *)authToken {
    SKClient *client   = [self new];
    client.username    = username;
    client->_authToken = authToken;
    
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

#pragma mark Casper

- (NSProgress *)casperRequest:(NSString *)url JWTParams:(NSDictionary *)JWTParams callback:(TBResponseBlock)callback {
    NSParameterAssert(url); NSParameterAssert(JWTParams);
    NSAssert(self.casperAPIKey, @"You must have a valid API key from https://clients.casper.io to sign in.");
    NSAssert(self.casperAPISecret, @"You must have a valid API secret from https://clients.casper.io to sign in.");
    
    // Headers
    NSString *signature = SKMakeCapserSignature(JWTParams, self.casperAPISecret);
    NSMutableDictionary *headers = @{SKHeaders.casperAPIKey: self.casperAPIKey, SKHeaders.casperSignature: signature}.mutableCopy;
    headers[TBHeader.userAgent] = self.casperUserAgent;
    
    // Request, callback with error checking
    return [[TBURLRequestBuilder make:^(TBURLRequestBuilder *make) {
        make.URL(url).headers(headers);
        make.bodyJSONFormString(@{@"jwt": [JWTParams JWTStringWithSecret:self.casperAPISecret]});
    }] POST:^(TBResponseParser *parser) {
        if (!parser.error) {
            if (parser.response.statusCode == 200) {
                callback(parser);
            } else {
                callback([TBResponseParser error:parser.JSON[@"message"] domain:@"SnapchatKit" code:parser.response.statusCode]);
            }
        } else {
            callback(parser);
        }
    }];
}

- (NSProgress *)getClientLoginData:(NSString *)username password:(NSString *)password timestamp:(NSString *)ts callback:(DictionaryBlock)callback {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(ts);
    
    NSDictionary *query = @{@"username": username, @"password": password, @"iat": [NSString timestampInSeconds]}.mutableCopy;
    NSString *url = @"https://casper-api.herokuapp.com/snapchat/ios/login";
    return [self casperRequest:url JWTParams:query callback:^(TBResponseParser *parser) {
        callback(parser.JSON, parser.error);
    }];
}

- (NSProgress *)getInformationForEndpoint:(NSString *)endpoint callback:(SKCasperResponseBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    
    // Check token cache first
    NSDictionary *cached = self.cache[endpoint];
    if (cached) {
        callback(cached[@"params"], cached[@"headers"], nil);
    }
    
    NSString *url = @"https://casper-api.herokuapp.com/snapchat/ios/endpointauth";
    NSMutableDictionary *query = @{@"auth_token": self.authToken, @"endpoint": endpoint, @"iat": [NSString timestampInSeconds]}.mutableCopy;
    query[@"username"] = self.username;
    
    return [self casperRequest:url JWTParams:query callback:^(TBResponseParser *parser) {
        [self.cache update:parser.JSON];
        
        NSDictionary *data = self.cache[endpoint];
        callback(data[@"params"], data[@"headers"], parser.error);
    }];
}

#pragma mark Convenience

- (NSProgress *)request:(SKConfigurationBlock)configure to:(NSString *)endpoint callback:(TBResponseBlock)callback success:(SKProxyBlock)success {
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:100];
    NSProgress *child1 = [self getInformationForEndpoint:endpoint callback:^(NSDictionary *bodyForm, NSDictionary *headers, NSError *error) {
        if (!error) {
            NSProgress *child2 = success([TBURLRequestBuilder make:^(TBURLRequestBuilder *make) {
                make.baseURL(SKConsts.baseURL).endpoint(endpoint);
                make.configuration(self.URLSessionConfig).session(self.URLSession);
                make.headers(headers);
                configure(make, bodyForm);
            }]);
            [progress addChild:child2 withPendingUnitCount:50];
        } else {
            TBRunBlockP(callback, [TBResponseParser error:error]);
        }
    }];
    
    [progress addChild:child1 withPendingUnitCount:50];
    return progress;
}

- (NSProgress *)postWith:(NSDictionary *)parameters to:(NSString *)endpoint callback:(TBResponseBlock)callback {
    [self post:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
        make.bodyJSONFormString(MergeDictionaries(parameters, bodyForm));
    } to:endpoint callback:callback];
}

- (NSProgress *)post:(SKConfigurationBlock)configurationHandler to:(NSString *)endpoint callback:(TBResponseBlock)callback {
    return [self request:configurationHandler to:endpoint callback:callback success:^NSProgress *(TBURLRequestProxy *proxy) {
        return [proxy POST:^(TBResponseParser *parser) {
            if (self.middleMan) {
                [self.middleMan handleResponse:parser completion:callback];
            } else {
                callback(parser);
            }
        }];
    }];
}

- (NSProgress *)get:(SKConfigurationBlock)configurationHandler from:(NSString *)endpoint callback:(TBResponseBlock)callback {
    return [self request:configurationHandler to:endpoint callback:callback success:^NSProgress *(TBURLRequestProxy *proxy) {
        return [proxy GET:^(TBResponseParser *parser) {
            if (self.middleMan) {
                [self.middleMan handleResponse:parser completion:callback];
            } else {
                callback(parser);
            }
        }];
    }];
}

#pragma mark Signing in

- (BOOL)isSignedIn {
    return self.authToken && self.username;
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password completion:(DictionaryBlock)completion {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(completion);
    
    [self getClientLoginData:username password:password timestamp:[NSString timestamp] callback:^(NSDictionary *stuff, NSError *error) {
        if (!error) {
            [[TBURLRequestBuilder make:^(TBURLRequestBuilder *make) {
                make.baseURL(SKConsts.baseURL).endpoint(SKEPAccount.login);
                make.bodyJSONFormString(stuff[@"params"]).headers(stuff[@"headers"]);
            }] POST:^(TBResponseParser *parser) {
                SKLog(@"Recieved Snapchat login response...");
                if (!parser.error) {
                    self.currentSession = [SKSession sessionWithJSONResponse:parser.JSON];
                    _authToken = self.currentSession.authToken;
                    completion(parser.JSON, nil);
                } else {
                    completion(nil, parser.error);
                }
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)restoreSessionWithUsername:(NSString *)username snapchatAuthToken:(NSString *)authToken doGetUpdates:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(authToken);
    _username        = username;
    _authToken       = authToken;
    if (completion) {
        [self updateSession:completion];
    }
}

- (void)signOut:(ErrorBlock)completion {
    [self post:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
        make.bodyJSONFormString(MergeDictionaries(bodyForm, @{@"username": self.currentSession.username}));
    } to:SKEPAccount.logout callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            [_cache clear];
            _currentSession    = nil;
            _username          = nil;
            _authToken         = nil;
            _deviceToken1i     = nil;
            _deviceToken1v     = nil;
            completion(nil);
        } else {
            completion(parser.error);
        }
    }];
}

#pragma mark Misc

- (void)updateSession:(ErrorBlock)completion {
    SKAssertIsSignedIn(self);
    
    NSDictionary *params = @{@"username": self.username,
                             @"friends_request": @{@"friends_sync_token": self.currentSession.friendsSyncToken ?: @0}.JSONString,
                             @"height": @(self.screenSize.height),
                             @"width": @(self.screenSize.width),
                             @"screen_height_px": @(self.screenSize.height),
                             @"screen_width_px": @(self.screenSize.width),
                             @"screen_width_in": @0,
                             @"screen_height_in": @0,
                             @"checksums_dict": self.currentSession.checksums ?: @"{}"};
    
    [self postWith:params to:SKEPUpdate.all callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            BOOL partialFriends = [parser.JSON[@"friends_response"][@"friends_sync_type"] isEqualToString:@"partial"];
            BOOL partialConvos  = [parser.JSON[@"conversations_response_info"][@"is_delta"] boolValue];
            if (partialFriends || partialConvos) {
                _currentSession = [[[SKSession alloc] initWithDictionary:parser.JSON] mergeWithOldSession:_currentSession];
            } else {
                _currentSession = [[SKSession alloc] initWithDictionary:parser.JSON];
            }
            _authToken = self.currentSession.authToken;
            TBRunBlockP(completion, nil);
        } else {
            TBRunBlockP(completion, parser.error);
        }
    }];
}

#pragma mark Registration

- (void)registerEmail:(NSString *)email password:(NSString *)password birthday:(NSString *)birthday completion:(DictionaryBlock)completion {
    NSParameterAssert(email); NSParameterAssert(password); NSParameterAssert(birthday); NSParameterAssert(completion);
    
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
    
    NSDictionary *params = @{@"email": email, @"password": password, @"birthday": birthday};
    [self postWith:params to:SKEPAccount.registration.start callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            // Continue registration
            if ([parser.JSON[@"logged"] boolValue]) {
                _authToken = parser.JSON[@"auth_token"];
                //                NSDictionary *result = @{@"email": json[@"email"],
                //                                         @"snapchat_phone_number": json[@"snapchat_phone_number"],
                //                                         @"username_suggestions": json[@"username_suggestions"]};
                completion(parser.JSON, nil);
            }
            // Failed for some reason
            else {
                completion(nil, [TBResponseParser error:parser.JSON[@"message"] domain:@"SnapchatKit" code:[parser.JSON[@"status"] integerValue]]);
            }
        }
    }];
}

- (void)registerUsername:(NSString *)username withEmail:(NSString *)registeredEmail gmail:(NSString *)gmail gmailPassword:(NSString *)gpass completion:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(registeredEmail); NSParameterAssert(gmail); NSParameterAssert(gpass); NSParameterAssert(completion);
    NSDictionary *params = @{@"email": registeredEmail,
                             @"username": registeredEmail,
                             @"selected_username": username,
                             @"height": @(self.screenSize.height),
                             @"width": @(self.screenSize.width)};
    
    [self postWith:params to:SKEPAccount.registration.username callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            // Continue registration
            self.currentSession = [[SKSession alloc] initWithDictionary:parser.JSON];
            if (kDebugJSON && !self.currentSession) {
                SKLog(@"Unknown error: %@", parser.JSON);
            } else {
                assert(self.currentSession);
                _username = self.currentSession.username;
                completion(nil);
            }
        }
        // Failed for some reason
        else {
            completion([TBResponseParser error:parser.JSON[@"message"] domain:@"SnapchatKit" code:[parser.JSON[@"status"] integerValue]]);
        }
    }];
}


- (void)getCaptcha:(ArrayBlock)completion {
    [self postWith:@{@"username": self.username} to:SKEPAccount.registration.getCaptcha callback:^(TBResponseParser *parser) {
        // Did get captcha ZIP
        if (!parser.error) {
            NSString *dataPath   = [NSString stringWithFormat:@"%@sck-captcha.tmp", NSTemporaryDirectory()];
            NSString *imagesPath = [NSString stringWithFormat:@"%@sck-captcha-images/", NSTemporaryDirectory()];
            [parser.data writeToFile:dataPath atomically:YES];
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
                } else {
                    // Error unzipping
                    completion(nil, error ?: [TBResponseParser error:@"Error unzipping captcha" domain:@"SnapchatKit" code:1]);
                }
            }];
        } else {
            // Failed to get captcha ZIP
            completion(nil, parser.error);
        }
    }];
}

- (void)solveCaptchaWithSolution:(NSString *)solution completion:(DictionaryBlock)completion {
    NSParameterAssert(solution);
    NSDictionary *params = @{@"username": self.username,
                             @"captcha_id": [NSString SCIdentifierWith:self.username and:[[NSString timestamp] substringToIndex:13]],
                             @"captcha_solution": solution};
    [self postWith:params to:SKEPAccount.registration.solveCaptcha callback:^(TBResponseParser *parser) {
        SKLog(@"%@", parser.JSON ?: parser.error);
    }];
}

- (void)sendPhoneVerification:(NSString *)mobile sendText:(BOOL)sms completion:(DictionaryBlock)completion {
    NSParameterAssert(mobile); NSParameterAssert(completion);
    
    NSArray *digits = [mobile allMatchesForRegex:@"\\d"];
    if (digits.count != 10 && digits.count != 11) {
        completion(nil, [TBResponseParser error:@"Invalid phone number" domain:@"SnapchatKit" code:1]);
        return;
    }
    
    NSString *countryCode;
    NSMutableString *number = [digits join:@""].mutableCopy;
    
    if (digits.count == 11) {
        countryCode = digits[0];
        [number deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    else {
        countryCode = @"1";
    }
    
    NSDictionary *params = @{@"username": self.username,
                             @"phoneNumber": number,
                             @"countryCode": countryCode,
                             @"action": @"updatePhoneNumber",
                             @"skipConfirmation": @YES};
    [self postWith:params to:SKEPAccount.registration.verifyPhone callback:^(TBResponseParser *parser) {
        SKLog(@"%@", parser.JSON ?: parser.error);
    }];
}

- (void)verifyPhoneNumberWithCode:(NSString *)code completion:(ErrorBlock)completion {
    NSParameterAssert(code); NSParameterAssert(completion);
    NSDictionary *params = @{@"action": @"verifyPhoneNumber",
                             @"username": self.username,
                             @"code": code};
    // Hash timestamp with static token before passing as token?
    [self postWith:params to:SKEPAccount.registration.verifyPhone callback:^(TBResponseParser *parser) {
        SKLog(@"%@", parser.JSON ?: parser.error);
    }];
}

#pragma mark For categories

- (void)sendEvents:(NSArray *)events data:(NSDictionary *)snapInfo completion:(ErrorBlock)completion {
    if (!completion) completion = ^(id e){};
    if (!events)   events = @[];
    if (!snapInfo) snapInfo = @{};
    NSDictionary *params = @{@"events": events.JSONString,
                             @"json": snapInfo.JSONString,
                             @"username": self.currentSession.username};
    
    [self postWith:params to:SKEPUpdate.snaps callback:^(TBResponseParser *parser) {
        TBRunBlockP(completion, parser.error);
    }];
}

@end