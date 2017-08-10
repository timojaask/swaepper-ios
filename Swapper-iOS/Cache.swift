import Foundation

func updateCaches() {
    MyBooksCache.sharedInstance.update()
    RequestedBooksCache.sharedInstance.update()
    ExploreBooksCache.sharedInstance.update()
}