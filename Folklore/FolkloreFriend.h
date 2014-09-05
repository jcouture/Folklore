//
// FolkloreFriend.h
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

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPJID.h>

typedef NS_ENUM(NSInteger, FolkloreFriendStatus) {
    FolkloreFriendStatusAvailable,
    FolkloreFriendStatusAway,
    FolkloreFriendStatusDoNotDisturb,
    FolkloreFriendStatusUnavailable
};

extern NSString* StringWithFolkloreFriendStatus(FolkloreFriendStatus status);
extern FolkloreFriendStatus FolkloreFriendStatusWithString(NSString *statusString);

@class FolkloreFriendInformation;

@interface FolkloreFriend : NSObject

@property (nonatomic, readonly) XMPPJID *JID;
@property (nonatomic) NSString *name;
@property (nonatomic, getter = isOnline) BOOL online;
@property (nonatomic) FolkloreFriendStatus status;
@property (nonatomic) FolkloreFriendInformation *friendInformation;

- (id)init __attribute__((unavailable));
- (instancetype)initWithJID:(XMPPJID *)JID;

@end
