//
//  NSMutableURLRequest+Util.m
//  Pods
//
//  Created by Tanner on 2/21/16.
//
//

#import "NSMutableURLRequest+Util.h"
#import "NSString+SnapchatKit.h"


@implementation NSMutableURLRequest (Util)

+ (instancetype)POST:(NSString *)urlString body:(NSDictionary *)body headers:(NSDictionary *)headers {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) { [NSException raise:NSInvalidArgumentException format:@"Tried to create an NSURL with a malformed URL string: %@", urlString]; }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [[NSString queryStringWithParams:body] dataUsingEncoding:NSUTF8StringEncoding];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    return request;
}

@end
