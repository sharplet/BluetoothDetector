//  Copyright (c) 2015 Outware. All rights reserved.

#import "AppDelegate.h"
#import "BluetoothDetector.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  RACSignal *bluetoothState = [[BluetoothDetector bluetoothState] timeout:10 onScheduler:RACScheduler.mainThreadScheduler];

  [[bluetoothState map:^(NSNumber *state) {
    switch ((CBCentralManagerState)state.integerValue) {
    case CBCentralManagerStatePoweredOff:
      return @"Powered Off";
    case CBCentralManagerStatePoweredOn:
      return @"Powered On";
    case CBCentralManagerStateResetting:
      return @"Resetting";
    case CBCentralManagerStateUnauthorized:
      return @"Unauthorized";
    case CBCentralManagerStateUnknown:
      return @"Unknown";
    case CBCentralManagerStateUnsupported:
      return @"Unsupported";
    }
  }] subscribeNext:^(NSString *stateDescription) {
    NSLog(@"#1: bluetooth state: %@", stateDescription);
  }];

  [bluetoothState subscribeNext:^(id _) {
    NSLog(@"#2: something happened!");
  }];

  return NO;
}

@end
