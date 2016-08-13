final class AuthenticationServiceImpl: AuthenticationService {
    
    private var authToken: String?
    private(set) var currentUser: User?
    
    private let socialAuthenticationService: SocialAuthenticationService
    private let apiClient: ApiClient
    private let authTokenStorage: AuthTokenStorageInput
    
    init(socialAuthenticationService: SocialAuthenticationService,
         apiClient: ApiClient,
         authTokenStorage: AuthTokenStorageInput)
    {
        self.socialAuthenticationService = socialAuthenticationService
        self.apiClient = apiClient
        self.authTokenStorage = authTokenStorage
    }
    
    convenience init() {
        let authTokenStorage = AuthTokenStorageImpl()
        
        self.init(
            socialAuthenticationService: SocialAuthenticationServiceImpl(),
            apiClient: ApiClientImpl(authTokenStorage: authTokenStorage),
            authTokenStorage: authTokenStorage
        )
    }
    
    // MARK: - AuthenticationService
    
    func authenticate(method: AuthenticationMethod, completion: AuthenticationResult -> ()) {
        
        switch method {
            
        case .Social(let socialNetwork):
            socialAuthenticationService.authenticate(socialNetwork) { [weak self] result in
                switch result {
                case .Success(let socialNetworkToken):
                    self?.apiClient.authenticate(via: socialNetwork, token: socialNetworkToken) { [weak self] result in
                        self?.handleAuthenticationResult(result, completion: completion)
                    }
                case .Failed(let error):
                    completion(.Failed(error: error))
                }
            }
            
        case .Native(let login, let password):
            apiClient.authenticate(login: login, password: password) { [weak self] result in
                self?.handleAuthenticationResult(result, completion: completion)
            }
        }
    }
    
    func register(parameters: RegistrationParameters, completion: AuthenticationResult -> ()) {
        // TODO
    }
    
    func currentUser(completion: User? -> ()) {
        // TODO
    }
    
    func signOut(completion completion: (() -> ())?) {
        authTokenStorage.setAuthToken(nil)
        currentUser = nil
        completion?()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidSignOutNotification, object: self)
    }
    
    // MARK: - Private
    
    private func handleAuthenticationResult(result: ApiResult<String>, completion: AuthenticationResult -> ()) {
        switch result {
        case .Success(let token):
            authTokenStorage.setAuthToken(token)
            completion(.Success)
            NSNotificationCenter.defaultCenter().postNotificationName(userDidSignInNotification, object: self)
        case .Failure(let error):
            completion(.Failed(error: error))
        }
    }
}