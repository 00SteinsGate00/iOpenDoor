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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // calls the OpenDoor API and sets the UI to open or closed accordingly
    func updateStatus() {
        
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
                            
                        }
                        
                        
                    }
                    // 'opendoor' not found in response JSON
                    else{
                        print("Error getting opendoor from JSON")
                        // set the UI to unknown
                        DispatchQueue.main.async {
                            self.statusUnknown()
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
        self.view.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
        self.lockSymbol.image = UIImage(named: "LockOpened")
    }
    
    // updates the UI to closed
    func doorIsClosed() {
        self.view.backgroundColor = UIColor(red: 252/255.0, green: 96/255.0, blue: 92/255.0, alpha: 1.0)
        self.lockSymbol.image = UIImage(named: "LockClosed")
    }
    
    // updates the UI to unknown
    func statusUnknown() {
        self.view.backgroundColor = UIColor(red: 253/255.0, green: 188/255.0, blue: 64/255.0, alpha: 1.0)
        self.lockSymbol.image = UIImage(named: "StatusUnknown")
    }
}


