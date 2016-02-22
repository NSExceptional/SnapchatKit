//
//  NSMutableURLRequest+Util.h
//  Pods
//
//  Created by Tanner on 2/21/16.
//
//

#import <Foundation/Foundation.h>


@interface NSMutableURLRequest (Util)

+ (instancetype)POST:(NSString *)url body:(NSDictionary *)body headers:(NSDictionary *)headers;

@end
