
/*
 儲存圖片在ＡＰＰ裡 https://medium.com/@z1235678/%E5%B0%87%E5%9C%96%E7%89%87%E5%84%B2%E5%AD%98%E5%9C%A8app%E8%A3%A1-b7690fb2074
 */
import UIKit
import Photos

class NewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate,UIPickerViewDataSource {
    var tableName :String = "record"
    let dbCreated = "DbCreated" //for userDefaults
    let recordId = "recordId"
    var newId = 0
    
    let formatter = DateFormatter()
    var picPath = ""
    
    //for edit record
    var rowId: Int = 0
    var name: String = ""
    var place: String = ""
    var inputDate: String = ""
    var expiredDate: String = ""
    var tookPicture = 0
    var inputName: String = ""
    var person: String = ""
    
    
    var db :SQLiteConnect?
    let userDe=UserDefaults.standard    //存取是否建立過表格

    //var placeList: Array = []
    var placeList = [""]  //["上層（冷凍）","下層（冷藏）"]
    
    var localId:String!
    
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var pickerInputDate: UIDatePicker!
    @IBOutlet weak var pickerExpiredDate: UIDatePicker!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    @IBOutlet weak var pickerViewPlace: UIPickerView!
    @IBOutlet weak var textInputPerson: UITextField!
    
    override func viewDidLoad() {
        print("====entering viewDidLoad of New Page====")
       // super.viewDidLoad()
        
        //for pickerViewPlace
        if let myList = userDe.array(forKey: "placeList") {
            placeList = myList as! [String]
        }

        pickerViewPlace.delegate = self
        pickerViewPlace.dataSource = self
        
        //for converting date formate
        formatter.dateFormat = "yyyy-MM-dd"

        // for edit mode
        if rowId != 0{
            print ("edit")
            //connect with DB to get the data
            let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
            db = SQLiteConnect(path: sqlitePath)
            if let mydb = db {
                // select
                let statement = mydb.fetch(
                    tableName, cond: "id == \(rowId)", order: nil)
                while sqlite3_step(statement) == SQLITE_ROW{
                    //id = sqlite3_column_int(statement, 0)
                    name = String(cString:sqlite3_column_text(statement, 1)!)
                    place = String(cString:sqlite3_column_text(statement, 2)!)
                    inputDate = String(cString:sqlite3_column_text(statement, 3)!)
                    expiredDate = String(cString:sqlite3_column_text(statement, 4)!)
                    person = String(cString:sqlite3_column_text(statement, 5)!)
                }
                sqlite3_finalize(statement)
                
                //set all objects to the data retrieved from DB
                //name
                textName.text = name
                //place
                if let index = placeList.index(of: place) {
                    pickerViewPlace.selectRow(index, inComponent: 0, animated: true)
                }
                //inputDate and expiredDate
                pickerInputDate.date = formatter.date(from: inputDate)!
                pickerExpiredDate.date = formatter.date(from: expiredDate)!
                //photo
                picPath = NSTemporaryDirectory() + "Picid\(rowId).data"//存檔路徑
                if let dbImage = UIImage(contentsOfFile: picPath) {
                    print("load photo \(rowId)")
                    itemImage.image = dbImage
                    
                }
                //inputPerson name
                textInputPerson.text = person
                
                //button color
                //view.backgroundColor = UIColor.lightText
                buttonConfirm.setTitleColor(UIColor.green, for: .normal)
                buttonConfirm.setTitle("確定修改", for: .normal)
            }
            
        }else{
            newId = findNewId()
            print("new")
        }
        
    }
    
    @IBAction func close(){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func save(){
        let inputdate = formatter.string(from: pickerInputDate.date)
        let expireddate = formatter.string(from: pickerExpiredDate.date)
        //let newId = findNewId()
        //var convertedDate0 = formatter.string(from: now)
        // 資料庫檔案的路徑
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        if let mydb = db {
            if let place = userDe.array(forKey: "placeList"){
                if rowId == 0 { //new mode
                    // insert
                    //if let place = userDe.array(forKey: "placeList") {
                        _ = mydb.insert(
                            tableName, rowInfo: [
                                "id":"\(newId)",
                                "name":"'\(textName.text!)'",
                                "place":"'\(place[pickerViewPlace.selectedRow(inComponent: 0)])'",
                                "inputDate":"'\(inputdate)'",
                                "expiredDate": "'\(expireddate)'",
                                "person":"'\(textInputPerson.text!)'"])
                        print("new entry")
                        userDe.set(newId, forKey: recordId)
                        picPath = NSTemporaryDirectory() + "Picid\(newId).data"//存檔路徑
                }
                else{   //edit mode
                    // update the database
                    
                    _ = mydb.update(
                        tableName,
                        cond: "id = \(rowId)",
                        rowInfo: [
                            "name":"'\(textName.text!)'",
                            "place":"'\(place[pickerViewPlace.selectedRow(inComponent: 0)])'",
                            "inputDate":"'\(inputdate)'",
                            "expiredDate": "'\(expireddate)'",
                            "person":"'\(textInputPerson.text!)'"])
                    //delete original photo if exists
                    if tookPicture == 1 {
                        deletePhoto(rowId:rowId)
                        picPath = NSTemporaryDirectory() + "Picid\(rowId).data"//存檔路徑
                    }
                }
            }
            else {
                print("Have to set place first")
            }
        }
        
        //存照片
        if tookPicture == 1 {
            if let dataToSave = itemImage.image?.jpegData(compressionQuality: 1.0){
                // UIImageJPEGRepresentation(imageToSave, 1.0){
                //********** 寫入檔案 **********
                
                print("saving photo to \(picPath)...")
                do{
                    try dataToSave.write(to: URL(fileURLWithPath: picPath), options: [.atomic])
                }catch{
                    print("無法順利儲存")
                }
            }else{
                print("no photo")
            }
        }
        //let newImage = UIImage(contentsOfFile: picPath)
        //itemImage.image = newImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        print("took a photo!!")
        tookPicture = 1
        //存至相簿
        //UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
        itemImage.image = selectedImage
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func addCamera(_ sender: Any){
        let imagePicker = UIImagePickerController() //生成照相的controller
        imagePicker.sourceType = .camera   //設定相機為來源
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)  //設定照相畫面
    }
    
    @IBAction func showAlbum(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum  //設定相片簿為來源
        imagePicker.delegate = self //as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        present(imagePicker, animated: true, completion: nil)
    }
    func deletePhoto(rowId: Int){
        let fileManager = FileManager()
        let originalPath = NSTemporaryDirectory() + "Picid\(rowId).data"
        print("===deleting photo from \(originalPath)")
        do{ //刪除檔案
            try fileManager.removeItem(atPath: originalPath)
        }catch{
            print("can't delete file")
        }
    }
    func findNewId() -> Int{
        return userDe.integer(forKey: recordId) + 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
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

