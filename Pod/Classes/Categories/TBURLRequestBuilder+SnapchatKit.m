//
//  TBURLRequestBuilder+SnapchatKit.m
//  Pods
//
//  Created by Tanner on 7/4/16.
//
//

#import "SnapchatKit-Constants.h"

@implementation TBURLRequestBuilder (SnapchatKit)

+ (TBURLRequestProxy *)sk_make:(void(^)(TBURLRequestBuilder *))configurationHandler {
    return [self make:^(TBURLRequestBuilder *make) {
        make.baseURL(SKConsts.baseURL)
        configurationHandler(make);
    }];
}

@end
