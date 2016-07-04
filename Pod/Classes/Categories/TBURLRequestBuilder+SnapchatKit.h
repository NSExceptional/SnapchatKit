//
//  TBURLRequestBuilder+SnapchatKit.h
//  Pods
//
//  Created by Tanner on 7/4/16.
//
//

#import "TBURLRequestBuilder.h"


@interface TBURLRequestBuilder (SnapchatKit)

+ (TBURLRequestProxy *)sk_make:(void(^)(TBURLRequestBuilder *make))configurationHandler;

@end
