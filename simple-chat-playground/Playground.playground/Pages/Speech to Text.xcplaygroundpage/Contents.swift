/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import PlaygroundSupport
import SpeechToTextV1

// Configure playground environment
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// Instantiate service
let speechToText = SpeechToText(
    username: Credentials.SpeechToTextUsername,
    password: Credentials.SpeechToTextPassword
)

// Load audio recording
let recordingPath = Bundle.main.path(forResource: "TurnRadioOn", ofType: "wav")!
let recording = URL(fileURLWithPath: recordingPath)

// Transcribe audio recording
let settings = RecognitionSettings(contentType: .wav)
speechToText.recognize(audio: recording, settings: settings) { text in
    print(text.bestTranscript)
}
