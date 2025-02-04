# Audio Mobile Dev Assignment
Records audio. The app have built-in noise detection for audio recording, alerting
the user if noise levels exceed a certain threshold. After recording, the app
reduces noise in the audio file. Users are able to play back and test the recorded
media and delete the media.

# Features
 **Media Recording:**
    - **Audio Recording:**
    class AudioManager
        private func startRecording() { }
        private func stopRecording() { }
        private func playRecording(at url: URL) { }
        private func stopPlayback() { }
        func deleteRecording(at offsets: IndexSet) { }
        func applyNoiseReductionEffect(to url: URL) { }
        
 **Playback::**
1. Make sure you have the Xcode version 14.0 or above installed on your computer.
2. Download the iOSAudioAssignment project files from the repository.
3. Open the project files in Xcode.
4. Review the code and make sure you understand what it does.
5. Run the active scheme.
You should see the UI with a button "Start recording" to the screen. Once you click on start recording you can record your audio that you want to record and then again press stop button, once stop is pressed below you will be able to fine a recorded audio which will have play button, pelase tap on play button to play the recorded audio you also can pause the played audio by tap on pause icon.
    To delete any exisisting recording jus left swipe the recorded audio you will be able to see delete button tap on that you can see the selected recorded audio will get deleted from the list.

        
 **Running the tests:**
The Audio project can be tested using the built-in framework XCTest.
To start testing the project, you will need to change the target in your Xcode project to Audio AssignmentTests, and then run the test cases.
These test files are placed in the "Audio AssignmentTest" folder, following the project structure with file name AudioManagerTest and MockAudioManagerTests. 
