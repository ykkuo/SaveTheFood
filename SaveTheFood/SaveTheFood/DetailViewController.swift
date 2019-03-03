

import UIKit


class DetailViewController: UIViewController {

    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var noPhotoLabel: UILabel!
    
    var rowId: Int = 0
    let picPath = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()
        //largeImageView.image = nil
        print("==View did load in DetailView")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("== Detail viewWillAppear==")
       // show photo
        if rowId != 0 {
            if let itemImage = UIImage(contentsOfFile: picPath + "Picid\(rowId).data") {
                print("load photo \(rowId)")
                largeImageView.image = itemImage
                noPhotoLabel.text = ""
            }
            else {
                print("photo doesn't exist")
                largeImageView.image = nil
                
            }
        }
        else{
           // dismiss(animated: true, completion: nil)
        }
      
    }


    @IBAction  func clickBackButton(){
        print("back")
        dismiss(animated: true, completion: nil)

    }

}


