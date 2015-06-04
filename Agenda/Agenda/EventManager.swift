//
//  EventManager.swift
//  Agenda
//
//  Created by Lucas Leal Mendonça on 02/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import EventKit

class EventManager: NSObject {
   
    //Classe singleton pra controlar os paranaue do EventKit.
    static let sharedInstance = EventManager();
    
    let eventStore:EKEventStore;
    
    private override init() {
        eventStore = EKEventStore();
    }
    
    func criaCalendario(){
        var jaCriado = false;
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        
        for calendar in calendars {
            
            //Calendário padrão do dispositivo se chama "Calendar". Talvez seja interessante criar um calendário só pro app.
            if calendar.title == "AgendApp" {
                jaCriado = true;
                break;
            }
        }
        
        if(jaCriado){
            println("Calendário AgendApp já existe");
        } else {
            let calendario = EKCalendar(forEntityType: EKEntityTypeEvent, eventStore: eventStore);
            calendario.title = "AgendApp";
            for source in eventStore.sources(){
                //let currentSourceType = source.sourceType as EKSourceType;
                if (source.sourceType.value == EKSourceTypeLocal.value){
                    calendario.source = source as! EKSource;
                }
            }
            
            var error : NSError?;
            eventStore.saveCalendar(calendario, commit: true, error: &error);
            
            if(error != nil){
                println("Deu ruim");
            } else {
                println("Pora ligo");
            }
        }
        
    }
    
    //Deve dar pra deixar isso mais bonito.
    func verificaPermissao()->Bool{
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            println("Já tava autorizado");
            return true;
        case .Denied:
            println("Access denied")
            return false;
        case .NotDetermined:
            return false;
        default:
            println("Case Default")
            return false;
        }
    }
    
    func insertEvent(dataAtividade: NSDate, nome: String, materia: String) {
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        for calendar in calendars {

            //Calendário padrão do dispositivo se chama "Calendar". Talvez seja interessante criar um calendário só pro app.
            if calendar.title == "AgendApp" {

                //calendar.
                //endDate padrão de uma hora mais tarde do start.
                let endDate = dataAtividade.dateByAddingTimeInterval(1 * 60 * 60)
                
                //Craindo o evento e colocando os atributos necessários.
                var event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
                event.title = nome;
                event.startDate = dataAtividade
                event.endDate = endDate
                event.notes = materia;
                event.addAlarm(EKAlarm(relativeOffset: -60));
                
                //let alarme = EKAlarm(relativeOffset: -60);

                // Salvando o evento no calendario.
                var error: NSError?
                let result = eventStore.saveEvent(event, span: EKSpanThisEvent, error: &error)
                
                if result == false {
                    if let theError = error {
                        println("An error occured \(theError)")
                    }
                }
            }
        }
    }
    
//    func calendarioUpdated(){
//        println("wow wink");
//    }

}
