import Foundation

struct Author {
    let id: String
    let name: String
    
    static func fromJson(_ json: [String: String]) -> Author? {
        guard let id = json["id"] else {
            return nil
        }
        guard let name = json["name"] else {
            return nil
        }
        return Author(id: id, name: name)
    }
}
