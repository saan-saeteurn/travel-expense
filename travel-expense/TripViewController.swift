//
//  TripViewController.swift
//  travel-expense
//
//  Created by Mileage Tracker Team on 11/23/14.
//  Authors:
//          Abi Kasraie
//          Julian Gigola
//          Michael Layman
//          Saan Saeteurn
//
//  Copyright (c) 2014 Saan Saeteurn. All rights reserved.
//

import UIKit
import AVFoundation

class TripViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var saveSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("S", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()
    
    let coreData: TripDataModel = TripDataModel()
    
    @IBOutlet var textFieldTripDate: UITextField!
    @IBOutlet var textFieldTrip: UITextField!
    @IBOutlet var textFieldOrigin: UITextField!
    @IBOutlet var textFieldDestination: UITextField!
    @IBOutlet var textFieldTotalDistance: UITextField!
    @IBOutlet var textFieldTotalCost: UITextField!
    @IBOutlet var buttonViewMap: UIButton!
    @IBOutlet var textFieldTripDescription: UITextView!
    
    var trip : String = ""
    var origin : String = ""
    var destination : String = ""
    var tripDate : NSDate? = NSDate()
    var totalDistance : Float = 0.00
    var totalCost : Float = 0.00
    var tripDescription : String = ""

    // Trip object to represent existing trip to update.
    var existingTripObject: Trip!
    
    @IBAction func tripDatePicker(sender: UITextField) {
        // Create a date pick for arrival date field.
        
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("tripDateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @IBAction func buttonCancel(sender: AnyObject) {
        println("Cancel Button Pressed")
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func butttonSave(sender: AnyObject) {
        /*
        On button click, do the followings:
        
        1. Get NSManageObjectContext(moc) from our app delegate.
        2a. Create a new Trip instance using our entity and context objecets.
        2b. Set the outlet data to our Trip object's attributes.
        3. Save our Trip object back into our data model.
        4. Navigate back to our main view controller.
        */
        
        println("Save Button Pressed \(textFieldTrip.text).")
        
        // 1. Get NSManageObjectContext(moc) from our app delegate.
        let context = coreData.getManageObjectContext()
        
        // 2a. Set current Trip object if it exists.
        if (existingTripObject != nil) {
            existingTripObject.trip = textFieldTrip.text
            existingTripObject.origin = textFieldOrigin.text
            existingTripObject.destination = textFieldDestination.text
            existingTripObject.tripDate = coreData.dateFormatter.dateFromString(textFieldTripDate.text!)!
            existingTripObject.totalDistance = (textFieldTotalDistance.text as NSString).floatValue
            existingTripObject.totalCost = (textFieldTotalCost.text as NSString).floatValue
            existingTripObject.tripDescription = textFieldTripDescription.text
            
        } else {
            // 2b. Create a new instance to our data model.
            var newTripObject = coreData.getNewTripObject()
            
            // 3. Map our properties.
            newTripObject.trip = textFieldTrip.text
            newTripObject.origin = self.textFieldOrigin.text
            newTripObject.destination = textFieldDestination.text
            newTripObject.tripDate = coreData.dateFormatter.dateFromString(textFieldTripDate.text)!
            newTripObject.totalDistance = (textFieldTotalDistance.text as NSString).floatValue
            newTripObject.totalCost = (textFieldTotalCost.text as NSString).floatValue
            newTripObject.tripDescription = textFieldTripDescription.text
        }
        
        if (textFieldTrip.text.isEmpty || textFieldDestination.text.isEmpty) {
            let alert = UIAlertView()
            alert.title = "Trip name or destination field cannot be empty."
            alert.message = "Please try again."
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
        else {
            // 3. Save our TaskItem object back into our data model.
            context.save(nil)
            audioPlayer.play()
            
            // 4. Navigate back to our main view controller.
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }

    func tripDateChanged(sender: UIDatePicker) {
        textFieldTripDate.text = coreData.dateFormatter.stringFromDate(sender.date)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Hide keyboard when clicking away from text field.
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide keyboard when 'return' key is pressed.
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = AVAudioPlayer(contentsOfURL: saveSound, error: nil)
        audioPlayer.prepareToPlay()
      
        // Set text fields to clear keyboard on 'return' key.
        textFieldTrip.delegate = self
        textFieldOrigin.delegate = self
        textFieldDestination.delegate = self
        textFieldTripDate.delegate = self
        textFieldTotalDistance.delegate = self
        textFieldTotalCost.delegate = self
        textFieldTripDescription.delegate = self
        
        if (existingTripObject != nil)
        {
            textFieldTrip.text = trip
            textFieldOrigin.text = origin
            textFieldDestination.text = destination
            textFieldTripDate.text = coreData.dateFormatter.stringFromDate(tripDate!)
            textFieldTotalDistance.text = totalDistance.description
            textFieldTotalCost.text = totalCost.description
            textFieldTripDescription.text = tripDescription
        }
        else
        {
            var currentDate : NSDate? = NSDate()
            textFieldTripDate.text = coreData.dateFormatter.stringFromDate(currentDate!)
        }
        
        if (textFieldTripDescription.text == "")
        {
            textViewDidEndEditing(textFieldTripDescription)
        }
        
        var tapDismiss = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapDismiss)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(){
        textFieldTripDescription.resignFirstResponder()
    }
    
    func textViewDidEndEditing(descriptionTextView: UITextView) {
        if (descriptionTextView.text == "") {
            descriptionTextView.text = "Optional"
            descriptionTextView.textColor = UIColor.lightGrayColor()
        }
        
        textFieldTripDescription.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(descriptionTextView: UITextView){
        if (descriptionTextView.text == "Enter trip description..."){
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.blackColor()
        }
        
        textFieldTripDescription.becomeFirstResponder()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if identifier == "showLocation" {
            
            if (textFieldTrip.text.isEmpty || textFieldDestination.text.isEmpty) {
                
                let alert = UIAlertView()
                alert.title = "Trip name field or destination field cannot be empty."
                alert.message = "Please input your locations."
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
                
            else {
                return true
            }
        }
        
        // by default, transition
        return true
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        println("View Map button press")
        
        if (segue.identifier == "showLocation") {
            var mapNavController = segue.destinationViewController as UINavigationController
            var mapViewController = mapNavController.viewControllers[0] as MapViewController
            mapViewController.origin = textFieldOrigin.text as NSString
            mapViewController.destination = textFieldDestination.text as NSString
            mapViewController.tripName = textFieldTrip.text as NSString
            mapViewController.totalDistance = textFieldTotalDistance.text as NSString
        }
    }

}
