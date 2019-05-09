//
//  BPLogViewController.swift
//  mybplog
//
//  Created by Rodney Witcher on 9/14/18.
//  Copyright © 2018 Pluckshot. All rights reserved.
//

import UIKit
import os.log
import RealmSwift
import GoogleMobileAds

//MARK: model
final class DB_BPEntry: Object {
    @objc dynamic var keyEntryDate = Date()
    @objc dynamic var entryDate = Date()
    @objc dynamic var systolic = 0
    @objc dynamic var diastolic = 0
    @objc dynamic var pulse = 0
    @objc dynamic var notes = ""
}

class BPLogViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, GADBannerViewDelegate {

    //MARK: properties
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    @IBOutlet weak var systolicTextField: UITextField!
    @IBOutlet weak var diastolicTextField: UITextField!
    @IBOutlet weak var pulseTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextView!
    @IBOutlet weak var navSave: UIBarButtonItem!
    @IBOutlet weak var bodySave: UIButton!
    @IBOutlet weak var EntryScrollView: UIScrollView!
    @IBOutlet weak var ContentStackView: UIStackView!
    @IBOutlet weak var InputTestFieldsView: UIStackView!
    @IBOutlet weak var SystolicView: UIStackView!
    @IBOutlet var TopView: UIView!
    
    var bpEntry: BPEntry?
    var currentBpEntryKey: Date?
    var bannerView: GADBannerView!
    
    //MARK: UITextFieldDelegate
    
    
    //MARK: navigation
    @IBAction func navCancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddEntryMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEntryMode {
            dismiss(animated: true, completion: nil)
        }else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The BPLogViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === navSave else {
            if #available(iOS 10.0, *) {
                os_log("The navsave button was not pressed, cancelling", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 10.0, *) {
                os_log("checking bodySave button", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            guard let buttonCheck = sender as? UIButton, buttonCheck === bodySave else {
                if #available(iOS 10.0, *) {
                    os_log("The body save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                } else {
                    // Fallback on earlier versions
                }
                return
            }
            let entryDate = entryDatePicker.date
            let systolic = systolicTextField.text ?? "0"
            let diastolic = diastolicTextField.text ?? "0"
            let pulse = pulseTextField.text ?? "0"
            let notes = notesTextField.text

            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            let dt =  df.string(from:(currentBpEntryKey!))
            
            if #available(iOS 10.0, *) {
                if dt == "" {
                    os_log("dt empty", log: OSLog.default, type: .debug)
                } else {
                    os_log("dt not empty", log: OSLog.default, type: .debug)
                }
            } else {
                // Fallback on earlier versions
            }
            
            bpEntry = BPEntry(_keydatetime: currentBpEntryKey!, _datetime: entryDate, _systolic: Int(systolic) ?? 0, _diastolic: Int(diastolic) ?? 0, _pulse: Int(pulse) ?? 0, _notes: notes)
            return
        }
        
        let entryDate = entryDatePicker.date
        let systolic = systolicTextField.text ?? "0"
        let diastolic = diastolicTextField.text ?? "0"
        let pulse = pulseTextField.text ?? "0"
        let notes = notesTextField.text
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        let dt =  df.string(from:(currentBpEntryKey!))
            
        if #available(iOS 10.0, *) {
            if dt == "" {
                os_log("dt empty", log: OSLog.default, type: .debug)
            } else {
                os_log("dt not empty", log: OSLog.default, type: .debug)
            }
        } else {
            // Fallback on earlier versions
        }
        
        bpEntry = BPEntry(_keydatetime: currentBpEntryKey!, _datetime: entryDate, _systolic: Int(systolic)!, _diastolic: Int(diastolic)!, _pulse: Int(pulse)!, _notes: notes)
    }
    
    //MARK: private methods
    override func viewDidLoad() {
        super.viewDidLoad()
        systolicTextField.delegate = self
        diastolicTextField.delegate = self
        pulseTextField.delegate = self
        notesTextField.delegate = self
        
        notesTextField.layer.borderColor = UIColor.gray.cgColor
        notesTextField.layer.borderWidth = 1.0
        notesTextField.layer.cornerRadius = 15.0
        
        // Do any additional setup after loading the view, typically from a nib.
        if let bpEntry = bpEntry {
            
            navigationItem.title = "Editing Entry ..."
            entryDatePicker.date = bpEntry.datetime
            systolicTextField.text = String(bpEntry.systolic)
            diastolicTextField.text = String(bpEntry.diastolic)
            pulseTextField.text = String(bpEntry.pulse)
            notesTextField.text = bpEntry.notes
            currentBpEntryKey = bpEntry.keydatetime
        } else {
            currentBpEntryKey = Date()
        }
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(self.scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        EntryScrollView.addGestureRecognizer(scrollViewTap)
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3092609430769673/7894201421"
        //Test adUnitID = ca-app-pub-3940256099942544/2934735716
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")
        self.view.endEditing(true)
    }
    @objc func scrollViewTapped() {
        self.view.endEditing(true)
    }
 
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            if #available(iOS 10.0, *) {
                os_log("about to return from textview", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        EntryScrollView.setContentOffset(CGPoint(x: 0, y:250), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        EntryScrollView.setContentOffset(CGPoint(x: 0, y:-50), animated: true)
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
