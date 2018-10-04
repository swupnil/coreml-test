//
//  InterfaceController.swift
//  CoreMLTest WatchKit Extension
//
//  Created by Swupnil Sahai on 10/4/18.
//  Copyright © 2018 Swupnil Sahai. All rights reserved.
//

import WatchKit

class InterfaceController: WKInterfaceController, PredictionManagerDelegate {
    
    // MARK: UI Elements
    
    @IBOutlet var sampleLabel: WKInterfaceLabel!
    @IBOutlet var predictionLabel: WKInterfaceLabel!
    
    // MARK: Initialization
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if #available(watchOS 4.2, *) {
            PredictionManager.shared.delegate = self
            PredictionManager.shared.reset()
        }
    }
    
    // MARK: Prediction Manager Delegate
    
    func didUpdate(startIndex: Int, endIndex: Int, prediction: String, probabilities: String) {
        DispatchQueue.main.async {
            self.sampleLabel.setText("Sample \(startIndex)-\(endIndex)")
            self.predictionLabel.setText("Activity Predicted: \(prediction)\n\nProbs = \(probabilities)")
        }
    }
    
    // MARK: Button Handling
    
    @IBAction func didReset() {
        if #available(watchOS 4.2, *) {
            PredictionManager.shared.reset()
        }
    }
    
    @IBAction func didTapNext() {
        if #available(watchOS 4.2, *) {
            PredictionManager.shared.analyzeNextSample()
        }
    }
    
    
}
