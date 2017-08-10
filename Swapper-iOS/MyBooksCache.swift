import Foundation

extension AppNotifications {
    static let MyBooksSectionCacheItemsChanged = "MyBooksSectionCacheItemsChanged"
    static let MyBooksSectionCacheStateChanged = "MyBooksSectionCacheStateChanged"
}

struct MyBooksSection {
    let title: String
    var books: [UserBook]
}

class MyBooksCache: NSObject {
    static let sharedInstance = MyBooksCache()
    
    override init() {
        super.init()
        let updateIntervalSeconds: TimeInterval = 5 * 1
        Timer.scheduledTimer(timeInterval: updateIntervalSeconds, target: self, selector: #selector(MyBooksCache.update), userInfo: nil, repeats: true)
    }
    
    fileprivate(set) var books : [UserBook] = [] {
        didSet {
            notifyItemsChanged()
        }
    }
    
    fileprivate(set) var state: CacheState = .empty {
        didSet {
            notifyStateChanged()
        }
    }
    
    func update() {
        if case .updating = state {
            return
        }
        guard let userId = ProfileService.sharedInstance.userId else {
            return
        }
        state = .updating
        SwapperApi.sharedInstance.getUserBooks(userId) { result in
            guard case .success(let data) = result else {
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            guard let jsonUserObject = json as? [String: Any] else {
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            guard let jsonBooksArray = jsonUserObject["books"] as? [[String: Any]] else {
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            self.books = jsonBooksArray.flatMap(UserBook.fromJson)
            self.state = .cached
        }
    }
    
    fileprivate func notifyItemsChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.MyBooksSectionCacheItemsChanged), object: self)
    }
    
    fileprivate func notifyStateChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.MyBooksSectionCacheStateChanged), object: self)
    }
}
