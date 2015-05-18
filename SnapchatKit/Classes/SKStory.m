//
//  SKStory.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStory.h"

@implementation SKStory

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    NSDictionary *story = json[@"story"];
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
        _created          = [NSDate dateWithTimeIntervalSince1970:[story[@"timestamp"] doubleValue]];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ id=%@, viewed=%hhd, duration=%lu, text=%@, time left=%lu>",
            NSStringFromClass(self.class), self.identifier, self.viewed, (unsigned long)self.duration, self.text, (unsigned long)self.timeLeft];
}

@end
