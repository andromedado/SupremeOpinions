//
//  FirstViewController.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import UIKit

enum FirstSection : Int, intValuable {
    case Reload
    case Available
    case NumSections
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReloadTableViewCellDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var button : UIButton!
    var available : [Opinion] = []
    var reloading : Bool?
    var fetching : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let path = FileManager.instance().availableOpinionsCacheFile
        if let data = NSData(contentsOfFile: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            self.available = unarchiver.decodeObjectForKey("available") as! Array
        }
        ReloadTableViewCell.registerWithTableView(tableView)
    }



    func buttonTap(cell: ReloadTableViewCell) {
        if ((self.reloading) != nil && self.reloading!) {
            return
        }
        cell.button.enabled = false
        self.reloading = true
        cell.progressBar.progress = 0
        cell.progressBar.hidden = false
        var promise = Fetcher.instance().availableOpinionsPromise().then({ (opinions) -> AnyObject? in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.available = opinions
                self.reloading = false
                cell.button.enabled = true
                cell.progressBar.setProgress(1, animated: true)
                self.tableView.reloadSection(FirstSection.Available)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * 1000000000), dispatch_get_main_queue(), { () -> Void in
                    cell.progressBar.hidden = true
                })
            })
            let nsOpinions = opinions as NSArray
            let path = FileManager.instance().availableOpinionsCacheFile
            let mutableData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: mutableData)
            archiver.encodeObject(opinions, forKey: "available")
            archiver.finishEncoding()
            let res = mutableData.writeToFile(path, atomically: true)
            return nil
        }, errorCallback: { (error) -> AnyObject? in
            println("Promise Rejected")
            println(error)
            return nil
        })
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 0
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            if let opinion = self.opinion(forIndexPath: indexPath) {
                var alert = UIAlertView(title: opinion.name, message: opinion.summary, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }

    func opinion(forIndexPath indexPath:NSIndexPath) -> Opinion? {
        return self.available[indexPath.row]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let opinion = self.opinion(forIndexPath: indexPath) {
            if (opinion.docket == nil) {
                return
            }
            if (opinion.downloaded) {
                self.tabBarController?.selectedIndex = 1
                if let second = self.tabBarController?.viewControllers?[1] as? SecondViewController {
                    second.presentOpinion(opinion)
                }
                return
            }
            let docket = self.available[indexPath.row].docket!
            if (contains(self.fetching, docket)) {
                return//Already Fetching
            }
            self.fetching.append(docket)
            opinion.download({ (err) -> () in
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                self.updateCell(cell, atIndexPath: indexPath)
            }, progress: nil)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        let fullWidth = self.tableView.bounds.width
        if (indexPath.section == 0) {
//            self.button?.frame = CGRect(x: 0, y: 0, width: fullWidth, height: cell.bounds.height)
//            cell.addSubview(self.button)
//            let xConstraint = NSLayoutConstraint(item: cell, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
//            cell.addConstraint(xConstraint)
//            let yConstraint = NSLayoutConstraint(item: cell, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
//            cell.addConstraint(yConstraint)
            let reloadCell = ReloadTableViewCell.dequeueFromTableView(tableView) as! ReloadTableViewCell
            reloadCell.delegate = self;
            cell = reloadCell;
        } else {
            self.updateCell(cell, atIndexPath: indexPath)
        }

        return cell
    }

    private func updateCell(cell:UITableViewCell?, atIndexPath indexPath: NSIndexPath) -> () {
        if (cell == nil) {
            return
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let certainCell = cell!
            if let opinion = self.opinion(forIndexPath: indexPath) {
                certainCell.textLabel?.text = opinion.name
                var accessoryType : UITableViewCellAccessoryType = .DetailButton
                if (opinion.downloaded) {
                    accessoryType = .DetailDisclosureButton
                }
                certainCell.accessoryType = accessoryType
            }
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = FirstSection(rawValue: section) {
            switch(section) {
            case .Reload:
                return 1
            case .Available:
                return self.available.count
            default:
                return 0
            }
        }
        return 0
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FirstSection.NumSections.rawValue
    }

}

