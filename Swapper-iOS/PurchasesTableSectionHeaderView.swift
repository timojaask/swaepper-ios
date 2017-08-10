import UIKit

class PurchasesTableSectionHeaderView: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setContent(_ title: String) {
        titleLabel.text = title
    }
}
