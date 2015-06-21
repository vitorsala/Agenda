//
//  EventManager.swift
//  Agenda
//
//  Created by Lucas Leal Mendonça on 02/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import EventKit

class EventManager {
   
    //Classe singleton pra controlar os paranaue do EventKit.
    static let sharedInstance = EventManager();
    
    let eventStore:EKEventStore;
    
    private init() {
        eventStore = EKEventStore();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncCalICloud:", name: "didFinishedSyncWithCloud", object: nil)
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
            if eventStore.sources() != nil {
                for source in eventStore.sources(){
                    //let currentSourceType = source.sourceType as EKSourceType;
                    if (source.sourceType.value == EKSourceTypeLocal.value){
                        calendario.source = source as! EKSource;
                    }
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
    
    func editaEvento(nNome: String, nData: NSDate, tarefa: Atividade){
        let cal = NSMutableArray();
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        for calendar in calendars {
            
            if calendar.title == "AgendApp" {
                cal.addObject(calendar);
                break;
            }
        }

        //Não dá pra pegar todos. Então tem que fazer essa gambiarra em duas fases mesmo :P
        let pred = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate.distantFuture() as! NSDate, calendars: cal as [AnyObject]);
        let eventos = NSMutableArray(array: eventStore.eventsMatchingPredicate(pred));
        var encontrou = false;
        for e in eventos{
            let evento = e as! EKEvent;
            //Se o nome e a data forem as mesmas, faz as alterações
            if(evento.title == tarefa.nomeAtiv && evento.startDate == tarefa.dataEntrega){
                evento.title = nNome;
                evento.startDate = nData;
                evento.endDate = evento.startDate.dateByAddingTimeInterval(60);
                evento.alarms = nil;
                //evento.addAlarm(EKAlarm(relativeOffset: -60));
                
                // Salvando o evento no calendario.
                var error: NSError?
                let result = eventStore.saveEvent(evento, span: EKSpanThisEvent, error: &error)
                
                if result == false {
                    if let theError = error {
                        println("An error occured \(theError)")
                    }
                }
                encontrou = true;
                break;
            }
        }
        
        //Se a data do evento estiver no passado.
        if(!encontrou){
            insertEvent(nData, nome: nNome, materia: tarefa.disciplina.nomeMateria);
        }

    }
    
    func deletaEventosFuturos(){
        let futuro :NSDate = NSDate.distantFuture() as! NSDate;
        let cal = NSMutableArray();
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        for calendar in calendars {
            
            if calendar.title == "AgendApp" {
                cal.addObject(calendar);
                break;
            }
        }
        
        if cal.count < 1{
            return
        }
        
        let pred = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: futuro, calendars: cal as [AnyObject]);
        let eventos = NSMutableArray(array: eventStore.eventsMatchingPredicate(pred));
        for evento in eventos{
            var error:NSError?;
            eventStore.removeEvent(evento as! EKEvent, span: EKSpanThisEvent, error: &error);
            if(error != nil){
                println("nem apago");
            } else {
                println("porra apago");
            }
        }
    }
    
    @objc func syncCalICloud(notif:NSNotification){
        let tarefas: NSArray = TarefaManager.sharedInstance.fetchTarefasFuturas()
        self.deletaEventosFuturos();
        for t in tarefas{
            let tarefa = t as! Atividade;
            insertEvent(tarefa.dataEntrega, nome: tarefa.nomeAtiv, materia: tarefa.disciplina.nomeMateria);
        }
        
    }
    
    func deletaTarefa(tarefa: Atividade){
        let futuro :NSDate = NSDate.distantFuture() as! NSDate;
        let cal = NSMutableArray();
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        for calendar in calendars {
            
            if calendar.title == "AgendApp" {
                cal.addObject(calendar);
                break;
            }
        }
        
        let pred = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: futuro, calendars: cal as [AnyObject]);
        let eventos = NSMutableArray(array: eventStore.eventsMatchingPredicate(pred));
        for e in eventos{
            let evento = e as! EKEvent;
            var error:NSError?;
            if(evento.title == tarefa.nomeAtiv && evento.startDate == tarefa.dataEntrega){
                eventStore.removeEvent(evento, span: EKSpanThisEvent, error: &error);
                if(error != nil){
                    println("nem apago");
                } else {
                    println("porra apago");
                    break;
                }
            }
        }
    }
    
    func deletaMateria(materia: Materia){
        let futuro :NSDate = NSDate.distantFuture() as! NSDate;
        let cal = NSMutableArray();
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        for calendar in calendars {
            
            if calendar.title == "AgendApp" {
                cal.addObject(calendar);
                break;
            }
        }
        
        let pred = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: futuro, calendars: cal as [AnyObject]);
        let eventos = NSMutableArray(array: eventStore.eventsMatchingPredicate(pred));
        for e in eventos{
            let evento = e as! EKEvent;
            var error:NSError?;
            if(evento.notes != nil && evento.notes == materia.nomeMateria){
                eventStore.removeEvent(evento, span: EKSpanThisEvent, error: &error);
                if(error != nil){
                    println("nem apago");
                } else {
                    println("porra apago");
                }
            }
        }
    }
    
    func editaMateria(nomeAntigo: String, nomeNovo: String){
        let futuro :NSDate = NSDate.distantFuture() as! NSDate;
        let cal = NSMutableArray();
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        for calendar in calendars {
            
            if calendar.title == "AgendApp" {
                cal.addObject(calendar);
                break;
            }

        }
        
        if cal.count < 1 {
            return
        }
        
        let pred = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: futuro, calendars: cal as [AnyObject]);
        let eventos = NSMutableArray(array: eventStore.eventsMatchingPredicate(pred));
        for e in eventos{
            let evento = e as! EKEvent;
            var error:NSError?;
            if(evento.notes != nil && evento.notes == nomeAntigo){
                evento.notes = nomeNovo;
                // Salvando o evento no calendario.
                var error: NSError?
                let result = eventStore.saveEvent(evento, span: EKSpanThisEvent, error: &error)
                
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
