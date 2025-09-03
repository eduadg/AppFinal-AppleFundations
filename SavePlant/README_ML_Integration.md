# Integração do Core ML no SavePlant

## Visão Geral
Esta implementação integra o modelo de machine learning `MLPlantSave.mlmodel` ao fluxo do ImagePicker para classificação automática de plantas e doenças.

## Arquivos Criados/Modificados

### 1. PlantDiseaseClassifier.swift (Novo)
- **Localização**: `Models/PlantDiseaseClassifier.swift`
- **Função**: Serviço singleton para classificação de imagens usando Vision + Core ML
- **Recursos**:
  - Classifica imagens de plantas usando o modelo treinado
  - Separa automaticamente planta e doença do resultado
  - Processa labels no formato "Planta___Doença" (ex: "Tomato___Early_blight")
  - Retorna confiança da predição

### 2. HospitalView.swift (Modificado)
- **Adições**:
  - Estados para controle da classificação (`isPredicting`, `lastConfidence`)
  - `onChange(of: selectedPhoto)` para detectar novas imagens
  - Integração automática com o formulário
  - Helper `tryMatchCommonDisease()` para casar doenças reconhecidas

### 3. PhotoSection (Modificado)
- **Adições**:
  - Indicador de progresso durante classificação
  - Mensagem de sucesso com nível de confiança
  - Parâmetros para controlar estados da UI

## Fluxo de Funcionamento

1. **Usuário seleciona/tira foto** → `ImagePicker` atualiza `selectedPhoto`
2. **onChange detecta mudança** → Inicia classificação automática
3. **PlantDiseaseClassifier processa imagem** → Retorna predição
4. **Formulário é preenchido automaticamente**:
   - Nome da planta (se vazio)
   - Doença (tenta casar com lista comum ou usa personalizada)
   - Observações (inclui confiança do modelo)
5. **UI mostra feedback visual**:
   - Progresso durante classificação
   - Confirmação com nível de confiança

## Como Usar

### Para Desenvolvedores
```swift
// Verificar se o classificador está disponível
guard let classifier = PlantDiseaseClassifier.shared else { return }

// Classificar uma imagem
classifier.classify(image) { prediction in
    guard let pred = prediction else { return }
    print("Planta: \(pred.plant)")
    print("Doença: \(pred.disease)")
    print("Confiança: \(pred.confidence)")
}
```

### Para Usuários
1. Abrir "Hospital" → "+" para nova análise
2. Selecionar ou tirar foto da planta
3. Aguardar classificação automática (progresso visual)
4. Ver campos preenchidos automaticamente
5. Ajustar se necessário e salvar

## Benefícios

- **Automatização**: Reduz tempo de preenchimento manual
- **Precisão**: Usa modelo treinado para identificação
- **UX**: Feedback visual claro durante processamento
- **Flexibilidade**: Permite edição manual após classificação
- **Integração**: Funciona com sistema existente de doenças comuns

## Requisitos Técnicos

- iOS 14.0+ (para Vision framework)
- Core ML framework
- Modelo `MLPlantSave.mlmodel` no bundle
- Permissões de câmera e galeria

## Estrutura do Modelo

O modelo espera labels no formato:
- **Entrada**: Imagem de planta
- **Saída**: Classificação no formato "Planta___Doença"
- **Exemplo**: "Tomato___Early_blight" → Planta: "Tomato", Doença: "Early blight"

## Tratamento de Erros

- Classificador retorna `nil` se falhar
- Estados de UI são resetados adequadamente
- Fallback para doenças personalizadas se não houver match
- Logs de confiança para transparência

## Próximos Passos Sugeridos

1. **Tratamentos padrão**: Preencher automaticamente baseado na doença reconhecida
2. **Cache de predições**: Evitar reclassificação de imagens idênticas
3. **Histórico de classificações**: Salvar predições para análise
4. **Feedback do usuário**: Permitir correção de classificações incorretas
5. **Otimização**: Batch processing para múltiplas imagens
