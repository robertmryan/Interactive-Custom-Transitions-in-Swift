//
//  BViewController.swift
//  InteractiveCustomTransitionsDemo
//
//  Created by Robert Ryan on 10/31/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

import UIKit

class BViewController: UIViewController, CustomNavigationControllerDelegate {

    func pushToNextScene() {
        performSegueWithIdentifier("PushToC", sender: self)
    }

}
