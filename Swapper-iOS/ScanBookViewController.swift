import UIKit
import Kingfisher
import ZBarSDK

extension ZBarSymbolSet: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

class ScanBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ZBarReaderDelegate, AppleBarcodeScannerDelegate {
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var searchButton: CustomButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noMatchesOverlayView: UIView!
    var ZBarReader: ZBarReaderViewController?
    var appleReader: AppleBarcodeScannerViewController?
    
    var booksFound: [Book] = []
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        noMatchesOverlayView.isHidden = true
        isbnTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func scanTapped(_ sender: AnyObject) {
        isbnTextField.resignFirstResponder()
//        if ZBarReader == nil {
//            ZBarReader = ZBarReaderViewController()
//        }
//        self.ZBarReader?.readerDelegate = self
//        self.ZBarReader?.scanner.setSymbology(ZBAR_UPCA, config: ZBAR_CFG_ENABLE, to: 1)
//        self.ZBarReader?.readerView.zoom = 1.0
//        self.ZBarReader?.modalInPopover = false
//        self.ZBarReader?.showsZBarControls = false
//        navigationController?.pushViewController(self.ZBarReader!, animated:true)
        appleReader = AppleBarcodeScannerViewController()
        appleReader?.delegate = self
        navigationController?.pushViewController(self.appleReader!, animated:true)
    }
    
    func barcodeScanned(_ barcode: String) {
        isbnTextField.text = barcode as String
        searchButtonTapped(searchButton)
        isbnTextField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let results = info[ZBarReaderControllerResults] as? ZBarSymbolSet else {
            print("failed to get results")
            return
        }
        var symbolFound : ZBarSymbol?
        
        for symbol in results {
            symbolFound = symbol as? ZBarSymbol
            break
        }
        let resultString = NSString(string: symbolFound!.data)
        print(resultString)
        isbnTextField.text = resultString as String
        searchButtonTapped(searchButton)
        isbnTextField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        guard let isbn = isbnTextField.text else {
            return
        }
        isbnTextField.resignFirstResponder()
        self.booksFound = []
        tableView.reloadData()
        noMatchesOverlayView.isHidden = true
        SwapperApi.sharedInstance.getBook(isbn) { result in
            guard case .success(let data) = result else {
                self.noMatchesOverlayView.isHidden = false
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                self.noMatchesOverlayView.isHidden = false
                return
            }
            guard let bookJson = json as? [String: Any] else {
                self.noMatchesOverlayView.isHidden = false
                return
            }
            guard let book = Book.fromJson(bookJson) else {
                self.noMatchesOverlayView.isHidden = false
                return
            }
            self.booksFound.append(book)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanResultTableCell") as? ScanResultTableCell else {
            return UITableViewCell()
        }
        let bookIndex = indexPath.row
        guard booksFound.count > bookIndex else {
            return UITableViewCell()
        }
        let book = booksFound[bookIndex]
        cell.setContent(book)
        cell.coverImage.kf.indicatorType = .activity
        if let coverImageUrl = URL(string: book.cover.large) {
            let placeholder = Image(named: "cover_placeholder")
            cell.coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        return booksFound.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ScanResultTableCell else {
            return
        }
        cell.coverImage.kf.cancelDownloadTask()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        
        if let exploreBookDetailViewController = segue.destination as? AddScannedBookViewController {
            guard let selectedBookIndex = tableView.indexPathForSelectedRow?.row else {
                return
            }
            guard booksFound.count > selectedBookIndex else {
                return
            }
            let selectedBook = booksFound[selectedBookIndex]
            exploreBookDetailViewController.setContnet(selectedBook)
        }
        
    }
}
