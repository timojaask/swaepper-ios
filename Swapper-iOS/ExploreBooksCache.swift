import Foundation

extension AppNotifications {
    static let ExploreBooksCacheItemsChanged = "ExploreBooksCacheItemsChanged"
    static let ExploreBooksCacheStateChanged = "ExploreBooksCacheStateChanged"
}

class ExploreBooksCache: NSObject {
    static let sharedInstance = ExploreBooksCache()
    
    override init() {
        super.init()
        let updateIntervalSeconds: TimeInterval = 5 * 1
        Timer.scheduledTimer(timeInterval: updateIntervalSeconds, target: self, selector: #selector(ExploreBooksCache.update), userInfo: nil, repeats: true)
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
        state = .updating
        SwapperApi.sharedInstance.getBooksOnSale() { result in
            guard case .success(let data) = result else {
                self.state = .error(reason: "Unable to retrive books on sale")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                self.state = .error(reason: "Unable to retrive books on sale")
                return
            }
            guard let jsonArray = json as? [[String: Any]] else {
                self.state = .error(reason: "Unable to retrive books on sale")
                return
            }
            self.books = jsonArray.flatMap(UserBook.fromJson)
            self.state = .cached
        }
    }
    
    fileprivate func notifyItemsChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.ExploreBooksCacheItemsChanged), object: self)
    }
    
    fileprivate func notifyStateChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.ExploreBooksCacheStateChanged), object: self)
    }
}
