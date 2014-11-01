//
//  AViewController.swift
//  InteractiveCustomTransitionsDemo
//
//  Created by Robert Ryan on 10/31/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

import UIKit

class AViewController: UIViewController, CustomNavigationControllerDelegate {

    func pushToNextScene() {
        performSegueWithIdentifier("PushToB", sender: self)
    }

    @IBAction func pressedCancelButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
