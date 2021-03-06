//
//  ViewController.swift
//  Siri
//
//  Created by Sahand Edrisian on 7/14/16.
//  Copyright © 2016 Sahand Edrisian. All rights reserved.
//

import UIKit
import Speech
import AVKit

class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet var speakerAnim: SpeakerAnimView!

    let speechSynthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "hu-HU"))!

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var player: AVAudioPlayer!
    var isSent: Bool = false
    var isGame: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        microphoneButton.isEnabled = false
        speechRecognizer.delegate = self
        speechSynthesizer.delegate = self
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)

        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false

            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }

            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }


    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            speakerAnim.stopAnimation()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            self.isSent = true
            let audioSession = AVAudioSession.sharedInstance()  //2
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setActive(false)
                
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            if self.questionTextView.text != "" || self.questionTextView.text != nil  {
                
                if self.questionTextView.text == "Justin játszanék valamit" || self.questionTextView.text == "Játszanék" {
                    self.isGame = true
                    self.answerTextView.text = "Flappy BigFish elindítva."
                    self.speak()
                    return
                }
                
                NetworkManager.sharedInstance.postText(speechText: self.questionTextView.text, success: { (answer) in
                    self.answerTextView.text = answer
                    self.speak()
                }) { (error) in
                    self.answerTextView.text = "Valami hiba történt."
                    self.speak()
                }
            } else {
                self.answerTextView.text = "Bocsi nem értettem mit mondtál?"
                self.speak()
            }
            
        } else {
            startRecording()
            speakerAnim.startAnimation()
            print(speechSynthesizer.isSpeaking)
        }
    }

    func playSound() {
        let url = Bundle.main.url(forResource: "ClickSound", withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }

    func startRecording() {

        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5

        recognitionRequest.shouldReportPartialResults = true  //6
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7

            var isFinal = false  //8
            if result != nil {
                if self.isSent {
                    self.isSent = false
                    //self.questionTextView.text = result?.bestTranscription.formattedString  //9
                    isFinal = (result?.isFinal)!
                } else {
                    self.questionTextView.text = result?.bestTranscription.formattedString  //9
                    isFinal = (result?.isFinal)!
                }
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.microphoneButton.isEnabled = true
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()  //12

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

        questionTextView.text = "Hallgatlak! ;)"
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }

    func speak() {
        self.microphoneButton.isUserInteractionEnabled = false
        if !speechSynthesizer.isSpeaking {
            /**
             let speechUtterance = AVSpeechUtterance(string: tvEditor.text)
             speechUtterance.rate = rate
             speechUtterance.pitchMultiplier = pitch
             speechUtterance.volume = volume
             speechSynthesizer.speakUtterance(speechUtterance)
             */
            let rate = AVSpeechUtteranceDefaultSpeechRate
            let pitch: Float = 1.0
            let volume: Float = 1.0
            let textParagraphs = answerTextView.text.components(separatedBy: "\n")

            let totalUtterances = textParagraphs.count
            let currentUtterance = 0
            var totalTextLength = 0
            let spokenTextLengths = 0

            for pieceOfText in textParagraphs {
                let speechUtterance = AVSpeechUtterance(string: pieceOfText)
                speechUtterance.rate = rate
                speechUtterance.pitchMultiplier = pitch
                speechUtterance.volume = volume
                speechUtterance.postUtteranceDelay = 0.005
                
                let voice = AVSpeechSynthesisVoice(language: "hu-HU")
                speechUtterance.voice = voice
                
                totalTextLength = totalTextLength + pieceOfText.utf16.count
                speechSynthesizer.speak(speechUtterance)
            }
        } else {
            speechSynthesizer.continueSpeaking()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finish Speech")
        self.microphoneButton.isUserInteractionEnabled = true
        if isGame {
            self.isGame = false
            performSegue(withIdentifier: "pushGame", sender: nil)
        }
        performSegue(withIdentifier: "pushGame", sender: nil)

    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("Pause Speech")
    }

    func pauseSpeech() {
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
    }

    func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
}
