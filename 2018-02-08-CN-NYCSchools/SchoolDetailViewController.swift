//
//  SchoolDetailViewController.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/12/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit
import SafariServices;
import MessageUI;

class SchoolDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var schoolData : SchoolDataObject?
    
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var numOfSATTestTakersLabel: UILabel!
    @IBOutlet weak var satCriticalReadingAvgScoreLabel: UILabel!
    @IBOutlet weak var satMathAvgScoreLabel: UILabel!
    @IBOutlet weak var satWritingAvgScoreLabel: UILabel!

    @IBOutlet weak var overViewParagrapgTextView: UITextView!

    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Information"
        
        if(self.schoolData != nil)
        {
            self.schoolLabel.text = self.schoolData?.schoolName;
            self.overViewParagrapgTextView.text = self.schoolData?.overviewParagraph;
            
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbn.lowercaseString contains[c] %@", self.schoolData.dbn.lowercaseString];
//            NSArray *filtered = [[ApplicationDataObject sharedData].schoolScoresList filteredArrayUsingPredicate:predicate];
            let searchString = self.schoolData!.dbn!.lowercased()
            var filtered : Array<SchoolScoresDataObject>  = ApplicationDataObject.shared.schoolScoresList.filter{$0.dbn!.lowercased().contains(searchString.lowercased())}

            // Should be found once and only once, considering all other counts including greater than 1 to be an error condition
            if(filtered.count == 1)
            {
                let schoolScoresDataObject = filtered[0] as SchoolScoresDataObject;
                self.numOfSATTestTakersLabel.text = schoolScoresDataObject.numOfSATTestTakers;
                self.satCriticalReadingAvgScoreLabel.text = schoolScoresDataObject.satCriticalReadingAvgScore;
                self.satMathAvgScoreLabel.text = schoolScoresDataObject.satMathAvgScore;
                self.satWritingAvgScoreLabel.text = schoolScoresDataObject.satWritingAvgScore;
            }
            else
            {
                self.numOfSATTestTakersLabel.text = "N/A";
                self.satCriticalReadingAvgScoreLabel.text = "N/A";
                self.satMathAvgScoreLabel.text = "N/A";
                self.satWritingAvgScoreLabel.text = "N/A";
            }
            
            if(self.schoolData!.phoneNumber!.count > 0)
            {
                self.phoneNumberButton.setTitle(String.init(format: "Call: %@", arguments: [self.schoolData!.phoneNumber!]), for: .normal)
            }
            else
            {
                self.phoneNumberButton.isEnabled = false;
            }
            
            if(self.schoolData!.email!.count > 0)
            {
                self.emailButton.setTitle(String.init(format: "Email: %@", arguments: [self.schoolData!.email!]), for: .normal)
            }
            else
            {
                self.emailButton.isEnabled = false;
            }
            
            if(self.schoolData!.website!.count > 0)
            {
                self.websiteButton.setTitle(String.init(format: "Visit: %@", arguments: [self.schoolData!.website!]), for: .normal)
            }
            else
            {
                self.websiteButton.isEnabled = false;
            }
            
            if(self.schoolData!.latitude!.count > 0 && self.schoolData!.longitude!.count > 0)
            {
                self.mapButton.isEnabled = true;
            }
            else
            {
                self.mapButton.isEnabled = false;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func phoneNumberButtonPressed(_ sender: UIButton)
    {
        var phoneNumber = schoolData!.phoneNumber!.replacingOccurrences(of: "(", with: "")
        phoneNumber = schoolData!.phoneNumber!.replacingOccurrences(of: ")", with: "")
        phoneNumber = schoolData!.phoneNumber!.replacingOccurrences(of: "-", with: "")
        phoneNumber = schoolData!.phoneNumber!.replacingOccurrences(of: " ", with: "")
        let phoneNumberURL = String.init(format: "tel://%@", arguments: [phoneNumber])
        UIApplication.shared.open(URL.init(string: phoneNumberURL)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton)
    {
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        var composer : MFMailComposeViewController;
        
        if(MFMailComposeViewController.canSendMail())
        {
            composer = MFMailComposeViewController.init()
            composer.setSubject("")
            composer.setMessageBody("", isHTML: false)
            
            composer.setToRecipients([self.schoolData!.email!])
            composer.mailComposeDelegate = self
            
            composer.modalPresentationStyle = .formSheet
            
            rootViewController.present(composer, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController.init(title: "Error Sending Mail", message: "There appears to be a problem sending e-mail.  Please ensure there is an e-mail account configured on this device and try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func websiteButtonPressed(_ sender: UIButton)
    {
        var urlString = self.schoolData!.website!
        if(!urlString.hasPrefix("http://") && !urlString.hasPrefix("https://"))
        {
            urlString = String.init(format: "http://%@", arguments: [urlString])
        }
        
        let safariVC = SFSafariViewController.init(url: URL.init(string: urlString)!)
        
        safariVC.modalTransitionStyle = .coverVertical;
        safariVC.delegate = nil;
        
        safariVC.modalPresentationStyle = .custom;
        UIApplication.shared.keyWindow!.rootViewController!.present(safariVC, animated:true, completion:nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        if(result == .cancelled)
        {
            let alertController = UIAlertController.init(title: "Error Sending Mail", message: "There appears to be a problem sending e-mail.  Please ensure there is an e-mail account configured on this device and try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        if(segue.identifier == "mapSegue")
        {
            let navCtrl : UINavigationController = segue.destination as! UINavigationController
            let mapViewController : MapViewController = navCtrl.topViewController as! MapViewController
            mapViewController.name = self.schoolData!.schoolName!
            mapViewController.longitude = self.schoolData!.longitude!
            mapViewController.lattitude = self.schoolData!.latitude!
        }
        
    }

}
