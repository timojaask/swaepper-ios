import Foundation

struct UserBook: Equatable {
    let id: String
    let state: State
    let price: Int
    let details: Book
    
    static func fromJson(_ json: [String: Any]) -> UserBook? {
        guard let id = json["id"] as? String else {
            return nil
        }
        guard let stateJson = json["state"] as? String, let state = State.fromJson(stateJson) else {
            return nil
        }
        guard let price = json["price"] as? Int else {
            return nil
        }
        guard let detailsJson = json["details"] as? [String:Any], let details = Book.fromJson(detailsJson) else {
            return nil
        }
        return UserBook(id: id, state: state, price: price, details: details)
    }
}

func ==(lhs: UserBook, rhs: UserBook) -> Bool {
    return lhs.id == rhs.id
}
