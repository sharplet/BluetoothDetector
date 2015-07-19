//  Copyright (c) 2015 Outware. All rights reserved.

#import "BluetoothDetector.h"

// clang-format off

@implementation BluetoothDetector

+ (RACSignal *)bluetoothState {
  dispatch_queue_t centralq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  RACScheduler *scheduler = [[RACTargetQueueScheduler alloc] initWithName:@"bluetooth central state signal" targetQueue:centralq];

  id delegate = [NSObject new];

  RACSignal *state = [[[delegate
    rac_signalForSelector:@selector(centralManagerDidUpdateState:) fromProtocol:@protocol(CBCentralManagerDelegate)]
    reduceEach:^(CBCentralManager *manager) {
      return @(manager.state);
    }]
    deliverOn:scheduler];

  CBCentralManager *manager = [[CBCentralManager alloc] initWithDelegate:delegate queue:centralq];

  RACSubject *subject = [RACReplaySubject replaySubjectWithCapacity:1];
  RACMulticastConnection *connection = [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
    return [RACCompoundDisposable compoundDisposableWithDisposables:@[
      [state subscribe:subscriber],
      [RACDisposable disposableWithBlock:^{
        (void)manager; // maintain a strong reference to the manager until disposal
      }]
    ]];
  }] multicast:subject];

  return [connection autoconnect];
}

@end
