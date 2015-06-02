//
//  CloudKitManager.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 02/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import CloudKit

struct RecordType {
    static let user = "User"
}

class CloudKitManager {
    var privateDB : CKDatabase
    var publicDB : CKDatabase
    var container : CKContainer

    static let sharedInstance = CloudKitManager()
    private init(){
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }

    func saveRecord(todo : AnyObject?, inEntityNamed: String) {
        let todoRecord = CKRecord(recordType: "Todos")
        todoRecord.setValue(todo, forKey: "todotext")
        publicDB.saveRecord(todoRecord, completionHandler: { (record, error) -> Void in
            NSLog("Saved to cloud kit")
        })
    }
}