//
//  MateriaManager.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class MateriaManager: NSObject{
    
    static let sharedInstance = MateriaManager()
    static let entityName = "Materia"
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var coreData = CoreDataStack.sharedInstance
        return coreData.managedObjectContext!
        }()

	func newMateria() -> Materia{
		return NSEntityDescription.insertNewObjectForEntityForName(MateriaManager.entityName, inManagedObjectContext: managedObjectContext) as! Materia
	}

    func insertNewMateria(nome:String){
        let newMateria = NSEntityDescription.insertNewObjectForEntityForName(MateriaManager.entityName, inManagedObjectContext: managedObjectContext) as! Materia
        newMateria.nomeMateria = nome
        newMateria.idCloud = "\(NSDate().timeIntervalSince1970 as Double)"
        self.save()

		if CloudKitManager.sharedInstance.icloudEnabled{

			var error : NSError? = nil
			self.saveInCloud(newMateria, error: &error)
		}

    }
    
    func save() {
        var error: NSError?;
        managedObjectContext.save(&error)
        
        if let e = error {
            println("Erro ao salvar.")
        }
    }
    
    func fetchAllMaterias() -> Array<Materia> {
        let fetchRequest = NSFetchRequest(entityName: MateriaManager.entityName)
        var error: NSError?
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults as? [Materia] {
            return results
        } else {
            println("Erro ao buscar todas as materias.")
        }
        
        return Array<Materia>()
    }
    
    func jaExisteMateria(nome:String) -> Bool {
        for materia in self.fetchAllMaterias() {
            if materia.nomeMateria == nome{
                return true
            }
        }
        return false
    }
    
    //BE VERY CAREFUL AROUND THIS PLEASE
    func deleteAllMaterias(){
        //THINK ABOUT WHAT YOU ARE DOING
        let materias = self.fetchAllMaterias()
        //ARE YOU SURE ABOUT THIS?
        for materia in materias{
            //HOLD ON RIGHT WHERE YOU ARE
            self.managedObjectContext.deleteObject(materia)
            //WELL IT IS DONE NOW
		}
		//GOOD JOB BREAKING IT HERO
		self.save()
    }

//	func removeDuplicated(){
//		var materias = self.fetchAllMaterias() // Pega todos as materias existentes
//
//		materias.sort{$0.0.nomeMateria.compare($0.1.nomeMateria) == NSComparisonResult.OrderedDescending}
//		while materias.count > 1 {
//			if materias[0].nomeMateria == materias[1].nomeMateria {
//				if materias[0].idCloud.doubleValue > materias[1].idCloud.doubleValue{
//					managedObjectContext.deleteObject(materias[1])
//					materias.removeAtIndex(1)
//				}
//				else{
//					managedObjectContext.deleteObject(materias[0])
//					materias.removeAtIndex(0)
//				}
//			}
//			else{
//				materias.removeAtIndex(0)
//			}
//		}
//		self.save()
//	}

    func deletaNotifsMateria(materia:Materia){
        let tarefas = TarefaManager.sharedInstance.fetchTarefasForMateria(materia)
        for tarefa in tarefas {
            TarefaManager.sharedInstance.deletaNotif(tarefa)
        }
    }

	func deletaMateria(materia: Materia){
		managedObjectContext.deleteObject(materia)

		if CloudKitManager.sharedInstance.icloudEnabled{
			self.deleteFromCloud(materia)
		}
	}

	func saveInCloud(materia: Materia, inout error err: NSError?){
		let cloud = CloudKitManager.sharedInstance

		let id = CKRecordID(recordName: materia.idCloud)

		let record = CKRecord(recordType: MateriaManager.entityName, recordID: id)

		record.setObject(materia.nomeMateria, forKey: "nomeMateria")

		cloud.privateDB.saveRecord(record, completionHandler: { (savedRecord, error) -> Void in

			if error != nil{
				println(error.localizedDescription)
			}
			err = error
		})
	}

	func deleteFromCloud(materia: Materia){
		let cloud = CloudKitManager.sharedInstance

		cloud.privateDB.deleteRecordWithID(CKRecordID(recordName: materia.idCloud), completionHandler: { (record, error) -> Void in

			if error != nil{
				println(error.localizedDescription)
			}
		})
	}

}