//
//  PredictionManager.swift
//  CoreMLTest WatchKit Extension
//
//  Created by Swupnil Sahai on 10/4/18.
//  Copyright © 2018 Swupnil Sahai. All rights reserved.
//

import CoreML

protocol PredictionManagerDelegate {
    func didUpdate(startIndex: Int, endIndex: Int,
                   prediction: String, probabilities: String)
}

@available(watchOSApplicationExtension 4.2, *)
class PredictionManager {
    
    /// The shared manager for the system.
    public static let shared = PredictionManager()
    public var delegate: PredictionManagerDelegate?
    
    /// Prediction Data
    private let classifier = ActivityClassifier()
    private let predictionDataArray: MLMultiArray?
    private var lastHiddenOutput: MLMultiArray? = nil
    private var lastHiddenCellOutput: MLMultiArray? = nil
    
    /// For keeping track of raw data and window state.
    private var csvData = [[String]]()
    private var windowStartIndex = 1
    
    /// Constants
    private let fileName = "sample_data"
    
    // MARK: Initialization
    
    /// Initializes the data from disk.
    init() {
        predictionDataArray = try? MLMultiArray(shape: [1 , ClassifierConstants.predictionWindowSize , ClassifierConstants.numOfFeatures] as [NSNumber], dataType: .double)
        
        if let data = readDataFromFile(file: fileName) {
            csvData = csv(data: data)
        }
    }
    
    // MARK: Data Reading
    
    /// Reads the csv file from disk.
    private func readDataFromFile(file:String) -> String? {
        guard let filePath = Bundle.main.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filePath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filePath)")
            return nil
        }
    }
    
    /// Cleans the new lines from the csv file.
    private func cleanRows(file:String) -> String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    /// Converts the csv string into an array of strings (per column).
    private func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for (i, row) in rows.enumerated() {
            /// Ignore column names in the header row.
            if i > 0 {
                let columns = row.components(separatedBy: ";")
                if !columns.isEmpty {
                    result.append(columns)
                }
            }
        }
        return result
    }
    
    // MARK: Data Updating
    
    /// Sets the specified data point at the specified index of the data array.
    private func setFeature(value: Double, at row: Int, in column: Int) {
        guard let dataArray = predictionDataArray else { return }
        
        let rowInWindow = row % ClassifierConstants.predictionWindowSize - 1
        dataArray[[0, rowInWindow, column] as [NSNumber]] = value as NSNumber
    }
    
    // MARK: Analysis
    
    /// Analyzes the current window of data.
    func analyzeSample() {
        
        let windowEndIndex = windowStartIndex + ClassifierConstants.predictionWindowSize - 1
        
        /// Set the input features for the current window.
        for i in windowStartIndex...windowEndIndex {
            let data = csvData[i][0].split(separator: ",")
            for j in 0..<ClassifierConstants.numOfFeatures {
                if j < data.count {
                    setFeature(value: Double(data[j])!, at: i, in: j)
                }
                else {
                    reset()
                    return
                }
            }
        }
        
        /// Get the prediction from the CoreML model.
        guard let dataArray = predictionDataArray else { return }
        let modelPrediction = try? classifier.prediction(features: dataArray, hiddenIn: lastHiddenOutput, cellIn: lastHiddenCellOutput)
        lastHiddenOutput = modelPrediction?.hiddenOut
        lastHiddenCellOutput = modelPrediction?.cellOut
        
        guard let predictionLabel = modelPrediction?.Label,
            let labelProbs = modelPrediction?.LabelProbability else { return }
        
        /// Display the prediction probabilities and argmax (final prediction) in the interface controller.
        var probabilities = "{\n"
        for classType in ClassifierConstants.classTypes {
            if let prob = labelProbs[classType] {
                probabilities += "\(classType): \(prob),\n"
            }
        }
        probabilities += "}"
        
        delegate?.didUpdate(startIndex: windowStartIndex, endIndex: windowEndIndex,
                            prediction: predictionLabel, probabilities: probabilities)
    }
    
    /// Resets back to analyzing the first window of data.
    func reset() {
        windowStartIndex = 1
        lastHiddenOutput = nil
        lastHiddenCellOutput = nil
        analyzeSample()
    }
    
    /// Analyzes the next window of data.
    func analyzeNextSample() {
        windowStartIndex += ClassifierConstants.predictionWindowSize
        
        if windowStartIndex >= csvData.count {
            reset()
            return
        }
        
        analyzeSample()
    }
    
}
