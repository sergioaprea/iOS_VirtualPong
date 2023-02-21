//
//  ContentView.swift
//  sensoriWatch1 Watch App
//
//  Created by Sergio Aprea on 10/02/23.
//
import SwiftUI
import CoreMotion
import Charts
import AVFoundation
import WatchKit
import HealthKit

var audio = AVAudioPlayer()

struct ContentView: View {
    
    let healthStore = HKHealthStore()
    
    let motionManager1 = CMMotionManager()
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    @State var session:HKWorkoutSession?
    
    let allTypes = Set([ HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! , HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    let config = HKWorkoutConfiguration()
    
    init() {
        config.activityType = .tableTennis
        config.locationType = .indoor
    }
    
    @State private var pitch = Double.zero
    @State private var yaw = Double.zero
    @State private var roll = Double.zero
    @State private var x = Double.zero
    @State private var y = Double.zero
    @State private var z = Double.zero
    @State private var radice = Double.zero
    @State private var colpo = ""
    
    
    func requestAuth() {
        healthStore.requestAuthorization(toShare: [HKObjectType.workoutType()], read: allTypes) {
            (success, error) in
            if !success {
                print("Error!")
            }
        }
    }
    
    func stopSession() {
        if let session1 = session {
            session1.stopActivity(with: Date())
            session1.end()
            self.session = nil
        }
    }
    
    var body: some View {
        VStack{
            Text("Roll: \(roll)")
            Text("x: \(x)")
            Text("y: \(y)")
            Text("z: \(z)")
            Text("Colpo: \(colpo)")
            Text("Forza: \(radice)")
            
            Button( action: {
                session = try? HKWorkoutSession.init(healthStore: self.healthStore, configuration: config)
                if let session = session {
                    let builder = session.associatedWorkoutBuilder()
                    builder.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore, workoutConfiguration: config)
                    session.startActivity(with: Date())
                    builder.beginCollection(withStart: Date(), completion: {
                        _, error in
                    })
                }
            }, label: {
                Text("Play")
            })
            
            Button(action: {
                stopSession()
            }, label: {
                Text("Stop")
            })
            
            
        }//Vstack
        .onAppear {
            print("ON APPEAR")
            requestAuth()
            self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
                self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
                    guard let data = data else {
                        print("Error: \(error!)")
                        return
                    }
                    self.motionManager.startAccelerometerUpdates(to: self.queue) { (data1: CMAccelerometerData?, error: Error?) in
                        guard let data1 = data1 else {
                            print("Error: \(error!)")
                            return
                        }
                        let _: CMAcceleration = data1.acceleration
                        self.motionManager.accelerometerUpdateInterval = 0.2
                        let userAcc: CMAcceleration = data.userAcceleration
                        let attitude: CMAttitude = data.attitude
                        
                        DispatchQueue.main.async {
                            self.pitch = attitude.pitch
                            self.yaw = attitude.yaw
                            self.roll = attitude.roll
                            self.x = userAcc.x
                            self.y = userAcc.y
                            self.radice = sqrt(pow(self.z-userAcc.z,2))
                            
                            if  self.radice > 1.2 {
                                print("pitch: \(attitude.pitch)")
                                print("yaw: \(attitude.yaw)")
                                print("roll: \(attitude.roll)")
                                print("x: \(Float(userAcc.x*1000.0))")
                                print("y: \(Float(userAcc.y*1000.0))")
                                print("z: \(Float(userAcc.z*1000.0)) self.z: \(self.z*1000.0) incremento: \(self.z - userAcc.z)")
                                print("colpo valido accelerazione: \(self.radice)")
                                
                                if self.z - userAcc.z > 0 {
                                    self.colpo = "Rovescio"
                                    playSound(sound: "pop-39222", type: "mp3")
                                } else {
                                    self.colpo = "Dritto"
                                    playSound(sound: "pop-94319", type: "mp3")
                                }
                                print("colpo: \(self.colpo)")
                            }
                            self.z = userAcc.z
                        }
                    }
                }
            }//.onappear
        }
        
        
    }

    
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audio.play()
            } catch {
                print("ERROR")
            }
        }
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

