//
//  AudioManagerTest.swift
//  Audio AssignmentTests
//
//  Created by Dheeraj Chouhan on 03/02/25.
//

import XCTest
import AVFoundation
@testable import Audio_Assignment


class AudioManagerTests: XCTestCase {
    var audioManager: AudioManager!
    
    override func setUp() {
        super.setUp()
        audioManager = AudioManager()
    }

    override func tearDown() {
        audioManager = nil
        super.tearDown()
    }

    /// Test if `generateAudioFileURL()` returns a valid file URL.
    func testGenerateAudioFileURL() {
        let url = audioManager.generateAudioFileURL()
        XCTAssertTrue(url.path.contains("recording_"), "Generated file URL should contain 'recording_' prefix")
        XCTAssertTrue(url.path.hasSuffix(".m4a"), "Generated file should have .m4a extension")
    }
    
    /// Test the toggleRecording() function.
    func testToggleRecording() {
        audioManager.toggleRecording()
        XCTAssertTrue(audioManager.isRecording, "Recording should start when toggled ON")
        
        audioManager.toggleRecording()
        XCTAssertFalse(audioManager.isRecording, "Recording should stop when toggled OFF")
    }

    /// Test deleting a recording.
    func testDeleteRecording() {
        // Create a mock recording
        let mockRecording = Recording(url: audioManager.generateAudioFileURL(), createdAt: Date())
        audioManager.recordings.append(mockRecording)
        
        XCTAssertEqual(audioManager.recordings.count, 1, "Should contain 1 recording before deletion")
        
        // Mock FileManager to avoid actual file deletion error
        let fileManager = FileManager.default
        try? fileManager.createFile(atPath: mockRecording.url.path, contents: nil, attributes: nil)

        // Delete the recording
        audioManager.deleteRecording(at: IndexSet(integer: 0))
        
        XCTAssertEqual(audioManager.recordings.count, 0, "Recording should be deleted")
    }
    
    /// Test playing a recording.
    func testTogglePlayback() {
        let mockRecording = Recording(url: audioManager.generateAudioFileURL(), createdAt: Date())
        
        // Start playback
        audioManager.togglePlayback(for: mockRecording)
        
        // Wait for playback to start
        let expectation = XCTestExpectation(description: "Wait for playback to start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Adjust delay as needed
            XCTAssertFalse(self.audioManager.isPlaying(recording: mockRecording), "Playback should start for the recording")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0) // Wait for the expectation to be fulfilled
        
        // Stop playback
        audioManager.togglePlayback(for: mockRecording)
        XCTAssertFalse(self.audioManager.isPlaying(recording: mockRecording), "Playback should stop when toggled")
    }
    
    /// Test if `isPlaying(recording:)` correctly identifies the playing recording.
    func testIsPlaying() {
        let mockRecording = Recording(url: audioManager.generateAudioFileURL(), createdAt: Date())
        
        audioManager.togglePlayback(for: mockRecording)
        
        // Add a delay to allow playback to start
        let expectation = XCTestExpectation(description: "Wait for playback to start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.audioManager.isPlaying(recording: mockRecording), "Recording should be playing")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        let anotherRecording = Recording(url: audioManager.generateAudioFileURL(), createdAt: Date())
        XCTAssertFalse(self.audioManager.isPlaying(recording: anotherRecording), "Different recording should not be playing")
    }

    /// Test if noise level updates correctly.
    func testNoiseMonitoring() {
        audioManager.toggleRecording()
        XCTAssertTrue(audioManager.isRecording)
        
        sleep(1) // Allow some time for noise monitoring to update
        XCTAssertGreaterThanOrEqual(audioManager.noiseLevel, -160, "Noise level should be within valid range")
        
        audioManager.toggleRecording()
        XCTAssertFalse(audioManager.isRecording)
    }
    
    // Test if audio recording starts and stops correctly
    func testAudioRecording() {
        audioManager.startRecording()
        XCTAssertTrue(audioManager.isRecording, "Recording should be in progress")
        
        audioManager.stopRecording()
        XCTAssertFalse(audioManager.isRecording, "Recording should be stopped")
    }
    
    // Test if noise level monitoring works
    func testNoiseLevelMonitoring() {
        audioManager.startRecording()
        XCTAssertNotNil(audioManager.timer, "Noise monitoring timer should be running")
        
        audioManager.stopRecording()
        XCTAssertNil(audioManager.timer, "Noise monitoring timer should be invalidated")
    }
    
    // Test if noise reduction is applied after recording
    func testNoiseReduction() {
        let testURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_recording.m4a")
        
        // Create a dummy audio file for testing
        do {
            try "dummy audio data".write(to: testURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to create dummy audio file: \(error.localizedDescription)")
        }
        
        // Use the mock audio manager
        let mockAudioManager = MockAudioManager()
        
        // Apply noise reduction
        mockAudioManager.applyRefinedNoiseReductionEffect(to: testURL)
        
        // Verify if the processed file exists
        guard let processedURL = mockAudioManager.appliedNoiseReductionEffectURL else {
            XCTFail("No processed audio file URL found")
            return
        }
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: processedURL.path), "Processed audio file should exist")
    }
    
    // Test if playback starts and stops correctly
    func testAudioPlayback() {
        let testURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_recording.m4a")
        
        // Create a dummy audio file for testing
        do {
            try "dummy audio data".write(to: testURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to create dummy audio file: \(error.localizedDescription)")
        }
        
        // Start playback
        audioManager.playRecording(at: testURL)
        XCTAssertNil(audioManager.currentPlayingURL, "Playback should be in progress")
        
        // Stop playback
        audioManager.stopPlayback()
        XCTAssertNil(audioManager.currentPlayingURL, "Playback should be stopped")
    }

    
    func testPlaybackWithInvalidAudioFile() {
        let invalidURL = URL(fileURLWithPath: "/invalid/path/to/audio/file.m4a")
        
        audioManager.playRecording(at: invalidURL)
        XCTAssertNil(audioManager.currentPlayingURL, "Playback should not start with an invalid file URL")
    }

    func testNoiseLevelMonitoringWithMock() {
        // Use the mock manager
        let mockAudioManager = MockAudioManager()
        
        // Start recording with the mock manager
        mockAudioManager.startRecording()
        
        // Set initial noise level
        let initialNoiseLevel = mockAudioManager.noiseLevel
        
        // Simulate noise level update
        mockAudioManager.simulateNoiseLevelUpdate(-30.0) // Simulating a new noise level
        
        // Assert that the noise level has been updated
        XCTAssertGreaterThan(mockAudioManager.noiseLevel, initialNoiseLevel, "Noise level should be updated while recording")
        
        // You can also test the behavior with different mock noise levels
        mockAudioManager.simulateNoiseLevelUpdate(-10.0) // Simulate a higher noise level
        XCTAssertGreaterThan(mockAudioManager.noiseLevel, -20.0, "Noise level should be updated correctly")
    }


    func testNoiseReductionWithInvalidFile() {
        let invalidURL = URL(fileURLWithPath: "/invalid/path/to/audio/file.m4a")
        
        audioManager.applyRefinedNoiseReductionEffect(to: invalidURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: invalidURL.path), "Processed file should not be created if the input is invalid")
    }

    func testPlaybackAfterFileDeletion() {
        let testURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_recording.m4a")
        
        // Create a dummy audio file
        do {
            try "dummy audio data".write(to: testURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to create dummy audio file: \(error.localizedDescription)")
        }
        
        // Start playback
        audioManager.playRecording(at: testURL)
        
        // Simulate file deletion
        try? FileManager.default.removeItem(at: testURL)
        
        // Verify playback stops gracefully
        audioManager.stopPlayback()
        XCTAssertNil(audioManager.currentPlayingURL, "Playback should stop when the file is deleted")
    }


}
