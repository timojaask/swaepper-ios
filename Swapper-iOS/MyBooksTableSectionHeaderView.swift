import UIKit

class MyBooksTableSectionHeaderView: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setContent(_ title: String) {
        titleLabel.text = title
    }
}
