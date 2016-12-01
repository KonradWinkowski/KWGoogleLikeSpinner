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
            
            if spinner == spinners.last {
                spinner.colors = [UIColor(hexString: "446CB3"),UIColor(hexString: "E4F1FE"),UIColor(hexString: "4183D7"),UIColor(hexString: "59ABE3"),UIColor(hexString: "81CFE0"),UIColor(hexString: "52B3D9"),UIColor(hexString: "C5EFF7"),UIColor(hexString: "22A7F0"),UIColor(hexString: "2C3E50"),UIColor(hexString: "22313F"),UIColor(hexString: "3A539B")]
            }
            
            spinner.isHidden = false
        }
    }


}

