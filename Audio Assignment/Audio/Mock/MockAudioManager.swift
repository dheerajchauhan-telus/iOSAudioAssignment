//
//  MockAudioManager.swift
//  Audio Assignment
//
//  Created by Dheeraj Chouhan on 03/02/25.
//

import Foundation

class MockAudioManager: AudioManager {

    // Simulating the noise level (read-write)
    private var _noiseLevel: Float = 50.0
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
    
    // Simulating the toggle recording action
    override func toggleRecording() {
        isRecording.toggle()
    }
    
    // Simulating the playback toggle
    override func togglePlayback(for recording: Recording) {
        // Mock the playback toggle logic
    }
    
    // Simulating the delete recording action
    override func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            _recordings.remove(at: index)
        }
    }
    
    // Manual noise alert simulation for testing
    func simulateNoiseAlert() {
        _showNoiseAlert = _noiseLevel > 75.0
    }
}
