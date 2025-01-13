import Foundation

struct Remedio: Codable,Identifiable {
    var id: Int
    var nome: String
    var hora: String
    var detalhe: String
    var inicioTratamento: Date
    var fimTratamento: Date
    var unidade: String
    var quantidade: Double
    var estoque: Double
}



struct RemedioAPI: Codable, Identifiable {
    var id: Int
    var nome: String
    var hora: String
    var detalhe: String
    var inicioTratamento: Date
    var fimTratamento: Date
    var unidade: String
    var quantidade: Double
    var estoque: Double
    var _id: String
    var _rev: String
}

// URL base da API
let apiURL = "http://10.87.154.34:1880/remedios"

import Foundation

func sendIndexToEndpoint(index: Int) {
    // URL do endpoint
    guard let url = URL(string: "http://10.87.154.34:1880/ligarGaveta") else {
        print("URL inválida")
        return
    }
    
    // Criação do request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Corpo da requisição (JSON com o índice do remédio)
    let body: [String: [Int]] = ["gavetas": [index]]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        print("Erro ao converter o corpo da requisição para JSON: \(error)")
        return
    }
    
    // Enviar a requisição
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Erro ao enviar requisição: \(error)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                print("Índice enviado com sucesso")
            } else {
                print("Falha ao enviar o índice. Código de status: \(httpResponse.statusCode)")
            }
        }
    }
    
    task.resume() // Inicia a requisição
}

// Função para salvar remédios na API via POST
func salvarRemedios(_ remedio: Remedio) {
    // Configura o URL
    guard let url = URL(string: apiURL) else { return }
    
    // Cria a requisição
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Codifica o remédio em JSON
    guard let jsonData = try? JSONEncoder().encode(remedio) else { return }
    request.httpBody = jsonData
    
    // Envia a requisição
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Erro ao salvar remédio: \(error)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            print("Remédio salvo com sucesso.")
            NotificationManager.shared.scheduleNotification(for: remedio)
        } else {
            print("Erro ao salvar remédio. Status Code: \(String(describing: response))")
        }
    }
    task.resume() // Inicia a tarefa de rede
    
}
// Função para carregar remédios da API via GET
func carregarRemedios() -> [Remedio] {
    var remedios: [Remedio] = []
    
    // Configura o URL
    guard let url = URL(string: apiURL) else { return remedios }
    
    // Cria a requisição
    let request = URLRequest(url: url)
    
    // Cria a tarefa de rede
    let semaphore = DispatchSemaphore(value: 0) // Para esperar a resposta antes de retornar
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Erro ao carregar remédios: \(error)")
            semaphore.signal()
            return
        }
        
        if let data = data {
            if let remediosAPI = try? JSONDecoder().decode([Remedio].self, from: data) {
                remedios = remediosAPI
            } else {
                print("Erro ao decodificar dados da API.")
            }
        }
        semaphore.signal()
    }
    task.resume() // Inicia a tarefa de rede
    semaphore.wait() // Espera a resposta da requisição
    
    return remedios
}

// Função para criar datas de exemplo
func createDate(day: Int, month: Int, year: Int) -> Date? {
    var dateComponents = DateComponents()
    dateComponents.day = day
    dateComponents.month = month
    dateComponents.year = year
    return Calendar.current.date(from: dateComponents)
}

// Função para gerar ID único incremental
func gerarIdUnico(remedios: [Remedio]) -> Int {
    return (remedios.map { $0.id }.max() ?? 0) + 1
}



// Função para carregar os remédios da API via GET
func carregarRemedios(completion: @escaping ([RemedioAPI]) -> Void) {
    guard let url = URL(string: apiURL) else { return }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Erro ao carregar remédios: \(error)")
            return
        }
        
        if let data = data {
            if let remedios = try? JSONDecoder().decode([RemedioAPI].self, from: data) {
                DispatchQueue.main.async {
                    completion(remedios)
                }
            } else {
                print("Erro ao decodificar os dados.")
            }
        }
    }
    task.resume()
}


// Função para editar um remédio na API via PUT
func editarRemedio(_ remedio: RemedioAPI) {
    guard let url = URL(string: "\(apiURL)") else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    
    let remedioAtualizado: RemedioAPI = RemedioAPI(
        id: remedio.id,
        nome: remedio.nome,
        hora: remedio.hora,
        detalhe: remedio.detalhe,
        inicioTratamento: remedio.inicioTratamento,
        fimTratamento: remedio.fimTratamento,
        unidade: remedio.unidade,
        quantidade: remedio.quantidade,
        estoque: remedio.estoque,
        _id: remedio._id,
        _rev: remedio._rev
    )
    
    let json = try? JSONEncoder().encode(remedioAtualizado)
    request.httpBody = json
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Erro ao editar remédio: \(error)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            print("Remédio atualizado com sucesso.")
        } else {
            print("Erro ao atualizar remédio. Status Code: \(String(describing: response))")
        }
    }
    task.resume()
}


