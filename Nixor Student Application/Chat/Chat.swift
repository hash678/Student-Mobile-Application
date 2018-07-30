//
//  Chat.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 15/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import JSQMessagesViewController
import MobileCoreServices
import AVKit
class Chat: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,MessageReceieved{
	
	var messageIDS = [String]()
	var id:String?
	var userAvatars = [String:String]()
	
	
	func messageReceived(senderID: String, text: String, displaname:String,messageID:String) {
	
		if !messageIDS.contains(messageID){
			messageIDS.append(messageID)
		messages.append(JSQMessage(senderId: senderID, displayName: displaname, text: text))
			collectionView.reloadData()}
	}
	
	
	let picker = UIImagePickerController()
	
	private var messages = [JSQMessage]()
	private let commonUtil = common_util()
	override func viewDidLoad() {
		super.viewDidLoad()
		self.inputToolbar.tintColor = #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
		self.inputToolbar.contentView.rightBarButtonItem.tintColor =  #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
		self.automaticallyScrollsToMostRecentMessage = true
		self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(#colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1), for: .normal)
		self.inputToolbar.contentView.rightBarButtonContainerView.tintColor = #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
		
		self.collectionView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9294117647, blue: 0.9333333333, alpha: 1)
		MessagesHandler.db = constants.CarpoolMessagesDB.child(id!)
		MessagesHandler.Instance.delegate = self
		MessagesHandler.Instance.observerMessages()
		self.senderId = commonUtil.getUserData(key: "username")
		//TODO: Change this back
		self.senderDisplayName = commonUtil.getUserData(key: "name")
		//self.senderDisplayName = "Hassan Abbasi"
		
		picker.delegate = self
	}
	
	override func didPressAccessoryButton(_ sender: UIButton!) {
		
		let alert =  UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .actionSheet)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
		let photos = UIAlertAction(title: "Photos", style: .default, handler: {
			(alert: UIAlertAction) in
		self.chooseMedia(type: kUTTypeImage)
		})
		
		let videos = UIAlertAction(title: "Videos", style: .default, handler: {
			(alert: UIAlertAction) in
			self.chooseMedia(type: kUTTypeMovie)
		})
		alert.addAction(photos)
		alert.addAction(cancel)
		alert.addAction(videos)
		present(alert, animated:true, completion: nil)
		
		
	}
	
	
	//MARK: Picker View function
	
	private func chooseMedia(type:CFString){
		picker.mediaTypes = [type as String]
		
		present(picker, animated: true, completion: nil)
		
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage{
			
			let img = JSQPhotoMediaItem(image: pic)
			self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img))
				
			
		}else if let vidurl = info[UIImagePickerControllerMediaURL] as? URL{
			let video = JSQVideoMediaItem(fileURL: vidurl, isReadyToPlay: true)
			self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video))
		}
		self.dismiss(animated: true, completion: nil)
		collectionView.reloadData()
	}
	
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
		
		
		MessagesHandler.Instance.sendMessage(senderID: senderId, senderName: senderDisplayName, text: text)
		
		finishSendingMessage()
		
	}
	
	
	
	
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
		
		
		return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(), diameter: 30)
	}
	
	
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
		let bubbleFactory = JSQMessagesBubbleImageFactory()
		let message = messages[indexPath.item]
		
		
		if message.senderId == senderId {
		
			return bubbleFactory?.outgoingMessagesBubbleImage(with: #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1))}
		return bubbleFactory?.incomingMessagesBubbleImage(with: #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1))
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
		return messages[indexPath.item]
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
		
		if messages[indexPath.item].senderId != "NixorApp"{
		if  let  photo = userAvatars[messages[indexPath.item].senderId]  {
		let url = URL(string:photo)
			cell.avatarImageView.circleImage()
			cell.avatarImageView.kf.setImage(with: url)
		}else{
				getPhotoUrl(cell: cell, username: messages[indexPath.item].senderId)
		}
		
		}
		
		return cell
		
	}
	
	
	
	
	//MARK: Tableview item photo
	func getPhotoUrl(cell:JSQMessagesCollectionViewCell, username:String){
		Firestore.firestore().collection("users").document(username).getDocument { (response, error) in
			if error == nil && response != nil{
				if response?.get("photourl") != nil{
					let url = URL(string: response?.get("photourl") as! String)
					self.userAvatars[username] = (response?.get("photourl") as! String)
					cell.avatarImageView.kf.setImage(with: url )
					cell.avatarImageView.circleImage()
					cell.avatarImageView.isHidden = false;
				}
				
			}
		}
		
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
		let message = messages[indexPath.item];
		
		if message.isMediaMessage{
			if let mediaItem = message.media as? JSQVideoMediaItem{
				let player = AVPlayer(url: mediaItem.fileURL)
				let playerController = AVPlayerViewController();
				playerController.player = player
				self.present(playerController,animated: true, completion: nil)
			}
			
			
		}
	}
	

}
