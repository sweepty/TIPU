//
//  CalendarListViewController.swift
//  tipu_doing02
//
//  Created by JunHee on 01/04/2018.
//  Copyright © 2018 JunHee. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import SnapKit
class CalendarListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var date: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var tableview: UITableView!
    
    var curDate:String = ""
    var perform: [NSManagedObject] = []
    var refresh: UIRefreshControl!
    var eventStore: EKEventStore?
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        //새로고침
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresher), for: .valueChanged)
        tableview.addSubview(refresh)
        
        // navagation bar
        self.navigationItem.title = "TIPU"
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        
        // get data from DB
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Perform")
        fetchRequest.predicate = NSPredicate(format: "deadline contains[c] %@", curDate)
        
        // sorting
        let sortDescriptor = NSSortDescriptor (key: "saveDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            perform = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // reload
        self.tableview.reloadData()
        
        // 날짜, 개수
        let arr = curDate.components(separatedBy: "-")
        let monthStr = arr[1]
        let dateStr = arr[2]
        let monthInt : Int = Int(monthStr)!
        let dateInt : Int = Int(dateStr)!
        self.date.text = "\(monthInt)월 \(dateInt)일"
        self.count.text = "총 \(perform.count) 개"
        
        // tableview backgrond
        tableview.backgroundColor = UIColor(red: CGFloat(242/255.0), green: CGFloat(242/255.0), blue: CGFloat(242/255.0), alpha: CGFloat(1.0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return perform.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @objc func refresher(_ sender: Any) {
        
        // 테이블 뷰 새로고침
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Perform")
        fetchRequest.predicate = NSPredicate(format: "deadline contains[c] %@", curDate)
        
        //정렬
        let sortDescriptor = NSSortDescriptor (key: "saveDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            perform = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            
        }
        
        self.tableview?.reloadData()
        
        // 이 앱을 통해 저장한 이전의 모든 알림 삭제
        refresh.endRefreshing()
    }
    
    // View가 보여질 때 자료를 DB에서 가져오도록 한다
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Perform")
        fetchRequest.predicate = NSPredicate(format: "deadline contains[c] %@", curDate)
        
        //정렬
        let sortDescriptor = NSSortDescriptor (key: "saveDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            perform = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        self.tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List Cell") as! ListTableViewCell
        
        //티켓버튼
        cell.ticketBtn.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(55)
            make.left.equalTo(20)
            make.top.equalToSuperview().offset(20)
        }
        
        //바
        cell.bar.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(1)
            make.height.equalToSuperview()
            make.left.equalTo(cell.cellView).offset(90)
            make.top.equalToSuperview()
        }
        cell.titleText.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(cell.bar).offset(20)
            make.width.equalToSuperview().offset(-30)
        }
        cell.deadlineText.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(50)
            make.left.equalTo(cell.bar).offset(25)
            make.width.equalToSuperview().offset(-30)
        }
        
        // cell 스타일
        cell.cellView.layer.cornerRadius = 7
        cell.backgroundColor = UIColor(red: CGFloat(242/255.0), green: CGFloat(242/255.0), blue: CGFloat(242/255.0), alpha: CGFloat(1.0))
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        cell.contentView.backgroundColor = UIColor(red: CGFloat(242/255.0), green: CGFloat(242/255.0), blue: CGFloat(242/255.0), alpha: CGFloat(1.0))
        
        let perform = self.perform[indexPath.row]
        var display: String = ""
        var sub:String = ""
        
        if let nameLabel = perform.value(forKey: "name") as? String {
            display = nameLabel
        }
        
        if let deadline = perform.value(forKey: "deadline") as? String {
            let text = deadline.components(separatedBy: " ")
            let kk = text[1].components(separatedBy: "-")
            sub = "입금기한 | "+kk[0]+"."+kk[1]+"."+kk[2]+" "+text[2]+" 까지"
        }
        
        //계좌번호만 알아내도록 자르기
        let account_origin: String = perform.value(forKey: "account") as! String
        let array = account_origin.components(separatedBy: " | ")
        let accountNum = Int(array[1])
        
        // cell button image 설정
        if let image = perform.value(forKey: "deposit") as? Bool {
            if image == true {
                cell.ticketBtn?.setImage(UIImage(named: "paid"), for: .normal)
                cell.ticketBtn?.tag = Int(accountNum!)
            }
            else {
                cell.ticketBtn?.setImage(UIImage(named: "not_paid"), for: .normal)
                cell.ticketBtn?.tag = Int(accountNum!)
            }
        }
        
        let deviceType = UIDevice.current.deviceType
        
        switch deviceType {
            
        case .iPhone4_4S:
            cell.titleText.font = UIFont (name: "HelveticaNeue-Medium", size: 15)
            cell.deadlineText.font = UIFont (name: "AppleSDGothicNeo-Light", size: 10)
            
        case .iPhones_5_5s_5c_SE:
            cell.titleText.sizeToFit()
            cell.titleText.font = UIFont (name: "HelveticaNeue-Medium", size: 16.5)
            cell.deadlineText.font = UIFont (name: "AppleSDGothicNeo-Light", size: 12)
            
        case .iPhones_6_6s_7_8:
            cell.titleText.font = UIFont (name: "HelveticaNeue-Medium", size: 18.5)
            cell.deadlineText.font = UIFont (name: "AppleSDGothicNeo-Light", size: 13)
            
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            cell.titleText.font = UIFont.systemFont(ofSize: 20.5)
            cell.deadlineText.font = UIFont.systemFont(ofSize: 14)
            
            cell.titleText.font = UIFont (name: "HelveticaNeue-Medium", size: 20.5)
            cell.deadlineText.font = UIFont (name: "AppleSDGothicNeo-Light", size: 14)
            
        case .iPhoneX:
            cell.titleText.font = UIFont (name: "HelveticaNeue-Medium", size: 20.5)
            cell.deadlineText.font = UIFont (name: "AppleSDGothicNeo-Light", size: 14)
            
        default:
            print("iPad or Unkown device")
            cell.titleText.font = UIFont (name: "HelveticaNeue-Medium", size: 18.5)
            cell.deadlineText.font = UIFont (name: "AppleSDGothicNeo-Light", size: 13)
        }
        
        cell.ticketBtn?.addTarget(self, action: #selector(clickTicketBtn), for: .touchUpInside)
        cell.titleText.text = display
        cell.deadlineText.text = sub
        
        return cell
    }
    
    @IBAction func clickTicketBtn(_ sender: UIButton) {
        let context = getContext()
        let accountNum = String(sender.tag)
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Perform")
        let predicate = NSPredicate(format: "account contains[c] %@", accountNum)
        
        fetchRequest.predicate = predicate
        do {
            let test = try context.fetch(fetchRequest)
            let objectUpdate = test[0] as! NSManagedObject
            if var deposit = objectUpdate.value(forKey: "deposit") as? Bool {
                if deposit == true {
                    deposit = false
                } else{
                    deposit = true
                }
                objectUpdate.setValue(deposit, forKey: "deposit")
            }
            do{
                try context.save()
            }
            catch
            {
                print(error)
            }
            self.tableview.reloadData()
        }
        catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Core Data 내의 해당 자료 삭제
            let context = getContext()
            context.delete(perform[indexPath.row])
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not delete \(error), \(error.userInfo)") }
            // 배열에서 해당 자료 삭제
            perform.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // 테이블 뷰 개수
            self.count.text = "총 \(Int(String(self.count.text![2]))!-1) 개"
        } else if editingStyle == .insert {
        }
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}
