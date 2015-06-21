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

let didBeginSyncWithCloudNotification = "didBeginSyncWithCloud"
let didFinishedSyncWithCloudNotification = "didFinishedSyncWithCloud"

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

        if true{//NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) == nil{
			var error : NSError? = nil

            if ConnectionCheck.isConnectedToNetwork() == false {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
                let netAlert = UIAlertController(title: "Sem conexão com a Internet", message: "Iniciando em modo offline. Neste modo, seus dados não serão salvos ou carregados do iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                netAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                }))
                viewController.presentViewController(netAlert, animated: true, completion: nil)
            }
            else{
                CKContainer.defaultContainer().accountStatusWithCompletionHandler { (acc, error) -> Void in
                    
                    if error == nil{
                        if acc == CKAccountStatus.Available{
                            println("Vai querer o icloud?")
                            let icloudalert = UIAlertController(title: "Ativar iCloud?", message: "Em modo offline, seus dados não serão salvos ou carregados do iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            icloudalert.addAction(UIAlertAction(title: "Online!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: CoreDataStackIcloudFlagForUserDefault)
                                
                                
                                // Código para sincronizar os dados
                                //self.rebase()
                                
                            }))
                            
                            icloudalert.addAction(UIAlertAction(title: "Offline!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                
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

	/**
		Deleta tudo do storage local, e atualiza com tudo que está na nuvem
	*/
	func rebase(){

		NSNotificationCenter.defaultCenter().postNotificationName(didBeginSyncWithCloudNotification, object: nil)
		// Essa notificação tem que travar qualquer outra operação!

		privateDB.performQuery(CKQuery(recordType: MateriaManager.entityName, predicate: NSPredicate(value: true)), inZoneWithID: nil) { (results: [AnyObject]!, error: NSError!) -> Void in

			if error == nil{
				dispatch_sync(dispatch_get_main_queue(), { () -> Void in
					CoreDataStack.sharedInstance.managedObjectContext?.reset()
					TarefaManager.sharedInstance.deleteAllTarefas()
					MateriaManager.sharedInstance.deleteAllMaterias()
				})
				
				var test : [Materia] = []

				for result in results as! [CKRecord]{
					let newMateria = MateriaManager.sharedInstance.newMateria()
					newMateria.idCloud = result.recordID.recordName
					newMateria.nomeMateria = result.objectForKey("nomeMateria") as! String
					test.append(newMateria)
				}

				self.privateDB.performQuery(CKQuery(recordType: TarefaManager.entityName, predicate: NSPredicate(value: true)), inZoneWithID: nil) { (results: [AnyObject]!, error: NSError!) -> Void in

					if error == nil{
						var disciplinas : [AnyObject] = []
						dispatch_sync(dispatch_get_main_queue(), { () -> Void in
							 disciplinas = Array(CoreDataStack.sharedInstance.managedObjectContext!.insertedObjects)
						})
						for result in results as! [CKRecord]{
							let newTarefa = TarefaManager.sharedInstance.newTarefa()
							newTarefa.idCloud = result.recordID.recordName
							newTarefa.nomeAtiv = result.objectForKey("nomeAtiv") as! String
							newTarefa.dataEntrega = result.objectForKey("dataEntrega") as! NSDate
							newTarefa.nota = result.objectForKey("nota") as! NSNumber
							newTarefa.tipoAtiv = result.objectForKey("tipoAtiv") as! NSNumber
							newTarefa.avaliado = result.objectForKey("avaliado") as! NSNumber
                            newTarefa.entregue = result.objectForKey("entregue") as! NSNumber
							newTarefa.disciplina = disciplinas.filter({ (e:AnyObject) -> Bool in
								if let obj = e as? Materia{
									return obj.idCloud == (result.objectForKey("disciplina") as! CKReference).recordID.recordName
								}
								return false
							}).first as! Materia
						}

						dispatch_sync(dispatch_get_main_queue(), { () -> Void in
							MateriaManager.sharedInstance.save()
						})

						NSNotificationCenter.defaultCenter().postNotificationName(didFinishedSyncWithCloudNotification, object: nil, userInfo: nil)
						// Libera as outras operações
					}
				}

			}
		}

	}
}