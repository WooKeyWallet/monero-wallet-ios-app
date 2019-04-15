
import UIKit

// MARK: Reusable support for UICollectionView

public extension UICollectionView {

  final func register<T: UICollectionViewCell>(cellType: T.Type)
    where T: Reusable {
      self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
  }

  final func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
    where T: Reusable {
      let bareCell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
      guard let cell = bareCell as? T else {
        fatalError(
          "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
            + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
            + "and that you registered the cell beforehand"
        )
      }
      return cell
  }
}
