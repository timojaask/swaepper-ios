import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        tabBar.tintColor = .white
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("bookRequested:"), name: "bookRequested", object: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func bookRequested(_ notification: Notification) {
//        guard let tabBarItems = tabBar.items else {
//            return
//        }
//        let purchasesTabBarItem = tabBarItems[1]
//        let numRequestedBooks = ExploreBooksCache.sharedInstance.books.filter({ $0.requested }).count
//        purchasesTabBarItem.badgeValue = "\(numRequestedBooks)"
    }
}
