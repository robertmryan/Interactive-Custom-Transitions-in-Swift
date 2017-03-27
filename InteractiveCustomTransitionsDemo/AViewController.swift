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

// If you want to allow navigation controller to automatically detect whether you can swipe right to left
// to push to the "next" scene, you should conform to `CustomNavigationControllerDelegate` and then
// implement `pushToNextScene`.

class AViewController: UIViewController, CustomNavigationControllerDelegate {

    func pushToNextScene() {
        performSegue(withIdentifier: "PushToB", sender: self)
    }

    @IBAction func pressedCancelButton(_ sender: AnyObject) {
        navigationController?.dismiss(animated: true)
    }
    
}
