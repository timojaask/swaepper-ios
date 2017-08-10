import Foundation

extension AppNotifications {
    static let RequestedBooksSectionCacheItemsChanged = "RequestedBooksSectionCacheItemsChanged"
    static let RequestedBooksSectionCacheStateChanged = "RequestedBooksSectionCacheStateChanged"
}

struct RequestedBooksSection {
    let title: String
    var books: [UserBook]
}

class RequestedBooksCache: NSObject {
    static let sharedInstance = RequestedBooksCache()
    
    override init() {
        super.init()
        let updateIntervalSeconds: TimeInterval = 5 * 1
        Timer.scheduledTimer(timeInterval: updateIntervalSeconds, target: self, selector: #selector(RequestedBooksCache.update), userInfo: nil, repeats: true)
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
        SwapperApi.sharedInstance.getRequestedBooks(userId) { result in
            guard case .success(let data) = result else {
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("fail: failed to serialize json")
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            guard let jsonBooksArray = json as? [[String: Any]] else {
                print("Doesn't contain books section")
                self.state = .error(reason: "Unable to retrive user's books")
                return
            }
            self.books = jsonBooksArray.flatMap(UserBook.fromJson)
            self.state = .cached
        }
    }
    
    fileprivate func notifyItemsChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.RequestedBooksSectionCacheItemsChanged), object: self)
    }
    
    fileprivate func notifyStateChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppNotifications.RequestedBooksSectionCacheStateChanged), object: self)
    }
}
