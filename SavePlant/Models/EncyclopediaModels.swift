import Foundation
import UIKit

// MARK: - Encyclopedia Models

public enum PostCategory: String, CaseIterable {
    case curiosidades = "Curiosidades"
    case tratamentos = "Tratamentos"
    case identificacao = "Identificação"
    case cuidados = "Cuidados"
    case pragas = "Pragas & Doenças"
    case botanica = "Botânica"
    
    var iconName: String {
        switch self {
        case .curiosidades:
            return "lightbulb.fill"
        case .tratamentos:
            return "cross.case.fill"
        case .identificacao:
            return "magnifyingglass"
        case .cuidados:
            return "heart.fill"
        case .pragas:
            return "bug.fill"
        case .botanica:
            return "leaf.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .curiosidades:
            return UIColor.systemYellow
        case .tratamentos:
            return UIColor.systemRed
        case .identificacao:
            return UIColor.systemBlue
        case .cuidados:
            return UIColor.systemGreen
        case .pragas:
            return UIColor.systemOrange
        case .botanica:
            return UIColor.systemPurple
        }
    }
}

public struct EncyclopediaPost: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let summary: String
    public let content: String
    public let category: PostCategory
    public let author: String
    public let date: Date
    public let readTime: Int // em minutos
    public let tags: [String]
    public let relatedPlantNames: [String] // plantas relacionadas
    public let imageData: Data? // imagem do post
    public let likes: Int
    public let isUserGenerated: Bool // se foi criado pelo usuário
    
    public init(
        title: String,
        summary: String,
        content: String,
        category: PostCategory,
        author: String = "SavePlant",
        date: Date = Date(),
        readTime: Int,
        tags: [String] = [],
        relatedPlantNames: [String] = [],
        imageData: Data? = nil,
        likes: Int = 0,
        isUserGenerated: Bool = false
    ) {
        self.title = title
        self.summary = summary
        self.content = content
        self.category = category
        self.author = author
        self.date = date
        self.readTime = readTime
        self.tags = tags
        self.relatedPlantNames = relatedPlantNames
        self.imageData = imageData
        self.likes = likes
        self.isUserGenerated = isUserGenerated
    }
    
    public var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

// MARK: - Encyclopedia Data Manager
public class EncyclopediaDataManager: ObservableObject {
    @Published public var posts: [EncyclopediaPost] = []
    @Published public var featuredPosts: [EncyclopediaPost] = []
    
    public static let shared = EncyclopediaDataManager()
    
    private init() {
        loadDefaultPosts()
    }
    
    public func addPost(_ post: EncyclopediaPost) {
        posts.insert(post, at: 0) // Adiciona no início
        updateFeaturedPosts()
    }
    
    public func likePost(_ post: EncyclopediaPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = posts[index]
            // Note: Como EncyclopediaPost é struct, precisaríamos de uma abordagem diferente
            // Por agora, vamos manter o likes como está
        }
    }
    
    public func getPostsByCategory(_ category: PostCategory) -> [EncyclopediaPost] {
        return posts.filter { $0.category == category }
    }
    
    public func getPostsRelatedToPlant(_ plantName: String) -> [EncyclopediaPost] {
        return posts.filter { post in
            post.relatedPlantNames.contains { relatedPlant in
                plantName.lowercased().contains(relatedPlant.lowercased()) ||
                relatedPlant.lowercased().contains(plantName.lowercased())
            }
        }
    }
    
    public func searchPosts(_ query: String) -> [EncyclopediaPost] {
        let lowercasedQuery = query.lowercased()
        return posts.filter { post in
            post.title.lowercased().contains(lowercasedQuery) ||
            post.summary.lowercased().contains(lowercasedQuery) ||
            post.tags.contains { $0.lowercased().contains(lowercasedQuery) } ||
            post.relatedPlantNames.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    private func updateFeaturedPosts() {
        // Seleciona os posts mais recentes e populares
        featuredPosts = Array(posts.sorted { first, second in
            if first.likes != second.likes {
                return first.likes > second.likes
            }
            return first.date > second.date
        }.prefix(5))
    }
    
    private func loadDefaultPosts() {
        posts = [
            // Curiosidades
            EncyclopediaPost(
                title: "Por que as plantas ficam amarelas?",
                summary: "Descubra as principais causas do amarelamento das folhas e como identificar cada uma delas.",
                content: """
                O amarelamento das folhas, conhecido cientificamente como clorose, é um dos problemas mais comuns que os jardineiros enfrentam. Existem várias causas possíveis:

                ## Principais Causas

                ### 1. Deficiência Nutricional
                - **Nitrogênio**: Amarelamento começando pelas folhas mais velhas
                - **Ferro**: Amarelamento entre as nervuras (clorose férrica)
                - **Magnésio**: Amarelamento nas bordas das folhas

                ### 2. Problemas de Irrigação
                - **Excesso de água**: Raízes apodrecem e não absorvem nutrientes
                - **Falta de água**: Planta entra em estresse hídrico

                ### 3. Doenças
                - Fungos podem causar amarelamento específico
                - Vírus frequentemente causam padrões de amarelamento

                ### 4. Fatores Ambientais
                - Mudanças bruscas de temperatura
                - Excesso ou falta de luz solar
                - pH do solo inadequado

                ## Como Diagnosticar

                1. **Observe o padrão**: folhas velhas ou novas primeiro?
                2. **Verifique o solo**: muito seco ou encharcado?
                3. **Analise a localização**: todas as plantas ou apenas uma?
                4. **Considere mudanças recentes**: fertilização, transplante, etc.

                ## Tratamento

                - Ajuste a irrigação conforme necessário
                - Aplique fertilizante balanceado se for deficiência nutricional
                - Melhore a drenagem se o solo estiver encharcado
                - Trate doenças específicas se identificadas

                Lembre-se: o amarelamento natural das folhas mais velhas é normal!
                """,
                category: .curiosidades,
                readTime: 5,
                tags: ["amarelamento", "clorose", "nutrição", "diagnóstico"],
                relatedPlantNames: ["tomate", "rosa", "citrus", "batata"]
            ),
            
            EncyclopediaPost(
                title: "A incrível comunicação entre plantas",
                summary: "As plantas podem se comunicar entre si através de sinais químicos. Conheça este fascinante mundo vegetal.",
                content: """
                Você sabia que as plantas podem "conversar" entre si? A comunicação vegetal é um campo fascinante da botânica que revela como as plantas interagem de maneiras surpreendentes.

                ## Tipos de Comunicação

                ### 1. Sinais Químicos Aéreos
                Quando atacadas por pragas, muitas plantas liberam compostos voláteis que:
                - Alertam plantas vizinhas sobre o perigo
                - Atraem predadores naturais das pragas
                - Ativam defesas em plantas próximas

                ### 2. Comunicação Subterrânea
                Através das raízes e fungos simbióticos:
                - **Rede Micorrízica**: fungos conectam raízes de diferentes plantas
                - **Troca de Nutrientes**: plantas podem compartilhar recursos
                - **Sinais de Alerta**: informações sobre estresse ou doenças

                ### 3. Alelopatia
                Algumas plantas liberam substâncias que:
                - Inibem o crescimento de competidores
                - Facilitam o crescimento de plantas benéficas
                - Modificam o ambiente ao seu redor

                ## Exemplos Fascinantes

                ### Acácias Africanas
                Quando girafas começam a comer suas folhas, as acácias:
                1. Aumentam a produção de taninos (tóxicos)
                2. Liberam etileno no ar
                3. Alertam outras acácias num raio de 50 metros

                ### Tomates e Pragas
                Tomateiros atacados por lagartas liberam compostos que:
                - Atraem vespas parasitas
                - Alertam tomateiros vizinhos
                - Ativam genes de defesa

                ### Florestas Conectadas
                Em uma floresta, árvores mães podem:
                - Nutrir mudas através da rede micorrízica
                - Compartilhar carbono com árvores doentes
                - Coordenar respostas a mudanças sazonais

                ## Aplicações Práticas

                ### No Jardim
                - **Plantas Companheiras**: algumas combinações se beneficiam mutuamente
                - **Controle Natural**: usar a comunicação para controle de pragas
                - **Biodiversidade**: plantar variedade de espécies fortalece a rede

                ### Na Agricultura
                - **Rotação de Culturas**: aproveitar efeitos alelopáticos positivos
                - **Consórcios**: combinar plantas que se comunicam beneficamente
                - **Manejo Integrado**: usar sinais naturais no controle de pragas

                A natureza é muito mais interconectada do que imaginamos!
                """,
                category: .curiosidades,
                readTime: 8,
                tags: ["comunicação", "alelopatia", "micorrizas", "defesa"],
                relatedPlantNames: ["tomate", "acácia", "todas"]
            ),
            
            // Tratamentos
            EncyclopediaPost(
                title: "Guia Completo: Tratamento do Míldio",
                summary: "Aprenda a identificar, tratar e prevenir o míldio, uma das doenças fúngicas mais comuns em plantas.",
                content: """
                O míldio é uma doença fúngica devastadora que afeta muitas plantas cultivadas. Com o conhecimento correto, é possível prevenir e tratar eficazmente.

                ## Identificação do Míldio

                ### Sintomas Visuais
                - **Manchas amarelas** nas folhas superiores
                - **Crescimento branco/cinza** na parte inferior das folhas
                - **Necrose progressiva** das áreas afetadas
                - **Queda prematura** das folhas

                ### Condições Favoráveis
                - **Alta umidade** (>85%)
                - **Temperaturas moderadas** (15-25°C)
                - **Pouca ventilação**
                - **Molhamento foliar** frequente

                ## Tratamento

                ### 1. Métodos Culturais
                **Imediatos:**
                - Remover folhas infectadas imediatamente
                - Melhorar ventilação entre plantas
                - Evitar irrigação nas folhas
                - Reduzir umidade ambiente

                **Preventivos:**
                - Espaçamento adequado entre plantas
                - Poda para melhor circulação de ar
                - Irrigação por gotejamento
                - Mulching para evitar respingos

                ### 2. Tratamentos Orgânicos
                **Bicarbonato de Sódio:**
                - 1 colher de sopa por litro de água
                - Aplicar semanalmente
                - Adicionar algumas gotas de detergente neutro

                **Óleo de Neem:**
                - Seguir instruções do fabricante
                - Aplicar no final da tarde
                - Repetir a cada 7-10 dias

                **Extrato de Alho:**
                - 100g de alho em 1L de água
                - Deixar em infusão por 24h
                - Coar e aplicar diluído (1:3)

                ### 3. Fungicidas Químicos
                **Preventivos:**
                - Cobre (calda bordalesa)
                - Mancozebe
                - Clorotalonil

                **Curativos:**
                - Metalaxil
                - Fosetil-Al
                - Dimetomorfe

                ⚠️ **Importante:** Alternar princípios ativos para evitar resistência

                ## Prevenção

                ### Escolha de Variedades
                - Optar por cultivares resistentes
                - Diversificar plantios
                - Evitar monoculturas

                ### Manejo Ambiental
                - **Irrigação:** pela manhã, na base da planta
                - **Ventilação:** garantir circulação de ar
                - **Limpeza:** remover restos vegetais
                - **Rotação:** não plantar suscetíveis no mesmo local

                ### Monitoramento
                - Inspeção semanal das plantas
                - Atenção a mudanças climáticas
                - Uso de armadilhas para esporos
                - Registro de ocorrências

                ## Plantas Mais Suscetíveis
                - Tomate, batata, pimentão
                - Pepino, abobrinha, melão
                - Rosa, petúnia, impatiens
                - Alface, espinafre, rúcula

                A prevenção sempre é o melhor remédio!
                """,
                category: .tratamentos,
                readTime: 10,
                tags: ["míldio", "fungos", "tratamento", "prevenção"],
                relatedPlantNames: ["tomate", "batata", "pepino", "rosa"]
            ),
            
            // Identificação
            EncyclopediaPost(
                title: "Como Identificar Deficiências Nutricionais",
                summary: "Aprenda a ler os sinais que suas plantas dão quando precisam de nutrientes específicos.",
                content: """
                As plantas são excelentes comunicadoras - elas nos mostram exatamente o que precisam através de suas folhas. Aprender a "ler" esses sinais é fundamental para manter plantas saudáveis.

                ## Macronutrientes

                ### Nitrogênio (N)
                **Sintomas:**
                - Amarelamento começando pelas folhas mais velhas
                - Crescimento lento e plantas menores
                - Folhas podem ficar completamente amarelas e cair

                **Tratamento:**
                - Fertilizante rico em nitrogênio
                - Esterco curtido
                - Ureia (com cuidado na dosagem)

                ### Fósforo (P)
                **Sintomas:**
                - Folhas com tons roxos ou avermelhados
                - Crescimento atrofiado
                - Floração e frutificação pobres
                - Sintomas começam pelas folhas velhas

                **Tratamento:**
                - Superfosfato simples
                - Farinha de osso
                - Fertilizantes com alto P

                ### Potássio (K)
                **Sintomas:**
                - Bordas das folhas amareladas ou queimadas
                - Folhas mais velhas afetadas primeiro
                - Plantas mais suscetíveis a doenças
                - Frutos de qualidade inferior

                **Tratamento:**
                - Cloreto de potássio
                - Cinza de madeira (com moderação)
                - Fertilizantes ricos em K

                ## Micronutrientes

                ### Ferro (Fe)
                **Sintomas:**
                - Clorose internerval (amarelo entre as nervuras)
                - Folhas novas afetadas primeiro
                - Nervuras permanecem verdes

                **Tratamento:**
                - Quelato de ferro
                - Sulfato de ferro
                - Corrigir pH do solo (6,0-6,5)

                ### Magnésio (Mg)
                **Sintomas:**
                - Amarelamento entre nervuras (folhas velhas primeiro)
                - Nervuras permanecem verdes
                - Pode progredir para necrose

                **Tratamento:**
                - Sulfato de magnésio (sal de Epsom)
                - Calcário dolomítico
                - Fertilizantes com Mg

                ### Cálcio (Ca)
                **Sintomas:**
                - Pontas e bordas das folhas queimadas
                - Folhas novas deformadas
                - Podridão apical em frutos (tomate, pimentão)

                **Tratamento:**
                - Calcário
                - Gesso agrícola
                - Cloreto de cálcio (foliar)

                ### Zinco (Zn)
                **Sintomas:**
                - Folhas pequenas e estreitas
                - Internódios curtos
                - Crescimento em roseta

                **Tratamento:**
                - Sulfato de zinco
                - Quelato de zinco
                - Fertilizantes com micronutrientes

                ## Diagnóstico Diferencial

                ### Como Distinguir
                1. **Observe qual parte da planta é afetada primeiro**
                   - Folhas velhas: N, P, K, Mg
                   - Folhas novas: Fe, Ca, Zn, B

                2. **Analise o padrão dos sintomas**
                   - Amarelamento uniforme: N
                   - Entre nervuras: Fe ou Mg
                   - Bordas queimadas: K ou Ca

                3. **Considere o contexto**
                   - Tipo de solo
                   - pH
                   - Irrigação
                   - Fertilizações anteriores

                ## Prevenção

                ### Análise de Solo
                - Fazer análise a cada 2-3 anos
                - Corrigir pH conforme necessário
                - Adicionar matéria orgânica regularmente

                ### Fertilização Balanceada
                - Usar fertilizantes NPK equilibrados
                - Incluir micronutrientes
                - Fracionar aplicações

                ### Cuidados Gerais
                - Manter boa drenagem
                - Irrigar adequadamente
                - Monitorar plantas regularmente

                Lembre-se: o excesso também pode ser prejudicial!
                """,
                category: .identificacao,
                readTime: 12,
                tags: ["nutrição", "deficiência", "diagnóstico", "fertilização"],
                relatedPlantNames: ["tomate", "rosa", "citrus", "batata", "todas"]
            ),
            
            // Cuidados
            EncyclopediaPost(
                title: "Irrigação Inteligente: Quando e Como Regar",
                summary: "Domine a arte da irrigação e mantenha suas plantas sempre saudáveis e bem hidratadas.",
                content: """
                A irrigação é uma das práticas mais importantes e, ao mesmo tempo, mais mal compreendidas no cuidado de plantas. Aprender a regar corretamente pode ser a diferença entre plantas prósperas e plantas doentes.

                ## Princípios Básicos

                ### Quando Regar
                **Teste do Dedo:**
                - Enfie o dedo 2-3cm no solo
                - Se estiver seco, está na hora de regar
                - Para plantas suculentas, espere secar completamente

                **Sinais Visuais:**
                - Solo com rachaduras
                - Folhas murchas (mas cuidado com o excesso!)
                - Vaso mais leve
                - Superfície do solo seca

                **Horários Ideais:**
                - **Manhã cedo** (6h-8h): melhor horário
                - **Final da tarde** (após 17h): segunda opção
                - **Evitar meio-dia**: evaporação excessiva
                - **Evitar noite**: favorece doenças

                ### Quantidade de Água
                **Regra Geral:**
                - Regar até a água sair pelos furos de drenagem
                - Para vasos: 10-15% do volume do vaso
                - Para jardim: molhar até 15-20cm de profundidade

                ## Métodos de Irrigação

                ### 1. Irrigação Manual
                **Regador com Crivo:**
                - Água distribuída uniformemente
                - Controle da quantidade
                - Ideal para plantas pequenas

                **Mangueira com Esguicho:**
                - Rapidez para áreas grandes
                - Ajustar pressão (jato suave)
                - Cuidado para não compactar o solo

                ### 2. Irrigação por Gotejamento
                **Vantagens:**
                - Economia de água
                - Irrigação constante
                - Evita molhar folhas
                - Automatização possível

                **Instalação:**
                - Fita gotejadora ou gotejadores
                - Timer para automatizar
                - Filtros para evitar entupimentos

                ### 3. Microaspersão
                **Ideal para:**
                - Canteiros de hortaliças
                - Jardins de flores
                - Áreas com plantas variadas

                ### 4. Irrigação Subterrânea
                **Garrafas PET:**
                - Furar tampinha com agulha
                - Enterrar no solo próximo às raízes
                - Ideal para plantas grandes

                ## Necessidades Específicas

                ### Por Tipo de Planta
                **Suculentas:**
                - Regar apenas quando solo seco
                - Água abundante, mas espaçada
                - Drenagem excelente obrigatória

                **Tropicais:**
                - Solo sempre úmido (não encharcado)
                - Borrifar folhas para umidade
                - Atenção à umidade do ar

                **Hortaliças:**
                - Irrigação regular e constante
                - Evitar estresse hídrico
                - Mulching para conservar umidade

                **Árvores Frutíferas:**
                - Irrigação profunda e menos frequente
                - Foco na zona das raízes
                - Ajustar conforme estação

                ### Por Estação
                **Verão:**
                - Irrigação mais frequente
                - Preferencialmente pela manhã
                - Mulching para conservar água

                **Inverno:**
                - Reduzir frequência
                - Cuidado com excesso
                - Monitorar plantas dormentes

                ## Qualidade da Água

                ### Água Ideal
                - **pH entre 6,0-7,0**
                - **Baixa salinidade**
                - **Livre de cloro excessivo**
                - **Temperatura ambiente**

                ### Tratamento Caseiro
                - Deixar água da torneira descansar 24h (elimina cloro)
                - Filtrar se muito calcária
                - Água da chuva é excelente (se limpa)

                ## Problemas Comuns

                ### Irrigação Excessiva
                **Sintomas:**
                - Folhas amarelas
                - Fungos no solo
                - Raízes podres
                - Crescimento lento

                **Solução:**
                - Parar irrigação temporariamente
                - Melhorar drenagem
                - Remover partes afetadas

                ### Irrigação Insuficiente
                **Sintomas:**
                - Folhas murchas
                - Solo rachado
                - Crescimento atrofiado
                - Queda de folhas

                **Solução:**
                - Aumentar frequência gradualmente
                - Irrigação profunda
                - Mulching

                ## Sistemas de Automação

                ### Timer Simples
                - Programar horários fixos
                - Ajustar conforme estação
                - Monitorar funcionamento

                ### Sensores de Umidade
                - Irrigação baseada na necessidade real
                - Economia de água
                - Maior precisão

                ### Sistemas Inteligentes
                - Conectados à internet
                - Consideram clima local
                - Ajustes remotos

                ## Dicas Práticas

                1. **Mulching:** reduz evaporação em até 70%
                2. **Drenagem:** sempre obrigatória em vasos
                3. **Observação:** cada planta tem suas necessidades
                4. **Flexibilidade:** ajustar conforme clima
                5. **Paciência:** plantas se adaptam gradualmente

                Lembre-se: é melhor irrigar menos vezes e mais profundamente!
                """,
                category: .cuidados,
                readTime: 15,
                tags: ["irrigação", "água", "rega", "cuidados", "automação"],
                relatedPlantNames: ["todas", "suculentas", "hortaliças", "frutíferas"]
            ),
            
            // Pragas
            EncyclopediaPost(
                title: "Pulgões: Identificação e Controle Natural",
                summary: "Aprenda a identificar e combater pulgões usando métodos naturais e eficazes.",
                content: """
                Os pulgões estão entre as pragas mais comuns em jardins e hortas. Pequenos mas numerosos, podem causar grandes danos se não controlados adequadamente.

                ## Identificação

                ### Características dos Pulgões
                - **Tamanho:** 1-4mm
                - **Cores:** verde, preto, cinza, vermelho, branco
                - **Formato:** corpo mole, em formato de pera
                - **Localização:** brotações novas, folhas tenras

                ### Sintomas do Ataque
                - **Folhas enroladas** ou deformadas
                - **Crescimento atrofiado** dos brotos
                - **Melada** (substância açucarada) nas folhas
                - **Fumagina** (fungo preto) sobre a melada
                - **Presença de formigas** (que "pastoreiam" pulgões)

                ## Ciclo de Vida

                ### Reprodução
                - **Partenogênese:** fêmeas geram cópias sem machos
                - **Rapidez:** nova geração a cada 10-15 dias
                - **Prolificidade:** até 80 descendentes por fêmea
                - **Formas aladas:** surgem para colonizar novas plantas

                ### Condições Favoráveis
                - **Temperaturas amenas** (18-25°C)
                - **Baixa umidade relativa**
                - **Plantas com excesso de nitrogênio**
                - **Ausência de predadores naturais**

                ## Controle Natural

                ### 1. Controle Biológico
                **Predadores Naturais:**
                - **Joaninhas:** adultos e larvas comem pulgões
                - **Crisopídeos:** larvas são vorazes
                - **Sirfídeos:** larvas se alimentam de pulgões
                - **Pássaros:** alguns comedores de insetos

                **Como Atrair:**
                - Plantar flores como cosmos, girassol, funcho
                - Evitar inseticidas químicos
                - Manter diversidade de plantas
                - Criar abrigos para insetos benéficos

                ### 2. Preparados Caseiros
                **Sabão de Coco:**
                - 20g de sabão em barra em 1L de água
                - Dissolver bem e aplicar com borrifador
                - Aplicar de manhã cedo ou final da tarde

                **Óleo de Neem:**
                - Seguir instruções do fabricante
                - Aplicar quinzenalmente
                - Evitar horários de sol forte

                **Extrato de Fumo:**
                - 50g de fumo de corda em 1L de água
                - Deixar de molho por 24h
                - Coar e diluir 1:1 antes de aplicar

                **Calda de Alho e Cebola:**
                - 100g de alho + 100g de cebola
                - Bater no liquidificador com 1L de água
                - Coar e aplicar puro

                ### 3. Métodos Físicos
                **Jato de Água:**
                - Borrifar água com pressão
                - Fazer pela manhã
                - Repetir diariamente até controle

                **Remoção Manual:**
                - Para infestações pequenas
                - Usar luvas
                - Esfregar folhas suavemente

                **Armadilhas Amarelas:**
                - Atraem pulgões alados
                - Colocar próximo às plantas
                - Monitorar população

                ## Prevenção

                ### Práticas Culturais
                **Adubação Equilibrada:**
                - Evitar excesso de nitrogênio
                - Usar fertilizantes balanceados
                - Preferir adubação orgânica

                **Plantas Companheiras:**
                - **Repelentes:** manjericão, hortelã, alecrim
                - **Atrativas:** capuchinha, mostarda (plantas-isca)
                - **Diversificação:** evitar monoculturas

                **Manejo do Ambiente:**
                - Eliminar plantas daninhas hospedeiras
                - Manter boa ventilação
                - Evitar irrigação nas folhas

                ### Monitoramento
                - **Inspeção semanal** das plantas
                - **Atenção especial** a brotações novas
                - **Verificar presença** de formigas
                - **Observar** insetos benéficos

                ## Plantas Mais Atacadas
                - **Hortaliças:** pimentão, berinjela, couve
                - **Ornamentais:** rosa, hibisco, primavera
                - **Frutíferas:** citros, macieira, pessegueiro
                - **Aromáticas:** manjericão, salsa, cebolinha

                ## Receitas Especiais

                ### Spray Multiuso Anti-Pulgão
                **Ingredientes:**
                - 1L de água
                - 1 colher de sopa de sabão líquido neutro
                - 1 colher de chá de óleo vegetal
                - 1 dente de alho batido

                **Modo de Preparo:**
                1. Misturar todos os ingredientes
                2. Coar bem
                3. Aplicar com borrifador
                4. Usar imediatamente

                ### Calda Repelente Concentrada
                **Ingredientes:**
                - 200g de alho
                - 100g de cebola
                - 50g de pimenta malagueta
                - 1L de água

                **Modo de Preparo:**
                1. Bater tudo no liquidificador
                2. Deixar descansar 24h
                3. Coar bem
                4. Diluir 1:10 para aplicar

                ## Cuidados Importantes
                - Testar preparados em pequena área primeiro
                - Aplicar preferencialmente no final da tarde
                - Não aplicar em plantas floridas (proteger abelhas)
                - Repetir aplicações conforme necessário
                - Observar se não há fitotoxicidade

                A persistência e a combinação de métodos são as chaves do sucesso!
                """,
                category: .pragas,
                readTime: 12,
                tags: ["pulgões", "pragas", "controle biológico", "receitas caseiras"],
                relatedPlantNames: ["rosa", "pimentão", "citros", "manjericão", "couve"]
            )
        ]
        
        updateFeaturedPosts()
    }
}
