protocol AuthenticationService {
    
    var authenticationStatus: AuthenticationStatus { get }
    
    func authenticate(_: AuthenticationMethod, completion: AuthenticationResult -> ())
    func register(_: RegistrationParameters, completion: RegistrationResult -> ())
    func currentUser(completion: User? -> ())
    func signOut(completion _: (() -> ())?)
}

enum AuthenticationStatus {
    /// Пользователь не авторизован
    case Unauthenticated
    /// Авторизован, но заполнены не все обязательный регистрационные данные (например, зашел впервые через соцсеть)
    case Intermediate
    /// Авторизован
    case Authenticated
}

enum AuthenticationMethod {
    case Native(login: String, password: String)
    case Social(SocialNetwork)
}

enum AuthenticationResult {
    case Success
    case Failed(NSError?)
}

enum RegistrationResult {
    case Success
    case PhoneAlreadyRegistered
    case Failed(NSError?)
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