
import UIKit

class ViewController_NewExpDate: UIViewController {
    @IBOutlet weak var pickerExpiredDate: UIDatePicker!
    var db :SQLiteConnect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func save(){
        let userDe=UserDefaults.standard    //存取是否建立過表格
        let tableName :String = "record"
        var newId: Int = 0
        let recordId = "recordId"
        
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expireddate = formatter.string(from: pickerExpiredDate.date)
        // 獲取當前時間
        let inputdate = formatter.string(from: Date())
        
        newId=userDe.integer(forKey: recordId) + 1
        
        db = SQLiteConnect(path: sqlitePath)
        if let mydb = db {
            if let place = userDe.array(forKey: "placeList"){
                // insert
                _ = mydb.insert(
                    tableName, rowInfo: [
                                    "id":"\(newId)",
                                    "name":"'\(userDe.value(forKey: "newName")!)'",
                                    "place":"'\(userDe.value(forKey: "newPlace")!)'",
                                    "inputDate":"'\(inputdate)'",
                                    "expiredDate": "'\(expireddate)'",
                                    "person":"''"
                    ]
                )
                print("new entry")
                userDe.set(newId, forKey: recordId)
            }
        }
    }
}
