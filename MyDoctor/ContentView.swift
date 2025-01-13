//
//  ContentView.swift
//  MyDoctor
//
//  Created by Turma01-3 on 08/10/24.
//

import SwiftUI

extension UITabBarController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 16
        // Choose with corners should be rounded
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top left, top right

        // Uses `accessibilityIdentifier` in order to retrieve shadow view if already added
        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = "TabBarShadow"
            shadowView.backgroundColor = UIColor.white
            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = Color.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
            shadowView.layer.shadowOpacity = 0.3
            shadowView.layer.shadowRadius = 10
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }
}


struct Wave: Shape {
    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }

    var strength: Double

    var frequency: Double

    var phase: Double

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()

        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midWidth = width / 2
        let midHeight = height / 2
        let oneOverMidWidth = 1 / midWidth

        // split our total width up based on the frequency
        let wavelength = width / frequency

        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))

        // now count across individual horizontal points one by one
        for x in stride(from: 0, through: width, by: 1) {
            // find our current position relative to the wavelength
            let relativeX = x / wavelength

            // find how far we are from the horizontal center
            let distanceFromMidWidth = x - midWidth

            // bring that into the range of -1 to 1
            let normalDistance = oneOverMidWidth * distanceFromMidWidth

            let parabola = -(normalDistance * normalDistance) + 1

            // calculate the sine of that position, adding our phase offset
            let sine = sin(relativeX + phase)

            // multiply that sine by our strength to determine final offset, then move it down to the middle of our view
            let y = parabola * strength * sine + (midHeight / 12)

            // add a line to here
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return Path(path.cgPath)
    }
}

struct Header: View{
    
    init() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "cutielight") // Defina a cor aqui

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    @State private var phase = 0.0
    var body: some View {
        ZStack {
            Image(systemName: "cross.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60)
                .offset(CGSize(width: 150.0, height: -300.0))
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .foregroundColor(.plum)
                .opacity(0.9)
            WaveForm(color: .cutie.opacity(0.9), amplify: 50)
            ZStack {
                Wave(strength: 20, frequency: 5, phase: self.phase)
                    .stroke(Color.grumpy.opacity(0.8), lineWidth: 5)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    self.phase = .pi * 2
                }
            }
        }

        .ignoresSafeArea(.all, edges: .top)
    }
}

struct NavBar: View {
    
    init() {
            // Configurando as cores para os itens da TabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "cutielight") // Defina a cor do fundo da TabBar
            
            // Definindo a cor dos itens não selecionados
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.grumpy
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.grumpy]
            
            // Definindo a cor dos itens selecionados
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
    @State var remedios: [Remedio] = carregarRemedios()
    var body: some View {
        TabView {
            
        
         Alarmes().tabItem {
                   Label(
                       title: { Text("Alarmes") },
                       icon: { Image(systemName: "calendar") }
                   )
            }
          
            NovoRemedioView().tabItem {
                Label(
                    title: { Text("Novo remédio") },
                    icon: { Image(systemName: "pills.fill") }
                )
            }
          
           Estoque()
            .tabItem {
                Label(
                    title: { Text("Medicamentos") },
                    icon: { Image(systemName: "shippingbox.fill") }
                )
            }
            
            
        }
        .tint(.white)
        
    }
}

struct ContentView: View {
    var body: some View {
       
        ZStack{
            Color.apricot
            Header()
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            Spacer()
            NavBar()
                
        }
    }
}

#Preview {
    ContentView()
}

struct WaveForm: View {
    var color: Color
    var amplify: CGFloat
    var body: some View {
        TimelineView(.animation) { timeLine in
            Canvas {context, size in
            let timeNow = timeLine.date.timeIntervalSinceReferenceDate
                
                let angle = timeNow.remainder(dividingBy: 2)
                
                let offset = angle * size.width
                
                
                context.translateBy(x: offset, y: 0)
                
                context.fill(getPath(size: size), with: .color(color))
                context.translateBy(x: -size.width,y: 0)
                context.fill(getPath(size: size), with: .color(color))
                context.translateBy(x: size.width * 2,y: 0)
                context.fill(getPath(size: size), with: .color(color))
             }
        }
    }
    
    func getPath(size: CGSize)->Path{
        return Path{ path in
            
            let midHeight = size.height / 24
            let width = size.width
            
            path.move(to:CGPoint(x: 0, y: midHeight))
            
            path.addCurve(to: CGPoint(x: width, y:midHeight),control1:CGPoint(x: width * 0.5, y: midHeight + amplify), control2: CGPoint(x: width * 0.5, y: midHeight - amplify))
            
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))

        }
    }
}

