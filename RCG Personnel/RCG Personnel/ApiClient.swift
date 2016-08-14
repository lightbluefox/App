protocol ApiClient {
    func authenticate(login _: String, password: String, completion: ApiResult<String> -> ())
    func authenticate(via socialNetwork: SocialNetwork, token: String, completion: ApiResult<String> -> ())
    func userInfo(completion: ApiResult<User> -> ())
}

enum ApiResult<T> {
    
    case Success(T)
    case Failure(NSError?)
    
    func onSuccess(handler: T -> ()) {
        if case .Success(let result) = self {
            handler(result)
        }
    }
    
    func onFailure(handler: NSError? -> ()) {
        if case .Failure(let error) = self {
            handler(error)
        }
    }
}