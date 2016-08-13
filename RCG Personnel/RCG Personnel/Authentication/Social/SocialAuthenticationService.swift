protocol SocialAuthenticationService {
    func authenticate(socialNetwork: SocialNetwork, completion: SocialNetworkAuthenticationResult -> ())
}

enum SocialNetwork {
    case VKontakte
    case Facebook
    case Twitter
}

enum SocialNetworkAuthenticationResult {
    case Success(token: String)
    case Failed(error: NSError)
}

final class SocialAuthenticationServiceImpl: SocialAuthenticationService {
    func authenticate(socialNetwork: SocialNetwork, completion: SocialNetworkAuthenticationResult -> ()) {
        // TODO
    }
}