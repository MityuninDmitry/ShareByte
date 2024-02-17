//
//  NotificationManager.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/15/24.
//

import Foundation

class NotificationManager: ObservableObject {
    static var shared = NotificationManager()
    var lock: NSLock = .init()
    
    private var newNotification: NotificationView?
    func setNewNotification(_ newNotification: NotificationView?) {
        lock.lock()
        guard let newNotification else {return}
        if !hasFree() {return}
        
        var notView = newNotification
        for index in self.freePositions.indices {
            
            if self.freePositions[index] {
        
                Task { // защита, если вдруг не освободится место через 7 секунд, то через 8 точно освободится
                    try await Task.sleep(for: .seconds(8))
                    if notifications[index] == newNotification {
                        Task { @MainActor in
                            self.freePositions[index] = true
                            self.notifications[index] = nil
                        }
                    }
                }
                
                notView.callback = {
                    self.freePositions[index] = true
                    self.notifications[index] = nil
                }
                self.notifications[index] = notView
                self.freePositions[index] = false
                
                break
            }
        }
        lock.unlock()
    }
    private var notifications: [Int: NotificationView?] = .init()
    @Published var freePositions: [Bool] = [true, true, true]
    
    func getNotificationBy(_ index: Int) -> NotificationView? {
        if let notification = notifications[index] {
           return notification
        }
       
        return nil
    }
    
    func hasFree() -> Bool {
        for freePosition in freePositions {
            if freePosition {
                
                return true
            }
        }
    
        return false
    }
    
    func allFree() -> Bool {
        
        for freePosition in freePositions {
            if !freePosition {
                
                return false
            }
        }
    
        return true
    }
}
