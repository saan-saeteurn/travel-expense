//
//  EmailViewController.swift
//  travel-expense
//
//  Created by Saan on 12/6/14.
//
//  Authors:
//          Abi Kasraie
//          Julian Gigola
//          Michael Layman
//          Saan Saeteurn
//
//  Copyright (c) 2014 Saan Saeteurn. All rights reserved.
//

import UIKit
import MessageUI


class EmailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    let coreData: TripDataModel = TripDataModel()
    var trips : Array<Trip> = []
    var summaryPlainText : String!
    var summaryHTML : String!
    
    @IBOutlet var textFieldEmailAddress: UITextField!
    
    @IBOutlet var textFieldSubject: UITextField!
    
    @IBOutlet var textViewBody: UITextView!

    
    @IBAction func Send(sender: UIBarButtonItem) {
        
        var subjectText = textViewBody.text
        subjectText = textFieldSubject.text
        
        var messageBody = textViewBody.text
        var recipients = [textFieldEmailAddress.text]
        
        var mc : MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(subjectText)
        mc.setMessageBody(self.summaryHTML, isHTML: true)
        mc.setCcRecipients(recipients)
        
        self.presentViewController(mc, animated: true, completion: nil)
        
        self.textFieldEmailAddress.text = ""
        self.textFieldSubject.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldEmailAddress.delegate = self
        textFieldSubject.delegate = self
        textViewBody.delegate = self
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Hide keyboard when clicking away from text field.
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(allTextFields: UITextField) -> Bool {
        // Hide keyboard when 'return' key is pressed.
        allTextFields.resignFirstResponder()
        return true
    }
    
    func calculateTripReportSummary() {
        var totalCount = trips.count
        var totalTripsDistance : Float = 0.00
        var totalTripsCost : Float = 0.00
        
        for tripObject in trips {
            totalTripsDistance += tripObject.totalDistance
            totalTripsCost += tripObject.totalCost
        }
        
        var headingText = "Here's a summary of your trips."
        var totalCountText = "Number of trips: \(totalCount)"
        var totalDistanceText = "Total overall distances: \(totalTripsDistance) Miles"
        var totalCostText = "Total overal cost: $\(totalTripsCost)"
        var footerText = "End of trip summary."
        
        self.summaryPlainText = headingText + "\n\n" + totalCountText + "\n\n" + totalDistanceText + "\n\n" + totalCostText + "\n\n" + footerText
        self.summaryHTML = headingText + "<br/><br/>" + totalCountText + "<br/><br/>" + totalDistanceText + "<br/><br/>" + totalCostText + "<br/><br/>" + footerText
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        
        case MFMailComposeResultSent.value:
            println("Mail sent")
            
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: \(error.localizedDescription)")
            
        default:
            break
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        let fetchReqest = coreData.getFetchRequest()
        
        var error: NSError?
        let fetchResults = coreData.getManageObjectContext().executeFetchRequest(fetchReqest, error: &error)
        
        if let castedResults = fetchResults as? [Trip]{
            trips = castedResults
            self.calculateTripReportSummary()
            self.textViewBody.text = summaryPlainText
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
