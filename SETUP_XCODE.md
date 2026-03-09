# IPA API Server — Setup Xcode

Guia completo para criar o projeto Xcode e gerar o IPA.

## 📋 Pré-requisitos

- **macOS** 12.0 ou superior
- **Xcode** 13.0 ou superior
- **Apple Developer Account** (para certificados)
- **CocoaPods** (opcional, para gerenciar dependências)

## 🚀 Setup Inicial

### 1. Criar Projeto Xcode

```bash
# Abra Xcode e crie um novo projeto:
# File → New → Project → iOS → App

# Configurações:
# - Product Name: IPAAPIServer
# - Team ID: Seu Team ID da Apple
# - Organization Identifier: com.seuapp
# - Bundle Identifier: com.seuapp.ipaserver
# - Language: Swift
# - User Interface: Storyboard
```

### 2. Copiar Arquivos

Copie os arquivos fornecidos para o projeto Xcode:

```bash
cp AppDelegate.swift /path/to/Xcode/Project/
cp Info.plist /path/to/Xcode/Project/
cp Podfile /path/to/Xcode/Project/
```

### 3. Configurar WebView

No Xcode:
1. Abra `AppDelegate.swift`
2. Substitua o conteúdo pelo arquivo fornecido
3. Atualize a URL do servidor (linha ~35):
   ```swift
   let urlString = "http://seu-servidor.com" // ou localhost:3000
   ```

### 4. Configurar Info.plist

1. Abra `Info.plist` do projeto
2. Substitua pelo arquivo fornecido
3. Atualize se necessário:
   - `CFBundleIdentifier` → seu Bundle ID
   - `NSAppTransportSecurity` → URLs do seu servidor

### 5. Adicionar Dylib (Opcional)

Se quiser integrar a dylib Objective-C:

1. Compile a dylib:
```bash
clang -shared -fPIC IPAAPIServer.m -o IPAAPIServer.dylib \
  -framework UIKit -framework Foundation
```

2. No Xcode:
   - Arraste `IPAAPIServer.dylib` para o projeto
   - Marque "Copy items if needed"
   - Adicione ao target

3. Em Build Phases → Link Binary With Libraries:
   - Adicione `IPAAPIServer.dylib`

## 🔨 Build e Geração do IPA

### Opção 1: Via Xcode (Recomendado)

```bash
# 1. Abra o projeto no Xcode
open IPAAPIServer.xcodeproj

# 2. Selecione seu device ou simulator
# 3. Product → Archive
# 4. Clique em "Distribute App"
# 5. Escolha "Development" ou seu método de distribuição
# 6. Siga os passos para gerar o IPA
```

### Opção 2: Via Terminal

```bash
# Torne o script executável
chmod +x build-ipa.sh

# Execute o build
./build-ipa.sh
```

O IPA será gerado em `build/IPA/IPAAPIServer.ipa`

## ✍️ Assinando o IPA

### Com seu Certificado

```bash
# 1. Listar certificados disponíveis
security find-identity -v -p codesigning

# 2. Assinar o IPA
codesign -fs "CERTIFICATE_NAME" IPAAPIServer.ipa

# 3. Verificar assinatura
codesign -v IPAAPIServer.ipa
```

### Com Provisioning Profile

```bash
# 1. Extrair o IPA
unzip -q IPAAPIServer.ipa -d Payload

# 2. Copiar provisioning profile
cp YOUR_PROFILE.mobileprovision Payload/IPAAPIServer.app/embedded.mobileprovision

# 3. Assinar
codesign -fs "CERTIFICATE_NAME" \
  --entitlements entitlements.plist \
  Payload/IPAAPIServer.app

# 4. Recriar IPA
zip -qr IPAAPIServer-signed.ipa Payload/
```

## 📱 Instalando no iPhone

### Opção 1: Xcode

```bash
# 1. Conecte o iPhone
# 2. Abra o projeto no Xcode
# 3. Selecione seu device
# 4. Product → Run (ou Cmd+R)
```

### Opção 2: Apple Configurator 2

```bash
# 1. Abra Apple Configurator 2
# 2. Conecte o iPhone
# 3. Arraste o IPA para o device
```

### Opção 3: ios-deploy

```bash
# Instalar ios-deploy
npm install -g ios-deploy

# Instalar IPA
ios-deploy -b IPAAPIServer.ipa
```

### Opção 4: Altserver (Sem Certificado)

```bash
# Baixe AltServer: https://altstore.io/
# 1. Abra AltServer
# 2. Conecte o iPhone
# 3. Selecione "Install AltStore"
# 4. Depois use AltStore para instalar o IPA
```

## 🔧 Configurações Importantes

### Bundle Identifier

Deve ser único e corresponder ao seu provisioning profile:
```
com.seuapp.ipaserver
```

### Team ID

Encontre em:
1. Xcode → Preferences → Accounts
2. Selecione sua conta Apple
3. Clique em "Manage Certificates"

### Provisioning Profile

1. Vá para [developer.apple.com](https://developer.apple.com)
2. Certificates, Identifiers & Profiles
3. Crie um novo Provisioning Profile
4. Selecione seu Bundle ID
5. Baixe e instale no Xcode

## 🌐 Conectar ao Servidor

### Localhost (Desenvolvimento)

Para conectar ao servidor rodando em `localhost:3000`:

1. No `AppDelegate.swift`, atualize:
```swift
let urlString = "http://localhost:3000"
```

2. Configure seu Mac para aceitar conexões:
```bash
# No Mac, rode o servidor
cd /home/ubuntu/ipa-api-server
pnpm dev
```

3. No iPhone, use o IP do Mac:
```swift
let urlString = "http://192.168.1.100:3000" // IP do seu Mac
```

### Servidor Remoto

Se usar um servidor remoto:

```swift
let urlString = "https://seu-servidor.com"
```

Certifique-se de:
- Usar HTTPS (não HTTP)
- Ter certificado SSL válido
- Firewall permitir conexões

## 🐛 Troubleshooting

### Erro: "Code signing required"

```bash
# Selecione um team no Xcode
# Ou configure manualmente:
xcode-select --install
```

### Erro: "Provisioning profile not found"

```bash
# Sincronize perfis no Xcode
# Preferences → Accounts → Download Manual Profiles
```

### Erro: "App not installed"

- Verifique se o Bundle ID está correto
- Confirme que o certificado é válido
- Tente remover e reinstalar

### App não conecta ao servidor

- Verifique a URL em `AppDelegate.swift`
- Confirme que o servidor está rodando
- Verifique firewall/rede
- Veja logs em Safari DevTools (Develop → seu device)

## 📊 Estrutura do Projeto

```
IPAAPIServer/
├── AppDelegate.swift         # Entry point do app
├── SceneDelegate.swift       # Scene management
├── ViewController.swift       # Main view controller
├── Main.storyboard           # UI layout
├── LaunchScreen.storyboard   # Launch screen
├── Assets.xcassets           # Imagens e ícones
├── Info.plist                # Configurações do app
└── Podfile                   # Dependências (opcional)
```

## 📝 Próximos Passos

1. **Personalizar UI** — Adicione seu logo e cores
2. **Integrar Dylib** — Adicione a dylib Objective-C
3. **Testar** — Instale no iPhone e teste
4. **Deploy** — Publique na App Store (opcional)

## 📞 Suporte

Para dúvidas:
- Consulte [Apple Developer Documentation](https://developer.apple.com/documentation/)
- Veja [Xcode Help](https://help.apple.com/xcode/)
- Acesse [Stack Overflow](https://stackoverflow.com/questions/tagged/ios)

---

**Desenvolvido por:** Ruan Dev  
**Última atualização:** 09/03/2026
