import UIKit
import Kingfisher

class MyBooksDetailViewController: UIViewController, UITextFieldDelegate {
    fileprivate var book: UserBook?
    fileprivate var isEditingPrice: Bool = false
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var setPriceButton: CustomButton!
    @IBOutlet weak var putOnSaleButton: CustomButton!
    @IBOutlet weak var deleteButton: CustomButton!
    
    func setContnet(_ book: UserBook) {
        self.book = book
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyBooksDetailViewController.myBooksSectionCacheItemsChanged(_:)), name: NSNotification.Name(rawValue: AppNotifications.MyBooksSectionCacheItemsChanged), object: nil)
        
        reloadBook()
    }
    
    func myBooksSectionCacheItemsChanged(_ notification: Notification) {
        reloadBook()
    }
    
    func reloadBook() {
        let foundBook = MyBooksCache.sharedInstance.books.filter { book in
            return book.id == self.book?.id
        }.first
        
        guard let book = foundBook else {
            return
        }
        
        self.book = book
        
        titleLabel.text = book.details.title
        authorLabel.text = book.details.authors.first?.name
        if !isEditingPrice {
            priceTextField.text = formatPrice(book.price)
        }
        if let coverImageUrl = URL(string: book.details.cover.large) {
            let placeholder = Image(named: "cover_placeholder")
            coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
        }
        updateActionButton(book.state)
        priceTextField.delegate = self
    }
    
    func formatPrice(_ price: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: Double(price)/100.0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        coverImage.kf.cancelDownloadTask()
    }
    
    func updateActionButton(_ bookState: State) {
        switch bookState {
        case .Idle:
            putOnSaleButton.isHidden = false
            putOnSaleButton.setTitle("Put on sale", for: UIControlState())
            deleteButton.isHidden = false
            deleteButton.setTitle("Delete", for: UIControlState())
        case .OnSale:
            putOnSaleButton.isHidden = false
            putOnSaleButton.setTitle("Remove from sale", for: UIControlState())
            deleteButton.isHidden = false
            deleteButton.setTitle("Delete", for: UIControlState())
        case .Requested:
            putOnSaleButton.isHidden = false
            putOnSaleButton.setTitle("Accept request", for: UIControlState())
            deleteButton.isHidden = false
            deleteButton.setTitle("Cancel request", for: UIControlState())
        case .Sold:
            putOnSaleButton.isHidden = true
            deleteButton.isHidden = false
            putOnSaleButton.setTitle("Delete", for: UIControlState())
        case .Trashed:
            putOnSaleButton.isHidden = true
            deleteButton.isHidden = true
        case .Accepted:
            putOnSaleButton.isHidden = true
            deleteButton.isHidden = true
        case .InTransfer:
            putOnSaleButton.isHidden = false
            putOnSaleButton.setTitle("Cancel transfer", for: UIControlState())
            deleteButton.isHidden = true
        case .MoneyTransferFail:
            putOnSaleButton.isHidden = false
            putOnSaleButton.setTitle("Put on sale", for: UIControlState())
            deleteButton.isHidden = true
        case .TransferCancelled:
            putOnSaleButton.isHidden = false
            putOnSaleButton.setTitle("Put on sale", for: UIControlState())
            deleteButton.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setPriceButton.isHidden = false
        isEditingPrice = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setPriceButton.isHidden = true
        guard let book = self.book else {
            return
        }
        priceTextField.text = formatPrice(book.price)
        isEditingPrice = false
    }
    
    @IBAction func setPriceButtonTapped(_ sender: AnyObject) {
        guard let newPriceString = priceTextField.text else {
            return
        }
        guard let newPriceEur = NumberFormatter().number(from: newPriceString)?.doubleValue else {
            return
        }
        let newPriceCents = Int(newPriceEur * 100)
        guard let book = self.book else {
            return
        }
        self.book = UserBook(id: book.id, state: book.state, price: newPriceCents, details: book.details)
        priceTextField.resignFirstResponder()
    }
    
    @IBAction func putOnSaleTapped(_ sender: AnyObject) {
        guard let book = book else {
            return
        }
        switch book.state {
        case .Idle:
            putBookOnSale()
        case .OnSale:
            removeBookFromSale()
        case .Requested:
            acceptRequest()
        case .Sold:
            break
        case .Accepted:
            break
        case .InTransfer:
            cancelTransfer()
        case .MoneyTransferFail:
            putBookOnSale()
        case .TransferCancelled:
            putBookOnSale()
        default:
            return
        }
    }
    
    @IBAction func deleteBookTapped(_ sender: AnyObject) {
        guard let book = book else {
            return
        }
        switch book.state {
        case .Idle:
            deleteBook()
        case .OnSale:
            deleteBook()
        case .Requested:
            cancelRequest()
            break
        case .Sold:
            deleteBook()
            break
        case .Accepted:
            break
        case .InTransfer:
            break
        case .MoneyTransferFail:
            break
        case .TransferCancelled:
            break
        default:
            return
        }
    }
    
    func putBookOnSale() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.putBookOnSale(book) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to put book on sale")
            }
        }
    }
    
    func removeBookFromSale() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.removeBookFromSale(book) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to remove book from sale")
            }
        }
    }
    
    func acceptRequest() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.acceptRequest(book) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to accept request")
            }
        }
    }
    
    func cancelRequest() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.cancelBookRequest(book) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to cancel request")
            }
        }
    }
    
    func cancelTransfer() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.cancelTransaction(book) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to cancel transfer")
            }
        }
    }
    
    func deleteBook() {
        guard let book = book else {
            return
        }
        SwapperApi.sharedInstance.deleteBook(book) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to delete book")
            }
        }
    }
}
