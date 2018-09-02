 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //
 
import UIKit
import CoreData
import UserNotifications

class ModCreatetaskViewController: UIViewController {

    weak var delegate: AddManageTaskViewControllerDelegate?

    public var categoryArray: [Category]!
    public var modifyTask: Task?
    public var indexPathOfmodifyTask: IndexPath?

    private var chosenCategory: Category?

    let notificationCenter = UNUserNotificationCenter.current()
    
    let options: UNAuthorizationOptions = [.alert, .sound, .badge];
    
    var notification: UNNotificationRequest?

    private let nameTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "Task title:"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add new task"
        textField.borderStyle = .roundedRect;
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .default
        textField.font = .boldSystemFont(ofSize: 17)
        return textField
    }()
    
    private let whenShouldDone: UILabel = {
        let label = UILabel()
        label.text = "Date should be done:"
        
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let dateShouldDoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add date  - optional"
        textField.borderStyle = .roundedRect;
        textField.font = .boldSystemFont(ofSize: 17)
        textField.addTarget(self, action: #selector(handleActionDatePick), for: .editingDidBegin)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let chooseCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category:"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add category - optional"
        textField.borderStyle = .roundedRect;
        textField.font = .boldSystemFont(ofSize: 17)
        textField.addTarget(self, action: #selector(handleActionCategoryPick), for: .editingDidBegin)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let  setNotificationOnLabel: UILabel = {
        let label = UILabel()
        label.text = "Turn notification on"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    private let  notificationSwitch: UISwitch = {
        let notificationSwitch = UISwitch()
        notificationSwitch.isOn = false
        return notificationSwitch
    }()
    
    private let  setIsDoneTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark task as done"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.isHidden = true
        return label
    }()
    private let  isDoneSwitch: UISwitch = {
        let isDoneSwitch = UISwitch()
        isDoneSwitch.isOn = false
        isDoneSwitch.isHidden = true
        return isDoneSwitch
    }()
    
    
    private let buttonSaveOrEdit: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Save task", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(displayP3Red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleSaveOrEditAction), for: .touchUpInside)
        return button
    }()
    
    private let buttonDelete: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Delete task", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleDeleteAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUIToNewOrModifyExists(modifyTask: modifyTask)
        
        checkNotificationIsSet()
        
        self.title = "Task List"
    }
    
     
    fileprivate func checkNotificationIsSet() {
        notificationSwitch.isOn = false
        notification = nil
         
        guard modifyTask != nil else { return }
        
        notificationCenter.getPendingNotificationRequests { (notifications) in
            
            for notification in notifications {
                if notification.identifier == self.modifyTask?.taskTitle {
                    DispatchQueue.main.async() {
                        self.notification = notification
                        self.notificationSwitch.isOn = true
                    }
                }
            }
        }
    }
    
     
    fileprivate func checkIfNotificationIsAllowed() {
        notificationCenter.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                return
            }
        }
    }
    
    fileprivate func createRequstAndAddNotificationToNotificationCenter(_ task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.taskTitle
        content.body = "Now"
        content.sound = UNNotificationSound.default()
        let date = task.dateToComplete!
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = task.taskTitle!
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: { (error) in
        })
    }
    
    func notificationSetOn(task: Task)  {
        checkIfNotificationIsAllowed()
        if notificationSwitch.isOn {
            createRequstAndAddNotificationToNotificationCenter(task)
        } else {
            if let tempNotification = notification {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [tempNotification.identifier])
            }
        }
        
    }
    
    
     
    @objc func handleSaveOrEditAction(sender: UIButton) {
         
        if titleTextField.text!.count < 3 {
            showAlert(message: "Task name is need to be at least 3 letters long.")
            return
        }
        let newTask = Task(taskTitle: titleTextField.text!, dateWhenShouldDone: Task.dateShouldBeDoneFromString(dateString: dateShouldDoneTextField.text!), category: chosenCategory, isItDone: isDoneSwitch.isOn)
        
         
        if notificationSwitch.isOn {
             
            if let tempNotification = notification {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [tempNotification.identifier])
            }
             
            guard newTask.dateToComplete != nil else {
                showAlert(message: "Please add date to turn on the notification.")
                notificationSwitch.isOn = false
                return
            }
            notificationSetOn(task: newTask)
        }
        
        if modifyTask == nil {
             
            if !newTask.isExist() {
                newTask.saveTaskToCoreData()
                delegate?.addNewTasksToActive(newTask: newTask)
                setUIToNewOrModifyExists(modifyTask: nil)
                
            } else {
                showAlert(message: "Task with name \"\(newTask.taskTitle!)\" is already exists.")
                return
            }
            notificationSetOn(task: newTask)
        } else {
             
             
            modifyTask!.modifyTask(newTask: newTask)
             
             
            setUIToNewOrModifyExists(modifyTask: nil)
            
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
     
    @objc func handleDeleteAction(sender: UIButton) {
        
         
        if let tempNotification = notification {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [tempNotification.identifier])
        }
         
        delegate?.removeTask(fromIndexPath: indexPathOfmodifyTask!)
         
        modifyTask?.deleteTaskCoreData()
         
        setUIToNewOrModifyExists(modifyTask: nil)
    }
}

 
extension ModCreatetaskViewController {
    
     
    func showAlert(message: String) {
        
        let allertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(allertController, animated: true, completion: nil)
    }
    
     
    func setUIToNewOrModifyExists(modifyTask: Task?) {
        if let taskExist = modifyTask {
            prepareItemForManageExistingTask(taskExist)
        } else {
            prepareItemForSaveNewTask()
        }
    }
    
     
    private func SetUpLayout() {
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [nameTaskLabel,
                                                   titleTextField,
                                                   whenShouldDone,
                                                   dateShouldDoneTextField,
                                                   chooseCategoryLabel,
                                                   setUpCategoryTextFieldAndcolorView(),
                                                   setUpNotificationIsDoneLabel(),
                                                   setUpNotificationIsDoneSwitch(),
                                                   setUpSaveDeleteButton()])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        view.addSubview(stack)
        stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        titleTextField.delegate = self
        
    }
    
    func setUpCategoryTextFieldAndcolorView() -> UIView {
        let view = UIView()
        view.addSubview(categoryTextField)
        view.addSubview(colorView)
        
        colorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        colorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        categoryTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        categoryTextField.trailingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -10).isActive = true
        categoryTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        return view
    }
    
    fileprivate func prepareItemForSaveNewTask() {
        titleTextField.text = ""
        titleTextField.borderStyle = .roundedRect
        dateShouldDoneTextField.text = ""
        dateShouldDoneTextField.borderStyle = .roundedRect
        chosenCategory = nil
        categoryTextField.text = ""
        categoryTextField.borderStyle = .roundedRect
        colorView.backgroundColor = .white
        buttonSaveOrEdit.setTitle("Save task", for: .normal)
        buttonDelete.isHidden = true
        setIsDoneTaskLabel.isHidden = true
        isDoneSwitch.isHidden = true
    }
    
    fileprivate func prepareItemForManageExistingTask(_ taskExist: Task) {
        titleTextField.text = taskExist.taskTitle
        titleTextField.borderStyle = .none
        
        let dateString = Task.dateShouldBeDoneToString(date: taskExist.dateToComplete)
        dateShouldDoneTextField.text = dateString
        dateShouldDoneTextField.borderStyle = .none
        chosenCategory = taskExist.category
        categoryTextField.text = taskExist.category?.name
        categoryTextField.borderStyle = .none
        colorView.backgroundColor = taskExist.category?.color
        buttonSaveOrEdit.setTitle("Modify task", for: .normal)
        buttonDelete.isHidden = false
        setIsDoneTaskLabel.isHidden = false
        isDoneSwitch.isHidden = false
        isDoneSwitch.isOn = taskExist.isItDone
    }
    
    func setUpSaveDeleteButton() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [buttonSaveOrEdit, buttonDelete])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
    func setUpNotificationIsDoneLabel() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [setNotificationOnLabel, setIsDoneTaskLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    func setUpNotificationIsDoneSwitch() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [notificationSwitch, isDoneSwitch])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
}


 
extension ModCreatetaskViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func handleActionDatePick(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.locale = Locale(identifier: "cs")
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        dateShouldDoneTextField.text = Task.dateShouldBeDoneToString(date: sender.date)
    }
    
    @objc func handleActionCategoryPick(sender: UITextField) {
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        sender.inputView = pickerView
    }
    
     
    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categoryArray.count + 1
    }
    
     
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Category"
        } else
        {
            return categoryArray[row-1].name
        }
    }
     
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            categoryTextField.text = categoryArray[row-1].name
            colorView.backgroundColor = categoryArray[row-1].color
            chosenCategory = categoryArray[row-1]
        }
    }
}

