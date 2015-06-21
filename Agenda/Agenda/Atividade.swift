//
//  Atividade.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 19/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import CoreData

class Atividade: NSManagedObject {

    @NSManaged var avaliado: NSNumber
    @NSManaged var dataEntrega: NSDate
    @NSManaged var entregue: NSNumber
    @NSManaged var idCloud: String
    @NSManaged var nomeAtiv: String
    @NSManaged var nota: NSNumber
    @NSManaged var tipoAtiv: NSNumber
    @NSManaged var disciplina: Materia

}
