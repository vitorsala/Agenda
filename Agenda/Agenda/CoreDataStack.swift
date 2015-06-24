//
//  CoreDataStack.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 08/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData

let CoreDataStackDidChangeNotification = "didUpdatedFromIcloud"
let CoreDataStackDidImportedNotification = "didImportFromIcloud"
let CoreDataStackIcloudFlagForUserDefault = "icloudAllowed"

class CoreDataStack {
	static let sharedInstance = CoreDataStack()

	private init(){
		let userDefault = NSUserDefaults.standardUserDefaults()

		// Verifica se o usuário quer que utilize o iCloud
		if userDefault.boolForKey(CoreDataStackIcloudFlagForUserDefault){
			// Verifica se o usuário está logado no iCloud.
			if CoreDataStack.isLoggedInIcloud(){
				let notcenter = NSNotificationCenter.defaultCenter()

				isOnline = true
				// Registra a instancia como observador das notificações lançadas pelo coordinator
				notcenter.addObserver(self, selector: "willChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: nil)

				notcenter.addObserver(self, selector: "didChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)

				notcenter.addObserver(self, selector: "didImportUibquitousContent:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: nil)
			}
			else{
				// Se o usuário não está logado no icloud, utiliza o sistema padrão
				userDefault.setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
			}
		}
		let coordinator = self.persistentStoreCoordinator
		println("iCloud "+(isOnline ? "Habilitado" : "Desabilitado"))
	}

	internal var isOnline : Bool = false

	private let icloudStoreOptions = [NSPersistentStoreUbiquitousContentNameKey : "Agenda",
		NSMigratePersistentStoresAutomaticallyOption : true,
		NSInferMappingModelAutomaticallyOption : true]

	private let icloudRemoveStoreOptions = [NSPersistentStoreRemoveUbiquitousMetadataOption : true,NSMigratePersistentStoresAutomaticallyOption : true,
		NSInferMappingModelAutomaticallyOption : true]

	// MARK:- iCloud Related
	/**
	Verifica se o usuário está logado, no iCloud, no dispositivo

	:returns: **true** caso o usuário esteja logado, **false** caso contrário
	*/
	static func isLoggedInIcloud() -> Bool{
		return NSFileManager.defaultManager().ubiquityIdentityToken != nil
	}

	/**
	Troca o tipo de persistencie entre local e remoto.
	
	A propriedade *isOnline* indica qual tipo de propriedade está sendo utilizdo (local ou local+icloud)
	*/
	func switchMode(){
		let notcenter = NSNotificationCenter.defaultCenter()

		var persistentStore : NSPersistentStore? = self.persistentStoreCoordinator?.persistentStores.first as? NSPersistentStore
		
		var error : NSError? = nil

		self.managedObjectContext?.reset()	// Antes de efetuar a troca, reseta o estado do contexto para o utimo estado válido.

		if isOnline {
			notcenter.removeObserver(self)
			persistentStore = self.persistentStoreCoordinator?.migratePersistentStore(persistentStore!, toURL: self.localStoreURL, options: self.icloudRemoveStoreOptions, withType: NSSQLiteStoreType, error: &error)
		}
		else{
			notcenter.addObserver(self, selector: "willChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: managedObjectContext?.persistentStoreCoordinator)

			notcenter.addObserver(self, selector: "didChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: managedObjectContext?.persistentStoreCoordinator)

			notcenter.addObserver(self, selector: "didImportUibquitousContent:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: managedObjectContext?.persistentStoreCoordinator)

			persistentStore = self.persistentStoreCoordinator?.migratePersistentStore(persistentStore!, toURL: self.remoteStoreURL, options: self.icloudStoreOptions, withType: NSSQLiteStoreType, error: &error)
		}

		if persistentStore == nil{
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = "Erro ao migrar o store"
			dict[NSUnderlyingErrorKey] = error
			error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(error), \(error!.userInfo)")
			abort()

		}

		isOnline = !isOnline
		NSUserDefaults.standardUserDefaults().setBool(isOnline, forKey: CoreDataStackIcloudFlagForUserDefault)
	}

	/**
	Método observadora para o primeiro setup quando o icloud é ativado no aplicativo.

	:param: notification : NSNotification
	*/
	@objc func willChange(notification : NSNotification){
		let userInfo = notification.userInfo

		println("iCloud setup exec")

		if managedObjectContext!.hasChanges{
			var error : NSError?
			if managedObjectContext!.save(&error){
				println(error?.description)
			}

		}
		else{
			managedObjectContext!.reset()
		}
	}

	/**
	Método observadora que é executado após o término da execução do setup do icloud

	:param: notification : NSNotification
	*/
	@objc func didChange(notification : NSNotification){
		
		NSNotificationCenter.defaultCenter().postNotificationName(CoreDataStackDidChangeNotification, object: nil, userInfo: nil)
	}

	/**
	Método observadora que será executado toda vez que o dispositivo detectar mudanças vindo do iCloud

	:param: notification : NSNotification
	*/
	@objc func didImportUibquitousContent(notification : NSNotification){
		// Faz o merge de dados
		managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)

		// Notifica as outras classes que ouve merge
		NSNotificationCenter.defaultCenter().postNotificationName(CoreDataStackDidImportedNotification, object: nil, userInfo: notification.userInfo)
	}

	// MARK: - Core Data stack

	lazy var remoteStoreURL : NSURL = {
		return	self.applicationDocumentsDirectory.URLByAppendingPathComponent("iCloudAgenda.sqlite") as NSURL
	}()

	lazy var localStoreURL : NSURL = {
		return	self.applicationDocumentsDirectory.URLByAppendingPathComponent("Agenda.sqlite")
		}() as NSURL

	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "BEPiD.Agenda" in the application's documents Application Support directory.
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1] as! NSURL
		}()

	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("Agenda", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
		}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)


		let url = (self.isOnline ? self.remoteStoreURL : self.localStoreURL)
		// let url = self.localStoreURL

		var error: NSError? = nil
		var failureReason = "There was an error creating or loading the application's saved data."

		var store : NSPersistentStore?

		let options : [String : AnyObject]? = (self.isOnline ? self.icloudStoreOptions : self.icloudRemoveStoreOptions)

		if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
			coordinator = nil
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			dict[NSUnderlyingErrorKey] = error
			error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(error), \(error!.userInfo)")
			abort()
		}

		return coordinator
		}()

	lazy var managedObjectContext: NSManagedObjectContext? = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		if coordinator == nil {
			return nil
		}
		var managedObjectContext = NSManagedObjectContext()
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
		}()
	// MARK: - Core Data Saving support

	func saveContext () {
		if let moc = self.managedObjectContext {
			var error: NSError? = nil
			if moc.hasChanges && !moc.save(&error) {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				NSLog("Unresolved error \(error), \(error!.userInfo)")
				abort()
			}
		}
	}
	
}