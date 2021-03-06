//
// Folklore.m
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

#import "Folklore.h"
#import "FolkloreFriendInformation.h"
#import <XMPPFramework/XMPPFramework.h>
#import <XMPPFramework/XMPPReconnect.h>
#import <XMPPFramework/XMPPRoster.h>
#import <XMPPFramework/XMPPRosterMemoryStorage.h>
#import <XMPPFramework/XMPPUser.h>
#import <XMPPFramework/XMPPLogging.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <XMPPFramework/XMPPJID.h>

NSTimeInterval const FolkloreDefaultConnectionTimeoutInterval = 30;

@interface Folklore ()
@property (nonatomic) NSTimeInterval connectionTimeout;
@property (nonatomic) XMPPStream *stream;
@property (nonatomic) NSString *password;
@property (nonatomic) NSArray *rosterUsers;
@property (nonatomic) dispatch_queue_t friendsQueue;
@end

@implementation Folklore

- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion {
    return [self initWithServerRegion:serverRegion withConnectionTimeout:FolkloreDefaultConnectionTimeoutInterval withConsoleDebugOutput:NO];
}

- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion withConnectionTimeout:(NSTimeInterval)connectionTimeout {
    return [self initWithServerRegion:serverRegion withConnectionTimeout:connectionTimeout withConsoleDebugOutput:NO];
}

- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion withConsoleDebugOutput:(BOOL)consoleDebugOutput {
    return [self initWithServerRegion:serverRegion withConnectionTimeout:FolkloreDefaultConnectionTimeoutInterval withConsoleDebugOutput:consoleDebugOutput];
}

- (instancetype)initWithServerRegion:(LoLServerRegion)serverRegion withConnectionTimeout:(NSTimeInterval)connectionTimeout withConsoleDebugOutput:(BOOL)consoleDebugOutput {
    if (self = [super init]) {
        _friendsQueue = dispatch_queue_create("com.Folklore.FriendsQueue", NULL);
        NSString *hostname = [self hostnameForServerRegion:serverRegion];
        
        _connectionTimeout = connectionTimeout;
        
        if (consoleDebugOutput) {
            [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
        }
        
        //* Setup the XMPPStream
        _stream = [[XMPPStream alloc] init];
        [_stream setHostName:hostname];
        [_stream setHostPort:5223];
        [_stream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        XMPPReconnect *reconnect = [[XMPPReconnect alloc] init];
        [reconnect activate:_stream];
        
        XMPPRosterMemoryStorage *rosterStorage = [[XMPPRosterMemoryStorage alloc] init];
        
        XMPPRoster *roster = [[XMPPRoster alloc] initWithRosterStorage:rosterStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [roster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [roster activate:_stream];
        [roster setAutoFetchRoster:YES];
    }
    
    return self;
}

- (void)connectWithUsername:(NSString *)username password:(NSString *)password {
    NSParameterAssert(username);
    NSParameterAssert(password);
    
    _password = password;
    
    //* League of Legends' specific jid format
    [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@pvp.net", username] resource:@"folklore"]];
    NSError *error = nil;
    
    if ([_stream isConnected]) {
        [self xmppStreamDidConnect:nil];
    } else {
        if (![_stream oldSchoolSecureConnectWithTimeout:_connectionTimeout error:&error]) {
            if ([_delegate respondsToSelector:@selector(folkloreConnection:didFailWithError:)]) {
                [_delegate folkloreConnection:self didFailWithError:error];
            }
        }
    }
}

- (void)disconnect {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    [_stream disconnectAfterSending];
}

- (void)sendMessage:(NSString *)message toFriend:(FolkloreFriend *)friend {
    NSParameterAssert(message);
    NSParameterAssert(friend);
    
    if ([message length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
		[body setStringValue:message];
        
		NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
		[messageElement addAttributeWithName:@"type" stringValue:@"chat"];
		[messageElement addAttributeWithName:@"to" stringValue:[friend.JID full]];
		[messageElement addChild:body];
        
		[_stream sendElement:messageElement];
    }
}


#pragma mark - XMPPStreamDelegate Protocol

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    if (![_stream authenticateWithPassword:[NSString stringWithFormat:@"AIR_%@", _password] error:&error]) {
        if ([_delegate respondsToSelector:@selector(folkloreConnection:didFailWithError:)]) {
            [_delegate folkloreConnection:self didFailWithError:error];
        }
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    //* The password is no longer needed
    _password = nil;
    
    if ([_delegate respondsToSelector:@selector(folkloreDidConnect:)]) {
        [_delegate folkloreDidConnect:self];
    }
    
    [_stream sendElement:[XMPPPresence presence]];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSString *message = @"Connection not authorized.";
    NSError *err = [NSError errorWithDomain:FolkloreErrorDomain code:FolkloreNotAuthorized userInfo:@{NSLocalizedDescriptionKey: message}];
    if ([_delegate respondsToSelector:@selector(folkloreConnection:didFailWithError:)]) {
        [_delegate folkloreConnection:self didFailWithError:err];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
		NSString *body = [[message elementForName:@"body"] stringValue];
        for (id <XMPPUser> user in _rosterUsers) {
            if ([[user jid] isEqualToJID:[message from] options:XMPPJIDCompareUser]) {
                if ([_delegate respondsToSelector:@selector(folklore:didReceiveMessage:fromFriend:)]) {
                    FolkloreFriend *friend = [self folkloreFriendWithXMPPUser:user];
                    [_delegate folklore:self didReceiveMessage:body fromFriend:friend];
                }
            }
        }
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    if ([_delegate respondsToSelector:@selector(folkloreConnectionDidTimeout:)]) {
        [_delegate folkloreConnectionDidTimeout:self];
    }
}


#pragma mark - XMPPRosterMemoryStorageDelegate Protocol

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    dispatch_async(_friendsQueue, ^{
        _rosterUsers = [sender sortedUsersByName];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:[_rosterUsers count]];
        
        for (id <XMPPUser> user in _rosterUsers) {
            [friends addObject:[self folkloreFriendWithXMPPUser:user]];
        }
        
        if ([_delegate respondsToSelector:@selector(folklore:didReceiveFriends:)]) {
            [_delegate folklore:self didReceiveFriends:friends];
        }
    });
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    dispatch_async(_friendsQueue, ^{
        XMPPJID *myJID = [_stream myJID];
        if ([[user jid] isEqualToJID:myJID options:XMPPJIDCompareUser]) {
            if ([_delegate respondsToSelector:@selector(folklore:didReceiveSelfUpdate:)]) {
                [_delegate folklore:self didReceiveSelfUpdate:[self folkloreFriendWithXMPPUser:user]];
            }
        } else {
            [self notifyFriendUpdateStatusWithUser:user resource:resource];
        }
    });
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    [self notifyFriendUpdateStatusWithUser:user resource:resource];
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    [self notifyFriendUpdateStatusWithUser:user resource:resource];
}

- (void)notifyFriendUpdateStatusWithUser:(XMPPUserMemoryStorageObject *)user resource:(XMPPResourceMemoryStorageObject *)resource {
    dispatch_async(_friendsQueue, ^{
        FolkloreFriend *friend = [self folkloreFriendWithXMPPUser:user];
        [friend setFriendInformation:[FolkloreFriendInformation friendInformationWithPresence:[resource presence]]];
        [friend setStatus:FolkloreFriendStatusWithString([[resource presence] show], friend.friendInformation.gameStatus)];
        if (!user.isOnline) {
            [friend setStatus:FolkloreFriendStatusUnavailable];
        }
        
        if ([_delegate respondsToSelector:@selector(folklore:didReceiveFriendUpdate:)]) {
            [_delegate folklore:self didReceiveFriendUpdate:friend];
        }
    });
}


#pragma mark - Private Implementation

- (FolkloreFriend *)folkloreFriendWithXMPPUser:(id <XMPPUser>)user {
    FolkloreFriend *friend = [[FolkloreFriend alloc] initWithJID:[user jid]];
    [friend setName:[user nickname]];
    return friend;
}

- (NSString *)hostnameForServerRegion:(LoLServerRegion)serverRegion {
    NSString *hostname = nil;
    
    switch (serverRegion) {
        case LoLServerRegionNorthAmerica:
            hostname = @"chat.na1.lol.riotgames.com";
            break;
        case LoLServerRegionEuropeWest:
            hostname = @"chat.euw1.lol.riotgames.com";
            break;
        case LoLServerRegionNordicEast:
            hostname = @"chat.eun1.lol.riotgames.com";
            break;
        case LoLServerRegionKorean:
            hostname = @"chat.kr.lol.riotgames.com";
            break;
        case LoLServerRegionBrazil:
            hostname = @"chat.br.lol.riotgames.com";
            break;
        case LoLServerRegionTurkey:
            hostname = @"chat.tr.lol.riotgames.com";
            break;
        case LoLServerRegionRussia:
            hostname = @"chat.ru.lol.riotgames.com";
            break;
        case LoLServerRegionLatinNorth:
            hostname = @"chat.la1.lol.riotgames.com";
            break;
        case LoLServerRegionLatinSouth:
            hostname = @"chat.la2.lol.riotgames.com";
            break;
        case LoLServerRegionOceanic:
            hostname = @"chat.oc1.lol.riotgames.com";
            break;
        case LoLServerRegionPublicBeta:
            hostname = @"chat.pbe1.lol.riotgames.com";
            break;
        case LoLServerRegionTaiwan:
            hostname = @"chattw.lol.garenanow.com";
            break;
        case LoLServerRegionThailand:
            hostname = @"chatth.lol.garenanow.com";
            break;
        case LoLServerRegionPhilippines:
            hostname = @"chatph.lol.garenanow.com";
            break;
        case LoLServerRegionVietnam:
            hostname = @"chatvn.lol.garenanow.com";
            break;
        default:
            break;
    }
    
    return hostname;
}

@end
