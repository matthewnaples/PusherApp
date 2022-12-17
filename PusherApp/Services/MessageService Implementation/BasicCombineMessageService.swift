//
//  BasicCombineMessageService.swift
//  PusherApp
//
//  Created by matt naples on 12/10/22.
//

import Foundation
import Combine
class BasicCombineMessageService: MessageService{
    let publisher: AnyPublisher<Message,Never>
    var cancellable: AnyCancellable?
    static var count = 0
    init(){
        self.publisher = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive), options: .none)
            .receive(on: DispatchQueue.main)
            .map {_ -> Message in
              // Generate a random word
            
              let words = ["apple", "orange", "banana", "strawberry", "grape"]
                BasicCombineMessageService.count += 1
              let randomIndex = Int.random(in: 0..<words.count)
                return Message(title: "random title \(BasicCombineMessageService.count)", body: words[randomIndex], size: Int.random(in: 1...50))
                
            }
          
            .eraseToAnyPublisher()
    }
    func subscribe(onReceive: @escaping (Result<Message, ApplicationError>) -> Void) {
        self.cancellable = publisher
            .sink { [weak self] completion in
                switch completion{
                case .finished:
                    print("finished")
                case .failure(let err):
                    print("err")
                }
  
        } receiveValue: { message in
            
            onReceive(.success(message))
        }
        
        
    }
    
    func unsubscribe() {
        self.cancellable = nil
    }
    
    
}
