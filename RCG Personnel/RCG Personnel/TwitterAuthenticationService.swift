import TwitterKit

final class TwitterAuthenticationService {
    
    func performAuthentication(completion: TwitterAuthenticationResult -> ()) {
//        completion(.Success(token: "49625412-gVKZl0O0YzV2sYawJxqtz8ukOXg8NsI3aRV6CzQN0", tokenSecret: "QLq8GO7vj5NNY3aPPfcEXiHtvG8deGK8nSy05s9oPT3bV"))
        twitter.logInWithCompletion { session, error in
            if let session = session {
                completion(.Success(token: session.authToken, tokenSecret: session.authTokenSecret))
            } else {
                completion(.Failure(error))
            }
        }
    }
    
    func performLogoff() {
        if let sessions = twitter.sessionStore.existingUserSessions() as? [TWTRSession] {
            for session in sessions {
                twitter.sessionStore.logOutUserID(session.userID)
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