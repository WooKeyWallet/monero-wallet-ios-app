
import UIKit

// MARK: Protocol definition

public protocol Reusable: class {
  static var reuseIdentifier: String { get }
}



public extension Reusable {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}
