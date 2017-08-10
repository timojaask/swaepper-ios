import Foundation

protocol Downloadable {
    static func fromJson(_ json: [String: Any]) -> Self?
    static func fromData(_ data: Data?) -> Self?
}

extension Downloadable {
    static func fromData(_ data: Data?) -> Self? {
        guard let data = data else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        guard let dictionary = json as? [String: Any] else {
            return nil
        }
        return fromJson(dictionary)
    }
}
