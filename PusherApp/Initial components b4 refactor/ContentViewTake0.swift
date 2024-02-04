//
//  ContentViewTake0.swift
//  PusherApp
//
//  Created by matt naples on 8/2/23.
//

import SwiftUI
import PusherSwift


struct ContentViewTake0: View {
    var pusher = Pusher(key: PusherInfo.key.value,
                        options: PusherClientOptions(
                            host: .cluster(PusherInfo.cluster.value)))
    @State private var channel: PusherChannel? = nil
    @State private var message: Message?
    @State private var initialLoad = true
    @State private var titleAppeared = false
    @State private var bodyAppeared =  false
    @State private var sizeAppeared =  false
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack{
            Spacer()
            if initialLoad{
                VStack{
                    ScalingCircleLoadingView()
                    Text("Connecting to message stream...")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous )
                    .background(.ultraThinMaterial))
            } else{
                if let message = message {
                    VStack(alignment: .leading){
                        Text(message.title.capitalized)
                            .font(.title)
                            .offset(x: titleAppeared ? 0 : -100)
                            .opacity(titleAppeared ? 1 : 0)
                            .transition(
                                .offset(x: -100).animation(.interpolatingSpring(stiffness: 10, damping: 10))
                                .combined(with: .opacity)
                            )
                        Text(message.body)
                            .offset(x: bodyAppeared ? 0 : -100)
                            .opacity(bodyAppeared ? 1 : 0)
                        Text("\(message.size) bytes")
                            .offset(x: sizeAppeared ? 0 : -100)
                            .opacity(sizeAppeared ? 1 : 0)
                    }
                    .onAppear(perform: fadeIn)
                    .onDisappear(perform: fadeOut)
                    .transition(.asymmetric(insertion: .fade(offset: -200), removal: .fade(offset: 200)))
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            subscribe()
        }
        .onDisappear {
            unsubscribe()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase{
            case .active:
                subscribe()
            default:
                unsubscribe()
            }
        }
    }
    
    //MARK: subscription logic
    private func subscribe() {
        pusher.connect()
        print("subscribed")
        channel?.unbindAll()
        channel = pusher.subscribe(channelName: PusherInfo.channel.value)
        channel?.bind(eventName: PusherInfo.event.value, eventCallback: { event in
            guard let json = event.data else{
                return // do not emit empty events
            }
            let decoded = self.decodeEvent(json: json)
            handleMessage(result: decoded)
        })
    }
    private func unsubscribe(){
        if let channel = channel {
            channel.unbindAll()
            pusher.unsubscribe(channel.name)
        }
        pusher.disconnect()
    }
    private func handleMessage(result: Result<Message, ApplicationError>){
     
        DispatchQueue.main.async {
            withAnimation {
                self.initialLoad = false
                switch result{
                case .failure(_):
                    //eat the error
                    print("error occurred")
                case .success(let message):
                        self.message = message
                }
            }
        }
    }
    
    //MARK: Decoding logic
    private func decodeEvent(json: String) -> Result<Message, ApplicationError>{
        guard let jsonData: Data = json.data(using: .utf8) else{
            return .failure(ApplicationError.generalError("We had an error occur in our system, please try again later", MessageServiceError.couldNotDecode("We could not decode the message: \(json)")))
        }
        do{
            let pusherMessage = try JSONDecoder().decode(PusherMessage.self, from: jsonData)
            print(json)
            let size = json.lengthOfBytes(using: .utf8) //MARK: can we assume utf-8
            let message = Message(title: pusherMessage.title, body: pusherMessage.message, size: size)
            return .success(message)
        }
        catch{
            return .failure(.generalError("We had an error occur in our system, please try again later", error))
        }
    }
    
    
    //MARK: animation logic
    private func fadeIn() {
        withAnimation(.introMessage.delay(0.2)) {
            titleAppeared = true
        }
        withAnimation(.introMessage.delay(0.4)) {
            bodyAppeared = true
        }
        withAnimation(.introMessage.delay(0.6)) {
            sizeAppeared = true
        }
    }
    
    private func fadeOut() {
        withAnimation(.introMessage.delay(0.5)) {
            titleAppeared = false
        }
        withAnimation(.introMessage.delay(1)) {
            bodyAppeared = false
        }
        withAnimation(.introMessage.delay(1.5)) {
            sizeAppeared = false
        }

    }
}

struct ContentViewTake0_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewTake0()
    }
}
