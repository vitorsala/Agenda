//
//  TarefaTableViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData

class TarefaTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var materia:Materia!
    var tarefas:NSMutableArray!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = materia.nomeMateria
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshData(nil)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: CoreDataStackDidImportedNotification, object: nil)
    }

	override func viewWillDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: CoreDataStackDidImportedNotification, object: nil)
	}

	@objc func refreshData(notification : NSNotification?){
		tarefas = NSMutableArray(array: TarefaManager.sharedInstance.fetchTarefasForMateria(self.materia))
		self.tableView.reloadData()
	}

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tarefas.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        let cell = tableView.dequeueReusableCellWithIdentifier("tarefaCelula") as! TarefasCell
        cell.nome?.text = (self.tarefas.objectAtIndex(indexPath.row) as! Atividade).nomeAtiv
        
//        cell.detailTextLabel?.text = "\((self.tarefas.objectAtIndex(indexPath.row) as! Atividade).nota)"
        
        if (self.tarefas.objectAtIndex(indexPath.row) as! Atividade).tipoAtiv == 0 {
            cell.img.image = UIImage(named: "imgProva.png");
        } else {
            cell.img.image = UIImage(named: "imgTrabalho.png");
        }
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm";
        cell.data?.text = dateFormatter.stringFromDate((self.tarefas.objectAtIndex(indexPath.row) as! Atividade).dataEntrega);
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let editTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editTarefa") as! EditarTarefaViewController
        editTVC.tarefa = self.tarefas.objectAtIndex(indexPath.row) as! Atividade
        self.navigationController?.pushViewController(editTVC, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //Apaga tarefa do calendário.
            EventManager.sharedInstance.deletaTarefa(self.tarefas.objectAtIndex(indexPath.row) as! Atividade);
            
            TarefaManager.sharedInstance.managedObjectContext.deleteObject(self.tarefas.objectAtIndex(indexPath.row) as! NSManagedObject)
            self.tarefas.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            TarefaManager.sharedInstance.save()
            
        }
        self.tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! AddTarefaViewController).materia = self.materia
    }
    

}
