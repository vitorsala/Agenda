//
//  OptionsViewController.swift
//  Agenda
//
//  Created by Lucas Leal Mendonça on 08/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {
    @IBOutlet weak var icloudSwitch: UISwitch!
    @IBOutlet weak var media: UITextField!
    @IBOutlet weak var alarme: UIDatePicker!
   
    @IBAction func salvar(sender: AnyObject) {
        let ud = NSUserDefaults.standardUserDefaults();
        if(media.text != ""){
            ud.setValue(media.text, forKey: "media");
        }
        //icloudAllowed
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let ud = NSUserDefaults.standardUserDefaults();
        if(ud.valueForKey("media") != nil){
            media.text = ud.valueForKey("media") as! String;
        }
        //alarme.datePickerMode = UIDatePicker.UIDatePickerModeTime;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.media.resignFirstResponder()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
