//
//  AudioVisualizerView.swift
//  Audio Assignment
//
//  Created by Dheeraj Chouhan on 05/02/25.
//

import SwiftUI

struct AudioVisualizerView: View {
    @ObservedObject var viewModel: AudioManager
    
    // Function to determine the color based on the amplitude
    private func getColor(for amplitude: Float) -> Color {
        switch amplitude {
        case let value where value > -5.0:  // High audio
            return Color.red.opacity(0.8)  // Crimson Red for high audio
        case let value where value > -15.0: // Medium audio
            return Color.yellow.opacity(0.8)  // Amber for medium audio
        default: // Low audio
            return Color.green.opacity(0.8)  // Light Green for low audio
        }
    }
    
    var body: some View {
        VStack {
            Text("Audio Visualizer")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            // Display the visualizer with a gradient background
            GeometryReader { geometry in
                ZStack {
                    // Gradient background for the visualizer
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // Audio bars
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(viewModel.audioAmplitudes, id: \.self) { amplitude in
                            // Normalize amplitude to fit within the height of the container
                            let height = max(CGFloat(abs(amplitude)) * geometry.size.height / 100.0, 1)
                            
                            // Draw bars with a rounded corner
                            Rectangle()
                                .fill(getColor(for: amplitude)) // Set color based on amplitude
                                .frame(width: 4, height: height) // Slightly wider bars
                                .cornerRadius(2)  // Rounded corners for each bar
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
        .padding()
    }
}
