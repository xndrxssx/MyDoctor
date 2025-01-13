//
//  Alarmes.swift
//  MyDoctor
//
//  Created by Turma01-3 on 08/10/24.
//

import SwiftUI


struct AlarmeCard: View {
    var remedio: Remedio
    
    var body: some View {
        HStack(alignment: .top, spacing: 13){
            VStack(alignment: .leading, spacing: 5){
                Text(remedio.hora).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().foregroundColor(.cutielight)
                HStack{
                    Text("\(String(remedio.quantidade) ) \(String(remedio.unidade) ) ").font(.headline).foregroundColor(.grumpy)
                    
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 5 ){
                
                HStack{
                    Text(remedio.nome).font(.headline).bold().foregroundColor(.grumpy)
                    /*Text("\(String(remedio.estoque) ) \(String(remedio.unidade) ) ").font(.headline)*/
                    
                    
                }
                Text(remedio.detalhe).font(.headline).foregroundColor(.gray)
            }
        }.padding(.horizontal,22).frame(minWidth: 350,minHeight: 110).overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.cutielight, lineWidth: 3)
        )
    }
}

// Lista de Alarmes
struct AlarmeList: View {
    @State var remedios: [Remedio] = carregarRemedios()
    
    var body: some View {
        Text("Informações do Remédio").bold().font(.title).foregroundColor(.gray)
        VStack {
            ForEach(remedios) { remedio in
                AlarmeCard(remedio: remedio)
                    .padding(.bottom, 5)
            }
        }.onAppear{
            remedios = carregarRemedios()
        }
    }
}

// Tela principal dos Alarmes
struct Alarmes: View {
    var body: some View {
        ScrollView {
            AlarmeList()
        }
        .padding(.top,40 )
        .padding()
    }
}

#Preview {
    Alarmes()
}

