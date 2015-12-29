//
//  SKTrophyMetrics.m
//  Pods
//
//  Created by Tanner on 12/29/15.
//
//

#import "SKTrophyMetrics.h"

@implementation SKTrophyMetrics
// , , ,
// , , ,
// , , , , ,

- (NSDictionary *)metrics {
    NSDictionary *metrics = @{@"front_facing_snaps": @(self.frontFacing),
                              @"many_color_snaps": @(self.manyColors),
                              @"video_snaps": @(self.video),
                              @"postin_n_snaps": @(self.postingNSnaps),
                              @"one_filter_snaps": @(self.oneFilter),
                              @"two_filter_snaps": @(self.twoFilters),
                              @"cold_filter_snaps": @(self.coldFilter),
                              @"hot_filter_snaps": @(self.hotFilter),
                              @"full_zoom_snaps": @(self.fullZoom),
                              @"black_and_white_snaps": @(self.blackAndWhite),
                              @"night_mode_snaps": @(self.nightMode),
                              @"big_text_snaps": @(self.bigText),
                              @"front_flash_snaps": @(self.frontFlash),
                              @"early_morning_snaps": @(self.earlyMorning)};
    
    NSMutableDictionary *filtered = metrics.mutableCopy;
    for (NSString *key in metrics)
        if (![metrics[key] boolValue])
            [filtered removeObjectForKey:key];
    
    return filtered.copy;
}

@end
