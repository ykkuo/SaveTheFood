import UIKit

class ViewController_NewName: UIViewController {
 
    @IBOutlet weak var textNewName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func next(){
        let userDe=UserDefaults.standard 
        userDe.set(textNewName.text, forKey: "newName")

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}
