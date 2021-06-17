//
//  ViewController.swift
//  DemoOfSqLite3
//
//  Created by Bhavin J kansara on 5/8/21.
//

import UIKit
import SQLite3
import SwiftyJSON
import Alamofire
import LoadingPlaceholderView

class tableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
}

class ViewController: UIViewController {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var tableViewBG: UITableView!
    
    var arrJobList = [JobList]()
    var dataBase: OpaquePointer?
    var getResponseData = JSON()
    var loadingPlaceholderView = LoadingPlaceholderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createTable()
        if (WebService().internetChecker(reachability: Reachability()!)) {
            self.setupLoadingPlaceholderView()
            self.performFakeNetworkRequest()
            self.getJobListData()
        }
        else{
            self.getDataWithApi()
        }
        
    }
    func setupLoadingPlaceholderView() {
        loadingPlaceholderView.gradientColor = .white
        loadingPlaceholderView.backgroundColor = .white
    }
    func performFakeNetworkRequest() {
      //  loadingPlaceholderView.cover(self.view)
    }
    func finishFakeRequest() {
        self.tableViewBG.reloadData()
        self.loadingPlaceholderView.uncover()
    }
    func getJobListData() {
       getAllData { (data, error) in
            if (error==nil) {
                
                self.InternalStoregeData()
                print(data!)
                    let viewM =  viewModel(data: data!)
                    self.arrJobList = viewM.JobResponseData!
             //   self.arrJobList = (data?.responseData.jobList)!
                
                DispatchQueue.main.async {
                    self.tableViewBG.reloadData()
                }
            }
        }
    }

}
extension ViewController {
    
    func createTable() {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("JobListss.sqlite")
        
        // open database
        
        if sqlite3_open(fileURL.path, &dataBase) != SQLITE_OK {
            print("error opening database")
        }
        
        print(fileURL.path)
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS JoblistData (userID INTEGER PRIMARY KEY AUTOINCREMENT, getResponseData TEXT)"
        
        if sqlite3_exec(dataBase, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error creating table: \(errmsg)")
        }
        
        print("Everything is fine")
        
    }
    
//    func createTable(){
//
//        let fileURL = try! FileManager.default.url(for: .documentationDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            .appendingPathComponent("job.sqlite")
//
//        if sqlite3_open(fileURL.path, &dataBase) != SQLITE_OK {
//            print("error opening database")
//        }
//
//        let createTableQuery = "CREATE TABLE IF NOT EXISTS JoblistData (userID INTEGER PRIMARY KEY AUTOINCREMENT, getResponseData TEXT)"
//        //(CategoryID INTEGER PRIMARY KEY AUTOINCREMENT,
//
//        if sqlite3_exec(dataBase, createTableQuery, nil, nil, nil) != SQLITE_OK {
//            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
//            print("error creating table: \(errmsg)")
//        }
//
//        print("Everything is fine")
//    }
    func InternalStoregeData() {
        var stmt: OpaquePointer?
        
        let Responce = getResponseData.rawString()
        let DeleteQuery = "DELETE FROM JoblistData"
        
        if sqlite3_prepare(dataBase, DeleteQuery, -1, &stmt, nil) != SQLITE_OK {
            print("error binding query")
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("Delete successfully")
        }
        
        let insertQuery = "INSERT INTO JoblistData (getResponseData) VALUES ('\(Responce!)')"
        
        if sqlite3_prepare(dataBase, insertQuery, -1, &stmt, nil) != SQLITE_OK {
            print("error binding query")
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("test saves successfully")
        }
    }
    func getDataWithApi(){
        
        var stmt: OpaquePointer?
        let selectSql = "SELECT * FROM JoblistData"
        
        if sqlite3_prepare_v2(dataBase, selectSql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                let RegionID = sqlite3_column_int(stmt, 0)
                let getResponseData = String(cString: sqlite3_column_text(stmt, 1))
                
                let data = Data(getResponseData.utf8)
                
                do {
                    if let jsonObject = try? JSON(data: data) {
                       
                        let datas = jsonObject["ResponseData"]["job_list"].arrayValue
                        self.arrJobList.removeAll()
                        
                        DispatchQueue.main.async {
                            self.finishFakeRequest()
                        }
                        
                      
                        for i in datas {
                            let decoder = JSONDecoder.init()
                            let obj : JobList = try decoder.decode(JobList.self, from: i.rawData())
                            self.arrJobList.append(obj)
                        }
                       
                        self.tableViewBG.reloadData()
                        
                    }
                    
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
    }
}
extension ViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrJobList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! tableViewCell
        let dictMain = self.arrJobList[indexPath.row]
        cell.lbl1.text = dictMain.jobTitle
        cell.lbl2.text = dictMain.clientName
        cell.lbl3.text = dictMain.jobLocation
        
        return cell
    }
    
}
extension ViewController {
    func getAllData(completion: @escaping (Welcome?, Error?) -> ()) {
        let url = "https://www.cloudrek.com/cradmin/api/jobseeker/app/job/saved"
      //  var req = URLRequest(url: url.asURL())
        var req = URLRequest(url: try! url.asURL())
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [:]
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue("eyJpdiI6ImxRK3hSd21xbmJpZnIyS1lXeUZMcHc9PSIsInZhbHVlIjoiTmJ2Y1dtN1JEb2s3UXZCYnU5ZlpWbmxVMWJpWmRaeGZLdUdqTWZycEs2SWp6WmhIM2pCWFBjRFhBRStzUVNDUUVNZEFsYTdrWFlWcG4xYnQxYXJGRzVcLzVybm83QjJuS2QrXC9rMmpKSHRNNzdycFdhYjVWQUdvQ1hQNUtta3pROWdoSE5LV2JoZFA1VnBLMW9JTytKK2t5dkM5Uk5hNEVsUWFxNDVFSzJudk1QUzNvNkJHcnJKY2JoY1ZTeE56UWsiLCJtYWMiOiI0YWJhNGU1ZmExYjVkZjZmNmVhYzQ4MTdmMmZkZjk1NzY3YTk0YzFiZDYzZGViMGU0ZDZiZDNmMWMyODQ2NzEzIn0=", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 20

        Alamofire.request(req).responseJSON { response in
          if let error = response.error {
            completion(nil, error)
            return
          }
          if let data = response.data {
            self.getResponseData = JSON(data)
            print(data)
            
            do {
            let joblistData: Welcome = try! JSONDecoder().decode(Welcome.self, from: data)
                completion(joblistData, nil)
            }
            catch let jsonError {
                print(jsonError.localizedDescription)
            }
          }
        }
      }
}
