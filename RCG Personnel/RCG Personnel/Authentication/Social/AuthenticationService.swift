protocol AuthenticationService {
    func authenticate(method: AuthenticationMethod, completion: AuthenticationResult -> ())
    func currentUser(completion: User? -> ())
    func signOut(completion: (() -> ())?)
}

enum AuthenticationMethod {
    case Native(login: String, password: String)
    case Social(SocialNetwork)
}

enum AuthenticationResult {
    case Success
    case Failed(error: NSError?)
}

// Это нехорошее решение, но оно быстрое и менее трешовое, чем было раньше
let userDidSignInNotification = "ru.lightbluefox.RCG-Personnel.AuthenticationServiceImpl.userDidSignInNotification"
let userDidSignOutNotification = "ru.lightbluefox.RCG-Personnel.AuthenticationServiceImpl.userDidSignOutNotification"