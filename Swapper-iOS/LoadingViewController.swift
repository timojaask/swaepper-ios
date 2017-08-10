import UIKit

class LoadingViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        let nextSegue = ProfileService.sharedInstance.isLoggedIn ? AppSegues.LoadingToMainSegue : AppSegues.LoadingToLoginSegue
        performSegue(withIdentifier: nextSegue, sender: self)
    }
}
