//
// FolkloreBuddy.m
//
// Copyright (c) 2013 Jean-Philippe Couture
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

#import "FolkloreBuddy.h"
#import "FolkloreBuddyInformations.h"

NSString* StringWithFolkloreBuddyStatus(FolkloreBuddyStatus status) {
    switch (status) {
        case FolkloreBuddyStatusAvailable:
            return @"Available";
        case FolkloreBuddyStatusAway:
            return @"Away";
        case FolkloreBuddyStatusDoNotDisturb:
            return @"Do Not Disturb";
        case FolkloreBuddyStatusUnavailable:
            return @"Unavailable";
    }
}

FolkloreBuddyStatus FolkloreBuddyStatusWithString(NSString *statusString) {
    if ([[statusString lowercaseString] isEqualToString:@"chat"]) {
        return FolkloreBuddyStatusAvailable;
    } else if ([[statusString lowercaseString] isEqualToString:@"away"]) {
        return FolkloreBuddyStatusAway;
    } else if ([[statusString lowercaseString] isEqualToString:@"dnd"]) {
        return FolkloreBuddyStatusDoNotDisturb;
    }
    return FolkloreBuddyStatusUnavailable;
}

@implementation FolkloreBuddy

- (instancetype)initWithJID:(XMPPJID *)JID {
    if (self = [super init]) {
        NSParameterAssert(JID);
        _JID = JID;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *d = [[NSMutableString alloc] initWithString:@"\n-----\nBUDDY\n"];
    [d appendFormat:@"id: %@\n", [self.JID description]];
    [d appendFormat:@"name: %@\n", self.name];
    [d appendFormat:@"isOnline: %@\n", self.isOnline ? @"true" : @"false"];
    [d appendFormat:@"status: %@\n", StringWithFolkloreBuddyStatus(self.status)];
    [d appendFormat:@"%@\n", [self.buddyInformations description]];
    return d;
}

@end
