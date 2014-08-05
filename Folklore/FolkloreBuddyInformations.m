//
// FolkloreBuddyInformations.m
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

#import "FolkloreBuddyInformations.h"
#import <XMPPFramework/XMPPUser.h>

@implementation FolkloreBuddyInformations

+ (FolkloreBuddyInformations *)buddyInformationsWithPresence:(XMPPPresence *)presence {
    FolkloreBuddyInformations *buddyInformations = nil;
    NSString *status = [presence status];
    if ([status length] > 0) {
        NSString *sanitizedStatus = [status stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSXMLElement *statusElement = [[NSXMLElement alloc] initWithXMLString:sanitizedStatus error:nil];
        buddyInformations = [FolkloreBuddyInformations new];
        [buddyInformations setProfileIcon:[[statusElement elementForName:@"profileIcon"] stringValueAsNSInteger]];
        [buddyInformations setLevel:[[statusElement elementForName:@"level"] stringValueAsNSInteger]];
        [buddyInformations setWins:[[statusElement elementForName:@"wins"] stringValueAsNSInteger]];
        [buddyInformations setLeaves:[[statusElement elementForName:@"leaves"] stringValueAsNSInteger]];
        [buddyInformations setOdinWins:[[statusElement elementForName:@"odinWins"] stringValueAsNSInteger]];
        [buddyInformations setOdinLeaves:[[statusElement elementForName:@"odinLeaves"] stringValueAsNSInteger]];
        [buddyInformations setTier:[[statusElement elementForName:@"tier"] stringValue]];
        [buddyInformations setStatusMessage:[[statusElement elementForName:@"statusMsg"] stringValue]];
        [buddyInformations setGameStatus:[[statusElement elementForName:@"gameStatus"] stringValue]];
        [buddyInformations setRankedWins:[[statusElement elementForName:@"rankedWins"] stringValueAsNSInteger]];
        [buddyInformations setRankedLosses:[[statusElement elementForName:@"rankedLosses"] stringValueAsNSInteger]];
        [buddyInformations setRankedRating:[[statusElement elementForName:@"rankedRating"] stringValueAsNSInteger]];
        [buddyInformations setRankedLeagueName:[[statusElement elementForName:@"rankedLeagueName"] stringValue]];
        [buddyInformations setRankedLeagueDivision:[[statusElement elementForName:@"rankedLeagueDivision"] stringValue]];
        [buddyInformations setRankedLeagueTier:[[statusElement elementForName:@"rankedLeagueTier"] stringValue]];
        [buddyInformations setRankedLeagueQueue:[[statusElement elementForName:@"rankedLeagueQueue"] stringValue]];
    }
    return buddyInformations;
}

- (NSString *)description {
    NSMutableString *d = [[NSMutableString alloc] initWithString:@"\n-----\nBUDDY INFORMATIONS\n"];
    [d appendFormat:@"profileIcon: %i\n", self.profileIcon];
    [d appendFormat:@"level: %i\n", self.level];
    [d appendFormat:@"wins: %i\n", self.wins];
    [d appendFormat:@"leaves: %i\n", self.leaves];
    [d appendFormat:@"odinWins: %i\n", self.odinWins];
    [d appendFormat:@"odinLeaves: %i\n", self.odinLeaves];
    [d appendFormat:@"tier: %@\n", self.tier];
    [d appendFormat:@"statusMessage: %@\n", self.statusMessage];
    [d appendFormat:@"gameStatus: %@\n", self.gameStatus];
    [d appendFormat:@"rankedLeagueName: %@\n", self.rankedLeagueName];
    [d appendFormat:@"rankedLeagueDivision: %@\n", self.rankedLeagueDivision];
    [d appendFormat:@"rankedLeagueTier: %@\n", self.rankedLeagueTier];
    [d appendFormat:@"rankedLeagueQueue: %@\n", self.rankedLeagueQueue];
    [d appendFormat:@"rankedWins: %i\n", self.rankedWins];
    [d appendFormat:@"rankedLosses: %i\n", self.rankedLosses];
    [d appendFormat:@"rankedRating: %i\n", self.rankedRating];
    return d;
}

@end
