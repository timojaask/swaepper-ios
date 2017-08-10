import Foundation

enum NSDateDecodingError: Error {
    case invalidStringFormat
}

extension Date {
    public static func decodeISO8601(_ dateString: String?) -> Date? {
        func stringToOrderDate(_ string: String) -> Date? {
            let fiLocale = Locale(identifier: "fi_FI")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = fiLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return dateFormatter.date(from: string)
        }
        
        guard let string = dateString else {
            return nil
        }
        
        guard let date = stringToOrderDate(string) else {
            return nil
        }
        return self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}
