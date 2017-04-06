//
//  SKIPCResponse.h
//  Pods
//
//  Created by Tanner on 4/6/17.
//
//

#import <Foundation/Foundation.h>


@interface SKIPCResponse : NSObject

+ (instancetype)response:(NSDictionary *)object error:(NSError *)error;
+ (instancetype)errorMessage:(NSString *)message;

@property (nonatomic, readonly) NSDictionary *object;
@property (nonatomic, readonly) NSMutableURLRequest *request;
@property (nonatomic, readonly) NSError *error;

@end
