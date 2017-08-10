import UIKit
import Kingfisher

class ExploreViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreViewController.exploreBooksCacheItemsChanged(_:)), name: NSNotification.Name(rawValue: AppNotifications.ExploreBooksCacheItemsChanged), object: nil)
        tableView.reloadData()
    }
    
    func exploreBooksCacheItemsChanged(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTableCell") as? ExploreTableCell else {
            return UITableViewCell()
        }
        let bookIndex = indexPath.row
        guard ExploreBooksCache.sharedInstance.books.count > bookIndex else {
            return UITableViewCell()
        }
        let book = ExploreBooksCache.sharedInstance.books[bookIndex]
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
        return ExploreBooksCache.sharedInstance.books.count
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
        guard let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "ExploreTableSectionHeaderView") as? ExploreTableSectionHeaderView else {
            return UIView()
        }
        sectionHeader.setContent("On sale")
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else {
            return 0
        }
        return 56
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ExploreTableCell else {
            return
        }
        cell.coverImage.kf.cancelDownloadTask()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        
        if let exploreBookDetailViewController = segue.destination as? ExploreBookDetailViewController {
            guard let selectedBookIndex = tableView.indexPathForSelectedRow?.row else {
                return
            }
            guard ExploreBooksCache.sharedInstance.books.count > selectedBookIndex else {
                return
            }
            let selectedBook = ExploreBooksCache.sharedInstance.books[selectedBookIndex]
            exploreBookDetailViewController.setContnet(selectedBook)
        }
        
    }
}
