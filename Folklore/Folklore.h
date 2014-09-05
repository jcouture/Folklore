//
// Folklore.h
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
#import "FolkloreFriend.h"
#import "FolkloreFriendInformation.h"

typedef NS_ENUM(NSInteger, LoLServerRegion) {
    LoLServerRegionNorthAmerica,
    LoLServerRegionEuropeWest,
    LoLServerRegionNordicEast,
    LoLServerRegionTaiwan,
    LoLServerRegionThailand,
    LoLServerRegionPhilippines,
    LoLServerRegionVietnam,
    LoLServerRegionKorean,
    LoLServerRegionBrazil,
    LoLServerRegionTurkey,
    LoLServerRegionRussia,
    LoLServerRegionLatinNorth,
    LoLServerRegionLatinSouth,
    LoLServerRegionOceanic,
    LoLServerRegionPublicBeta
};

static NSString *const FolkloreErrorDomain = @"FolkloreErrorDomain";

typedef NS_ENUM(NSInteger, FolkloreErrorCode) {
    FolkloreNotAuthorized
};

@class FolkloreFriendInformation;
@protocol FolkloreDelegate;

@interface Folklore : NSObject
@property (nonatomic, weak) id <FolkloreDelegate> delegate;
- (id)init __attribute__((unavailable));
- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion;
- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion withConnectionTimeout:(NSTimeInterval)connectionTimeout;
- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion withConsoleDebugOutput:(BOOL)consoleDebugOutput;
- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion withConnectionTimeout:(NSTimeInterval)connectionTimeout withConsoleDebugOutput:(BOOL)consoleDebugOutput;
- (void)connectWithUsername:(NSString *)username password:(NSString *)password;
- (void)disconnect;
- (void)sendMessage:(NSString *)message toFriend:(FolkloreFriend *)friend;
@end


@protocol FolkloreDelegate <NSObject>
@optional
- (void)folkloreDidConnect:(Folklore *)folklore;
- (void)folkloreConnection:(Folklore *)folklore didFailWithError:(NSError *)error;
- (void)folkloreConnectionDidTimeout:(Folklore *)folklore;
- (void)folklore:(Folklore *)folklore didReceiveMessage:(NSString *)message fromFriend:(FolkloreFriend *)friend;
- (void)folklore:(Folklore *)folklore didReceiveFriends:(NSArray *)friends;
- (void)folklore:(Folklore *)folklore didReceiveFriendUpdate:(FolkloreFriend *)friend;
- (void)folklore:(Folklore *)folklore didReceiveSelfUpdate:(FolkloreFriend *)friend;
@end
