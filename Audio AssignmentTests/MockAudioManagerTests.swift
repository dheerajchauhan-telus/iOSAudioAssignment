//
//  MockAudioManagerTests.swift
//  Audio AssignmentTests
//
//  Created by Dheeraj Chouhan on 03/02/25.
//

import XCTest
@testable import Audio_Assignment

class MockAudioManagerTests: XCTestCase {

    func testNoiseAlert_WhenNoiseLevelIsHigh_ShowsAlert() {
        let viewModel = MockAudioManager()
        viewModel.noiseLevel = 80.0
        viewModel.simulateNoiseAlert()  // Manually trigger the alert check
        
        XCTAssertTrue(viewModel.showNoiseAlert)  // Expecting the alert to show when noise level exceeds 75.0
    }

    func testNoiseAlert_WhenNoiseLevelIsLow_HidesAlert() {
        let viewModel = MockAudioManager()
        viewModel.noiseLevel = 50.0
        viewModel.simulateNoiseAlert()  // Manually trigger the alert check
        
        XCTAssertFalse(viewModel.showNoiseAlert)  // Expecting the alert to hide when noise level is below 75.0
    }

    func testRecordingButton_WhenToggled_ChangesRecordingState() {
        let viewModel = MockAudioManager()
        
        // Initially, the viewModel should not be recording
        XCTAssertFalse(viewModel.isRecording)
        
        // Toggle recording to start
        viewModel.toggleRecording()
        XCTAssertTrue(viewModel.isRecording)  // Now it should be recording
        
        // Toggle again to stop recording
        viewModel.toggleRecording()
        XCTAssertFalse(viewModel.isRecording)  // It should stop recording
    }

    func testRecordingList_WhenRecordingsAdded_ReflectsInList() {
        let viewModel = MockAudioManager()
        
        let recording = Recording(url: URL(fileURLWithPath: "test.m4a"), createdAt: Date())
        viewModel.recordings.append(recording)
        
        XCTAssertEqual(viewModel.recordings.count, 1)  // The list should have 1 recording
    }
}

