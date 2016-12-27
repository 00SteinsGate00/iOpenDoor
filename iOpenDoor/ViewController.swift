//
//  ViewController.swift
//  iOpenDoor
//
//  Created by Jan Holub on 27.12.16.
//  Copyright © 2016 Jan Holub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lockSymbol: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    func doorIsOpen() {
        self.view.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
        self.lockSymbol.image = UIImage(named: "LockOpened")
    }
    
    func doorIsClosed() {
        self.view.backgroundColor = UIColor(red: 252/255.0, green: 96/255.0, blue: 92/255.0, alpha: 1.0)
        self.lockSymbol.image = UIImage(named: "LockClosed")
    }
}

