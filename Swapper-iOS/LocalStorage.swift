import Foundation

struct LocalStorageKeys {
}

// Use to read/write data that is presisted
// between application launches.
class LocalStorage {
    
    // NOTE: Singleton
    static let sharedInstance = LocalStorage()
    
    // MARK: - public methods
    
    func setBool(_ key:String, value:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    func getBool(_ key:String) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key)
    }
    
    func setDate(_ key:String, value:Date) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    func getDate(_ key:String) -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key) as? Date
    }
    
    func setString(_ key:String, value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    func getString(_ key:String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key) as? String
    }
    
    func setInt(_ key:String, value:Int) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    func getInt(_ key:String) -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }
    
    func objectExists(_ key: String) -> Bool {
        let fm = FileManager()
        return fm.fileExists(atPath: urlForFile(key).path)
    }
    
    func saveObject(_ object: Any, key: String) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        do {
            try data.write(to: urlForFile(key), options: NSData.WritingOptions.completeFileProtection)
            return true
        } catch {
            return false
        }
    }
    
    func loadObject(_ key: String) -> Any? {
        do {
            let data = try Data.init(contentsOf: urlForFile(key), options: NSData.ReadingOptions())
            return NSKeyedUnarchiver.unarchiveObject(with: data) as Any
        } catch {
            return nil
        }
    }
    
    func deleteObject(_ key: String) -> Bool {
        do {
            try FileManager().removeItem(at: urlForFile(key))
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - private methods
    
    fileprivate func urlForFile(_ name: String) -> URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirectoryURL.appendingPathComponent(name)
    }
}
