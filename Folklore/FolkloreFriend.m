//
// FolkloreFriend.m
//
// Copyright (c) 2014 Jean-Philippe Couture
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FolkloreFriend.h"
#import "FolkloreFriendInformation.h"

NSString* StringWithFolkloreFriendStatus(FolkloreFriendStatus status) {
    switch (status) {
        case FolkloreFriendStatusUnavailable:
            return @"unavailable";
        case FolkloreFriendStatusAvailable:
            return @"available";
        case FolkloreFriendStatusAway:
            return @"away";
        case FolkloreFriendStatusInQueue:
            return @"in queue";
        case FolkloreFriendStatusInChampionSelect:
            return @"in champion select";
        case FolkloreFriendStatusInGame:
            return @"in game";
    }
}

FolkloreFriendStatus FolkloreFriendStatusWithString(NSString *statusString, NSString *gameStatus) {
    if ([[statusString lowercaseString] isEqualToString:@"chat"]) {
        return FolkloreFriendStatusAvailable;
    } else if ([[statusString lowercaseString] isEqualToString:@"away"]) {
        return FolkloreFriendStatusAway;
    } else if ([[statusString lowercaseString] isEqualToString:@"dnd"]) {
        if ([[gameStatus lowercaseString] isEqualToString:@"inqueue"]) {
            return FolkloreFriendStatusInQueue;
        } else if ([[gameStatus lowercaseString] isEqualToString:@"championselect"]) {
            return FolkloreFriendStatusInChampionSelect;
        } else if ([[gameStatus lowercaseString] isEqualToString:@"ingame"]) {
            return FolkloreFriendStatusInGame;
        }
    }
    return FolkloreFriendStatusUnavailable;
}

@implementation FolkloreFriend

- (instancetype)initWithJID:(XMPPJID *)JID {
    if (self = [super init]) {
        NSParameterAssert(JID);
        _JID = JID;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.JID=%@", self.JID];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.friendInformation=%@", self.friendInformation];
    [description appendFormat:@", self.status=%@", StringWithFolkloreFriendStatus(self.status)];
    [description appendString:@">"];

    return description;
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![[other class] isEqual:[self class]]) return NO;

    return [self isEqualToFolkloreFriend:other];
}

- (BOOL)isEqualToFolkloreFriend:(FolkloreFriend *)friend {
    if (self == friend) return YES;
    if (nil == friend) return NO;
    if (self.JID != friend.JID && ![self.JID isEqualToJID:friend.JID]) return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.JID hash];
}

@end
