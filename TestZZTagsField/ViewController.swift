//
//  ViewController.swift
//  TestZZTagsField
//
//  Created by Zhicong Zang on 9/8/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tagsField = ZZTagsField(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        tagsField.backgroundColor = .yellowColor()
        
        // Events
        tagsField.onDidAddTag = { _ in
            print("DidAddTag")
        }
        
        tagsField.onDidRemoveTag = { _ in
            print("DidRemoveTag")
        }
        
        tagsField.onDidChangeText = { _, text in
            print("DidChangeText")
        }
        
        tagsField.onDidBeginEditing = { _ in
            print("DidBeginEditing")
        }
        
        tagsField.onDidEndEditing = { _ in
            print("DidEndEditing")
        }
        
        tagsField.onDidChangeHeightTo = { sender, height in
            print("HeightTo \(height)")
        }
        view.addSubview(tagsField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

