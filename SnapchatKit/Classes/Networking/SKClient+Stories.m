//
//  SKClient+Stories.m
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Stories.h"
#import "SKStory.h"
#import "SKBlob.h"

@implementation SKClient (Stories)

- (void)loadStory:(SKStory *)story completion:(ResponseBlock)completion {
    [self get:[NSString stringWithFormat:@"%@%@", kepGetStoryBlob, story.mediaIdentifier] callback:^(NSData *data, NSError *error) {
        if (!error) {
            [SKBlob blobWithStoryData:data forStory:story completion:^(SKBlob *storyBlob, NSError *blobError) {
                if (!blobError) {
                    completion(storyBlob, nil);
                } else {
                    completion(nil, blobError);
                }
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)loadStories:(NSArray *)stories completion:(ArrayBlock)completion {
    
}

@end