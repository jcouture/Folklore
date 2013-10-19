//
// FolkloreBuddyInformations.h
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

#import <Foundation/Foundation.h>

@class FolkloreBuddy;

@interface FolkloreBuddyInformations : NSObject

- (instancetype)initWithBuddy:(FolkloreBuddy *)buddy;

@property (nonatomic, readonly) FolkloreBuddy *buddy;

@property (nonatomic, assign) NSInteger profileIcon;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger wins;
@property (nonatomic, assign) NSInteger leaves;
@property (nonatomic, assign) NSInteger odinWins;
@property (nonatomic, assign) NSInteger odinLeaves;
@property (nonatomic, assign) NSInteger rankedLosses;
@property (nonatomic, assign) NSInteger rankedRating;
@property (nonatomic) NSString *tier;
@property (nonatomic) NSString *skinname;
@property (nonatomic) NSString *gameQueueType;
@property (nonatomic) NSString *statusMessage;
@property (nonatomic) NSString *gameStatus;
@property (nonatomic) NSTimeInterval timeStamp;

@end
