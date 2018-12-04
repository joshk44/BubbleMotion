//
//  CommunicationService.swift
//  BubbleMotion
//
//  Created by Jose Ferreyra on 10/09/2018.
//  Copyright © 2018 Arthur Knopper. All rights reserved.
//


import Foundation
import MultipeerConnectivity

protocol CommunicationServiceDelegate {
    
    func connectedDevicesChanged(manager : CommunicationService, connectedDevices: [String])
    func startMatch ()
    func bombReceived(bomb: GameState)
    func finishMatch (points: Int)
}

class CommunicationService : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let CommServiceType = "communic-bubble"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    public var contrincant : String
    
    var delegate : CommunicationServiceDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: CommServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: CommServiceType)
        self.contrincant = ""
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    
    func sendInvitationToPlay () {
        
        let jsonMessage: [String: Any] = [
            "sender": self.myPeerId.displayName,
            "messageType": MessageType.Invite.rawValue,
            "value": "true"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        send (message: jsonString!)
    }
    
    func respondInvitationToPlay (response: Bool) {
        
        let jsonMessage: [String: Any] = [
            "sender": self.myPeerId.displayName,
            "messageType": MessageType.ResponseInvite.rawValue,
            "value": response.description
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        send (message: jsonString!)
    }
    
    func sendStartMatch () {
        
        let jsonMessage: [String: Any] = [
            "sender": self.myPeerId.displayName,
            "messageType": MessageType.StartMatch.rawValue,
            "value": "true"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        send (message: jsonString!)
    }
    
    func sendBomb (bomb: GameState) {
        let jsonMessage: [String: Any] = [
            "sender": self.myPeerId.displayName,
            "messageType": MessageType.Bomb.rawValue,
            "value": bomb.rawValue
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        send (message: jsonString!)
    }
    
    func sendResults (points: Int){
        let jsonMessage: [String: Any] = [
            "sender": self.myPeerId.displayName,
            "messageType": MessageType.FinishMatch.rawValue,
            "value": "\(points)"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        send (message: jsonString!)
    }

    
    func send(message : String) {
        NSLog("%@", "message sent: \(message) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
}

extension CommunicationService : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension CommunicationService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension CommunicationService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
        if (session.connectedPeers.map{$0.displayName}.count > 0) {
            contrincant = session.connectedPeers.map{$0.displayName}[0]
        } else {
            contrincant = "No device connected"
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let str = String(data: data, encoding: .utf8)!
        let message = parseJSON (data: data)
        print ( "messsage type: \(message.messageType)")

        switch message.messageType {
        case MessageType.Invite.rawValue:
            DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showMultiplayerInvite()
            }
        case MessageType.ResponseInvite.rawValue:
            if (message.value == "true") {
            self.sendStartMatch()
            self.delegate?.startMatch ()
            }
        case MessageType.StartMatch.rawValue:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.startMatch()
        case MessageType.Bomb.rawValue:
            self.delegate?.bombReceived (bomb: GameState(rawValue: message.value)!)
        case MessageType.FinishMatch.rawValue:
            self.delegate?.finishMatch (points: Int(message.value)!)
        default:
            NSLog("%@", "non process data: \(str)")
            
        }
            }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    
    struct Message: Decodable {
        var messageType: String
        var sender: String
        var value: String
    }
    
    func parseJSON(data: Data) -> Message{
        var resultValue: Message?
        do {
            let decoder = JSONDecoder()
            resultValue = try decoder.decode(Message.self, from: data)
        } catch let error {
            print ("error parsing json", error)
        }
        return resultValue!
    }
    
}

enum MessageType:String {
    case Invite = "invite-to-play"
    case ResponseInvite = "response-invite-to-play"
    case StartMatch = "start-match"
    case Bomb = "bomb"
    case FinishMatch = "finish-match"
}
