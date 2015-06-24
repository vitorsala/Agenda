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
			let netAlert = UIAlertController(title: "Sem conexão com a Internet", message: "Não foi possível conectar com o iCloud.\nA sincronização com iCloud foi desativada neste aplicativo pois não foi encontrada uma conexão com a internet.", preferredStyle: UIAlertControllerStyle.Alert)
			netAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
			}))
			self.presentViewController(netAlert, animated: true, completion: nil)
		}
		else{

			if NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) == nil{
				if CoreDataStack.isLoggedInIcloud() {

					println("Vai querer o icloud?")
					let icloudalert = UIAlertController(title: "Ativar iCloud?", message: "Em modo offline, seus dados não serão salvos ou carregados do iCloud.\nEsta configuração pode ser modificada posteriormente nas configurações do aplicativo, localizado nas configurações do dispositivo.", preferredStyle: UIAlertControllerStyle.Alert)


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
					let icloudalert = UIAlertController(title: "iCloud", message: "Este aplicativo utiliza o iCloud para sincronizar dados.\nPara utilizar o iCloud, associe uma conta com este aparelho pelo menu Opções do dispositivo.", preferredStyle: UIAlertControllerStyle.Alert)


					icloudalert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
						self.performSegueWithIdentifier("startAppSegue", sender: nil)
					}))
					self.presentViewController(icloudalert, animated: true, completion: nil)

					NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
					CoreDataStack.sharedInstance

				}
			}
			else if (NSUserDefaults.standardUserDefaults().boolForKey(CoreDataStackIcloudFlagForUserDefault) == true && CoreDataStack.isLoggedInIcloud() == false){
				let icloudalert = UIAlertController(title: "iCloud", message: "Não foi possível conectar com o iCloud.\nA sincronização com iCloud foi desativada neste aplicativo pois não foi encontrada uma conta associada com o dispositivo.", preferredStyle: UIAlertControllerStyle.Alert)


				icloudalert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					self.performSegueWithIdentifier("startAppSegue", sender: nil)
				}))
				self.presentViewController(icloudalert, animated: true, completion: nil)

				NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
			}
			else{
				CoreDataStack.sharedInstance
				performSegueWithIdentifier("startAppSegue", sender: nil)
			}
		}

	}

	@objc func endSync(notification: NSNotification){
		NSNotificationCenter.defaultCenter().removeObserver(self)
		loading?.removeFromSuperview()
		performSegueWithIdentifier("startAppSegue", sender: nil)

	}

}