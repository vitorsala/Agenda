//
//  Materia.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 19/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import CoreData

class Materia: NSManagedObject {

    @NSManaged var idCloud: String
    @NSManaged var nomeMateria: String
    @NSManaged var atividadesDaMateria: NSSet

}
