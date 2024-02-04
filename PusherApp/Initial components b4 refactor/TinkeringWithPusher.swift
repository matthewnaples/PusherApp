//
//  ContentView1.swift
//  PusherApp
//
//  Created by matt naples on 12/9/22.
//

import SwiftUI
import PusherSwift
class SomeObject{
    init(){
        print("initting object")
    }
    deinit{
        print("deinitting object")
    }
}

struct TinkeringWithPusher: View {
    @State private var title: String?
    @State private var message: String?
    @State private var size: String?
    let pusherService = TransparentPusherService.shared //MARK: Would like to remove singleton. Also, we should not depend on a concrete implementation.
    let object = SomeObject()
    
    // MARK: We should not have our views depending on Pusher data types.
    func handleEvent(event: PusherEvent){
        
        //MARK: move json mapping logic elsewhere
                print("handle event called")
        guard let json: String = event.data,
              let jsonData: Data = json.data(using: .utf8)
        else{
            print("Could not convert JSON string to data")
            return
        }
        
        let decoded = try? JSONDecoder().decode(PusherMessage.self, from: jsonData)
        guard let decodedMessage = decoded else {
            print("Could not decode message")
            return
        }
        print("json size: \(MemoryLayout.size(ofValue: event.data))") // need to get the payload
        
        
        DispatchQueue.main.async {
            self.title = decodedMessage.title
            self.message = decodedMessage.message
        }
  
        
    }
    var body: some View {
        VStack{
            Text(title ?? "no message message title :(.")
            Text(message ?? "no message")
            Text("json payload size: \(size ?? "no size provided"))")
            Divider()
            Text("pusher controls")
            HStack{
                
                //MARK: we probably don't need to expose all these methods from our service. Too much implementation detail. It would maybe be even worse if we just had a singleton `Pusher` instance running throughout the app and having to manage subscriptions, message names, channels, etc. in the view.
                Button("globally bind"){
                    pusherService.globalBind(callback: handleEvent(event:))
                }
                VStack{
                    Button("connect"){
                        pusherService.connect()
                    }
                    .foregroundColor(.green)
                    
                    Button("disconnect"){
                        pusherService.disconnect()
                    }
                    
                }
                VStack{
                    Button("subscribe"){
                        pusherService.subscribe()
                    }
                    .foregroundColor(.green)
                    Button("unsubscribe"){
                        pusherService.unsubscribe()
                    }
                }
                VStack{
                    Button("bind"){
                        pusherService.bind(callback: handleEvent(event:))
                    }
                    .foregroundColor(.green)
                    
                    Button("unbind"){
                        pusherService.unbind()
                    }
                }
                
                
            }
        }
    }
}

struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        TinkeringWithPusher()
    }
}
