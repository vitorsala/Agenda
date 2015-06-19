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

    }

	override func viewWillAppear(animated: Bool) {
		// Verifica se o usuário está logado no iCloud.
		// Caso positivo, permite a ativação do iCloud no app
		var error : NSError? = nil
		if CloudKitManager.sharedInstance.accountStatus == AccountStatus.Available{
			icloudSwitch.addTarget(self, action: "switchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
			if CloudKitManager.sharedInstance.icloudEnabled{
				icloudSwitch.on = true
			}
		}
		// Caso negativo, evita que o iCloud seja ativado.
		else {
			icloudSwitch.enabled = false
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
		NSUserDefaults.standardUserDefaults().setBool(switchState.on, forKey: CoreDataStackIcloudFlagForUserDefault)
//		MateriaManager.sharedInstance.removeDuplicated()
//		TarefaManager.sharedInstance.removeDuplicated()

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
