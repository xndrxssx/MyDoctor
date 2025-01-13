//
//  RegistrarRemedio.swift
//  MyDoctor
//
//  Created by Turma01-3 on 08/10/24.
//

import SwiftUI
struct NovoRemedioView: View {
    @State private var nome: String = ""
    @State private var hora: String = ""
    @State private var detalhe: String = ""
    @State private var inicioTratamento: Date = Date()
    @State private var fimTratamento: Date = Date()
    @State private var unidade: String = "mg"
    @State private var quantidade: String = ""
    @State private var estoque: String = ""
   
  
    func adicionarRemedio() {
        guard let quantidadeDouble = Double(quantidade) else { return }
        guard let estoqueDouble = Double(estoque) else {return}
        let novoRemedio = Remedio(
            id: carregarRemedios().count,
            nome: nome,
            hora: hora,
            detalhe: detalhe,
            inicioTratamento: inicioTratamento,
            fimTratamento: fimTratamento,
            unidade: unidade,
            quantidade: quantidadeDouble,
            estoque: estoqueDouble
        )
        salvarRemedios(novoRemedio)
        
        nome = ""
        hora = ""
        detalhe = ""
        quantidade = ""
        estoque = ""
    }
    
    var body: some View {
       
        Form {
            Section(header: Text("Novo Remédio").bold().font(.title) ) {
                TextField("Nome", text: $nome)
                TextField("Hora (ex: 08:00)", text: $hora)
                TextField("Detalhe", text: $detalhe)
                DatePicker("Início do Tratamento", selection: $inicioTratamento, displayedComponents: .date)
                DatePicker("Fim do Tratamento", selection: $fimTratamento, displayedComponents: .date)
                Picker("Unidade", selection: $unidade) {
                    Text("mg").tag("mg")
                    Text("ml").tag("ml")
                    Text("cápsulas").tag("cápsulas")
                }
                TextField("Quantidade", text: $quantidade)
                    .keyboardType(.decimalPad)
                TextField("Em Estoque", text: $estoque)
                    .keyboardType(.decimalPad)
            }
            
            Section {
                Button(action: adicionarRemedio) {
                    Text("Adicionar Remédio")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .padding(.top,40)
        .navigationTitle("Novo Remédio")
    }
    

    
}


#Preview {
    NovoRemedioView()
}
