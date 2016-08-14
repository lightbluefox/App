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
        completion(.Failure(nil))
    }
    
    func userInfo(completion: ApiResult<User> -> ()) {
        let headers = ["Authorization": "Bearer " + (authTokenStorage.authToken ?? "")]
        
        // TODO: отрефакторить
        Alamofire.request(.GET, Constants.apiUrl + "api/v01/users/current", headers: headers)
            .responseJSON { response in
                switch response.result {
                case .Success(let json as Dictionary<String, AnyObject>):
                    let userData = json["usersdata"] as? Dictionary<String, AnyObject>
                    
                    let user = User(
                        photo: userData?["avatar"] as? String,
                        firstName: userData?["name"] as? String,
                        middleName: userData?["fatherName"] as? String,
                        lastName: userData?["surName"] as? String,
                        phone: json["login"] as? String,
                        email: userData?["email"] as? String,
                        birthDate: userData?["birthDate"] as? String,
                        height: userData?["height"] as? Int,
                        size: userData?["clothesSize"] as? Int,
                        hasMedicalBook: userData?["hasMedicalCard"] as? Bool,
                        medicalBookNumber: userData?["medicalCardNumber"] as? String,
                        metroStation: userData?["subWayStation"] as? String,
                        passportData: userData?["passportData"] as? String,
                        gender: (userData?["ifMale"] as? Bool).flatMap { $0 ? .Male : .Female }
                    )
                    
                    user.guid = json["guid"] as? String
                    
                    completion(.Success(user))
                    
                case .Failure:
                    completion(.Failure(response.result.error))
                default:
                    completion(.Failure(nil))
                }
        }
    }
}
