//
//  SKTrophyMetrics.h
//  Pods
//
//  Created by Tanner on 12/29/15.
//
//

#import <Foundation/Foundation.h>


/// The purpsoe of this class is to simplify the use of \c updateTrophiesWithMetrics:completion:
@interface SKTrophyMetrics : NSObject

@property (nonatomic) BOOL frontFacing;
@property (nonatomic) BOOL manyColors;
@property (nonatomic) BOOL video;
@property (nonatomic) BOOL postingNSnaps;
@property (nonatomic) BOOL oneFilter;
@property (nonatomic) BOOL twoFilters;
@property (nonatomic) BOOL fullZoom;
@property (nonatomic) BOOL coldFilter;
@property (nonatomic) BOOL hotFilter;
@property (nonatomic) BOOL blackAndWhite;
@property (nonatomic) BOOL nightMode;
@property (nonatomic) BOOL bigText;
@property (nonatomic) BOOL earlyMorning;
@property (nonatomic) BOOL frontFlash;

@property (nonatomic, readonly) NSDictionary *metrics;

@end
