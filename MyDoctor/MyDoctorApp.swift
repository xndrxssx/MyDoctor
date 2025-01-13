//
//  MyDoctorApp.swift
//  MyDoctor
//
//  Created by Turma01-3 on 08/10/24.
//

import SwiftUI

@main
struct MyDoctorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showScreenIdoso = false
    @State private var remedioNome = "Dipirona"
    @State private var remedioHora = ""
       
    var body: some Scene {
    
        WindowGroup {
            ContentView().onAppear {
                
                  NotificationManager.shared.requestPermission()
                                  
                  // Observa o evento de notificação recebida
                  NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowScreenIdoso"), object: nil, queue: .main) { notification in
                      if let content = notification.object as? UNNotificationContent {
                          remedioNome = content.userInfo["nome"] as! String
                          print(remedioNome)
                          remedioHora = content.userInfo["hora"] as! String
                          print(remedioHora)
                          let index = content.userInfo["id"] as! Int
                          showScreenIdoso = true
                          sendIndexToEndpoint(index: index)
                      }
                  }
            }
            .sheet(isPresented: $showScreenIdoso) {
                ScreenIdoso(remedio: $remedioNome, hora: $remedioHora,exibirScreen: $showScreenIdoso)
            }
        }
    }
}
