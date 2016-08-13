import Alamofire

final class ApiClientImpl: ApiClient {
    
    static let errorDomain = "ru.lightbluefox.RCG-Personnel.ApiClientImpl.errorDomain"
    
    enum Error: Int {
        case Unknown
    }
    
    private let baseUrl = Constants.apiUrl
    
    private let authTokenStorage: AuthTokenStorageOutput
    
    init(authTokenStorage: AuthTokenStorageOutput) {
        self.authTokenStorage = authTokenStorage
    }
    
    // MARK: - ApiClient
    
    func authenticate(login login: String, password: String, completion: ApiResult<String> -> ()) {
        Alamofire.request(.PUT, baseUrl + "api/v01/token", parameters: ["login": login, "password": password])
            .responseJSON { response in
                switch response.result {
                case .Success(let json as Dictionary<String, AnyObject>):
                    if let token = json["token"] as? String {
                        completion(.Success(token))
                    } else {
                        let errorMessage = json["error"] as? String
                        
                        completion(.Failure(errorMessage.flatMap {
                            NSError(domain: ApiClientImpl.errorDomain, code: Error.Unknown.rawValue, userInfo: [
                                NSLocalizedDescriptionKey: $0
                            ])
                        }))
                    }
                case .Failure(let error):
                    completion(.Failure(error))
                default:
                    completion(.Failure(nil))
                }
            }
    }
    
    func authenticate(via socialNetwork: SocialNetwork, token: String, completion: ApiResult<String> -> ()) {
        // TODO
    }
    
    func userInfo(completion: ApiResult<User> -> ()) {
        // TODO
    }
}
