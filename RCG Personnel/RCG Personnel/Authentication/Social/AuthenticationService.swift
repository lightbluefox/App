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
    
    func currentUser(completion: User? -> ()) {
        // TODO
    }
    
    func signOut(completion: (() -> ())?) {
        currentUser = nil
        completion?()
    }
    
    // MARK: - Private
    
    private func handleAuthenticationResult(result: ApiResult<String>, completion: AuthenticationResult -> ()) {
        switch result {
        case .Success(let token):
            authTokenStorage.setAuthToken(token)
            completion(.Success)
        case .Failure(let error):
            completion(.Failed(error: error))
        }
    }
}