//  placePickerViewController.swift


import UIKit

class placePickerViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource  {
    let userDe = UserDefaults.standard
    @IBOutlet weak var pickerViewPlace: UIPickerView!
    @IBOutlet weak var textNewPlace: UITextField!
    
    
    var placeList: [String] = []//["上層（冷凍）","下層（冷藏）"]
    // save Array
    //self.userDefault.set(userList, forKey: "userList")
    //self.userDefault.synchronize()
    
    // load Array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let myList = userDe.array(forKey: "placeList") {
            //print("userList:\(placeList)")
            placeList = myList as! [String]
            
        }

        /*
        if let myList = userDe.array(forKey: "placeList") {
            placeList = myList as! [String]
        }
        else {
            userDe.set(placeList, forKey: "placeList")
            print ("initial setting for placelist")
            return
        }
         */
        pickerViewPlace.delegate = self //as! UIPickerViewDelegate
        pickerViewPlace.dataSource = self //as! UIPickerViewDataSource
        
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {//(宣告picker的橫列有幾個)
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//(宣告直列要顯示的數量)
        return placeList.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //{(宣告pickerView要顯示的內容)
         return placeList[row]
        
    }
    
    @IBAction func addPlace(){
        placeList.append(textNewPlace.text!)
        //show success message
        let controller = UIAlertController(title: "已新增", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
        
        userDe.set(placeList,forKey: "placeList")
        viewDidLoad()
    }
    @IBAction func deletePlace(){
        //print(pickerViewPlace.selectedRow(inComponent: 0))
        //if let place = userDe.array(forKey: "placeList") {
        //       print(place[pickerViewPlace.selectedRow(inComponent: 0)])
        //}
        placeList.remove(at: pickerViewPlace.selectedRow(inComponent: 0))
        //print(placeList)
        userDe.set(placeList,forKey: "placeList")
        viewDidLoad()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}
