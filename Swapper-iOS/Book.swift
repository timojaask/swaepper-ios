import Foundation

struct Book: Equatable, Downloadable {
    let id: String
    let title: String
    let isbn: String
    let publishYear: String
    let numberOfPages: Int
    let authors: [Author]
    let cover: Cover
    
    static func fromJson(_ json: [String: Any]) -> Book? {
        guard let id = json["id"] as? String else {
            return nil
        }
        guard let title = json["title"] as? String else {
            return nil
        }
        guard let isbn = json["isbn"] as? String else {
            return nil
        }
        guard let publishYear = json["publishYear"] as? String else {
            return nil
        }
        guard let numberOfPages = json["numberOfPages"] as? Int else {
            return nil
        }
        guard let authorsJson = json["authors"] as? [[String:String]] else {
            return nil
        }
        let authors = authorsJson.flatMap { (author) -> Author? in
            return Author.fromJson(author)
        }
        guard let coverJson = json["cover"] as? [String:String], let cover = Cover.fromJson(coverJson) else {
            return nil
        }
        return Book(id: id, title: title, isbn: isbn, publishYear: publishYear, numberOfPages: numberOfPages, authors: authors, cover: cover)
    }
}

func ==(lhs: Book, rhs: Book) -> Bool {
    return lhs.id == rhs.id
}
