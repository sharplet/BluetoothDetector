//  Copyright (c) 2015 Outware. All rights reserved.

import ReactiveCocoa
import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var bluetoothLabel: UILabel?

  var bluetoothText: DynamicProperty {
    return DynamicProperty(object: bluetoothLabel, keyPath: "text")
  }

  var bluetoothStatus: SignalProducer<AnyObject?, NoError> {
    return bluetoothPoweredOn()
      .map {
        return "Bluetooth " + ($0 ? "Powered On" : "Powered Off")
      }
      .flatMapError { error in
        return SignalProducer(value: "<error: \(error.description)>")
      }
      .observeOn(UIScheduler())
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    bluetoothText <~ bluetoothStatus
  }
}
