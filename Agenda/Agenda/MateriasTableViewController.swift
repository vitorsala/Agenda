//
//  MateriasTableViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import EventKit

class MateriasTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var editando:Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var arrayMaterias = NSMutableArray()

	var loading : LoadingView?
    
    let em:EventManager = EventManager.sharedInstance;

    override func viewDidLoad() {
        super.viewDidLoad()

        //Se o usuário não permitiu que usassem o calendário anteriormente, pergunta de novo lol.
        if(!em.verificaPermissao()){
            em.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        //NSNotificationCenter.defaultCenter().addObserver(self!.em, selector: "calendarioUpdated", name: EKEventStoreChangedNotification, object: nil);
                        println("porra ligo no granted");
                    } else {
                        println("Access denied")
                    }
                })
        }

		// Permissão para usar o icloud
		if CoreDataStack.sharedInstance.isLoggedInIcloud(){
			if NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) == nil{

				NSNotificationCenter.defaultCenter().addObserverForName(CoreDataStackDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in

					self.arrayMaterias = NSMutableArray(array: MateriaManager.sharedInstance.fetchAllMaterias())
					self.tableView.reloadData()
					self.loading?.removeFromSuperview()
				})

				self.loading = NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: nil).first as? LoadingView

				println("Vai querer o icloud?")

				let icloudalert = UIAlertController(title: "iCloud?", message: "Vai usar o iCloud?", preferredStyle: UIAlertControllerStyle.Alert)

				icloudalert.addAction(UIAlertAction(title: "YEAH!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					NSUserDefaults.standardUserDefaults().setBool(true, forKey: CoreDataStackIcloudFlagForUserDefault)
					CoreDataStack.sharedInstance.setup()
					self.view.addSubview(self.loading!)
				}))

				icloudalert.addAction(UIAlertAction(title: "NOPE!", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
					NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
					CoreDataStack.sharedInstance.setup()
				}))

				self.presentViewController(icloudalert, animated: true, completion: nil)

			}
			else{
				CoreDataStack.sharedInstance.setup()
			}
		}
		else{
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: CoreDataStackIcloudFlagForUserDefault)
			CoreDataStack.sharedInstance.setup()
		}

        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {

        self.editando = false
        self.editButton.title = "Editar"

		if NSUserDefaults.standardUserDefaults().objectForKey(CoreDataStackIcloudFlagForUserDefault) != nil{
			refreshData(nil)
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: CoreDataStackDidImportedNotification, object: nil)
    }

	override func viewWillDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: CoreDataStackDidImportedNotification, object: nil)
	}

	@objc func refreshData(notification : NSNotification?){
		arrayMaterias = NSMutableArray(array: MateriaManager.sharedInstance.fetchAllMaterias())
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMaterias.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel?.text = (arrayMaterias.objectAtIndex(indexPath.row) as! Materia).nomeMateria
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !editando{
            let tarefaTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TarefasTVC") as! TarefaTableViewController
            tarefaTVC.materia = self.arrayMaterias.objectAtIndex(indexPath.row) as! Materia
            self.navigationController?.pushViewController(tarefaTVC, animated: true)
        }
        else{
           let editTVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editMateria") as! EditarMateriaViewController
            editTVC.materia = self.arrayMaterias.objectAtIndex(indexPath.row) as! Materia
            self.navigationController?.pushViewController(editTVC, animated: true)
        }
    }
    

    @IBAction func editButton(sender: AnyObject) {
        self.editando = !self.editando
        if self.editando{
            editButton.title = "OK"
        }
        else{
            editButton.title = "Editar"
        }
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
