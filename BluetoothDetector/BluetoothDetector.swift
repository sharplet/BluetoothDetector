//  Copyright (c) 2015 Outware. All rights reserved.

import CoreBluetooth
import Foundation
import ReactiveCocoa

// MARK: - Error type

public enum BluetoothError: Int, Printable, ErrorType {
  case Unsupported
  case Unauthorized

  public var description: String {
    switch self {
    case .Unsupported:
      return "Bluetooth Unsupported"
    case .Unauthorized:
      return "Bluetooth Unauthorized"
    }
  }

  public var nsError: NSError {
    return NSError(domain: "bluetooth", code: self.rawValue, userInfo: [
      NSLocalizedDescriptionKey: description
    ])
  }
}

// MARK: - Bluetooth signals

public func bluetoothPoweredOn() -> SignalProducer<Bool, BluetoothError> {
  let delegate = BluetoothDelegate()

  let poweredOn = delegate.stateProducer
    |> promoteErrors(BluetoothError.self)
    |> flatMap(.Concat) { state -> SignalProducer<Bool, BluetoothError> in
      switch state {
      case .Unsupported:
        return SignalProducer(error: .Unsupported)
      case .Unauthorized:
        return SignalProducer(error: .Unauthorized)
      case .PoweredOn:
        return SignalProducer(value: true)
      case .PoweredOff, .Unknown, .Resetting:
        return SignalProducer(value: false)
      }
    }

  return SignalProducer { sink, disposable in
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let central = CBCentralManager(delegate: delegate, queue: queue, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    disposable.addDisposable({ central; delegate })
    disposable.addDisposable(poweredOn.start(sink))
  }
}

// MARK: - Central manager delegate

private final class BluetoothDelegate: NSObject, CBCentralManagerDelegate {
  private let (stateProducer, stateSink) = SignalProducer<CBCentralManagerState, NoError>.buffer(1)

  @objc
  func centralManagerDidUpdateState(central: CBCentralManager!) {
    sendNext(stateSink, central.state)
  }
}
