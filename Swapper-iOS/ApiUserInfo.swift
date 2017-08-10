import Foundation

struct ApiUserInfo: Equatable, Downloadable {
    let id: String
    let phoneNumber: String
    let email: String
    let firstName: String
    let lastName: String
    let birthday: Date?
    let books: [Book]
    let hasWallet: Bool
    let hasBankCard: Bool
    
    static func fromJson(_ json: [String: Any]) -> ApiUserInfo? {
        guard let id = json["id"] as? String else {
            return nil
        }
        guard let phoneNumber = json["phoneNumber"] as? String else {
            return nil
        }
        guard let email = json["email"] as? String else {
            return nil
        }
        guard let firstName = json["firstName"] as? String else {
            return nil
        }
        guard let lastName = json["lastName"] as? String else {
            return nil
        }
        guard let birthdayString = json["birthday"] as? String else {
            return nil
        }
        let birthday = Date.decodeISO8601(birthdayString)
        guard let booksJson = json["books"] as? [[String:String]] else {
            return nil
        }
        let books = booksJson.flatMap { (book) -> Book? in
            return Book.fromJson(book)
        }
        guard let hasWallet = json["hasWallet"] as? Bool else {
            return nil
        }
        guard let hasBankCard = json["hasBankCard"] as? Bool else {
            return nil
        }
        return ApiUserInfo(id: id, phoneNumber: phoneNumber, email: email, firstName: firstName, lastName: lastName, birthday: birthday, books: books, hasWallet: hasWallet, hasBankCard: hasBankCard)
    }
}

func ==(lhs: ApiUserInfo, rhs: ApiUserInfo) -> Bool {
    return lhs.id == rhs.id
}
