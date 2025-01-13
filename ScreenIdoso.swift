import SwiftUI

struct ScreenIdoso: View {
    @State private var isHolding = false
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    
    @Binding var remedio: String
    @Binding var hora: String
    @State var exibirScreen: Binding<Bool>;
    
    var body: some View {
        VStack {
            Spacer()

            // Nome do medicamento - Centralizado
            Text(remedio)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)  // Centraliza o texto

            // Horário - Centralizado
            Text("\(hora)h")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 50)
                .multilineTextAlignment(.center)  // Centraliza o texto
            
           

            // Botão com Progress Bar - Centralizado
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .foregroundColor(.white.opacity(0.3))

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)  // Animate progress

                Text("Segure")
                    .font(.title)
                    .foregroundColor(.white)
                    .onLongPressGesture(
                        minimumDuration: 3.0,
                        pressing: { pressing in
                            if pressing {
                                startProgress()
                            } else {
                                resetProgress()
                            }
                        },
                        perform: {
                            exibirScreen.wrappedValue = false
                        }
                    )
            }
            .frame(width: 200, height: 200) // Tamanho ajustado para o botão
            .padding()
                
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Para garantir centralização
        .background(Color.pink)
        .edgesIgnoringSafeArea(.all)
    }
    
    // Função para iniciar o progresso
    func startProgress() {
        isHolding = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if self.progress < 1.0 {
                self.progress += 0.01 / 3.0  // 3 segundos
            } else {
                self.timer?.invalidate()
                print("Progress completed!")
            }
        }
    }

    // Função para resetar o progresso
    func resetProgress() {
        isHolding = false
        timer?.invalidate()
        progress = 0.0
    }
}


