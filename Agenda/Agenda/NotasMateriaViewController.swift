//
//  NotasMateriaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/2/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class NotasMateriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var materia:Materia!
    var tarefas:NSMutableArray!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Relatorio para \(materia.nomeMateria)"

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        refreshData(nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: didFinishedSyncWithCloudNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: didFinishedSyncWithCloudNotification, object: nil)
    }
    
    func refreshData(notification : NSNotification?){
		self.tarefas = NSMutableArray(array: TarefaManager.sharedInstance.fetchTarefasForMateria(materia));
		self.tableView.reloadData();
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tarefas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        
        let tarefa = tarefas.objectAtIndex(indexPath.row) as! Atividade
        
        cell.textLabel?.text = tarefa.nomeAtiv
        
        let nota = tarefa.nota
        
        if tarefa.avaliado == 1{
            cell.detailTextLabel?.text = "\(nota)"
            let ud = NSUserDefaults.standardUserDefaults();
            if(ud.valueForKey("media") != nil){
                if(nota.floatValue < (ud.valueForKey("media") as! NSString).floatValue){
                    cell.backgroundColor = UIColor.redColor();
                } else {
                    cell.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.25);
                }
            }
        }
        else {
            cell.detailTextLabel?.text = "Ainda não avaliado."
        }
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
