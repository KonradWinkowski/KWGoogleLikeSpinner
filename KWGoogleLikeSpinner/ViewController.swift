//
//  ViewController.swift
//  KWGoogleLikeSpinner
//
//  Created by Konrad Winkowski on 11/30/16.
//  Copyright © 2016 Konrad Winkowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var spinners: [KWGoogleLikeSpinner]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for spinner in spinners {
            spinner.isHidden = false
        }
    }


}

