import UIKit

class RegisterViewController: UITableViewController {
    
    @IBAction func registerButtonTapped(_ sender: AnyObject) {
        guard let userId = ProfileService.sharedInstance.userId else {
            debugPrint("RegisterViewController: UserId not set")
            return
        }
        ProfileService.sharedInstance.createWallet(userId) { (success) in
            guard success else {
                debugPrint("RegisterViewController: createWallet failed")
                return
            }
            self.performSegue(withIdentifier: AppSegues.RegisterToMainSegue, sender: self)
        }
    }
}
