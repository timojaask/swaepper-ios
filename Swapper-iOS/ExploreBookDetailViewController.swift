import UIKit
import Kingfisher

class ExploreBookDetailViewController: UIViewController {
    fileprivate var book: UserBook?
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var purchaseButton: CustomButton!
    
    func setContnet(_ book: UserBook) {
        self.book = book
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let book = self.book {
            titleLabel.text = book.details.title
            authorLabel.text = book.details.authors.first?.name
            priceLabel.text = "\(Double(book.price)/100.0) €"
            if let coverImageUrl = URL(string: book.details.cover.large) {
                let placeholder = Image(named: "cover_placeholder")
                coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
            }
        }
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        sendRequest()
    }
    
    func sendRequest() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.sendBookRequest(book) { result in
            guard case .success = result else {
                debugPrint("Error: failed to send book request")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coverImage.kf.cancelDownloadTask()
    }
}
