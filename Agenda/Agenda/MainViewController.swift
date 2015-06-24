//
//  MainViewController.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 24/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class MainViewController : UIViewController{
	var loading : LoadingView?

	override func viewDidAppear(animated: Bool) {
		
		if ConnectionCheck.isConnectedToNetwork() == false {
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
			let netAlert = UIAlertController(title: "Sem conexão com a Internet", message: "Iniciando em modo offline. Neste modo, seus dados não serão salvos ou carregados do iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
			netAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
			}))
			self.presentViewController(netAlert, animated: true, completion: nil)
		}
		else{

			if NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) == nil{


				if CoreDataStack.isLoggedInIcloud() {

					println("Vai querer o icloud?")
					let icloudalert = UIAlertController(title: "Ativar iCloud?", message: "Em modo offline, seus dados não serão salvos ou carregados do iCloud.", preferredStyle: UIAlertControllerStyle.Alert)


					icloudalert.addAction(UIAlertAction(title: "Offline!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in

						NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
						CoreDataStack.sharedInstance
						self.performSegueWithIdentifier("startAppSegue", sender: nil)

					}))

					icloudalert.addAction(UIAlertAction(title: "Online!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in

						NSUserDefaults.standardUserDefaults().setBool(true, forKey: CoreDataStackIcloudFlagForUserDefault)

						// Código para sincronizar os dados
						self.loading = (NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: [:]).first as! LoadingView)

						self.loading!.frame = UIScreen.mainScreen().bounds
						
						self.view.addSubview(self.loading!)
						NSNotificationCenter.defaultCenter().addObserver(self, selector: "endSync:", name: CoreDataStackDidChangeNotification, object: nil)

						CoreDataStack.sharedInstance

					}))
					self.presentViewController(icloudalert, animated: true, completion: nil)
				}

				else{
					NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
					CoreDataStack.sharedInstance
					
					performSegueWithIdentifier("startAppSegue", sender: nil)
				}
			}
			else{
				CoreDataStack.sharedInstance
				performSegueWithIdentifier("startAppSegue", sender: nil)
			}
		}

	}

	@objc func endSync(notification: NSNotification){
		loading?.removeFromSuperview()
		performSegueWithIdentifier("startAppSegue", sender: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "startAppSegue"{
		}
	}
}