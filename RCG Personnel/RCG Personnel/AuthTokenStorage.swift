protocol AuthTokenStorageOutput {
    var authToken: String? { get }
}

protocol AuthTokenStorageInput {
    func setAuthToken(_: String?)
}

final class AuthTokenStorageImpl: AuthTokenStorageInput, AuthTokenStorageOutput {
    
    static let userDefaultsKey = NSUserDefaultsKeys.tokenKey
    
    private(set) var authToken: String? {
        get { return NSUserDefaults.standardUserDefaults().stringForKey(AuthTokenStorageImpl.userDefaultsKey) }
        set { NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: AuthTokenStorageImpl.userDefaultsKey) }
    }
    
    func setAuthToken(authToken: String?) {
        self.authToken = authToken
    }
}