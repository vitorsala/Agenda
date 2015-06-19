//
//  CloudKitManager.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 18/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import CloudKit
import CoreData
import UIKit

enum AccountStatus {
	case Available
	case NoAccount
	case CouldNotDetermine
}

class CloudKitManager{
	static let sharedInstance = CloudKitManager()

	internal let container : CKContainer
	internal let privateDB : CKDatabase
	internal let publicDB : CKDatabase

	internal var accountStatus : AccountStatus = AccountStatus.CouldNotDetermine

	private var timer : NSTimer?

	internal var icloudEnabled : Bool {
		get{
			var error:NSError? = nil
			if (accountStatus == AccountStatus.Available){

				if let ret = NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) as? Bool{
					return ret
				}
			}
			return false
		}
		set{
			NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: CoreDataStackIcloudFlagForUserDefault)
		}
	}
	
	private init(){
		container = CKContainer.defaultContainer()
		privateDB = container.privateCloudDatabase
		publicDB = container.publicCloudDatabase

		checkAccountStatus()

		timer = NSTimer(timeInterval: 300, target: self, selector: "checkAccountStatus", userInfo: nil, repeats: true)
	}

	deinit{
		timer!.invalidate()
	}

	func checkAccountStatus(){
		CKContainer.defaultContainer().accountStatusWithCompletionHandler { (acc, error) -> Void in

			var status : AccountStatus = AccountStatus.CouldNotDetermine

			if error == nil{
				if acc == CKAccountStatus.Available{
					status = AccountStatus.Available
				}
				else if acc == CKAccountStatus.NoAccount {
					status = AccountStatus.NoAccount
				}
				else{
					status = AccountStatus.CouldNotDetermine
				}
			}

			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.accountStatus = status
			})
		}
	}

	func askForAuth(#viewController : UIViewController!){

		if NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) == nil{
			var error : NSError? = nil

			CKContainer.defaultContainer().accountStatusWithCompletionHandler { (acc, error) -> Void in

				if error == nil{
					if acc == CKAccountStatus.Available{
						println("Vai querer o icloud?")
						let icloudalert = UIAlertController(title: "iCloud?", message: "Vai usar o iCloud?", preferredStyle: UIAlertControllerStyle.Alert)

						icloudalert.addAction(UIAlertAction(title: "YEAH!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in

							NSUserDefaults.standardUserDefaults().setBool(true, forKey: CoreDataStackIcloudFlagForUserDefault)

							// Código para sincronizar os dados

						}))

						icloudalert.addAction(UIAlertAction(title: "NOPE!", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in

							NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)

						}))

						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							viewController.presentViewController(icloudalert, animated: true, completion: nil)
						})
					}

					else{
						NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
					}
				}
			}
		}
	}
}