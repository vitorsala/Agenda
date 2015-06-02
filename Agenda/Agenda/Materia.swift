//
//  Materia.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import CoreData

class Materia: NSManagedObject {

    @NSManaged var nomeMateria: String
    @NSManaged var atividadesDaMateria: NSSet

}
