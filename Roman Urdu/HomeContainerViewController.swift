 //
//  HomeContainerViewController.swift
//  Islam 360
//
//  Created by Macbook on 05/04/2017.
//  Copyright © 2017 IslamicPortal. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class HomeContainerViewController: UIViewController, AVAudioPlayerDelegate {
    
    
    public static var instance : HomeContainerViewController? // contain value once this viewcontroller is initialized
    
    
    
    private var player:AVPlayer = AVPlayer()
    private var playingIndex = 0
    private var playingUrls : [URL] = []
    
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var playerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var backward: UIButton!
    
    
    @IBOutlet weak var repeatView: UIView!
    @IBOutlet weak var repeatImageView: UIImageView!
    @IBOutlet weak var repeatLabel: UILabel!
    
    
    
    // MARK:- ViewController Overrides

    
    override func viewDidLoad() {
        super.viewDidLoad()

        HomeContainerViewController.instance = self
        
        self.setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    
    // MARK:- User Interaction Functions
    
    @IBAction func playPauseTapped(_ sender: Any) {
    
        if self.player.rate == 0.0 {
            self.play()
        }
        else {
            self.pause()
        }
        
    }

    @IBAction func forwardTapped(_ sender: Any) {
        self.playAudio(index: self.playingIndex+1)
    }
    
    @IBAction func backwardTapped(_ sender: Any) {
        self.playAudio(index: self.playingIndex-1)
    }
    
    @IBAction func repeatTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
   
    @objc func swipeLeft(sender:Any) {
        self.showPlayerContainer()
    }
    
    @objc func swipeRight(sender:Any) {
        self.hidePlayerContainer()
    }
    

    
    
    // MARK:- Helper Functions

    private func setup() {
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(sender:)))
        swipeLeftGesture.direction = .left
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(sender:)))
        swipeRightGesture.direction = .right
        
        self.view.addGestureRecognizer(swipeLeftGesture)
        self.view.addGestureRecognizer(swipeRightGesture)
        
//        self.hidePlayerContainer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeContainerViewController.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        
    }
    
    private func playAudio(index:Int) {
        
        if self.playingUrls.count == 0 || index >= self.playingUrls.count || index < 0 {
            return
        }
        
        self.player = AVPlayer(url: self.playingUrls[index])
        self.player.play()
        
        self.playingIndex = index
        
        self.playPause.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        self.playPause.isEnabled = true
        
        self.manageForwardAndBackward()
        
    }
    
    
    func next() {
        
        self.playAudio(index: self.playingIndex+1)
    }
    
    func previous() {
        
        self.playAudio(index: self.playingIndex-1)
    }
    
    func pause() {
        
        self.player.pause()
        self.playPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    func play() {
        
        self.player.play()
        self.playPause.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    func play(playlist:[URL]) {
        
        self.playingUrls = playlist
        self.playAudio(index: 0)
        
        self.showPlayerContainer()
    }
    
    func play(url:URL) {
        
        self.playingUrls.append(url)
        self.playAudio(index: self.playingUrls.count-1)
        
        self.showPlayerContainer()
    }
    
    
    @objc func playerDidFinishPlaying(sender: NSNotification) {
        
        self.playPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        self.player.seek(to: kCMTimeZero)
        
        if self.playingIndex == self.playingUrls.count - 1 {
            self.playAudio(index: 0)
        }
        else {
            self.playAudio(index: self.playingIndex+1)
        }
        
    }

    
    private func manageForwardAndBackward() {
        
        // Forward
        if self.playingUrls.count-1 > self.playingIndex {
            self.forward.isEnabled = true
        }
        else {
            self.forward.isEnabled = false
        }
        
        // Backward 
        if self.playingIndex > 0 {
            self.backward.isEnabled = true
        }
        else {
            self.backward.isEnabled = false
        }
        
    }
    
    private func showPlayerContainer() {
        
//        self.playerContainerLeadingConstraint.constant = -(self.playerContainerView.frame.width+20)
        
        
        self.playerWidthConstraint = self.playerWidthConstraint.setMultiplier(multiplier: 1.0)
            
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            self.playerContainerView.superview?.layoutIfNeeded()
            self.playerContainerView.alpha = 1
        }) { (comp) in
            
        }
        
    }
    
    private func hidePlayerContainer() {
        
//        self.playerContainerLeadingConstraint.constant = 0
        
        self.playerWidthConstraint = self.playerWidthConstraint.setMultiplier(multiplier: 0.1)

        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            self.playerContainerView.superview?.layoutIfNeeded()
            self.playerContainerView.alpha = 0
            
            
        }) { (comp) in
            
        }
        
    }
    
    

    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
  
    
    
    enum Repeat:Int {
        
        case noRepeat = 0
        case repeat_ = 1
        case repeatAll = 2
        
        
        var nextMode : Repeat {
            
            if let returnValue = Repeat(rawValue: self.rawValue + 1) {
                return returnValue
            }
            else {
                return Repeat(rawValue: 0)!
            }
            
        }
        
        var image:UIImage {
            
            switch self {
            case .repeat_:
                return #imageLiteral(resourceName: "repeat")
            
            case .noRepeat:
                return #imageLiteral(resourceName: "no_repeat")
                
            case .repeatAll:
                return #imageLiteral(resourceName: "repeat_all")
                
            }
        }
        
        var title :String {
            
            switch self {
            case .repeat_:
                return "repeat"
                
            case .noRepeat:
                return "no repeat"
                
            case .repeatAll:
                return "repeat all"
                
            }
        }
        
    }

}
 
 
 protocol HomeContainerViewControllerDelegate {
    func homeContainerVCStartPlayingUrlAtIndex(index:Int, downloadStartIndex:Int, withTranslation:Bool)
 }
