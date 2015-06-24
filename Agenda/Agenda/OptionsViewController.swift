//
//  OptionsViewController.swift
//  Agenda
//
//  Created by Lucas Leal Mendonça on 08/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CloudKit

class OptionsViewController: UITableViewController {
    @IBOutlet weak var media: UITextField!
    @IBOutlet weak var alarme: UIDatePicker!
    
    var loading:LoadingView!
   
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

		let gesture = UITapGestureRecognizer(target: self, action: "touchesAction")
		self.view.addGestureRecognizer(gesture)
        //alarme.datePickerMode = UIDatePicker.UIDatePickerModeTime;
        // Do any additional setup after loading the view.

    }

	override func viewWillAppear(animated: Bool) {
		// Verifica se o usuário está logado no iCloud.
		// Caso positivo, permite a ativação do iCloud no app
		var error : NSError? = nil

	}

    override func viewWillDisappear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchesAction() {
        self.media.resignFirstResponder()
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
