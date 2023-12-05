//
//  NotificationManager.swift
//  ExamBuddy
//
//  Created by Ali Moussa on 05/12/2023.
//

import UserNotifications

struct NotificationManager {
    static let shared = NotificationManager()
    private let userNotificationCenterCurrent = UNUserNotificationCenter.current()
    
    func requestPermission() {
        self.userNotificationCenterCurrent.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func determineNotificationSettings(completion:@escaping (UNAuthorizationStatus) -> Void) {
        self.userNotificationCenterCurrent.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                completion(.notDetermined)
            case .denied:
                completion(.denied)
            case .authorized:
                completion(.authorized)
            case .provisional:
                completion(.provisional)
            default:
                break
            }
        }
    }
    
    func addNotification(timeInterval: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Timer is over"
        content.subtitle = "\(timeInterval) has passed. Time to hop to the next question."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        self.userNotificationCenterCurrent.add(request)
    }
}
