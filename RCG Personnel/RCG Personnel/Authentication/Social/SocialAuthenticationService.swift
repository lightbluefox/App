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

// MARK: - AuthenticationService

protocol AuthenticationService {
    var currentUser: User? { get }
    func authenticate(method: AuthenticationMethod, completion: AuthenticationResult -> ())
}

enum AuthenticationMethod {
    case Native(login: String, password: String)
    case Social(network: SocialNetwork)
}

enum AuthenticationResult {
    case Success(user: User)
    case Failed(error: NSError)
}

final class AuthenticationServiceImpl: AuthenticationService {
    
    var currentUser: User?
    
    private let socialAuthenticationService: SocialAuthenticationService
    private let apiClient: ApiClient
    
    func authenticate(method: AuthenticationMethod, completion: AuthenticationResult -> ()) {
        
        switch method {
        
        case .Social(let socialNetwork):
            authenticateViaSocialNetwork(socialNetwork) { [weak self] result in
                self?.handleAuthenticationResult(result, completion: completion)
            }
        
        case .Native(let login, let password):
            apiClient.authenticate(withLogin: login, password: password) { [weak self] result in
                self?.handleAuthenticationResult(result, completion: completion)
            }
        }
    }
    
    private func authenticateViaSocialNetwork(socialNetwork: SocialNetwork, completion: AuthenticationResult -> ()) {
        socialAuthenticationService.authenticate(socialNetwork) { [weak self] result in
            switch result {
            case .Success(let token):
                self?.apiClient.authenticateViaSocialNetwork(socialNetwork, token: token, completion: completion)
            case .Failed(let error):
                completion(.Failed(error: error))
            }
        }
    }
    
    private func handleAuthenticationResult(result: AuthenticationResult, completion: AuthenticationResult -> ()) {
        if case .Success(let user) = result {
            currentUser = user
        }
        completion(result)
    }
}

protocol ApiClient {
    func authenticate(withLogin login: String, password: String, completion: AuthenticationResult -> ())
    func authenticateViaSocialNetwork(socialNetwork: SocialNetwork, token: String, completion: AuthenticationResult -> ())
}

final class AuthTest {
    
    private let authService: AuthenticationService
    
    func auth() {
        
        let method = AuthenticationMethod.Social(network: .Facebook)
        
        authService.authenticate(method) { [weak self] result in
            switch result {
            case .Success(let user):
                if user.confirmed {
                    // TODO: успешная авторизация
                } else {
                    // TODO: надо показать форму регистрации для заполнения данных
                }
            case .Failed(let error):
                // TODO: показать ошибку
                break
            }
        }
    }
}