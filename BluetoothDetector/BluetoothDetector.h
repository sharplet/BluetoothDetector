//  Copyright (c) 2015 Outware. All rights reserved.

@import CoreBluetooth;
@import Foundation;
@import ReactiveCocoa;

@interface BluetoothDetector : NSObject

+ (RACSignal *)bluetoothState;

@end
