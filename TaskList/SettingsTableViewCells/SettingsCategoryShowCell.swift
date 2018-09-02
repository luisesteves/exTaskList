 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //

import UIKit

 
class CategoryShowCell: UITableViewCell, UITextFieldDelegate {

    
    
    weak var delegate: CategoryShowCellDelegate?
    
     
    private let colorsCategory = [UIColor.black, UIColor.blue,UIColor.brown,UIColor.cyan, UIColor.darkGray, UIColor.gray, UIColor.green, UIColor.lightGray, UIColor.magenta, UIColor.orange, UIColor.purple, UIColor.red, UIColor.yellow]
    
     
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add new category"
        textField.borderStyle = .none;
        textField.isUserInteractionEnabled = false
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .default
        textField.font = .boldSystemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let editView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let manageCategoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add Category name"
        textField.borderStyle = .roundedRect;
        textField.font = .boldSystemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let buttonSaveOrEdit: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Save", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(displayP3Red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let colorCollectionView: UICollectionView! = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpLayout()
        buttonSaveOrEdit.addTarget(self, action: #selector(handleSaveOrEditButton), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     
    public func setCell(category: Category) {
        titleTextField.text = category.name
        colorView.backgroundColor = category.color
    }
     
    public func editViewIsHidden(isHidden: Bool)  {
        if isHidden {
            editView.isHidden = true
            titleTextField.borderStyle = .none
            titleTextField.isUserInteractionEnabled = false
            
        } else {
            editView.isHidden = false
            titleTextField.borderStyle = .roundedRect
            titleTextField.isUserInteractionEnabled = true
        }
        
    }

     
    public func getCategory() -> Category? {
        if let titleExists = titleTextField.text, titleExists.count >= 3 {
            return Category(nameOfCategory: titleTextField.text!, ColorOfCategory: colorView.backgroundColor!)
        } else {
            return nil
        }
    }

    @objc func handleSaveOrEditButton(sender: UIButton) {
        delegate?.categoryShowCellSaveButtonTapped(self)
    }
}

 
extension CategoryShowCell {
    
    fileprivate func setUpViewForCategoryLayout(_ viewForCategory: UIView) {
        
        colorView.topAnchor.constraint(equalTo: viewForCategory.topAnchor, constant: 5).isActive = true
        colorView.trailingAnchor.constraint(equalTo: viewForCategory.trailingAnchor, constant: -5).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        titleTextField.topAnchor.constraint(equalTo: viewForCategory.topAnchor, constant: 5).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: viewForCategory.leadingAnchor, constant: 20).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -10).isActive = true
        titleTextField.bottomAnchor.constraint(equalTo: viewForCategory.bottomAnchor, constant: -5).isActive = true
    }
    
    fileprivate func setUpLayoutEditViewLayout() {
        colorCollectionView.topAnchor.constraint(equalTo: editView.topAnchor, constant: 5).isActive = true
        colorCollectionView.bottomAnchor.constraint(equalTo: editView.bottomAnchor, constant: -5).isActive = true
        colorCollectionView.trailingAnchor.constraint(equalTo: buttonSaveOrEdit.leadingAnchor, constant: -10).isActive = true
        colorCollectionView.leadingAnchor.constraint(equalTo: editView.leadingAnchor, constant: 5).isActive = true
        
        buttonSaveOrEdit.bottomAnchor.constraint(equalTo: editView.bottomAnchor, constant: -5).isActive = true
        buttonSaveOrEdit.trailingAnchor.constraint(equalTo: editView.trailingAnchor, constant: -5).isActive = true
        buttonSaveOrEdit.topAnchor.constraint(equalTo: editView.topAnchor, constant: 5).isActive = true
        buttonSaveOrEdit.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    fileprivate func setUpLayout() {
        
        
        let viewForCategory = UIView()
        viewForCategory.addSubview(titleTextField)
        viewForCategory.addSubview(colorView)
        setUpViewForCategoryLayout(viewForCategory)
        
        editView.addSubview(colorCollectionView)
        editView.addSubview(buttonSaveOrEdit)
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellID")
        setUpLayoutEditViewLayout()
        
        let stackViewForCell = UIStackView(arrangedSubviews: [viewForCategory,editView])
        stackViewForCell.translatesAutoresizingMaskIntoConstraints = false
        stackViewForCell.axis = .vertical
        stackViewForCell.spacing = 10
        addSubview(stackViewForCell)
        stackViewForCell.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stackViewForCell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        stackViewForCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        stackViewForCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
    }
    
    
}


 
extension CategoryShowCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 25, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
        cell.backgroundColor = colorsCategory[indexPath.row]
        cell.layer.cornerRadius = 12
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorView.backgroundColor = colorsCategory[indexPath.item]
    }
}


