//
//  ViewController.swift
//  assn4
//
//  Created by Saeedeh Salimian on 7/16/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ModelChangDelegate {
    /****** OUTLETS ******/
    @IBOutlet weak var myCustomView: UIView!
    @IBOutlet weak var mySlider: UISlider!
    @IBOutlet weak var myGenerationLabel: UILabel!
    @IBOutlet weak var myResetButton: UIButton!
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var myGridSlider: UISlider!
    @IBOutlet weak var mySpeedVal: UILabel!
    @IBOutlet weak var myGridSizeVal: UILabel!
    
    /****** ACTIONS ******/
    @IBAction func myResetButtonTouchUpInside(sender: AnyObject) {
        mySwitch.on = false
        timer.invalidate()
        lifeDataModel.reset()
    }
    @IBAction func mySwitchValueChanged(sender: UISwitch) {
        if sender.on == true {
            startTimer()        // Encapsulated in a method since it is called from two different sources: the slider and the button
        }
        else {
            timer.invalidate()
        }
    }
    @IBAction func mySpeedSliderValueChanged(sender: AnyObject) {
        mySpeedVal.text = String(format: "%.1f", mySlider.value)
        if mySwitch.on {
            timer.invalidate()
            startTimer()
        }
    }
    
    @IBAction func myGridSliderValueChanged(sender: AnyObject) {
        lifeDataModel.size = Int(myGridSlider.value)
        lifeDataModel.reset() // Absolutely necessary to allocate new memory for the new size of the grid
    }
    /****** VARIABLES ******/
    var timer = NSTimer()
    var lifeDataModel = LifeDataModel()

    /****** GENERAL METHODS ******/
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1/Double(self.mySlider.value), target: self, selector: #selector(ViewController.countUp), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Turn off the switch initially
        mySwitch.on = false
        // Assign self to take over the delegate in charge of updating the UI based on changes in model
        lifeDataModel.delegate = self
        lifeDataModel.reset()
        // Pass a reference of data model to customUIView class
        guard let view = myCustomView as? CustomView else{
            print("myCustomView cannot be cast to CustomView")
            return
        }
        lifeDataModel.reset()
        view.lifeDataModel = lifeDataModel
        
        // Set up gesture recognizer
        let tapper = UITapGestureRecognizer(target: self, action: #selector(ViewController.gestureRecognized(_:)))
        view.addGestureRecognizer(tapper)
        let panner = UIPanGestureRecognizer(target: self, action: #selector(ViewController.gestureRecognized(_:)))
        view.addGestureRecognizer(panner)
        
        //minor initialization 
        mySpeedVal.text = String(format: "%.1f", mySlider.value)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Reset the model, which will prompt a view update too
        updateUI()
    }
    
    // Function to call with every tick of the timer
    func countUp() {
        lifeDataModel.moveToNextGeneration()
    }
    
    // Capture both Pan and Tap gestures here
    
    // Challenge here is to translate a raw point value (say, for
    // the x component, from 0 to myCustomView.bounds.width) into a
    // logical grid value, in order to correctly mutate the model.
    // For now we'll just use debugging prints to demonstrate the API.
    func gestureRecognized(gest: UIGestureRecognizer) {
        var p: CellPoint    // Current tapped cell
        // REF: http://stackoverflow.com/questions/25354882/static-function-variables-in-swift
        struct CurrentBrush {   // This shit is borderline ViewModel/Datamodel; I said fuck-it and created a static variable instead
            static var brush = CellState.Alive
        }
        //static var currentBrush: CellState
        let rawPoint = gest.locationInView(myCustomView)
        guard let customView = myCustomView as? CustomView else {
            print("customView not instantiated properly")
            return
        }
        
        // Disallow cell editing while simulation is running
        if mySwitch.on {
            return
        }
        switch gest.state {
        case .Began:
            print("Pan began at \(rawPoint)")
            p.col = Int(Double(rawPoint.x)/customView.cellWidth)
            p.row = Int(Double(rawPoint.y)/customView.cellHeight)
            CurrentBrush.brush = lifeDataModel.cellStateAt(p).inverse
            print("changed brush to \(CurrentBrush.brush)")
            lifeDataModel.setCellAt(p, toState: CurrentBrush.brush)// keep mutations inside class
        case .Changed:
            print("Pan moved to \(rawPoint)")
            p.col = Int(Double(rawPoint.x)/customView.cellWidth)
            p.row = Int(Double(rawPoint.y)/customView.cellHeight)
            lifeDataModel.setCellAt(p, toState: CurrentBrush.brush)// keep mutations inside class
        case .Ended:
            if let _ = gest as? UITapGestureRecognizer {
                // Tap *only* generates a .Ended event
                print("Tapped at \(rawPoint), number of touches: \(gest.numberOfTouches())")
                p.col = Int(Double(rawPoint.x)/customView.cellWidth)
                p.row = Int(Double(rawPoint.y)/customView.cellHeight)
                CurrentBrush.brush = lifeDataModel.cellStateAt(p).inverse
                print("changed brush to \(CurrentBrush.brush)")
                lifeDataModel.setCellAt(p, toState: CurrentBrush.brush)// keep mutations inside class
            }
            else {
                print("Pan ended at \(rawPoint)")
                p.col = Int(Double(rawPoint.x)/customView.cellWidth)
                p.row = Int(Double(rawPoint.y)/customView.cellHeight)
                lifeDataModel.setCellAt(p, toState: CurrentBrush.brush)// keep mutations inside class
            }
            
        case .Cancelled: return
        case .Failed: return
        case .Possible: return
        }
    }

    
    func updateUI() {
        // Generation text label
        myGenerationLabel.text = String(lifeDataModel.generation)
        // Grid slider text label
        myGridSizeVal.text = String(lifeDataModel.size)
        // Redraw grid
        myCustomView.setNeedsDisplay()
        
    }
    
    /****** MODEL DELEGATE PROTOCOL METHODS ******/
    func modelDataChanged() {
        guard let _ = view.window else {
            print ("modelDataChanged: Not visible")
            return
        }
        
        updateUI()
    }


}

