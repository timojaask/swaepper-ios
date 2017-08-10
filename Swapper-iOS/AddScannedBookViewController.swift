import UIKit
import Kingfisher

class AddScannedBookViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var addButton: CustomButton!
    
    fileprivate var book: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let book = self.book else {
            return
        }
        titleLabel.text = book.title
        authorLabel.text = book.authors.first?.name
        guard let coverImageUrl = URL(string: book.cover.large) else {
            return
        }
        let placeholder = Image(named: "cover_placeholder")
        coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        coverImage.kf.cancelDownloadTask()
        super.viewWillDisappear(animated)
    }
    
    func setContnet(_ book: Book) {
        self.book = book
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        guard let book = self.book else {
            return
        }
        SwapperApi.sharedInstance.addBook(book.id) { result in
            guard case .success = result else {
                debugPrint("Error: unable to add book")
                return
            }
            MyBooksCache.sharedInstance.update()
            ExploreBooksCache.sharedInstance.update()
            
            // TODO: Make the navigation logic so that this view controller wouldn't be accessing parent.
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
}
