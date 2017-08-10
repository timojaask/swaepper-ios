import Foundation

struct Cover {
    let small: String
    let medium: String
    let large: String
    
    static func fromJson(_ json: [String: String]) -> Cover? {
        guard let small = json["small"] else {
            return nil
        }
        guard let medium = json["medium"] else {
            return nil
        }
        guard let large = json["large"] else {
            return nil
        }
        return Cover(small: small, medium: medium, large: large)
    }
}
