//
//  TarefaManager.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData

class TarefaManager: NSObject{
    
    static let sharedInstance = TarefaManager()
    static let entityName = "Atividade"
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var coredata = CoreDataStack.sharedInstance;
        return coredata.managedObjectContext!
        }()
    
    
    //TIPO 0 = PROVA   TIPO 1 = TRABALHO
    func insertNewTarefa(nome:String, disc:Materia, data:NSDate, tipo:Int){
        let newTarefa = NSEntityDescription.insertNewObjectForEntityForName(TarefaManager.entityName, inManagedObjectContext: managedObjectContext) as! Atividade
        newTarefa.nomeAtiv = nome
        newTarefa.disciplina = disc
        newTarefa.dataEntrega = data
        newTarefa.tipoAtiv = tipo
        newTarefa.idCloud = NSDate().timeIntervalSince1970 as Double
        self.save()
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
    }
    
}
