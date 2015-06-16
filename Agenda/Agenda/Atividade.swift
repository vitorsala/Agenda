//
//  Atividade.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/14/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import CoreData

class Atividade: NSManagedObject {

    @NSManaged var avaliado: NSNumber
    @NSManaged var dataEntrega: NSDate
    @NSManaged var entregue: NSNumber
    @NSManaged var nomeAtiv: String
    @NSManaged var nota: NSNumber
    @NSManaged var tipoAtiv: NSNumber
    @NSManaged var idCloud: NSNumber
    @NSManaged var disciplina: Materia

}
