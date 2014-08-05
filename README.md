# Folklore

League of Legends chat service library for iOS and OS X.

## Installation

Add the following to your [`Podfile`](http://docs.cocoapods.org/podfile.html)
and then run `pod install`

```ruby
pod 'Folklore'
```

Don't forget to `#import <Folklore/Folklore.h>`.

## Usage

### Establishing a connection

```objc
- (void)didTapConnectButton:(id)sender {
    _folklore = [[Folklore alloc] initWithServerRegion:LoLServerRegionNorthAmerica];
    [_folklore setDelegate:self];
    [_folklore connectWithUsername:@"jdoe"
                          password:@"secret123"];
}

#pragma mark - FolkloreDelegate Protocol

- (void)folkloreDidConnect:(Folklore *)folklore {
    NSLog(@"Connection successful");
}

- (void)folkloreConnection:(Folklore *)folklore didFailedWithError:(NSError *)error {
    NSLog(@"Connection failed with error: %@", error);
}
```

### Buddy list update

```objc
#pragma mark - FolkloreDelegate Protocol

- (void)folklore:(Folklore *)folklore didUpdatedBuddyList:(NSArray *)buddies {
    for (FolkloreBuddy *buddy in buddies) {
        NSLog(@"%@ is %@", buddy.name, (buddy.isOnline ? @"online" : @"offline"));
    }
}
```

### Sending and receiving messages

```objc
// `_buddies` is a NSArray of FolkloreBuddy objects, obtained during a buddy list update.
[_folklore sendMessage:@"Welcome to Summoner's Rift!" toBuddy:_buddies[index]];

#pragma mark - FolkloreDelegate Protocol

- (void)folklore:(Folklore *)folklore didReceivedMessage:(NSString *)message fromBuddy:(FolkloreBuddy *)buddy {
    NSLog(@"[%@] %@", buddy.name, message);
}
```

## Contact

 * [Jean-Philippe Couture](https://github.com/jcouture)
 * [@jcouture](https://twitter.com/jcouture)


## License

Folklore is available under the MIT license. See the LICENSE file for more info.

## Disclaimer

League of Legends content and materials are trademarks and copyrights of Riot Games or its licensors. All rights reserved.