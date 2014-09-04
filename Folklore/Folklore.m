//
// Folklore.m
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

#import "Folklore.h"
#import "FolkloreBuddyInformations.h"
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
    [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@pvp.net", username] resource:@"xiff"]];
    NSError *error = nil;
    
    if (![_stream oldSchoolSecureConnectWithTimeout:_connectionTimeout error:&error]) {
        if ([_delegate respondsToSelector:@selector(folkloreConnection:didFailWithError:)]) {
            [_delegate folkloreConnection:self didFailWithError:error];
        }
    }
}

- (void)disconnect {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    [_stream disconnectAfterSending];
}

- (void)sendMessage:(NSString *)message toBuddy:(FolkloreBuddy *)buddy {
    NSParameterAssert(message);
    NSParameterAssert(buddy);
    
    if ([message length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
		[body setStringValue:message];
        
		NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
		[messageElement addAttributeWithName:@"type" stringValue:@"chat"];
		[messageElement addAttributeWithName:@"to" stringValue:[buddy.JID full]];
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
                if ([_delegate respondsToSelector:@selector(folklore:didReceiveMessage:fromBuddy:)]) {
                    FolkloreBuddy *buddy = [self buddyWithXMPPUser:user];
                    [_delegate folklore:self didReceiveMessage:body fromBuddy:buddy];
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
    _rosterUsers = [sender sortedUsersByAvailabilityName];
    NSMutableArray *buddyList = [[NSMutableArray alloc] initWithCapacity:[_rosterUsers count]];
    
    for (id <XMPPUser> user in _rosterUsers) {
        [buddyList addObject:[self buddyWithXMPPUser:user]];
    }
    
    if ([_delegate respondsToSelector:@selector(folklore:didPopulateBuddyList:)]) {
        [_delegate folklore:self didPopulateBuddyList:buddyList];
    }
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    XMPPJID *myJID = [_stream myJID];
    if ([[user jid] isEqualToJID:myJID options:XMPPJIDCompareUser]) {
        if ([_delegate respondsToSelector:@selector(folklore:didUpdateSelf:)]) {
            [_delegate folklore:self didUpdateSelf:[self buddyWithXMPPUser:user]];
        }
    } else {
        [self notifyBuddyUpdateStatusWithUser:user resource:resource];
    }
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    [self notifyBuddyUpdateStatusWithUser:user resource:resource];
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    [self notifyBuddyUpdateStatusWithUser:user resource:resource];
}

- (void)notifyBuddyUpdateStatusWithUser:(XMPPUserMemoryStorageObject *)user resource:(XMPPResourceMemoryStorageObject *)resource {
    FolkloreBuddy *buddy = [self buddyWithXMPPUser:user];
    [buddy setStatus:FolkloreBuddyStatusWithString([[resource presence] show])];
    [buddy setBuddyInformations:[FolkloreBuddyInformations buddyInformationsWithPresence:[resource presence]]];

    if ([_delegate respondsToSelector:@selector(folklore:didUpdateBuddy:)]) {
        [_delegate folklore:self didUpdateBuddy:buddy];
    }
}


#pragma mark - Private Implementation

- (FolkloreBuddy *)buddyWithXMPPUser:(id <XMPPUser>)user {
    FolkloreBuddy *buddy = [[FolkloreBuddy alloc] initWithJID:user.jid];
    [buddy setName:user.nickname];
    [buddy setOnline:user.isOnline];
    return buddy;
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
