import Foundation

enum State: String {
    case Idle = "Idle"
    case OnSale = "OnSale"
    case Requested = "Requested"
    case Accepted = "Accepted"
    case MoneyTransferFail = "MoneyTransferFail"
    case InTransfer = "InTransfer"
    case TransferCancelled = "TransferCancelled"
    case Sold = "Sold"
    case Trashed = "Trashed"
    
    static func fromJson(_ json: String) -> State? {
        return State(rawValue: json)
    }
    
    var humanReadableString: String {
        get {
            switch self {
                case .Idle:
                    return "Not on sale"
                case .OnSale:
                    return "On sale"
                default:
                    return self.rawValue
            }
        }
    }
}
