import Foundation

extension LocalStorageKeys {
    static let ProfileService_PhoneNumber = "ProfileService_PhoneNumber"
    static let ProfileService_UserId = "ProfileService_UserId"
}

class ProfileService {
    static let sharedInstance = ProfileService()
    
    var isLoggedIn: Bool {
        return userId != nil
    }
    
    var userId: String? {
        get {
            debugPrint("userId: \(LocalStorage.sharedInstance.getString(LocalStorageKeys.ProfileService_UserId) ?? "")")
            return LocalStorage.sharedInstance.getString(LocalStorageKeys.ProfileService_UserId)
        }
        set {
            if let value = newValue {
                LocalStorage.sharedInstance.setString(LocalStorageKeys.ProfileService_UserId, value: value)
            } else {
                LocalStorage.sharedInstance.deleteObject(LocalStorageKeys.ProfileService_UserId)
            }
        }
    }
    
    var phoneNumber: String? {
        get {
            return LocalStorage.sharedInstance.getString(LocalStorageKeys.ProfileService_PhoneNumber)
        }
        set {
            if let value = newValue {
                LocalStorage.sharedInstance.setString(LocalStorageKeys.ProfileService_PhoneNumber, value: value)
            } else {
                LocalStorage.sharedInstance.deleteObject(LocalStorageKeys.ProfileService_PhoneNumber)
            }
        }
    }
    
    func register(_ phoneNumber:String, completion: @escaping (_ result: ApiRegistrationResult) -> Void) {
        SwapperApi.sharedInstance.register(phoneNumber) { result in
            if case .success(let userInfo) = result {
                self.phoneNumber = userInfo.phoneNumber
                self.userId = userInfo.id
            }
            completion(result)
        }
    }
    
    func loginWithPhone(_ phoneNumber: String, completion: @escaping (_ result: ApiLoginResult) -> Void) {
        SwapperApi.sharedInstance.getUserByPhoneNumber(phoneNumber) { result in
            if case .success(let userInfo) = result {
                self.phoneNumber = userInfo.phoneNumber
                self.userId = userInfo.id
            }
            completion(result)
        }
    }
    
    func createWallet(_ userId: String, completion: @escaping (_ success: Bool) -> Void) {
        SwapperApi.sharedInstance.createUserWallet() { result in
            guard case .success = result else {
                completion(false)
                return
            }
            
            self.addBankCard(userId) { success in
                debugPrint("add bank card result: \(success)")
                completion(success)
            }
        }
    }
    
    func addBankCard(_ userId: String, completion: @escaping (_ success: Bool) -> Void) {
        SwapperApi.sharedInstance.addUserBankCard(userId) { result in
            if case .success = result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
