import SwiftUI
import UserNotifications

import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erro ao solicitar permissão: \(error.localizedDescription)")
            }
        }
    }

  
    func scheduleNotification(for remedio: Remedio) {
        let content = UNMutableNotificationContent()
        content.title = "Hora de tomar \(remedio.nome)"
        content.body = "Tome \(remedio.quantidade) \(remedio.unidade)"
        content.sound = .default
        
        // Adicionar informações extras no userInfo
        content.userInfo = [
            "id": remedio.id,
            "nome": remedio.nome,
            "quantidade": remedio.quantidade,
            "unidade": remedio.unidade,
            "hora": remedio.hora
        ]
        
        // Convertendo a string "hh:mm" para DateComponents
        let horaComponents = remedio.hora.split(separator: ":").compactMap { Int($0) }
        guard horaComponents.count == 2 else { return }
        
        var triggerDate = DateComponents()
        triggerDate.hour = horaComponents[0]
        triggerDate.minute = horaComponents[1]
        
        let requestIdentifier = "\(remedio.id)_\(remedio.id)" // Usando id para o identificador da notificação
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            }
        }
    }
}
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @ObservedObject var notificationManager = NotificationManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Função chamada quando a notificação é recebida com o app em foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        
        // Exibir a tela ScreenIdoso
        NotificationCenter.default.post(name: NSNotification.Name("ShowScreenIdoso"), object: notification.request.content)
    }
}
