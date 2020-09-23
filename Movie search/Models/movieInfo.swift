import Foundation

struct MovieInfo: Decodable {
    var Response: String
    var Title: String?
    var Director: String?
    var Poster: URL?
    var Actors: String?
    var Plot: String?
    var Ratings: [Rating]?
}

struct Rating: Decodable {
    var Source: String
    var Value: String
}
