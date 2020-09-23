import Foundation

struct MovieFeed: Decodable {
    var Response: String
    var totalResults: String?
    var Search: [Movie]?
}

struct Movie: Decodable {
    var Poster: URL
    var Title: String
    var `Type`: String
    var Year: String
    var imdbID: String
}
