import TwitterKit

final class TwitterAuthenticationService {
    
    func performAuthentication(completion: TwitterAuthenticationResult -> ()) {
        twitter.logInWithCompletion { session, error in
            if let session = session {
                completion(.Success(token: session.authToken, tokenSecret: session.authTokenSecret))
            } else {
                completion(.Failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    private let twitter = Twitter.sharedInstance()
}

enum TwitterAuthenticationResult {
    case Success(token: String, tokenSecret: String)
    case Failure(NSError?)
}