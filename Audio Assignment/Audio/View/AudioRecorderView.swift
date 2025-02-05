//
//  AudioRecorderView.swift
//  Audio Assignment
//
//  Created by Dheeraj Chouhan on 30/01/25.
//

import SwiftUI

struct AudioRecorderView: View {
    @StateObject private var viewModel = AudioManager()
    
    var body: some View {
        VStack(spacing: 20) {
            NoiseLevelView(noiseLevel: viewModel.noiseLevel, showAlert: viewModel.showNoiseAlert)
            RecordingButton(isRecording: viewModel.isRecording, action: viewModel.toggleRecording)
            RecordingListView(viewModel: viewModel)
            // Audio visualizer
            AudioVisualizerView(viewModel: viewModel)
                .padding(.top)
        }
        .padding()
    }
}

struct NoiseLevelView: View {
    let noiseLevel: Float
    let showAlert: Bool
    
    var body: some View {
        Text("Noise Level: \(Int(noiseLevel)) dB")
            .font(.headline)
            .foregroundColor(showAlert ? .red : .primary)
    }
}

struct RecordingButton: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isRecording ? "Stop Recording" : "Start Recording")
                .padding()
                .frame(maxWidth: .infinity)
                .background(isRecording ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct RecordingListView: View {
    @ObservedObject var viewModel: AudioManager
    
    var body: some View {
        List {
            ForEach(viewModel.recordings) { recording in
                HStack {
                    Text("Recording at \(recording.createdAt.formatted())")
                    Spacer()
                    Button(action: { viewModel.togglePlayback(for: recording) }) {
                        Image(systemName: viewModel.isPlaying(recording: recording) ? "stop.circle" : "play.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onDelete(perform: viewModel.deleteRecording)
        }
    }
}


#Preview {
    AudioRecorderView()
}
