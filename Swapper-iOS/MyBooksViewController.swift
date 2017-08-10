import UIKit
import Kingfisher

class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(MyBooksViewController.myBooksSectionCacheItemsChanged(_:)), name: NSNotification.Name(rawValue: AppNotifications.MyBooksSectionCacheItemsChanged), object: nil)
        tableView.reloadData()
    }
    
    func myBooksSectionCacheItemsChanged(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        return MyBooksCache.sharedInstance.books.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyBooksTableCell") as? MyBooksTableCell else {
            return UITableViewCell()
        }
        let bookIndex = indexPath.row
        guard MyBooksCache.sharedInstance.books.count > bookIndex else {
            return UITableViewCell()
        }
        let book = MyBooksCache.sharedInstance.books[bookIndex]
        cell.setContent(book)
        cell.coverImage.kf.indicatorType = .activity
        if let coverImageUrl = URL(string: book.details.cover.large) {
            let placeholder = Image(named: "cover_placeholder")
            cell.coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        
        if let exploreBookDetailViewController = segue.destination as? MyBooksDetailViewController {
            guard let selectedBookIndex = tableView.indexPathForSelectedRow?.row else {
                return
            }
            guard MyBooksCache.sharedInstance.books.count > selectedBookIndex else {
                return
            }
            let selectedBook = MyBooksCache.sharedInstance.books[selectedBookIndex]
            exploreBookDetailViewController.setContnet(selectedBook)
        }
    }
}
