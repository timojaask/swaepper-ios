import Foundation


enum ApiRegistrationResult {
    case success(user: ApiUserInfo)
    case userExists
    case unknownError
}

enum ApiLoginResult {
    case success(user: ApiUserInfo)
    case userNotFound
    case unknownError
}

enum ApiGenericGetDataResult {
    case success(data: Data)
    case unknownError
}

enum ApiGenericResult {
    case success
    case unknownError
}

class SwapperApi {
    static let sharedInstance = SwapperApi()
 
    fileprivate let baseUrl = "https://swaepper-staging.herokuapp.com/api"
    
    func register(_ phoneNumber: String, completion: @escaping (ApiRegistrationResult) -> Void) {
        let params = ["phoneNumber": phoneNumber]
        let url = "\(baseUrl)/user"
        RestService.sharedInstance.postRequest(url, headers: [:], params: params) { (success, response, statusCode) in
            if success {
                if let userInfo = ApiUserInfo.fromData(response) {
                    completion(.success(user: userInfo))
                } else {
                    completion(.unknownError)
                }
            } else if statusCode == 409 {
                completion(.userExists)
            } else {
                completion(.unknownError)
            }
        }
    }
    
    func getUserByPhoneNumber(_ phoneNumber: String, completion: @escaping (ApiLoginResult) -> Void) {
        func stripPlus(_ phoneNumber: String) -> String {
            guard phoneNumber.hasPrefix("+") else {
                return phoneNumber
            }
            return String(phoneNumber.characters.dropFirst())
        }
        let url = "\(baseUrl)/user?phone=\(stripPlus(phoneNumber))"
        RestService.sharedInstance.getRequest(url, headers: [:]) { (success, response, statusCode) in
            if success {
                if let userInfo = ApiUserInfo.fromData(response) {
                    completion(.success(user: userInfo))
                } else {
                    completion(.unknownError)
                }
            } else if statusCode == 404 {
                completion(.userNotFound)
            } else {
                completion(.unknownError)
            }
        }
    }
    
    func getBooksOnSale(_ completion: @escaping (ApiGenericGetDataResult) -> Void) {
        let url = "\(baseUrl)/books/onsale"
        let userId = ProfileService.sharedInstance.userId ?? ""
        genericGetDataRequest(url, headers: ["userId": userId], completion: completion)
    }
    
    func getBook(_ isbn: String, completion: @escaping (ApiGenericGetDataResult) -> Void) {
        let url = "\(baseUrl)/books/find?isbn=\(isbn)"
        genericGetDataRequest(url, headers: [:], completion: completion)
    }
    
    func getUserBooks(_ userId: String, completion: @escaping (ApiGenericGetDataResult) -> Void) {
        let userId = ProfileService.sharedInstance.userId ?? ""
        let url = "\(baseUrl)/user/\(userId)/"
        genericGetDataRequest(url, headers: [:], completion: completion)
    }
    
    func getRequestedBooks(_ userId: String, completion: @escaping (ApiGenericGetDataResult) -> Void) {
        let userId = ProfileService.sharedInstance.userId ?? ""
        let url = "\(baseUrl)/user/\(userId)/requested/"
        genericGetDataRequest(url, headers: [:], completion: completion)
    }
    
    func sendBookRequest(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: .OnSale, toState: .Requested, completion: completion)
    }
    
    func cancelBookRequest(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: .Requested, toState: .OnSale, completion: completion)
    }
    
    func pickUpBook(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: nil, toState: .Sold, completion: completion)
    }
    
    func putBookOnSale(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: nil, toState: .OnSale, completion: completion)
    }
    
    func removeBookFromSale(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: nil, toState: .Idle, completion: completion)
    }
    
    func acceptRequest(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: nil, toState: .Accepted, completion: completion)
    }
    
    func cancelTransaction(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        setBookStateRequest(book, fromState: nil, toState: .TransferCancelled, completion: completion)
    }
    
    func addBook(_ bookId: String, completion: @escaping (ApiGenericResult) -> Void) {
        let params = ["bookId": bookId]
        let userId = ProfileService.sharedInstance.userId ?? ""
        let url = "\(baseUrl)/user/\(userId)/book/"
        genericPostRequest(url, headers: [:], params: params, completion: completion)
    }
    
    func deleteBook(_ book: UserBook, completion: @escaping (ApiGenericResult) -> Void) {
        let userBookId = book.id
        let userId = ProfileService.sharedInstance.userId ?? ""
        let url = "\(baseUrl)/user/\(userId)/book/\(userBookId)"
        RestService.sharedInstance.deleteRequest(url, headers: [:]) { (success, response, statusCode) in
            guard success else {
                completion(.unknownError)
                return
            }
            updateCaches()
            completion(.success)
        }
    }
    
    func createUserWallet(_ completion: @escaping (ApiGenericResult) -> Void) {
        let userId = ProfileService.sharedInstance.userId ?? ""
        let url = "\(baseUrl)/user/\(userId)/wallet/"
        let params = [
            "email": "test@test.net",
            "firstName": "Ivan",
            "lastName": "Ivanov",
            "address": "Some street 5 NY",
            "birthday": 633830400,
            "nationality": "FI",
            "countryOfResidence": "FI"
        ] as [String : Any]
        genericPostRequest(url, headers: [:], params: params, completion: completion)
    }
    
    func addUserBankCard(_ userId: String, completion: @escaping (ApiGenericResult) -> Void) {
        let userId = ProfileService.sharedInstance.userId ?? ""
        let url = "\(baseUrl)/user/\(userId)/card/"
        let params = [
            "cardNumber": "4706750000000033",
            "expiration": "0917",
            "cvx": "123"
        ]
        genericPostRequest(url, headers: [:], params: params, completion: completion)
    }
    
    fileprivate func setBookStateRequest(_ book: UserBook, fromState: State?, toState: State, completion: @escaping (ApiGenericResult) -> Void) {
        let url = "\(baseUrl)/transaction/book"
        let params = [
            "userBookId": book.id,
            "originatorId": ProfileService.sharedInstance.userId ?? "",
            "fromState": fromState?.rawValue ?? book.state.rawValue,
            "toState": toState.rawValue,
            "price": book.price
            ] as [String : Any]
        genericPostRequest(url, headers: [:], params: params, completion: completion)
    }
    
    fileprivate func genericGetDataRequest(_ url: String, headers: [String:String], completion: @escaping (ApiGenericGetDataResult) -> Void) {
        RestService.sharedInstance.getRequest(url, headers: headers) { (success, response, statusCode) in
            guard success else {
                completion(.unknownError)
                return
            }
            guard let data = response else {
                completion(.unknownError)
                return
            }
            completion(.success(data: data))
        }
    }
    
    fileprivate func genericPostRequest(_ url: String, headers: [String:String], params: [String: Any], completion: @escaping (ApiGenericResult) -> Void) {
        RestService.sharedInstance.postRequest(url, headers: [:], params: params) { (success, response, statusCode) in
            guard success else {
                debugPrint("POST request failed with URL: \(url)")
                debugPrint("Server returned error with code: \(statusCode)")
                completion(.unknownError)
                return
            }
            updateCaches()
            completion(.success)
        }
    }
}
