//
//  ContentView.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var logStarting = false
    @ObservedObject var sensorLogger = WatchSensorManager()
    
    @State private var started = false
    @State private var count:Int = 0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Button(action: {
                self.logStarting.toggle()
                
                print("LogStarting: ", self.logStarting)
                
                if (self.logStarting ){
                    
                    // 計測スタート
                    //                    var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
                    let samplingFrequency = 10
                    print("sampling frequency = \(samplingFrequency) on watch")
                    
                    // なぜかサンプリング周波数が0のときは100にしておく
                    //                    if samplingFrequency == 0 {
                    //                        samplingFrequency = 100
                    //                    }
                    WKInterfaceDevice.current().play(.start)
                    self.sensorLogger.startUpdate(Double(samplingFrequency))
                    self.started = true
                    
                }
            }) {
                if self.logStarting {
                    Image(systemName: "pause.circle")
                }
                else {
                    Image(systemName: "play.circle")
                }
            }
            
            VStack {
                VStack {
                Text("Accelerometer").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.accX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accY))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accZ))
                }.padding(.horizontal)
                }
                
                VStack {
                Text("Gyroscope").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                }.padding(.horizontal)
                }

            }
        }.onReceive(timer) {
            time in
            if self.started {
                
                print("count: ",self.count)
                self.count = self.count + 1
                if self.count > 6 {
                    WKInterfaceDevice.current().play(.stop)
                    self.sensorLogger.stopUpdate()
                    self.started = false
                    self.logStarting.toggle()
                    print("LogStarting: ", self.logStarting)


                }
            }
            else {
                self.count = 0
            }
                
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
