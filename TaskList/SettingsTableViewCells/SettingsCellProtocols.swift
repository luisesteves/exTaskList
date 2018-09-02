 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //
 
protocol SwitchCellDelegate: class {
    func switchCellTableViewValueChanged(_ sender: SwitchCell)
}

protocol CategoryShowCellDelegate: class {
    func categoryShowCellSaveButtonTapped(_ sender: CategoryShowCell)
    
    
}
