import Foundation

//swiftlint:disable large_tuple
internal enum Route {
    case logIn(email: String, password: String)
    case signUp(username: String, email: String, password: String)
    case getCurrentUser
    case getProfile(String)
    case followUser(String)
    case unfollowUser(String)
    case getArticles
    case getFeedArticles
    case createArticle

    internal var requestProperties:
        (method: Method, path: String, body: Encodable?) {

        switch self {
        case let .logIn(email, password):
            return (.post, "api/users/login", ["email": email, "password": password])
        case let .signUp(username, email, password):
            return (.post, "api/users",
                    ["username": username, "email": email, "password": password])
        case .getCurrentUser:
            return (.get, "api/user", nil)
        case let .getProfile(username):
            return (.get, "api/profiles/\(username)", nil)
        case let .followUser(user):
            return (.post, "api/profiles/\(user)/follow", nil)
        case let .unfollowUser(user):
            return (.delete, "api/profiles/\(user)/follow", nil)
        case .getArticles: // query
            return (.get, "api/articles", nil)
        case .getFeedArticles: //query
            return (.get, "api/articles/feed", nil)
        case .createArticle:
            return (.post, "api/articles", nil)
        }
    }
}
