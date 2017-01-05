//
//  ViewController.swift
//  iOpenDoor
//
//  Created by Jan Holub on 27.12.16.
//  Copyright © 2016 Jan Holub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK vars
    @IBOutlet weak var lockSymbol: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // positions for the pull to refresh mechanies
    var lockSymbolOriginalPos:CGPoint!
    var timeStampOriginalPos:CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // set the orignal positions of the symbols
        lockSymbolOriginalPos = lockSymbol.center
        timeStampOriginalPos  = timeStamp.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // calls the OpenDoor API and sets the UI to open or closed accordingly
    func updateStatus() {
        
        // start the activity indicator
        self.activityIndicator.startAnimating()
        self.lockSymbol.isHidden = true
        
        // request to the OpenDoor API
        let urlrequest = URLRequest(url: URL(string: "https://www.fachschaft.cs.uni-kl.de/opendoor.json")!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // task to handle the request and set the status accordingly
        let task = session.dataTask(with: urlrequest, completionHandler: {(data, response, error) in
            // check for error
            if(error != nil){
                print("Error calling OpenDoor")
                // set the UI to unknown
                DispatchQueue.main.async {
                    self.statusUnknown()
                    // update the timestamp
                    self.setTimeStamp()
                    self.activityIndicator.stopAnimating()
                    self.lockSymbol.isHidden = false
                }
                return
            }
            // no error
            else{
                do{
                    
                    // convert the JSON object
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    // retrieve the 'opendoor' value as a bool
                    if let status = json["opendoor"] as? Bool {
                        
                        
                        // the following code will update the UI and should thus not run async
                        DispatchQueue.main.async {
                            // open
                            if(status){
                                self.doorIsOpen()
                            }
                            // closed
                            else{
                                self.doorIsClosed()
                            }
                            
                            // update the timestamp
                            self.setTimeStamp()
                            self.activityIndicator.stopAnimating()
                            self.lockSymbol.isHidden = false
                            
                        }
                        
                        
                    }
                    // 'opendoor' not found in response JSON
                    else{
                        print("Error getting opendoor from JSON")
                        // set the UI to unknown
                        DispatchQueue.main.async {
                            self.statusUnknown()
                            // update the timestamp
                            self.setTimeStamp()
                            self.activityIndicator.stopAnimating()
                            self.lockSymbol.isHidden = false
                        }
                        return
                    }
                    
                    
                }
                // error converting the JSON object
                catch {
                    print ("Error trying to parse JSON")
                    // set the UI to unknown
                    DispatchQueue.main.async {
                        self.statusUnknown()
                        // update the timestamp
                        self.setTimeStamp()
                        self.activityIndicator.stopAnimating()
                        self.lockSymbol.isHidden = false
                    }
                    return
                }
                
                
            }
        })
        
        // perform the task
        task.resume()
        
    }

    
    // updates the UI to open
    func doorIsOpen() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
                self.lockSymbol.image = UIImage(named: "LockOpened")
        }, completion: nil)
        
    }
    
    // updates the UI to closed
    func doorIsClosed() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor(red: 252/255.0, green: 96/255.0, blue: 92/255.0, alpha: 1.0)
            self.lockSymbol.image = UIImage(named: "LockClosed")
        }, completion: nil)
        
    }
    
    // updates the UI to unknown
    func statusUnknown() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor(red: 253/255.0, green: 188/255.0, blue: 64/255.0, alpha: 1.0)
            self.lockSymbol.image = UIImage(named: "StatusUnknown")
        }, completion: nil)
        
    }
    
    // sets the timestamp in the UI to the current time
    // it represents when the status was last updated
    func setTimeStamp() {
        let currentTime = Date()
        let timeString = DateFormatter.localizedString(from: currentTime, dateStyle: .none, timeStyle: .short)
        self.timeStamp.text = timeString
    }
    
    
    // MARK: Gesture
    
    @IBAction func pullToReresh(recognizer: UIPanGestureRecognizer) {
        
        // get the translation of the pan
        let translation = recognizer.translation(in: self.view)
        
        // animate lock sybol and timestamp
        self.lockSymbol.center.y = max(self.lockSymbolOriginalPos.y, self.lockSymbol.center.y +  0.8 * translation.y)
        self.timeStamp.center.y  = max(self.timeStampOriginalPos.y,  self.timeStamp.center.y  +  0.6 * translation.y)
        
        // reset the gesture recognizer
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        
        
        // when the user stopped dragging, move the symbols back to the orignal  position and trigger the refresh action
        if recognizer.state == UIGestureRecognizerState.ended {
            
            // move the symbols back to their original positions
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.lockSymbol.center = self.lockSymbolOriginalPos
                self.timeStamp.center  = self.timeStampOriginalPos
            },
            // refresh open state when the animation finished
            completion: { finished in
                self.updateStatus()
            })
                        
            
        }
    }
}


