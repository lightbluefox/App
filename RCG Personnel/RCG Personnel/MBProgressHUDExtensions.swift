import MBProgressHUD

extension MBProgressHUD {
    static func showHud(in viewController: UIViewController?, animated: Bool = true) -> MBProgressHUD? {
        return (viewController?.view).flatMap { MBProgressHUD.showHUDAddedTo($0, animated: animated) }
    }
}
