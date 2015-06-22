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
    @IBOutlet weak var icloudSwitch: UISwitch!
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endSync:", name: didFinishedSyncWithCloudNotification, object: nil)
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
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: didFinishedSyncWithCloudNotification, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchesAction() {
        self.media.resignFirstResponder()
    }

    @IBAction func sincronizar(sender: AnyObject) {

            
		//NSUserDefaults.standardUserDefaults().setBool(switchState.on, forKey: CoreDataStackIcloudFlagForUserDefault)
		if (NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) as! Bool) == true {

			self.loading = NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: nil).first as? LoadingView
			self.loading.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height)
			self.view.addSubview(self.loading)
			self.view.userInteractionEnabled = false
			self.tabBarController!.tabBar.hidden = true

			if ConnectionCheck.isConnectedToNetwork() == false {
				let netAlert = UIAlertController(title: "Sem conexão com a Internet", message: "Impossível sincronizar com iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
				netAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				}))
				self.presentViewController(netAlert, animated: true, completion: { () -> Void in
					self.loading.removeFromSuperview()
					self.view.userInteractionEnabled = true
					self.tabBarController!.tabBar.hidden = false
				})
			}
			else{
				CloudKitManager.sharedInstance.rebase()
			}
		}
		else{
			let icloudalert = UIAlertController(title: "iCloud está desativado", message: "Em modo offline, seus dados não podem ser salvos ou carregados do iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
			icloudalert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
			}))
			self.presentViewController(icloudalert, animated: true, completion: nil)
		}
    }
    
	func switchValueChanged(switchState: UISwitch){
        if switchState.on {
            if ConnectionCheck.isConnectedToNetwork() == false {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
                let netAlert = UIAlertController(title: "Sem conexão com a Internet", message: "Impossivel habilitar iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                netAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                }))
                self.presentViewController(netAlert, animated: true, completion: nil)
            }
            if CloudKitManager.sharedInstance.accountStatus == AccountStatus.Available {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: CoreDataStackIcloudFlagForUserDefault)
            }
            else{
                
            }
        }
        else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
        }
        
        //loading?.removeFromSuperview()
//		MateriaManager.sharedInstance.removeDuplicated()
//		TarefaManager.sharedInstance.removeDuplicated()

	}
    
    func endSync(notif:NSNotification){
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.view.userInteractionEnabled = true
			self.tabBarController!.tabBar.hidden = false
		})
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
