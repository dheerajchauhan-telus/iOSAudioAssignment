#Audio Mobile Dev Assignment
The app records audio with built-in noise detection, alerting the user if noise levels exceed a certain threshold. After recording, the app reduces noise in the audio file. Users can play back, test, and delete recorded media.

 **Architecture**
The app follows the MVVM (Model-View-ViewModel) architecture:

*Model*:
Recording: Represents an audio recording with properties like url and createdAt.
AudioManager: Handles audio recording, playback, noise reduction, and noise level monitoring.

*View*:
AudioRecorderView: The main SwiftUI view that displays the UI components.

*Subviews*:
NoiseLevelView: Displays the current noise level.
RecordingButton: A button to start/stop recording.
RecordingListView: Displays a list of recordings with playback and delete options.
AudioVisualizerView: Visualizes audio amplitudes during recording.

*ViewModel*:
AudioManager: Acts as the ViewModel, managing the state and logic for audio recording, playback, and noise reduction.


#Features
1. Media Recording
Start Recording:
User Action: Tap the "Start Recording" button.
Method: startRecording() in AudioManager.
Code Snippet:
func startRecording() {
    do {
        try configureAudioSession()
        let audioFilename = generateAudioFileURL()
        let settings = getAudioSettings()
        
        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        isRecording = true
        
        startNoiseMonitoring()
    } catch {
        print("Failed to start recording: \(error.localizedDescription)")
    }
}

Stop Recording:
User Action: Tap the "Stop Recording" button.
Method: stopRecording() in AudioManager.

Code Snippet:
func stopRecording() {
    audioRecorder?.stop()
    isRecording = false
    timer?.invalidate()
    timer = nil
    
    if let url = audioRecorder?.url {
        let _ = Recording(url: url, createdAt: Date())
    }
}

2. Noise Detection
Noise Level Monitoring:
Method: startNoiseMonitoring() in AudioManager.
Code Snippet:
private func startNoiseMonitoring() {
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        self.audioRecorder?.updateMeters()
        self.noiseLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0.0
        self.showNoiseAlert = self.noiseLevel > self.noiseThreshold
    }
}

Noise Alert:
User Action: The app automatically shows an alert if the noise level exceeds the threshold.
Method: showNoiseAlert is updated in startNoiseMonitoring().

3. Noise Reduction
Apply Noise Reduction:
Method: applyRefinedNoiseReductionEffect(to url: URL) in AudioManager.

Code Snippet:
func applyRefinedNoiseReductionEffect(to url: URL) {
    do {
        let audioEngine = AVAudioEngine()
        let audioFile = try AVAudioFile(forReading: url)
        
        // Nodes for processing
        let audioPlayerNode = AVAudioPlayerNode()
        let eqNode = AVAudioUnitEQ(numberOfBands: 2)
        
        // High-pass filter
        let highPassBand = eqNode.bands[0]
        highPassBand.filterType = .highPass
        highPassBand.frequency = 300
        highPassBand.gain = -12
        
        // Low-pass filter
        let lowPassBand = eqNode.bands[1]
        lowPassBand.filterType = .lowPass
        lowPassBand.frequency = 5000
        lowPassBand.gain = -12
        
        // Attach and connect nodes
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(eqNode)
        audioEngine.connect(audioPlayerNode, to: eqNode, format: audioFile.processingFormat)
        audioEngine.connect(eqNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        try audioEngine.start()
        
        // Process the audio file
        let outputURL = url.deletingLastPathComponent().appendingPathComponent("refined_processed_\(url.lastPathComponent)")
        let outputFile = try AVAudioFile(forWriting: outputURL, settings: audioFile.fileFormat.settings)
        
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        try audioFile.read(into: outputBuffer!)
        try outputFile.write(from: outputBuffer!)
        
        print("Processed audio saved at \(outputURL)")
    } catch {
        print("Failed to apply noise reduction: \(error.localizedDescription)")
    }
}

4. Playback
Play Recording:
User Action: Tap the "Play" button next to a recording in the list.
Method: playRecording(at url: URL) in AudioManager.
Code Snippet:
func playRecording(at url: URL) {
    do {
        try configureAudioSessionPlay()
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()
        currentPlayingURL = url
    } catch {
        print("Failed to play recording: \(error.localizedDescription)")
    }
}

Stop Playback:
User Action: Tap the "Stop" button during playback.
Method: stopPlayback() in AudioManager.
Code Snippet:
func stopPlayback() {
    audioPlayer?.stop()
    currentPlayingURL = nil
}

5. Delete Recordings
Delete Recording:
User Action: Swipe left on a recording in the list and tap "Delete".
Method: deleteRecording(at offsets: IndexSet) in AudioManager.

Code Snippet:
func deleteRecording(at offsets: IndexSet) {
    for index in offsets {
        let recording = recordings[index]
        do {
            try FileManager.default.removeItem(at: recording.url)
            recordings.remove(at: index)
        } catch {
            print("Failed to delete recording: \(error.localizedDescription)")
        }
    }
}

#Running the App
Ensure you have Xcode 14.0 or above installed.
Clone the repository and open the project in Xcode.
Run the app on a simulator or physical device.
Use the "Start Recording" button to record audio.
Play, delete, or apply noise reduction to recordings.

#Running the Tests
The app includes unit tests using the XCTest framework. To run the tests:
Change the target in Xcode to Audio AssignmentTests.
Run the test cases in the AudioManagerTests and MockAudioManagerTests files.


#Dependencies
AVFoundation: For audio recording, playback, and noise reduction.
SwiftUI: For building the user interface.
