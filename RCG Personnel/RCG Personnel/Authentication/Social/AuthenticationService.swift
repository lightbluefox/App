protocol AuthenticationService {
    func authenticate(_: AuthenticationMethod, completion: AuthenticationResult -> ())
    func register(_: RegistrationParameters, completion: AuthenticationResult -> ())
    func currentUser(completion: User? -> ())
    func signOut(completion _: (() -> ())?)
}

enum AuthenticationMethod {
    case Native(login: String, password: String)
    case Social(SocialNetwork)
}

enum AuthenticationResult {
    case Success
    case Failed(error: NSError?)
}

struct RegistrationParameters {
    var login: String
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var email: String?
    var gender: Gender?
    var dateOfBirth: NSDate?
    var height: Int?
    var clothingSize: Int?
    var metro: String?
    var passport: String?
}

// Это нехорошее решение, но оно быстрое и менее трешовое, чем было раньше
let userDidSignInNotification = "ru.lightbluefox.RCG-Personnel.AuthenticationServiceImpl.userDidSignInNotification"
let userDidSignOutNotification = "ru.lightbluefox.RCG-Personnel.AuthenticationServiceImpl.userDidSignOutNotification"