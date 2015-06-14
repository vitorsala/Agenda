//
//  MateriaManager.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData

class MateriaManager: NSObject{
    
    static let sharedInstance = MateriaManager()
    static let entityName = "Materia"
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var coreData = CoreDataStack.sharedInstance
        return coreData.managedObjectContext!
        }()
    
    func insertNewMateria(nome:String){
        let newMateria = NSEntityDescription.insertNewObjectForEntityForName(MateriaManager.entityName, inManagedObjectContext: managedObjectContext) as! Materia
        newMateria.nomeMateria = nome
        newMateria.idCloud = NSDate().timeIntervalSince1970 as Double
        self.save()
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
    }
    
}