//
//  SKCasperCache.m
//  Pods
//
//  Created by Tanner on 2/21/16.
//
//

#import "SKCasperCache.h"
#import "SnapchatKit-Constants.h"
#import "NSDictionary+SnapchatKit.h"

@interface SKCasperCache ()
@property (nonatomic) NSMutableDictionary *cache;
@end

@implementation SKCasperCache

#pragma mark - Initializers

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (instancetype)fromDictionary:(NSDictionary *)oldCache {
    NSDate *now = [NSDate date];
    NSMutableDictionary *cache = oldCache.mutableCopy;
    
    // Remove expired objects now or at a later date
    for (NSDictionary *endpoint in oldCache) {
        if ([now compare:endpoint[@"expires"]] == NSOrderedDescending) {
            [cache removeObjectForKey:endpoint[@"endpoint"]];
        } else {
            NSInteger timeLeft = [endpoint[@"expires"] timeIntervalSinceDate:now];
            [self performSelector:@selector(safelyRemoveDataForEndpoint:) withObject:endpoint[@"endpoint"] afterDelay:timeLeft];
        }
    }
    
    // Fill out and return new cache
    SKCasperCache *ret = [SKCasperCache new];
    ret.cache = cache;
    return ret;
}

#pragma mark - Misc

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@> cache:\n%@",
            NSStringFromClass(self.class), self.cache.JSONString];
}

#pragma mark - Public interface

- (void)update:(NSDictionary *)response {
    if ([response[@"code"] integerValue] == 200) {
        if ([response[@"force_expire_cached"] boolValue]) {
            [_cache removeAllObjects];
        }
        
        // Cache the objects with a specified expiration date
        for (NSDictionary *endpoint in response[@"endpoints"]) {
            NSInteger cacheTime = [endpoint[@"cache_millis"] floatValue]/1000;
            NSMutableDictionary *m = endpoint.mutableCopy;
            
            // Content-Type header for specific endpoints
            if ([endpoint[@"endpoint"] isEqualToString:SKEPStories.upload] || [endpoint[@"endpoint"] isEqualToString:SKEPSnaps.upload]) {
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", SKConsts.boundary];
                m[@"headers"] = SKMergeDictionaries(endpoint[@"headers"], @{SKHeaders.contentType: contentType});
            }
            
            m[@"expires"] = [NSDate dateWithTimeIntervalSinceNow:cacheTime];
            _cache[endpoint[@"endpoint"]] = m.copy;
            
            // Remove object from cache after delay
            [self performSelector:@selector(safelyRemoveDataForEndpoint:) withObject:endpoint[@"endpoint"] afterDelay:cacheTime];
        }
    }
}

- (void)clear {
    [_cache removeAllObjects];
}

- (NSDictionary *)dictionaryValue { return _cache.copy; }

- (NSDictionary *)dataForEndpoint:(NSString *)endpoint {
    return _cache[endpoint];
}

- (NSDictionary *)objectForKeyedSubscript:(NSString *)endpoint {
    return _cache[endpoint];
}

#pragma mark - Private

- (void)safelyRemoveDataForEndpoint:(NSString *)endpoint {
    if ([NSThread isMainThread]) {
        [_cache removeObjectForKey:endpoint];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_cache removeObjectForKey:endpoint];
        });
    }
}

@end
