//
//  SKTrophy.m
//  Pods
//
//  Created by Tanner on 12/23/15.
//
//

#import "SKTrophy.h"

@implementation SKTrophy

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ label=%@ unicode=%@> Stages:\n%@",
            NSStringFromClass(self.class), _label, _unicode, _stages.description];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"label": @"label",
             @"unicode": @"unicode",
             @"stages": @"stages"};
}

+ (NSValueTransformer *)stagesJSONTransformer { return [self sk_modelArrayTransformerForClass:[SKTrophyStage class]]; }

@end


@implementation SKTrophyStage

- (NSString *)description {
    return _unicode;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ label=%@ unicode=%@ status=%@>",
            NSStringFromClass(self.class), _label, _unicode, _status];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"label": @"label",
             @"unicode": @"unicode",
             @"status": @"status",
             @"achievedOn": @"achieved_timestamp"};
}

MTLTransformPropertyDate(achievedOn)

@end