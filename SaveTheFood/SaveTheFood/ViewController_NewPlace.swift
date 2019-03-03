
import UIKit

class ViewController_NewPlace: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var pickerViewPlace: UIPickerView!
    let userDe=UserDefaults.standard    //存取是否建立過表格
    var placeList = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let myList = userDe.array(forKey: "placeList") {
            placeList = myList as! [String]
        }
        
        pickerViewPlace.delegate = self //as! UIPickerViewDelegate
        pickerViewPlace.dataSource = self
       
     }
    
    @IBAction func next(){
        if let place = userDe.array(forKey: "placeList"){
            print(place[pickerViewPlace.selectedRow(inComponent: 0)])
            userDe.set(place[pickerViewPlace.selectedRow(inComponent: 0)], forKey: "newPlace")
        }
    }
    //picker list
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//(宣告直列要顯示的數量)
        return placeList.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {//(宣告picker的橫列有幾個)
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //{(宣告pickerView要顯示的內容)
        return placeList[row]
        
    }
}
