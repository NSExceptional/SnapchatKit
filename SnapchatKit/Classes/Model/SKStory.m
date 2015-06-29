//
//  SKStory.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStory.h"
#import "SKClient+Stories.h"

@implementation SKStory

- (id)initWithDictionary:(NSDictionary *)json {
    NSDictionary *story = json[@"story"];
    // I merge the "story" key dictionary with the rest of
    // the JSON so that unknownJSONKeys is more thorough.
    if (kDebugJSON) {
        NSMutableDictionary *fullJSON = json.mutableCopy;
        [fullJSON addEntriesFromDictionary:story];
        fullJSON[@"story"] = @{};
        json = fullJSON;
    }
    
    self = [super initWithDictionary:json];
    if (self) {
        _viewed           = [json[@"viewed"] boolValue];
        _shared           = [story[@"is_shared"] boolValue];
        _zipped           = [story[@"zipped"] boolValue];
        _matureContent    = [story[@"mature_content"] boolValue];
        _needsAuth        = [story[@"needs_auth"] boolValue];

        _duration         = [story[@"time"] integerValue];

        _identifier       = story[@"id"];
        _text             = story[@"caption_text_display"];
        _clientIdentifier = story[@"client_id"];

        _mediaIdentifier  = story[@"media_id"];
        _mediaIV          = story[@"media_iv"];
        _mediaKey         = story[@"media_key"];
        _mediaKind        = [story[@"media_type"] integerValue];
        _mediaURL         = [NSURL URLWithString:story[@"media_url"]];

        _thumbIV          = story[@"thumbnail_iv"];
        _thumbURL         = [NSURL URLWithString:story[@"thumbnail_url"]];

        _timeLeft         = [story[@"time_left"] integerValue];
        _created          = [NSDate dateWithTimeIntervalSince1970:[story[@"timestamp"] doubleValue]/1000];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"story", @"viewed", @"is_shared", @"zipped", @"mature_content", @"needs_auth", @"time",
                                              @"id", @"caption_text_display", @"client_id", @"media_id", @"media_iv", @"media_type",
                                              @"media_url", @"thumbnail_iv", @"thumbnail_url", @"time_left", @"timestamp"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ id=%@, viewed=%hhd, duration=%lu, text=%@, time left=%lu>",
            NSStringFromClass(self.class), self.identifier, self.viewed, (unsigned long)self.duration, self.text, (unsigned long)self.timeLeft];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKStory class]])
        return [self isEqualToStory:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToStory:(SKStory *)story {
    return [story.identifier isEqualToString:self.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

@end

@implementation SKStory (SKClient)

- (void)load:(ErrorBlock)completion {
    NSParameterAssert(completion);
    [[SKClient sharedClient] loadStoryBlob:self completion:^(SKBlob *blob, NSError *error) {
        if (!error) {
            _blob = blob;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (void)loadThumbnail:(ErrorBlock)completion {
    NSParameterAssert(completion);
    [[SKClient sharedClient] loadStoryThumbnailBlob:self completion:^(SKBlob *blob, NSError *error) {
        if (!error) {
            _thumbnailBlob = blob;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (NSString *)suggestedFilename {
    if (!self.blob)
        return nil;
    if (self.blob.isImage)
        return [NSString stringWithFormat:@"%@.jpg", self.identifier];
    else if (self.blob.overlay)
        return self.identifier;
    else
        return [NSString stringWithFormat:@"%@.mp4", self.identifier];
}

@end