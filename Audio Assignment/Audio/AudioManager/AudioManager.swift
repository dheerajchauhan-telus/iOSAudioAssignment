//
//  AudioManager.swift
//  Audio Assignment
//
//  Created by Dheeraj Chouhan on 30/01/25.
//

import AVFoundation
import Foundation

struct Recording: Identifiable {
    let id = UUID()
    let url: URL
    let createdAt: Date
}

/// Manages audio recording, playback, and noise reduction.
class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Properties
    var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    private let noiseThreshold: Float = -10.0
    
    @Published var isRecording = false
    @Published var currentPlayingURL: URL?
    @Published var noiseLevel: Float = 0.0
    @Published var showNoiseAlert = false
    @Published var recordings: [Recording] = []
    @Published var audioAmplitudes: [Float] = []  // Holds the audio amplitude values for visualizer
    
    // MARK: - Public Methods
    
    /// Toggles recording state (Start/Stop).
    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }
    
    /// Toggles playback for a given recording.
    func togglePlayback(for recording: Recording) {
        isPlaying(recording: recording) ? stopPlayback() : playRecording(at: recording.url)
    }
    
    /// Checks if a recording is currently playing.
    func isPlaying(recording: Recording) -> Bool {
        return currentPlayingURL == recording.url
    }
    
    /// Deletes selected recordings from the list.
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
    
    // MARK: - Private Methods
    
    /// Starts audio recording.
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
    
    /// Stops audio recording.
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        if let url = audioRecorder?.url {
            let _ = Recording(url: url, createdAt: Date())
        }
    }
    
    /// Plays an audio recording.
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
    
    /// Stops audio playback.
     func stopPlayback() {
        audioPlayer?.stop()
        currentPlayingURL = nil
    }
    
    /// Generates a unique file URL for audio recordings.
    func generateAudioFileURL() -> URL {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
    }
    
    /// Configures the audio session for recording and playback.
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
    }
    
    private func configureAudioSessionPlay() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
    }
    
    /// Returns the audio recording settings.
    private func getAudioSettings() -> [String: Any] {
        return [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    /// Monitors noise level during recording.
    private func startNoiseMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioRecorder?.updateMeters()
            self.noiseLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0.0
            self.showNoiseAlert = self.noiseLevel > self.noiseThreshold
            
            // Store the current amplitude for the visualizer
            let amplitude = self.noiseLevel
            self.audioAmplitudes.append(amplitude)
            
            // Limit the array size to 100 for performance
            if self.audioAmplitudes.count > 100 {
                self.audioAmplitudes.removeFirst()
            }
        }
    }
    
    /// Applies basic noise reduction to an audio file.
    func applyRefinedNoiseReductionEffect(to url: URL) {
        do {
            let audioEngine = AVAudioEngine()
            let audioFile = try AVAudioFile(forReading: url)
            
            // Nodes for processing
            let audioPlayerNode = AVAudioPlayerNode()
            let eqNode = AVAudioUnitEQ(numberOfBands: 2) // Applying High-Pass and Low-Pass filters
            
            // High-pass filter (remove low-frequency noise)
            let highPassBand = eqNode.bands[0]
            highPassBand.filterType = .highPass
            highPassBand.frequency = 300  // Remove low frequencies below 300Hz
            highPassBand.gain = -12  // Attenuate low frequencies
            
            // Low-pass filter (remove high-frequency noise)
            let lowPassBand = eqNode.bands[1]
            lowPassBand.filterType = .lowPass
            lowPassBand.frequency = 5000  // Remove frequencies above 5000Hz
            lowPassBand.gain = -12  // Attenuate high frequencies
            
            // Attach and connect nodes in the audio engine
            audioEngine.attach(audioPlayerNode)
            audioEngine.attach(eqNode)
            
            // Connect audioPlayerNode -> eqNode -> outputNode
            audioEngine.connect(audioPlayerNode, to: eqNode, format: audioFile.processingFormat)
            audioEngine.connect(eqNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
            
            try audioEngine.start()
            
            // Process the audio file into a buffer
            let outputURL = url.deletingLastPathComponent().appendingPathComponent("refined_processed_\(url.lastPathComponent)")
            let outputFile = try AVAudioFile(forWriting: outputURL, settings: audioFile.fileFormat.settings)
            
            let outputBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            try audioFile.read(into: outputBuffer!)
            
            // Write the processed audio into a new file
            try outputFile.write(from: outputBuffer!)
            
            print("Processed audio saved at \(outputURL)")
            
            // Create a new Recording with the processed audio and append it to the recordings array
            let newRecording = Recording(url: outputURL, createdAt: Date())
            recordings.append(newRecording)
        } catch {
            print("Failed to apply noise reduction: \(error.localizedDescription)")
        }
    }



}

// MARK: - AVAudioRecorder & AVAudioPlayer Delegate
extension AudioManager: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            applyRefinedNoiseReductionEffect(to: recorder.url)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentPlayingURL = nil
    }
}
