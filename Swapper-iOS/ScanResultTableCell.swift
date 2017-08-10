import UIKit

class ScanResultTableCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    func setContent(_ book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.first?.name
    }
}
