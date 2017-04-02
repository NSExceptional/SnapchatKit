//
//  SKCasperCache.h
//  Pods
//
//  Created by Tanner on 2/21/16.
//
//

#import <Foundation/Foundation.h>


/// See the SKCasperCache class for an example implementaiton.
@protocol SKCasperCache <NSObject>
+ (id)fromDictionary:(NSDictionary *)oldCache;
@property (nonatomic, readonly) NSDictionary *dictionaryValue;

/// Add entries to the cache. Takes a full response from the casper serves.
- (void)update:(NSDictionary *)response;
/// Remove all cache entries
- (void)clear;
/// Expected to return the same data returned from the Casper API for a given endpoint.
- (NSDictionary *)objectForKeyedSubscript:(NSString *)endpoint;
@end


@interface SKCasperCache : NSObject <SKCasperCache>

/// Use this for new caches
- (instancetype)init;
/// @return nil if the file was empty or could not be opened.
+ (instancetype)fromDictionary:(NSDictionary *)oldCache;

/// Useful for serialization
@property (nonatomic, readonly) NSDictionary *dictionaryValue;
- (void)clear;

- (void)update:(NSDictionary *)response;

/// @return The data for the given endpoint with the keys "headers" and "params"
- (NSDictionary *)dataForEndpoint:(NSString *)endpoint;
/// Same as dataForEndpoint:
- (NSDictionary *)objectForKeyedSubscript:(NSString *)endpoint;

@end
