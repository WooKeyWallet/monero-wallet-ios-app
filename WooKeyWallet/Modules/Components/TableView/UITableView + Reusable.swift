
import UIKit

// MARK: Reusable support for UITableView

public extension UITableView {
  
  final func register<T>(cellType: T.Type)
    where T: Reusable {
      self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
  }

  
  final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
    where T: Reusable {
      guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
        fatalError(
          "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
            + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
            + "and that you registered the cell beforehand"
        )
      }
      return cell
  }

  
  final func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type)
    where T: Reusable {
      self.register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
  }

  final func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T?
    where T: Reusable {
      guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
        fatalError(
          "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
            + "matching type \(viewType.self). "
            + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
            + "and that you registered the header/footer beforehand"
        )
      }
      return view
  }
}
