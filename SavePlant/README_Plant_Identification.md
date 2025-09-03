# Identificação Automática de Plantas - SavePlant

## Funcionalidade Implementada

O projeto SavePlant agora inclui uma funcionalidade de identificação automática de plantas usando a API do Plant.id. Quando o usuário seleciona uma foto de uma planta na seção Hospital, o sistema automaticamente:

1. **Identifica a espécie da planta** usando IA
2. **Preenche automaticamente** o nome da planta
3. **Adiciona informações científicas** às observações
4. **Continua analisando** doenças (se o classificador ML estiver disponível)

## Como Funciona

### 1. Seleção de Foto
- O usuário acessa a seção Hospital
- Clica em "Adicionar Nova Planta"
- Seleciona uma foto da planta

### 2. Identificação Automática
- A foto é enviada para a API do Plant.id
- O sistema recebe informações detalhadas sobre a planta:
  - Nome comum da planta
  - Nome científico
  - Família botânica
  - Nomes comuns alternativos
  - Nível de confiança da identificação

### 3. Preenchimento Automático
- O nome da planta é preenchido automaticamente
- As informações científicas são adicionadas às observações
- O usuário pode revisar e editar as informações antes de salvar

## Configuração da API

### Chave da API

⚠️ **IMPORTANTE**: A funcionalidade atualmente usa dados simulados para demonstração.

Para ativar a API real do Plant.id:

1. **Obtenha uma chave válida** em https://plant.id/
2. **Substitua a chave** no arquivo `PlantIdentificationService.swift`
3. **Descomente** o código da API real
4. **Comente** o código de simulação

Chave atual (pode estar inválida):
```
bEKhd6HBXL7o18HVtUmjeHKk2THUCVaD5QUbQnIP5TmMcPtard
```

### Endpoint
- **URL**: `https://api.plant.id/v2/identify`
- **Método**: POST
- **Formato**: multipart/form-data
- **Parâmetros**:
  - `images`: arquivo de imagem da planta
  - `organs`: "leaf" (foco em folhas)
  - `include_related_images`: "true"
  - `lang`: "pt" (português)

## Arquivos Modificados

### 1. `Models/PlantIdentificationService.swift` (NOVO)
- Serviço para comunicação com a API do Plant.id
- Modelos de dados para resposta da API
- Tratamento de erros
- Extrator de informações da planta

### 2. `Views/HospitalView.swift`
- Integração com o serviço de identificação
- Estados para controle da identificação
- Interface atualizada para mostrar progresso
- Preenchimento automático de campos

## Estrutura de Dados

### PlantIdentificationResult
```swift
public struct PlantIdentificationResult: Codable {
    let result: PlantResult
    let status: String
    let message: String
}
```

### PlantInfo
```swift
public struct PlantInfo {
    let name: String
    let scientificName: String?
    let family: String?
    let commonNames: [String]
    let confidence: Double
}
```

## Fluxo de Usuário

1. **Entrada**: Usuário seleciona foto da planta
2. **Processamento**: Sistema identifica a planta via API
3. **Resultado**: Campos são preenchidos automaticamente
4. **Revisão**: Usuário pode editar informações
5. **Salvamento**: Dados são salvos no sistema

## Tratamento de Erros

- **Imagem inválida**: Verificação de formato e qualidade
- **Erro de rede**: Tratamento de falhas de conexão
- **Erro da API**: Mensagens de erro amigáveis
- **Timeout**: Tratamento de requisições lentas

## Benefícios

- **Automatização**: Reduz necessidade de digitação manual
- **Precisão**: Identificação baseada em IA especializada
- **Informações científicas**: Dados botânicos precisos
- **Experiência do usuário**: Interface mais fluida e intuitiva
- **Eficiência**: Processo mais rápido para adicionar plantas

## Limitações

- **Dependência de internet**: Requer conexão ativa
- **Qualidade da imagem**: Melhores resultados com fotos claras
- **Taxa de API**: Limitações da API gratuita do Plant.id
- **Idioma**: Respostas em português quando disponível

## Próximos Passos

1. **Cache local**: Armazenar identificações para uso offline
2. **Histórico**: Manter histórico de identificações
3. **Melhorias de UI**: Indicadores visuais mais sofisticados
4. **Validação**: Verificação adicional de resultados
5. **Backup**: Sistema de fallback para falhas de API

## Suporte

Para dúvidas ou problemas com a funcionalidade de identificação de plantas, consulte a documentação da API do Plant.id ou entre em contato com a equipe de desenvolvimento.
