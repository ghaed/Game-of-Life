//
//  CustomView.swift
//  assn4
//
//  Created by Saeedeh Salimian on 7/17/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import UIKit

class CustomView: UIView {
    // Width of each cell
    var cellWidth: Double {
        get {
            guard let model = lifeDataModel else {
                print("cannot get cellwidth since model is not instantiated yet")
                return 0
            }
            return Double(bounds.width)/Double(model.size)
        }
    }
    // Height of each cell
    var cellHeight: Double {
        get {
            guard let model = lifeDataModel else {
                print("cannot get cellwidth since model is not instantiated yet")
                return 0
            }
            return Double(bounds.width)/Double(model.size)
        }
    }
    var lifeDataModel: LifeDataModel?
    override func drawRect(rect: CGRect) {
        guard let model = self.lifeDataModel else {
            print("cannot do drawRect since lifeDataModel is not initialized")
            return
        }
        print ("Entering Rect")
        print ("Sweeping the UIView")
        var xLoc = 0.0
        var yLoc = 0.0
        for xIndex in 0..<model.size {
            for yIndex in 0..<model.size {
                xLoc = Double(xIndex) * self.cellWidth
                yLoc = Double(yIndex) * self.cellHeight
                let cell = UIBezierPath(rect: CGRect(x: xLoc, y: yLoc, width: self.cellWidth, height: self.cellWidth))
                switch model.grid[xIndex][yIndex] {
                case .Alive:
                    //print("Detected an alive cell. Drawing...")
                    UIColor.greenColor().setFill()
                case .Born:
                    //print("Detected a born cell. Drawing...")
                    UIColor.cyanColor().setFill()
                case .Died:
                    //print("Detected a died cell. Drawing...")
                    UIColor.brownColor().setFill()
                case .Empty:
                    //print("Detected an empty cell. Drawing...")
                    UIColor.grayColor().setFill()
                }
                
                UIColor.blueColor().setStroke()
                //print("Cell rectangle set up x:\(xIndex) y:\(yIndex) width:\(self.cellWidth)")
                cell.lineWidth = 2
                cell.fill()
                cell.stroke()
            }
        }
        print("Grid redrawn successfully")
        
    }
    

    

    

}
