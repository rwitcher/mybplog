//
//  BPEntryTableViewController.swift
//  mybplog
//
//  Created by Rodney Witcher on 9/18/18.
//  Copyright © 2018 Pluckshot. All rights reserved.
//

import UIKit
import os.log
import RealmSwift

class BPEntryTableViewController: UITableViewController {

    //MARK: Properties
    var bpEntryList = [BPEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Use the edit button item provided by the table view controller.
        self.navigationItem.leftBarButtonItem = editButtonItem
        if let retrievedBPEntries = loadBPEntryList() {
            bpEntryList += retrievedBPEntries
            if bpEntryList.count == 0 {
                let alertController = UIAlertController(title: "No Entries Yet", message: "To start, click 'Create' below or push the '+' in the top right corner", preferredStyle: .alert)
                let createAction = UIAlertAction(title: "Create", style: .default) { (action:UIAlertAction) in
                    print("You've pressed create");
                    self.performSegue(withIdentifier: "AddEntry", sender: self)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                    print("You've pressed cancel");
                }
                alertController.addAction(createAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            bpEntryList = []
        }
        /*
        bpEntryList.sort {
            switch($0, $1) {
            case ($0.keydatetime, $1.keydatetime): return $0.keydatetime > $1.keydatetime;
            }
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bpEntryList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BPEntryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BPEntryTableViewCell else {
            fatalError("The dequeued cell is not an instance of BPEntryTableViewCell.")
        }
        let bpEntry = bpEntryList[indexPath.row]
        // Configure the cell...
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        cell.dateTimeLabel.text = "   " + df.string(from:(bpEntry.datetime))
        cell.bpLabel.text = String(bpEntry.systolic) + " - " + String(bpEntry.diastolic)
        cell.pulseLabel.text = String(bpEntry.pulse)
        cell.notesLabel.text = bpEntry.notes
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let deletedBPEntry = bpEntryList[indexPath.row]
            deleteBPEntry(e: deletedBPEntry)
            bpEntryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController.
        switch(segue.identifier ?? "") {
        case "AddEntry":
            if #available(iOS 10.0, *) {
                os_log("Adding a new bp entry.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        case "ShowEntry":
            if #available(iOS 10.0, *) {
                os_log("Show a bp entry.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            guard let bpEntryDetailViewController = segue.destination as? BPLogViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedBpEntryCell = sender as? BPEntryTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "nosenderfound")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBpEntryCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            // Pass the selected object to the new view controller.
            let selectedBpEntry = bpEntryList[indexPath.row]
            bpEntryDetailViewController.bpEntry = selectedBpEntry
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "noseguefound")")
        }
    }

    //MARK: actions
    @IBAction func unwindToBPList(sender: UIStoryboardSegue) {
        //Check the sender, confirming it's from the BpEntry Detail ViewController.  If it is set bpEntry to the bpEntry from the source
        if let sourceViewController = sender.source as? BPLogViewController, let bpEntry = sourceViewController.bpEntry {
            //First check if the tableView has a selected Row/BpEntry
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update the selected/existing bpEntry/row
                bpEntryList[selectedIndexPath.row] = bpEntry
                bpEntryList.sort( by: {$0.keydatetime > $1.keydatetime});
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                tableView.reloadData();
            } else {
                // Add a new bpentry
                
                //If adding at end
                //let newIndexPath = IndexPath(row: bpEntryList.count, section: 0)
                //tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                //If adding at front
                let newIndexPath = IndexPath(row: 0, section: 0)
                bpEntryList.insert(bpEntry, at: 0);
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                bpEntryList.sort( by: {$0.keydatetime > $1.keydatetime});
                tableView.reloadRows(at: [newIndexPath], with: .none)
                tableView.reloadData();
            }
            //Save this new entry
            saveBPEntry(e: bpEntry)
        }
    }
    
    @IBAction func exportLog(_ sender: UIBarButtonItem) {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        let bpList = loadBPEntryList()
        var rawExpString = "Blood Pressure Entries\n\n";
        for entry in bpList! {
            let dt =  df.string(from:(entry.datetime))
            rawExpString = rawExpString + dt + "\n - Blood Pressure: " + String(entry.systolic) + "/" + String(entry.diastolic) + " mmHg \n"
            rawExpString += " - Pulse: " + String(entry.pulse) + " bpm \n"
            rawExpString += " - Notes: " + String(entry.notes!) + "\n\n"
        }
        let expString = [rawExpString]
        let ac = UIActivityViewController(activityItems: expString, applicationActivities: [])
        ac.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        present(ac, animated: true)
        //ac.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
    }
    
    //MARK: private methods
    private func saveBPEntry(e: BPEntry) {
        let realm = try! Realm()
        let entryObject = realm.objects(DB_BPEntry.self).filter("entryDate = %@", e.datetime)
        if entryObject.count == 0 {
        
            let newEntry = DB_BPEntry()
            newEntry.keyEntryDate = e.keydatetime
            newEntry.entryDate = e.datetime
            newEntry.systolic = e.systolic
            newEntry.diastolic = e.diastolic
            newEntry.pulse = e.pulse
            newEntry.notes = e.notes!
            
            //let realm = try! Realm()
            try! realm.write {
                realm.add(newEntry)
            }
        } else {
            
            //let realm = try! Realm()
            try! realm.write {
                entryObject[0].entryDate = e.datetime
                entryObject[0].systolic = e.systolic
                entryObject[0].diastolic = e.diastolic
                entryObject[0].pulse = e.pulse
                entryObject[0].notes = e.notes!
            }
        }
    }
    
    private func deleteBPEntry(e: BPEntry) {
        let realm = try! Realm()
        let entryObject = realm.objects(DB_BPEntry.self).filter("keyEntryDate = %@", e.keydatetime)
        try! realm.write {
            realm.delete(entryObject)
        }
    }
    
    private func loadBPEntryList() -> [BPEntry]? {
        var dbEntries = [BPEntry]()
        let realm = try! Realm()
        let entries: Results<DB_BPEntry> = realm.objects(DB_BPEntry.self).sorted(byKeyPath: "entryDate", ascending: false)
        for entry in entries {
            let dbEntry = BPEntry(_keydatetime: entry.keyEntryDate, _datetime: entry.entryDate, _systolic: entry.systolic, _diastolic: entry.diastolic, _pulse: entry.pulse, _notes: entry.notes)
            dbEntries.append(dbEntry!)
        }
        return dbEntries
    }
}
