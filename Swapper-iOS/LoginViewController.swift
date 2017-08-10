import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var loginOkLabel: UILabel!
    @IBOutlet weak var unknownErrorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        phoneNumberTextField.text = ""
        phoneNumberTextField.becomeFirstResponder()
        loginOkLabel.alpha = 0
        unknownErrorView.alpha = 0
        unknownErrorView.layer.cornerRadius = 5
        activityIndicator.isHidden = true
    }
    
    @IBAction func okButtonTapped(_ sender: AnyObject) {
        guard let phoneNumber = phoneNumberTextField.text else {
            return
        }
        phoneNumberTextField.resignFirstResponder()
        ProfileService.sharedInstance.register(phoneNumber) { (result) in
            self.loginOkLabel.alpha = 0
            self.unknownErrorView.alpha = 0
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            switch (result) {
            case .success(let userInfo):
                debugPrint("Regustration: success")
                self.requestUserInfo(userInfo)
            case .userExists:
                debugPrint("Regustration: user exists")
                self.getUserByPhoneNumber(phoneNumber)
            case .unknownError:
                debugPrint("Regustration: unknown error")
                self.onUnknownError()
            }
        }
    }
    
    fileprivate func getUserByPhoneNumber(_ phoneNumber: String) {
        ProfileService.sharedInstance.loginWithPhone(phoneNumber) { result in
            switch (result) {
            case .success(let userInfo):
                debugPrint("Login with phone: Got user info")
                if userInfo.hasWallet && userInfo.hasBankCard {
                    self.onLoginOk()
                } else {
                    self.requestUserInfo(userInfo)
                }
            case .userNotFound:
                debugPrint("Login with phone: User not found")
                self.onUnknownError()
            case .unknownError:
                debugPrint("Login with phone: Unknown error")
                self.onUnknownError()
            }
        }
    }
    
    fileprivate func requestUserInfo(_ userInfo: ApiUserInfo) {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        performSegue(withIdentifier: AppSegues.LoginToRegisterSegue, sender: self)
    }
    
    fileprivate func onUnknownError() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.4, animations: {
            self.unknownErrorView.alpha = 1
        })
    }
    
    fileprivate func onLoginOk() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.4, animations: { 
            self.loginOkLabel.alpha = 1
        }, completion: { _ in
            delay(1, block: {
                MyBooksCache.sharedInstance.update()
                self.performSegue(withIdentifier: AppSegues.LoginToMainSegue, sender: self)
            })
        }) 
    }
}
