//
//  TarefaManager.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class TarefaManager: NSObject{
    
    static let sharedInstance = TarefaManager()
    static let entityName = "Atividade"
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var coredata = CoreDataStack.sharedInstance;
        return coredata.managedObjectContext!
        }()


	func newTarefa() -> Atividade{
		return NSEntityDescription.insertNewObjectForEntityForName(TarefaManager.entityName, inManagedObjectContext: managedObjectContext) as! Atividade
	}
    
    //TIPO 0 = PROVA   TIPO 1 = TRABALHO
    func insertNewTarefa(nome:String, disc:Materia, data:NSDate, tipo:Int){
        let newTarefa = NSEntityDescription.insertNewObjectForEntityForName(TarefaManager.entityName, inManagedObjectContext: managedObjectContext) as! Atividade
        newTarefa.nomeAtiv = nome
        newTarefa.disciplina = disc
        newTarefa.dataEntrega = data
        newTarefa.tipoAtiv = tipo
        newTarefa.idCloud = "\(NSDate().timeIntervalSince1970 as Double)"
        self.save()

        self.criaNotif(newTarefa)

		if CloudKitManager.sharedInstance.icloudEnabled{

			var error : NSError? = nil
			self.saveInCloud(newTarefa, error: &error)
		}
        
    }
    
    func criaNotif(newTarefa: Atividade) {
        //cria notif
        let ud = NSUserDefaults.standardUserDefaults()
        if ud.valueForKey("horaAlerta") == nil {
            ud.setValue(NSDate(), forKey: "horaAlerta")
        }
        let comeco : String;
        if(newTarefa.tipoAtiv == 0){
            comeco = "Realização de prova";
        } else {
            comeco = "Entrega de trabalho";
        }
        for i in 0...7 {
            //montando o horario correto - favor testar
            var dia = newTarefa.dataEntrega
            //Se o dia iterado for depois que o horário atual, coloca no calendário
            if(dia.dateByAddingTimeInterval((-60)*60*24*Double(i)).timeIntervalSinceDate(NSDate()) > 0){
                
                
                var unitFlags = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |  NSCalendarUnit.CalendarUnitDay
                var calendar = NSCalendar.currentCalendar()
                var comps = calendar.components(unitFlags, fromDate: dia)
                comps.day -= i
                comps.hour = calendar.component(NSCalendarUnit.CalendarUnitHour, fromDate: (ud.valueForKey("horaAlerta") as! NSDate))
                comps.minute = calendar.component(NSCalendarUnit.CalendarUnitMinute, fromDate: (ud.valueForKey("horaAlerta") as! NSDate))
                comps.second = 0
                var newDate = calendar.dateFromComponents(comps)

                var message:String
                
                if i == 0 {
                    message = "\(comeco) hoje!"//"A data da atividade é hoje!"
                }
                else if i == 1 {
                    message = "\(comeco) daqui um dia."//"Falta um dia para a data d atividade."
                }
                else{
                    message = "\(comeco) daqui \(i) dias."//"Faltam \(i) dias para a data da atividade."
                }
                
                LocalNotificationManager.sharedInstance.scheduleNewNotification(title: "\(newTarefa.disciplina.nomeMateria): \(newTarefa.nomeAtiv)", msg: message, action: "Ok", options: [newTarefa.idCloud: i], toDate: newDate!)
            } else {
                //Se não, não coloca e sai do for.
                break;
            }
        }
    }
    
    func atualizaNotif(tarefa:Atividade) {
        self.deletaNotif(tarefa)
        self.criaNotif(tarefa)
    }
    
    func deletaNotif(tarefa:Atividade) {
        var notif = LocalNotificationManager.sharedInstance.getNotificationUsingFilter { (notification) -> (Bool) in
            return notification.userInfo?[tarefa.idCloud] != nil
        }
        for eachNotif in notif {
            LocalNotificationManager.sharedInstance.cancelSingleScheduledNotification(eachNotif)
        }
    }
    
    func save() {
        var error: NSError?;
        managedObjectContext.save(&error)
        
        if let e = error {
            println("Erro ao salvar.")
        }
    }
    
    func fetchAllTarefas() -> Array<Atividade> {
        let fetchRequest = NSFetchRequest(entityName: TarefaManager.entityName)
        var error: NSError?
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults as? [Atividade] {
            return results
        } else {
            println("Erro ao buscar todas as tarefas.")
        }
        
        return Array<Atividade>()
    }
    
    func fetchTarefasForMateria(materia:Materia) -> Array<Atividade> {
        let fetchRequest = NSFetchRequest(entityName: TarefaManager.entityName)
        var error: NSError?
        let predicate = NSPredicate(format: "disciplina == %@", materia)
        fetchRequest.predicate = predicate
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults as? [Atividade] {
            return results
        } else {
            println("Erro ao buscar tarefas.")
        }
        
        return Array<Atividade>()
    }
    
    func fetchTarefasFuturas() -> Array<Atividade> {
        let fetchRequest = NSFetchRequest(entityName: TarefaManager.entityName)
        var error: NSError?
        
        //Ordena de acordo com a data
        var sortDescriptor = NSSortDescriptor(key: "dataEntrega", ascending: true);
        var sortDescriptors = NSArray(object: sortDescriptor);
        fetchRequest.sortDescriptors = sortDescriptors as [AnyObject]
        
        let predicate = NSPredicate(format: "dataEntrega >= %@", NSDate())
        fetchRequest.predicate = predicate
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults as? [Atividade] {
            return results
        } else {
            println("Erro ao buscar tarefas.")
        }
        
        return Array<Atividade>()
    }
    
    func fetchTarefasPassadas() -> Array<Atividade> {
        let fetchRequest = NSFetchRequest(entityName: TarefaManager.entityName)
        var error: NSError?
        
        //Ordena de acordo com a data
        var sortDescriptor = NSSortDescriptor(key: "dataEntrega", ascending: true);
        var sortDescriptors = NSArray(object: sortDescriptor);
        fetchRequest.sortDescriptors = sortDescriptors as [AnyObject]
        
        let predicate = NSPredicate(format: "dataEntrega <= %@", NSDate())
        fetchRequest.predicate = predicate
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults as? [Atividade] {
            return results
        } else {
            println("Erro ao buscar tarefas.")
        }
        
        return Array<Atividade>()
    }
    
    func fetchTarefasBetweenDates(firstDate:NSDate, lastDate:NSDate) -> Array<Atividade> {
        let fetchRequest = NSFetchRequest(entityName: TarefaManager.entityName)
        var error: NSError?
        let predicate = NSPredicate(format: "(dataEntrega >= %@) AND (dataEntrega <= %@)", firstDate, lastDate)
        fetchRequest.predicate = predicate
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults as? [Atividade] {
            return results
        } else {
            println("Erro ao buscar tarefas.")
        }
        
        return Array<Atividade>()
    }
    
    func getMediaSimples(materia:Materia) -> Float {
        var media:Float = 0.0
        
        let fetchRequest = NSFetchRequest(entityName: TarefaManager.entityName)
        var error: NSError?
        let predicate = NSPredicate(format: "disciplina == %@", materia)
        fetchRequest.predicate = predicate
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        var numAtivs = 0
        if let results = fetchedResults as? [Atividade] {
            if results.count < 1{
                return -1
            }
            for ativ in results {
                if ativ.avaliado == 1 {
                    media = media + ativ.nota.floatValue
                    numAtivs++
                }
            }
            if numAtivs < 1 {
                return -1
            }
            return media/Float(numAtivs)
        } else {
            println("Erro ao buscar tarefas.")
        }
        
        return media
    }
    
    //BE VERY CAREFUL AROUND THIS PLEASE
    func deleteAllTarefas(){
        //THINK ABOUT WHAT YOU ARE DOING
        let tarefas = self.fetchAllTarefas()
        //ARE YOU SURE ABOUT THIS?
        for tarefa in tarefas{
            //HOLD ON RIGHT WHERE YOU ARE
            self.managedObjectContext.deleteObject(tarefa)
            //WELL IT IS DONE NOW
        }
        //GOOD JOB BREAKING IT HERO
		self.save()
    }

	func deleteTarefa(#tarefa: Atividade){
		managedObjectContext.deleteObject(tarefa)

		if CloudKitManager.sharedInstance.icloudEnabled{
			self.deleteFromCloud(tarefa)
		}
	}

//	func removeDuplicated(){
//		func removeDuplicated(){
//			var tarefas = self.fetchAllTarefas() // Pega todos as materias existentes
//			tarefas.sort{$0.0.nomeAtiv.compare($0.1.nomeAtiv) == NSComparisonResult.OrderedDescending}
//			while tarefas.count > 1 {
//				if tarefas[0].nomeAtiv == tarefas[1].nomeAtiv {
//					if tarefas[0].idCloud.doubleValue > tarefas[1].idCloud.doubleValue{
//						managedObjectContext.deleteObject(tarefas[1])
//						tarefas.removeAtIndex(1)
//					}
//					else{
//						managedObjectContext.deleteObject(tarefas[0])
//						tarefas.removeAtIndex(0)
//					}
//				}
//				else{
//					tarefas.removeAtIndex(0)
//				}
//			}
//			self.save()
//		}
//	}

	func saveInCloud(tarefa: Atividade, inout error err: NSError?){
		let cloud = CloudKitManager.sharedInstance

		let id = CKRecordID(recordName: tarefa.idCloud)
		let record = CKRecord(recordType: TarefaManager.entityName, recordID: id)

		record.setObject(tarefa.nomeAtiv, forKey: "nomeAtiv")
		record.setObject(tarefa.avaliado, forKey: "avaliado")
		record.setObject(tarefa.dataEntrega, forKey: "dataEntrega")
		record.setObject(tarefa.nota, forKey: "nota")
		record.setObject(tarefa.tipoAtiv, forKey: "tipoAtiv")

		let reference = CKReference(recordID: CKRecordID(recordName: "\(tarefa.disciplina.idCloud)"), action: CKReferenceAction.DeleteSelf)

		record.setObject(reference, forKey: "disciplina")

		cloud.privateDB.saveRecord(record, completionHandler: { (savedRecord, error) -> Void in

			if error != nil{
				println(error.localizedDescription)
			}
			err = error
		})
	}

	func deleteFromCloud(tarefa: Atividade){
		let cloud = CloudKitManager.sharedInstance

		cloud.privateDB.deleteRecordWithID(CKRecordID(recordName: tarefa.idCloud), completionHandler: { (record, error) -> Void in

			if error != nil{
				println(error.localizedDescription)
			}
		})
	}

}
