//
//  PusherMessageService.swift
//  PusherApp
//
//  Created by matt naples on 12/10/22.
//

import Foundation
import PusherSwift

enum MessageServiceError: Error{
    case couldNotDecode(String)
}
class PusherMessageService: MessageService{
    private static let GENERIC_ERROR_MESSAGE = "We had an error occur in our system, please try again later"
    private let pusher: Pusher
    var channel: PusherChannel?
    
    public init(){
        
        let options = PusherClientOptions(
            host: .cluster(PusherInfo.cluster.value)
        )
        
        self.pusher = Pusher(key: PusherInfo.key.value, options: options)
        //        pusher.connect()
    }
    
    private func decodeEvent(json: String) -> Result<Message, ApplicationError>{
        
        guard let jsonData: Data = json.data(using: .utf8) else{
            return .failure(ApplicationError.generalError(PusherMessageService.GENERIC_ERROR_MESSAGE, MessageServiceError.couldNotDecode("We could not decode the message: \(json)")))
        }
        do{
            let pusherMessage = try JSONDecoder().decode(PusherMessage.self, from: jsonData)
            print(json)
            let size = json.lengthOfBytes(using: .utf8) //MARK: can we assume utf-8
        
            let message = Message(title: pusherMessage.title, body: pusherMessage.message, size: size)
            return .success(message)
        }
        catch{
            return .failure(.generalError(PusherMessageService.GENERIC_ERROR_MESSAGE, error))
        }
    }
   
    
   public func unsubscribe(){
        if let channel = channel {
            channel.unbindAll()
            pusher.unsubscribe(channel.name)
        }
        pusher.disconnect()
    }
    

    public func subscribe(onReceive: @escaping (Result<Message,ApplicationError>) -> Void) {
        pusher.connect()
        print("subscribed")
        channel?.unbindAll()
        channel = pusher.subscribe(channelName: PusherInfo.channel.value)
        channel?.bind(eventName: PusherInfo.event.value, eventCallback: {[weak self] event in
            guard let self = self else {
                return
            }
            guard let json = event.data else{
                return // do not emit empty events
            }
            let decoded = self.decodeEvent(json: json)
            onReceive(decoded)
        })
    }
    
}

struct PusherMessage: Codable{
    let title: String
    let message: String
}





