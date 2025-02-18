//
//  MockAudioManager.swift
//  Audio Assignment
//
//  Created by Dheeraj Chouhan on 03/02/25.
//

import Foundation

class MockAudioManager: AudioManager {
    
    // Simulating the noise level (read-write)
    private var _noiseLevel: Float = -50.0
    override var noiseLevel: Float {
        get { _noiseLevel }
        set { _noiseLevel = newValue }
    }
    
    // Simulating recording state (read-write)
    private var _isRecording: Bool = false
    override var isRecording: Bool {
        get { _isRecording }
        set { _isRecording = newValue }
    }
    
    // Simulating noise alert (read-write) - Manual State Change for Mock
    private var _showNoiseAlert: Bool = false
    override var showNoiseAlert: Bool {
        get {
            return _showNoiseAlert
        }
        set {
            _showNoiseAlert = newValue
        }
    }
    
    // Simulating the recordings (read-write)
    private var _recordings: [Recording] = []
    override var recordings: [Recording] {
        get { _recordings }
        set { _recordings = newValue }
    }
    
    var appliedNoiseReductionEffectURL: URL?
    override func applyRefinedNoiseReductionEffect(to url: URL) {
          // Simulate the effect application without real processing
          let processedURL = url.deletingLastPathComponent().appendingPathComponent("refined_processed_\(url.lastPathComponent)")
          appliedNoiseReductionEffectURL = processedURL
          
          // Simulate the "processing" of the audio file by just touching the file
          FileManager.default.createFile(atPath: processedURL.path, contents: nil, attributes: nil)
      }
    
    override func startRecording() {
        super.startRecording()
        // You can simulate setting the noise level manually here
        self.noiseLevel = -50.0 // Dummy noise level for testing
    }
    
    // Optionally, simulate noise level updates
    func simulateNoiseLevelUpdate(_ level: Float) {
        self.noiseLevel = level
    }
    
    // Simulating the toggle recording action
    override func toggleRecording() {
        isRecording.toggle()
    }
    
    // Manual noise alert simulation for testing
    func simulateNoiseAlert() {
        _showNoiseAlert = _noiseLevel > 75.0
    }
}
