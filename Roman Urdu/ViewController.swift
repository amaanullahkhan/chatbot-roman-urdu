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

import UIKit
import AI
import AVFoundation
import JSQMessagesViewController


class ViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!

    var audioPlayer: AVAudioPlayer?
    
    
    fileprivate var playlists:[String:[String]] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.setupPlaylist()
        self.setupInterface()
        self.setupSender()
        self.conversation(event_or_query: "WELCOME")
    }
}

// MARK: API.AI Services
extension ViewController {
    
    /// Instantiate playlist
    func setupPlaylist() {
        self.playlists["work"]  = ["not afraid", "satisfaction","running up that hill", "under the bridge"]
        self.playlists["study"] = ["one more time", "not afraid","love the way you lie"]
        self.playlists["workout"] = ["despacito", "one more time"]
        self.playlists["relax"] = ["master of puppets", "love the way you lie"]
        self.playlists["morning"] = ["not afraid", "satisfaction","running up that hill", "under the bridge"]
        self.playlists["all"] = ["angie","best of you","closer", "despacito", "enter sandman", "fade to black","get lucky", "hey you", "i want to break free", "love the way you lie", "master of puppets","not afraid","one more time", "paint it black","running up that hill","satisfaction","terrible lie","under the bridge","we will rock you"]
    }
    
    /// Present an error message
    func failure(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    /// Start a new conversation
    func conversation(event_or_query:String) {
        
        AI.sharedService.textRequest(event_or_query).success { response in
            
            self.doActionOnResponse(response: response)
            
            self.presentResponse(response.result.fulfillment?.speech ?? "")
            
        }.failure(completionHandler: failure)
    }
    
    /// Present a conversation reply and speak it to the user
    func presentResponse(_ response: String) {
        
        // create message
        let message = JSQMessage(
            senderId: User.watson.rawValue,
            displayName: User.getName(User.watson),
            text: response
        )
        
        // add message to chat window
        if let message = message {
            self.messages.append(message)
            DispatchQueue.main.async { self.finishSendingMessage() }
        }
    }
    
    func doActionOnResponse(response:TextQueryRequest.ResponseType) {
        
        switch response.result.action ?? "" {
            
        case "music.play":
            
            let music = response.result.parameters?["song"] as? String ?? ""
            if !music.isEmpty {
                
                // play music
                if let songUrl = Bundle.main.path(forResource: music.lowercased(), ofType: "mp3") {
                    let url = URL.init(fileURLWithPath: songUrl)
                    HomeContainerViewController.instance?.play(url: url)
                }
            }
            
        case "playlist.play":
            let playlist = response.result.parameters?["playlist"] as? String ?? ""
            if !playlist.isEmpty {
                
                // play playlist
                if let playlistSongs:[String] = self.playlists[playlist.lowercased()] {
                    
                    var urls = [URL]()
                    for song in playlistSongs {
                        let songUrl = Bundle.main.path(forResource: song, ofType: "mp3")
                        urls.append(URL.init(fileURLWithPath: songUrl!))
                    }
                    HomeContainerViewController.instance?.play(playlist: urls)
                }
            }
            
        case "player.backward":
            HomeContainerViewController.instance?.previous()
            
        case "player.forward":
            HomeContainerViewController.instance?.next()

            
        case "player.pause":
            HomeContainerViewController.instance?.pause()
            
        case "player.play":
            HomeContainerViewController.instance?.play()

            
        default:
            break
            
        }
    }
    
}

// MARK:- Configuration
extension ViewController {

    
    func setupInterface() {
        
        // textview autocorrection off
        self.inputToolbar.contentView.textView.autocorrectionType = .no
        
        // remove attachment button on textview left
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        
        // bubbles
        let factory = JSQMessagesBubbleImageFactory()
        let incomingColor = UIColor.jsq_messageBubbleLightGray()
        let outgoingColor = UIColor.jsq_messageBubbleGreen()
        incomingBubble = factory!.incomingMessagesBubbleImage(with: incomingColor)
        outgoingBubble = factory!.outgoingMessagesBubbleImage(with: outgoingColor)
        
        // avatars
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
    }
    
    func setupSender() {
        senderId = User.me.rawValue
        senderDisplayName = User.getName(User.me)
    }
    
    override func didPressSend(
        _ button: UIButton!,
        withMessageText text: String!,
        senderId: String!,
        senderDisplayName: String!,
        date: Date!)
    {
        let message = JSQMessage(
            senderId: User.me.rawValue,
            senderDisplayName: User.getName(User.me),
            date: date,
            text: text
        )
        
        if let message = message {
            self.messages.append(message)
            self.finishSendingMessage(animated: true)
        }
        self.conversation(event_or_query: text)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // required by super class
    }
}

// MARK: Collection View Data Source
extension ViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int)
        -> Int
    {
        return messages.count
    }
    
    override func collectionView(
        _ collectionView: JSQMessagesCollectionView!,
        messageDataForItemAt indexPath: IndexPath!)
        -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(
        _ collectionView: JSQMessagesCollectionView!,
        messageBubbleImageDataForItemAt indexPath: IndexPath!)
        -> JSQMessageBubbleImageDataSource!
    {
        let message = messages[indexPath.item]
        let isOutgoing = (message.senderId == senderId)
        let bubble = (isOutgoing) ? outgoingBubble : incomingBubble
        return bubble
    }
    
    override func collectionView(
        _ collectionView: JSQMessagesCollectionView!,
        avatarImageDataForItemAt indexPath: IndexPath!)
        -> JSQMessageAvatarImageDataSource!
    {
        let message = messages[indexPath.item]
        return User.getAvatar(message.senderId)
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell = super.collectionView(
            collectionView,
            cellForItemAt: indexPath
        )
        let jsqCell = cell as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        let isOutgoing = (message.senderId == senderId)
        jsqCell.textView.textColor = (isOutgoing) ? .white : .black
        return jsqCell
    }
}
