import UIKit
import Kingfisher

class PurchasesViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PurchasesViewController.bookRequested(_:)), name: NSNotification.Name(rawValue: "bookRequested"), object: nil)
//        tableView.delegate = self
//        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(PurchasesViewController.bookRequested(_:)), name: NSNotification.Name(rawValue: AppNotifications.RequestedBooksSectionCacheItemsChanged), object: nil)
        tableView.reloadData()
    }
    
    func requestedBooks() -> [UserBook] {
        return RequestedBooksCache.sharedInstance.books;
//        return ExploreBooksCache.sharedInstance.books.filter { $0.requested }
    }
    
    @objc func bookRequested(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PurchasesTableCell") as? PurchasesTableCell else {
            return UITableViewCell()
        }
        let bookIndex = indexPath.row
        guard requestedBooks().count > bookIndex else {
            return UITableViewCell()
        }
        let book = requestedBooks()[bookIndex]
        cell.setContent(book)
        cell.coverImage.kf.indicatorType = .activity
        if let coverImageUrl = URL(string: book.details.cover.large) {
            let placeholder = Image(named: "cover_placeholder")
            cell.coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        return requestedBooks().count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return UIView()
        }
        guard let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "PurchasesTableSectionHeaderView") as? PurchasesTableSectionHeaderView else {
            return UIView()
        }
        sectionHeader.setContent("Requested")
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PurchasesTableCell else {
            return
        }
        cell.coverImage.kf.cancelDownloadTask()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        
        if let purchaseDetailViewController = segue.destination as? PurchaseDetailViewController {
            guard let selectedBookIndex = tableView.indexPathForSelectedRow?.row else {
                return
            }
            guard requestedBooks().count > selectedBookIndex else {
                return
            }
            let selectedBook = requestedBooks()[selectedBookIndex]
            purchaseDetailViewController.setContnet(selectedBook)
        }
        
    }
}
