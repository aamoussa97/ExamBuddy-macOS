//
//  ExamBuddyApp.swift
//  ExamBuddy
//
//  Created by Ali Moussa on 05/12/2023.
//

import SwiftUI

@main
struct ExamBuddyApp: App {
    @State var isActive: Bool = false
    @State var isRepeating: Bool = true
    
    @State var timeRemaining = Constants.DEFAULT_TIME
    @State var timer: Timer?
    
    @State var notificationsStatusBool: Bool = false
    @State var notificationsStatusTitle: String = ""
    @State var notificationsStatusIcon: String = ""
    
    private let notificationManager = NotificationManager.shared
    
    var body: some Scene {
        /*
         WindowGroup {
         ContentView()
         }
         */
        
        MenuBarExtra {
            HStack {
                Button(action: {
                    self.startTimer()
                }) {
                    Text("Start timer")
                    Image(systemName: "play")
                }
                .keyboardShortcut("P")
                .disabled(isActive)
            }
            
            HStack {
                Button(action: {
                    self.stopTimer()
                }) {
                    Text("Stop timer")
                    Image(systemName: "stop")
                }
                .disabled(!isActive)
                .keyboardShortcut("S")
            }
            
            HStack {
                Button(action: {
                    self.stopTimer()
                    self.resetTimer()
                }) {
                    Text("Restart timer")
                    Image(systemName: "arrow.clockwise")
                }
                .keyboardShortcut("R")
            }
            
            Divider()
            
            Text("Version 1.0.0")
                .foregroundStyle(.secondary)
            
            HStack {
                Button(action: {
                    self.notificationManager.requestPermission()
                }) {
                    Text(notificationsStatusTitle)
                    Image(systemName: notificationsStatusIcon)
                }
                .disabled(notificationsStatusBool)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: isActive ? "timer.circle.fill" : "timer.circle")
                //Spacer()
                Text(isActive ? self.formatTimeRemaining() : "Idle")
            }
            .onAppear() {
                self.notificationManager.determineNotificationSettings(completion: { unAuthorizationStatusResponse in
                    switch unAuthorizationStatusResponse {
                    case .authorized:
                        notificationsStatusBool = true
                        notificationsStatusTitle = "Notifications configured correctly"
                        notificationsStatusIcon = "bell"
                    case .provisional:
                        notificationsStatusBool = true
                        notificationsStatusTitle = "Notifications configured correctly"
                        notificationsStatusIcon = "bell"
                    case .denied:
                        break
                    case .notDetermined:
                        notificationsStatusBool = false
                        notificationsStatusTitle = "Request permission for notifications"
                        notificationsStatusIcon = "bell.slash"
                        
                        self.notificationManager.requestPermission()
                    default:
                        break
                    }
                })
            }
        }
    }
    
    private func processTimer(timer: Timer) {
        if (self.timeRemaining > 0) {
            self.timeRemaining -= 1
        } else if (isRepeating) {
            timer.invalidate()
            self.timeRemaining = Constants.DEFAULT_TIME
            self.startTimer()
        } else {
            timer.invalidate()
        }
    }
    
    private func startTimer() {
        self.isActive = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            processTimer(timer: timer)
        }
        
        self.notificationManager.addNotification(timeInterval: timeRemaining)
    }
    
    private func stopTimer() {
        self.isActive = false
        timer?.invalidate()
    }
    
    private func resetTimer() {
        self.timeRemaining = Constants.DEFAULT_TIME
    }
    
    private func formatTimeRemaining() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let formattedString = formatter.string(from: TimeInterval(self.timeRemaining))!
        
        return formattedString
    }
}
