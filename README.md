# IPA API Server — iOS App

App iOS que roda o dashboard web do IPA API Server.

## 📱 Sobre

Este é um wrapper iOS que permite acessar o dashboard web da plataforma IPA API Server diretamente do seu iPhone.

**Funcionalidades:**
- ✅ Dashboard web completo
- ✅ Gerenciar keys, packages, UDIDs
- ✅ Integração com dylib Objective-C
- ✅ Dark theme técnico
- ✅ Suporte offline com cache

## 🚀 Quick Start

### No Mac (Local)

```bash
# 1. Clonar repositório
git clone https://github.com/seu-usuario/ipa-api-server-ios.git
cd ipa-api-server-ios

# 2. Abrir no Xcode
open ipa-app-xcode/

# 3. Configurar:
# - Selecione seu team
# - Atualize Bundle ID
# - Selecione seu device

# 4. Build & Run
# Product → Run (Cmd+R)
```

### Via GitHub Actions (Automático)

1. Push para `main` ou `develop`
2. GitHub Actions faz o build automaticamente
3. Baixe o IPA em "Actions" → "Artifacts"

## 📋 Pré-requisitos

- **macOS** 12.0+
- **Xcode** 13.0+
- **iOS** 13.0+ (no device)
- **Apple Developer Account** (para assinar)

## 🔧 Configuração

### 1. Bundle ID

Atualize em `Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.seuapp.ipaserver</string>
```

### 2. Servidor

Atualize em `AppDelegate.swift`:
```swift
let urlString = "http://seu-servidor.com"
```

### 3. Certificado

No Xcode:
1. Selecione o projeto
2. Signing & Capabilities
3. Selecione seu team

## 🔨 Build

### Xcode

```bash
# Archive
Product → Archive

# Export
Click "Distribute App" → Development
```

### Terminal

```bash
chmod +x build-ipa.sh
./build-ipa.sh
```

### GitHub Actions

```bash
# Push para trigger o build
git push origin main

# Baixe em Actions → Artifacts
```

## ✍️ Assinar IPA

Veja `SIGN_AND_INSTALL.md` para instruções completas.

```bash
# Simples
codesign -fs "Seu Certificado" Payload/IPAAPIServer.app
zip -qr IPAAPIServer-signed.ipa Payload/
```

## 📱 Instalar no iPhone

### Opção 1: Xcode
```bash
Product → Run
```

### Opção 2: Apple Configurator 2
Arraste o IPA para o device

### Opção 3: ios-deploy
```bash
ios-deploy -b IPAAPIServer-signed.ipa
```

## 📚 Documentação

- `SETUP_XCODE.md` — Setup completo
- `SIGN_AND_INSTALL.md` — Assinatura e instalação
- `.github/workflows/build-ipa.yml` — GitHub Actions

## 🐛 Troubleshooting

### App não conecta ao servidor
- Verifique URL em `AppDelegate.swift`
- Confirme que o servidor está rodando
- Verifique firewall/rede

### Erro ao assinar
- Verifique certificado em Keychain
- Confirme provisioning profile
- Veja `SIGN_AND_INSTALL.md`

### Build falha no GitHub Actions
- Verifique logs em "Actions"
- Confirme que o projeto está correto
- Veja `build.log` e `export.log`

## 📊 Estrutura

```
ipa-app-xcode/
├── AppDelegate.swift          # Entry point
├── Info.plist                 # Configurações
├── Podfile                    # Dependências
├── build-ipa.sh              # Script de build
├── .github/workflows/        # GitHub Actions
│   └── build-ipa.yml
├── SETUP_XCODE.md            # Guia de setup
├── SIGN_AND_INSTALL.md       # Guia de assinatura
└── README.md                 # Este arquivo
```

## 🔐 Segurança

**NUNCA commite:**
- Certificados (`.p12`, `.cer`)
- Chaves privadas (`.key`)
- Provisioning profiles (`.mobileprovision`)

Use GitHub Secrets para dados sensíveis.

## 📝 Licença

MIT

## 📞 Suporte

Para dúvidas:
- Veja a documentação incluída
- Consulte [Apple Developer Docs](https://developer.apple.com/documentation/)
- Abra uma issue no GitHub

---

**Desenvolvido por:** Ruan Dev  
**Última atualização:** 09/03/2026
