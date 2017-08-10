import UIKit

class MyBooksTableCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setContent(_ book: UserBook) {
        titleLabel.text = book.details.title
        authorLabel.text = book.details.authors.first?.name
        priceLabel.text = "\(Double(book.price)/100.0) €"
        statusLabel.text = book.state.humanReadableString.uppercased()
    }
}
