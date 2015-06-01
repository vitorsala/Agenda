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
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        return appDelegate.managedObjectContext!
        }()
    
    func insertNewTarefa(nome:String, disc:Materia, data:NSDate){
        let newTarefa = NSEntityDescription.insertNewObjectForEntityForName(TarefaManager.entityName, inManagedObjectContext: managedObjectContext) as! Atividade
        newTarefa.nomeAtiv = nome
        newTarefa.disciplina = disc
        newTarefa.dataEntrega = data
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
