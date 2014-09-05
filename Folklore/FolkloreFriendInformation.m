//
// FolkloreFriendInformation.m
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

#import "FolkloreFriendInformation.h"
#import <XMPPFramework/XMPPUser.h>

@implementation FolkloreFriendInformation

+ (FolkloreFriendInformation *)friendInformationWithPresence:(XMPPPresence *)presence {
    FolkloreFriendInformation *friendInformation = nil;
    NSString *status = [presence status];
    if ([status length] > 0) {
        NSString *sanitizedStatus = [status stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSXMLElement *statusElement = [[NSXMLElement alloc] initWithXMLString:sanitizedStatus error:nil];
        friendInformation = [FolkloreFriendInformation new];
        [friendInformation setProfileIcon:[[statusElement elementForName:@"profileIcon"] stringValueAsNSInteger]];
        [friendInformation setLevel:[[statusElement elementForName:@"level"] stringValueAsNSInteger]];
        [friendInformation setWins:[[statusElement elementForName:@"wins"] stringValueAsNSInteger]];
        [friendInformation setLeaves:[[statusElement elementForName:@"leaves"] stringValueAsNSInteger]];
        [friendInformation setOdinWins:[[statusElement elementForName:@"odinWins"] stringValueAsNSInteger]];
        [friendInformation setOdinLeaves:[[statusElement elementForName:@"odinLeaves"] stringValueAsNSInteger]];
        [friendInformation setTier:[[statusElement elementForName:@"tier"] stringValue]];
        [friendInformation setStatusMessage:[[statusElement elementForName:@"statusMsg"] stringValue]];
        [friendInformation setGameStatus:[[statusElement elementForName:@"gameStatus"] stringValue]];
        [friendInformation setRankedWins:[[statusElement elementForName:@"rankedWins"] stringValueAsNSInteger]];
        [friendInformation setRankedLosses:[[statusElement elementForName:@"rankedLosses"] stringValueAsNSInteger]];
        [friendInformation setRankedRating:[[statusElement elementForName:@"rankedRating"] stringValueAsNSInteger]];
        [friendInformation setRankedLeagueName:[[statusElement elementForName:@"rankedLeagueName"] stringValue]];
        [friendInformation setRankedLeagueDivision:[[statusElement elementForName:@"rankedLeagueDivision"] stringValue]];
        [friendInformation setRankedLeagueTier:[[statusElement elementForName:@"rankedLeagueTier"] stringValue]];
        [friendInformation setRankedLeagueQueue:[[statusElement elementForName:@"rankedLeagueQueue"] stringValue]];
    }
    return friendInformation;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.profileIcon=%ld", (long)self.profileIcon];
    [description appendFormat:@", self.level=%ld", (long)self.level];
    [description appendFormat:@", self.wins=%ld", (long)self.wins];
    [description appendFormat:@", self.leaves=%ld", (long)self.leaves];
    [description appendFormat:@", self.odinWins=%ld", (long)self.odinWins];
    [description appendFormat:@", self.odinLeaves=%ld", (long)self.odinLeaves];
    [description appendFormat:@", self.tier=%@", self.tier];
    [description appendFormat:@", self.statusMessage=%@", self.statusMessage];
    [description appendFormat:@", self.gameStatus=%@", self.gameStatus];
    [description appendFormat:@", self.rankedLeagueName=%@", self.rankedLeagueName];
    [description appendFormat:@", self.rankedLeagueDivision=%@", self.rankedLeagueDivision];
    [description appendFormat:@", self.rankedLeagueTier=%@", self.rankedLeagueTier];
    [description appendFormat:@", self.rankedLeagueQueue=%@", self.rankedLeagueQueue];
    [description appendFormat:@", self.rankedWins=%ld", (long)self.rankedWins];
    [description appendFormat:@", self.rankedLosses=%ld", (long)self.rankedLosses];
    [description appendFormat:@", self.rankedRating=%ld", (long)self.rankedRating];
    [description appendString:@">"];
    return description;
}

@end
