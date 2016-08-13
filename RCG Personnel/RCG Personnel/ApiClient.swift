protocol ApiClient {
    func authenticate(login _: String, password: String, completion: ApiResult<String> -> ())
    func authenticate(via socialNetwork: SocialNetwork, token: String, completion: ApiResult<String> -> ())
    func userInfo(completion: ApiResult<User> -> ())
}

enum ApiResult<T> {
    case Success(T)
    case Failure(NSError?)
}