//
//  OptionsViewController.swift
//  Agenda
//
//  Created by Lucas Leal Mendonça on 08/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    @IBOutlet weak var icloudSwitch: UISwitch!
    @IBOutlet weak var media: UITextField!
    @IBOutlet weak var alarme: UIDatePicker!
   
    @IBAction func salvar(sender: AnyObject) {
        let ud = NSUserDefaults.standardUserDefaults();
        if(media.text != ""){
            ud.setValue(media.text, forKey: "media");
        }
        ud.setValue(alarme.date, forKey: "horaAlerta")
        LocalNotificationManager.sharedInstance.updateAllNotificationsTime(ud.valueForKey("horaAlerta") as! NSDate)
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

		icloudSwitch.addTarget(self, action: "switchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
		if CoreDataStack.sharedInstance.isOnline{
			icloudSwitch.on = true
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.media.resignFirstResponder()
    }

	func switchValueChanged(switchState: UISwitch){

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "storageDidChange:", name: CoreDataStackDidChangeNotification, object: nil)

		CoreDataStack.sharedInstance.switchMode()

		MateriaManager.sharedInstance.removeDuplicated()
		TarefaManager.sharedInstance.removeDuplicated()

	}

	func storageDidChange(notification : NSNotification){
//
//		MateriaManager.sharedInstance.removeDuplicated()
//		TarefaManager.sharedInstance.removeDuplicated()

		NSNotificationCenter.defaultCenter().removeObserver(self)
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
