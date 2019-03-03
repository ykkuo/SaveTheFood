/***** 參考資料 *****
 教學網站 https://www.raywenderlich.com/5995-beginning-table-views/lessons/4
 viewDidLoad、viewWillAppear等ViewController事件發生順序介紹 https://www.iwaishin.com/ios-viewcontroller-event-introduce/
 虛擬鍵盤 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/%E8%99%9B%E6%93%AC%E9%8D%B5%E7%9B%A4%E9%9A%B1%E8%97%8F-aefaa7a4e3d5
 Date - String 轉換 https://blog.csdn.net/shenjie_xsj/article/details/79033861
 
 照相功能 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/%E7%B0%A1%E6%98%93%E8%AA%AA%E6%98%8Eswift-4-%E5%9F%BA%E6%9C%ACcamera%E8%88%87album%E4%BD%BF%E7%94%A8%E7%B0%A1%E4%BB%8B-19f2ad1cfef8
 
 Table在CollectionView實作 http://www.hangge.com/blog/cache/detail_1678.html

 
 圓角 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/%E5%AF%A6%E9%A9%97imageview%E7%9A%842x-3x%E6%95%88%E6%9E%9C-%E4%B8%A6%E5%8A%A0%E5%85%A5%E5%9C%93%E8%A7%92-990fb0eef130
 
 remove an item from an array https://stackoverflow.com/questions/24051633/how-to-remove-an-element-from-an-array-in-swift
 
 ***SQL***
 SQLite https://www.jianshu.com/p/fc6ce7ee651e
 https://itisjoe.gitbooks.io/swiftgo/content/database/sqlite.html
 
 ***Table***
 向左滑動建立按鈕 https://medium.com/@cwlai.unipattern/app%E9%96%8B%E7%99%BC-%E4%BD%BF%E7%94%A8swift-9-swipe-%E5%90%91%E5%B7%A6%E6%BB%91%E5%8B%95-a0e286660211
 
 cell 設定不能選擇 https://www.crifan.com/swift_let_tableview_cell_untouchable_unselectable/
 https://stackoverflow.com/questions/25127995/make-certain-area-of-uitableviewcell-not-selectable
 建立多個table view cell https://medium.com/@stasost/ios-how-to-build-a-table-view-with-multiple-cell-types-2df91a206429
 table 換頁資料傳遞 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/%E9%A0%81%E9%9D%A2%E9%96%93%E7%9A%84%E8%B3%87%E6%96%99%E5%82%B3%E9%81%9E-%E4%B8%80-448579bd45dd

 Protocols https://medium.com/@cwlai.unipattern/app%E9%96%8B%E7%99%BC-%E4%BD%BF%E7%94%A8swift-6-protocols-ffd700ea23bc

 
 *******************/

/******Outstanding issues******
 auto-layout for different devices
 delete record
 calendar Chinese //datePicker.locale = Locale(identifier: "")
 better UI
 count down
 icon
 better UI - align
 clean useless objects
 add image - maxId
 click to show big picture 1.1
 bug - drop table also delete picture
 multiple swipe action - 1.1
 edit record
 rebuild the whole thing
 flexible setting for place etc.
 bug - edit mode - image becomes grey
 pick photo from album
 add name tag
 msgboxes for drop table and places adding
 --solved--
 
 OCR - auto detect the expired date
 bug - date diff in the end of a year
 bug - first time add photo leads to nothing
 
 *****************************/
import UIKit
import Foundation

class TableViewController: UITableViewController {
    var tableName = "record"
    let dbCreated = "DbCreated" //for userDefaults
    let recordId = "recordId"   //for userDefaults
    var db :SQLiteConnect?
    let userDe = UserDefaults.standard    //存取是否建立過表格
    let formatter = DateFormatter()
    let picPath = NSTemporaryDirectory()
    
    class item {
        var id = 0
        var name = ""
        var place = ""
        var inputDate = ""
        var expiredDate = ""
        var image = ""
        var person = ""
        init(id: Int, name: String, place: String, inputDate: String, expiredDate: String, image: String, person: String) {
            self.id = id
            self.name = name
            self.place = place
            self.inputDate = inputDate
            self.expiredDate = expiredDate
            self.image = image
            self.person = person
        }
    }
    var items:[item] = []
    
    override func viewDidLoad() {
        print("==main viewDidLoad==")
        super.viewDidLoad()
        formatter.dateFormat = "YYYY-MM-dd"
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        db = SQLiteConnect(path: sqlitePath)
        
        
        //        if let dbExist = userDe.value(forKey: dbCreated) as? Bool{
        if (userDe.value(forKey: dbCreated) as? Bool) == nil{
            print("creating table")
            createTable()
        }
        //set selection for Places
        guard userDe.array(forKey: "placeList") != nil else {
            print ("initial setting for placelist")
            let placeList = ["上層（冷凍）","下層（冷藏）"]
            userDe.set(placeList, forKey: "placeList")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("== main viewWillAppear==")
        //super.viewWillAppear(animated)
        displayRecord()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 1
        
        if items.count == 0{
            return 2    //header + dummy cell
        }
        else{
            return items.count + 1  //header + number of cells
        }
 
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let convertedDate = formatter.date(from: formatter.string(from: Date()))
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let cellRow = indexPath.row - 1
        
        if indexPath.row == 0 { //first cell is used as header
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) //as! TableViewCell
             headerCell.selectionStyle = UITableViewCell.SelectionStyle.none
            return headerCell
        }
        else {
             //display data
            if items.count == 0 {
                //cell.idLabel.text=""
                cell.foodImageView.image = nil
                cell.nameLabel.text = "空無一物，按右上方“＋”新增"
                cell.placeLabel.text = ""
                cell.inputDateLabel.text = ""
                cell.expiredDateLabel.text = ""
                cell.isUserInteractionEnabled = false
                
            }
            else {
                if let itemImage = UIImage(contentsOfFile: picPath + "Picid\(items[cellRow].id).data") {
                    cell.foodImageView.image = itemImage
                }
                else {
                    //print ("no image")
                    cell.foodImageView.image = nil
                }
                cell.idLabel.text = String(items[cellRow].id)
                cell.nameLabel.text = " " + items[cellRow].name
                
                // inputDate - 今天
                var days = Date().daysBetweenDate(fromDate: convertedDate!, toDate: formatter.date(from: items[cellRow].inputDate)!)
                cell.inputDateLabel.text = "已被\(items[cellRow].person)放到\(items[cellRow].place)\(-days)天"
                
                cell.expiredDateLabel.text = items[cellRow].expiredDate
                // expiredDate - 今天
                days = Date().daysBetweenDate(fromDate: convertedDate!, toDate: formatter.date(from: items[cellRow].expiredDate)!)
                if days<0 {
                    cell.placeLabel.text = "已過期\(-days)天!!"
                    cell.placeLabel.textColor = UIColor.red
                    
                }
                else if days == 0 {
                    cell.placeLabel.text = "今天到期!!"
                    cell.placeLabel.textColor = UIColor.red
                    
                }
                else{
                    cell.placeLabel.text = "還可以放\(String(days))天"
                }
                //cell.foodImageView.image = UIImage(named: restaurants[indexPath.row].image)
                
            }
        }
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    /*
     
     */
    // Override to support editing the table view.
    // only work for one button
    /*
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     
     if (items.count != 0 && editingStyle == .delete && indexPath.row != 0) {
     
     // Delete the row from the data source
     deleteRow(rowId: items[indexPath.row-1].id)
     
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     
     }
     */
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (items.count != 0) { if (indexPath.row != 0){
            let deleteAction = UITableViewRowAction(style: .default, title: "刪除", handler: { (action, indexPath) -> Void in
                // Delete the row from the data source
                self.deleteRow(rowId: self.items[indexPath.row-1].id)
            })
            let editAction = UITableViewRowAction(style: .default, title: "修改", handler: { (action, indexPath) -> Void in
                self.editRecord(rowId: self.items[indexPath.row-1].id)
            })
            editAction.backgroundColor = UIColor.green
            //deleteAction.backgroundColor = UIColor.green
            //print(indexPath.row)
            return [deleteAction,editAction]
        }}
        print("no enter")
        print("indexPath = \(indexPath.row)")
        return []
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print(segue.identifier)
        if items.count != 0{
            //print("preparing count==0")
            if segue.identifier == "DetailPage"{
                if let controller = storyboard?.instantiateViewController(withIdentifier: "DetailPageView") as? DetailViewController {
                    print("enter controller")
                    print("item id: \(items[(self.tableView.indexPathForSelectedRow?.row)!-1].id)")
                    controller.rowId = (items[(self.tableView.indexPathForSelectedRow?.row)!-1].id)
                    present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func displayRecord(){
        items = []
        // 資料庫檔案的路徑
        if let dbExist = userDe.value(forKey: dbCreated) as? Bool{
            //print("dbExist = \(dbExist)")
            if dbExist == true{
                print("fetching data...")
                let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
                db = SQLiteConnect(path: sqlitePath)
                if let mydb = db {
                    // select
                    let statement = mydb.fetch(
                        tableName, cond: "1 == 1", order: "expiredDate asc")
                    while sqlite3_step(statement) == SQLITE_ROW{
                        
                        let id = sqlite3_column_int(statement, 0)
                        let name = String(cString:sqlite3_column_text(statement, 1)!)
                        let place = String(cString:sqlite3_column_text(statement, 2)!)
                        let inputDate = String(cString:sqlite3_column_text(statement, 3)!)
                        let expiredDate = String(cString:sqlite3_column_text(statement, 4)!)
                        let person = String(cString:sqlite3_column_text(statement, 5)!)
                        print("\(id). \(name) 位置: \(place) 放入日期： \(inputDate) 到期日: \(expiredDate)")
                        items.append(item(id: Int(id), name: name, place: place, inputDate: inputDate, expiredDate: expiredDate, image: "", person: person))
                    }
                    
                    sqlite3_finalize(statement)
                    
                }
            }
            print("data retrieved: \(items.count)")
            tableView.reloadData()
        }
    }
    func deleteRow(rowId: Int){
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        db = SQLiteConnect(path: sqlitePath)
        
        if let _=userDe.value(forKey: "DbCreated"){
            if let mydb = db {
                print("deleting row \(rowId)...")
                //delete record in database
                _ = mydb.delete(tableName, cond: "id = \(rowId)")
                //delete photo
                deletePhoto(rowId: rowId)
                //set recordId if deleting the last row
                if rowId == userDe.integer(forKey: recordId){
                    userDe.set(userDe.integer(forKey: recordId) - 1, forKey: recordId)
                }
                
                displayRecord()
            }
        }
    }
    func editRecord(rowId: Int){
        print("edit record")
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "NewPageView") as? NewViewController {
            print("new page controller")
            controller.rowId = rowId
            present(controller, animated: true, completion: nil)
        }
        
    }
    func createTable(){
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        db = SQLiteConnect(path: sqlitePath)
        
        print("creating new table")
        if let mydb = db {
            
            // create table
            _ = mydb.createTable(tableName, columnsInfo: [
                "id integer primary key",
                "name text",
                "place text",
                "inputDate text",
                "expiredDate text",
                "person text"])
            userDe.set(true, forKey: dbCreated)
            userDe.set(0, forKey: recordId)
            //complete saving
            userDe.synchronize()
        }
        
    }
    func deletePhoto(rowId: Int){
        let fileManager = FileManager()
        let originalPath = NSTemporaryDirectory() + "Picid\(rowId).data"
        do{ //刪除檔案
            try fileManager.removeItem(atPath: originalPath)
        }catch{
            print("can't delete file")
        }
    }
    @IBAction func dropTable(){
        showAlert()
    }
    func showAlert(){
        //show success message
        let controller = UIAlertController(title: "確定嗎", message: "要刪除全部資料？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            action in
            self.dropAllData()
        })
        let cancelAction = UIAlertAction(title: "還是算了", style: .cancel, handler: nil)
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
        
    }
    func dropAllData(){
        //check and delete photos if available
        for i in 0...items.count{
            //delete photo
            deletePhoto(rowId: i)
        }
        //drop table
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        db = SQLiteConnect(path: sqlitePath)
        if let mydb=db{
            _ = mydb.dropTable(tableName)
        }
        createTable()
        displayRecord()
    }
    
}


extension Date {
    func daysBetweenDate(fromDate: Date, toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
        return components.day ?? 0
    }
}
