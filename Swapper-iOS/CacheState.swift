import Foundation

enum CacheState {
    case empty
    case updating
    case cached
    case error(reason: String)
}
