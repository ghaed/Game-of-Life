//
//  LifeDataModel.swift
//  assn4
//
//  Created by Saeedeh Salimian on 7/16/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import UIKit

protocol ModelChangDelegate {
    func modelDataChanged()
}

/* CGPoint is floating point and not appropriate */
typealias CellPoint = (col: Int, row: Int)

/* Alive is equivalent to Born computationally. Similarly for Died * Empty.
 But visually we want the option of rendering them differently, so we model
 it */
enum CellState {
    case Alive
    case Died
    case Born
    case Empty
    
    // But importantly, provide the logical abstraction over it
    var isLive: Bool {
        get {
            return self == .Alive || self == .Born
        }
    }
    
    // inverse of any current value; useful in the drawing stage
    var inverse: CellState {
        get {
            switch self {
            case .Alive, .Born:
                return .Empty
            case .Died, .Empty:
                return .Alive
            }
        }
    }
    
}


/* A more formal way of communicating between model and VC */

/* Model abstraction: ViewController will pick a model that implements
 this interface and instantiate it, but the rest of the
 ViewController's methods will pretend they don't know what concrete type it
 is and use the protocol as the type. */
protocol LifeDataSource {
    func moveToNextGeneration()
    func setCellAt(point: CellPoint, toState state: CellState)
    func cellStateAt(point: CellPoint) -> CellState
    func reset()
    var generation: Int { get }
    var size: Int { get }
}



class LifeDataModel: LifeDataSource {
    func moveToNextGeneration() {
        self.generation += 1
        var newGrid = self.grid     // Create a copy to store the new copy. Mutate the actual model only in the end to avoid unnecessary delegate callings
        for col in 0..<self.size {
            for row in 0..<self.size {
                switch (self.grid[col][row].isLive, countNeighborsWithToroidTopology((col: col, row: row))) {
                case (true, 0), (true, 1):
                    newGrid[col][row] = .Died
                case (true, 2), (true, 3):
                    newGrid[col][row] = .Alive
                case (true, 4), (true, 5), (true, 6), (true, 7), (true, 8):
                    newGrid[col][row] = .Died
                case (false, 3):
                    newGrid[col][row] = .Born
                default:
                    newGrid[col][row] = .Empty
                }
            }
        }
        grid = newGrid
    }
    func setCellAt(point: CellPoint, toState state: CellState) {
        grid[point.col][point.row] = state
    }
    
    func cellStateAt(point: CellPoint) -> CellState {
        return grid[point.col][point.row]
    }
    func reset() {
        self.generation = 1
        // REF: http://stackoverflow.com/questions/24811456/how-to-create-swift-empty-two-dimensional-array-with-size
        // Tried the following compact form, but it did not work because the array is empty initially :(
        // grid = grid.map({$0.map({_ in CellState.Empty})})
        grid = [[CellState]]()
        for xIndex in 0..<size {
            grid.append([CellState]())
            for _ in 0..<size {
                grid[xIndex].append(.Empty)
            }
        }
    }
    
    // Convenience method to see how to count neighbors. You may copy this
    // into your solution. Node 'grid' is a 2-D array of 'CellState's.
    
    // Count the neighbors of a cell, treating the grid as a if it were
    // wrapped around both the X and Y axes, so it becomes effectively a
    // doughnut. Effectively, a cell at the leftmost boundary has as its
    // neighbor the cell on the same row at the rightmost
    // boundary. Similar for top and bottom.
    var grid = [[CellState]]() {
        didSet {
            delegate?.modelDataChanged()
        }
    }
    var gridXDim = 10 {
        didSet {
            delegate?.modelDataChanged()
        }
    }
    var gridYDim = 10
    
    func countNeighborsWithToroidTopology(p: CellPoint) -> Int {
        var count = 0
        
        for neighborXOffset in -1...1 {
            for neighborYOffset in -1...1 {
                if neighborXOffset == 0 && neighborYOffset == 0 {
                    continue // self isn't a neighbor
                }
                let neighbor = (row: (self.size + p.row + neighborXOffset)%self.size, col: (self.size + p.col + neighborYOffset)%self.size) // Swift remainder operator is stupid, so, we have to work around it
                // Problem for you: fix the wrap around bugs (both > bound and < 0)
                if grid[neighbor.col][neighbor.row].isLive {
                    count += 1
                }
                
            }
        }
        
        return count
    }
    
    
    var generation: Int = 0 {
        didSet {
            delegate?.modelDataChanged()
        }
    }
    var size: Int {
        get {
            return gridXDim
        }
        set {
            self.gridXDim = newValue
            self.gridYDim = newValue
        }
    }
    
    
    /****** DELEGATES ******/
    var delegate: ModelChangDelegate? {
        didSet {
            if let _ = delegate {
                print("From now on, propagating messages to delegate")
            }
            else {
                print("delegate cleared")
            }
        }
    }

    
}