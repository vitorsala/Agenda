//
//  Atividade.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import CoreData

class Atividade: NSManagedObject {

    @NSManaged var nomeAtiv: String
    @NSManaged var dataEntrega: NSDate
    @NSManaged var nota: NSNumber
    @NSManaged var disciplina: Materia

}
