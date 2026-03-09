# Assinando e Instalando o IPA

Guia passo a passo para assinar o IPA com seu certificado e instalar no iPhone.

## 📋 Pré-requisitos

- IPA gerado (não assinado)
- Certificado da Apple (`.p12` ou `.cer`)
- Provisioning Profile (`.mobileprovision`)
- iPhone conectado ao Mac

## 🔐 Passo 1: Importar Certificado

### Se você tem um arquivo `.p12`:

```bash
# Importar para Keychain
security import seu_certificado.p12 -k ~/Library/Keychains/login.keychain-db

# Você será pedido para digitar a senha
```

### Se você tem `.cer` + `.key`:

```bash
# Converter para .p12
openssl pkcs12 -export -in seu_certificado.cer -inkey sua_chave.key \
  -out seu_certificado.p12 -name "CERTIFICATE_NAME"

# Depois importar
security import seu_certificado.p12 -k ~/Library/Keychains/login.keychain-db
```

## 📋 Passo 2: Verificar Certificados Disponíveis

```bash
# Listar todos os certificados
security find-identity -v -p codesigning

# Saída esperada:
# 1) ABC123DEF456... "iPhone Developer: seu@email.com (XXXXXXXXXX)"
# 2) XYZ789UVW012... "iPhone Distribution: Sua Empresa (YYYYYYYYYY)"
```

Copie o nome exato do certificado (entre aspas).

## 📋 Passo 3: Instalar Provisioning Profile

```bash
# Copiar para a pasta correta
cp seu_profile.mobileprovision \
  ~/Library/MobileDevice/Provisioning\ Profiles/

# Xcode sincronizará automaticamente
```

## ✍️ Passo 4: Assinar o IPA

### Método 1: Simples (Recomendado)

```bash
# Descompactar IPA
unzip -q IPAAPIServer.ipa -d Payload

# Copiar provisioning profile
cp seu_profile.mobileprovision \
  Payload/IPAAPIServer.app/embedded.mobileprovision

# Assinar o app
codesign -fs "iPhone Developer: seu@email.com (XXXXXXXXXX)" \
  Payload/IPAAPIServer.app

# Recriar IPA
zip -qr IPAAPIServer-signed.ipa Payload/
rm -rf Payload
```

### Método 2: Com Entitlements

```bash
# Extrair entitlements do provisioning profile
security cms -D -i seu_profile.mobileprovision > profile.plist
plutil -extract Entitlements xml1 -o entitlements.plist profile.plist

# Descompactar IPA
unzip -q IPAAPIServer.ipa -d Payload

# Copiar provisioning profile
cp seu_profile.mobileprovision \
  Payload/IPAAPIServer.app/embedded.mobileprovision

# Assinar com entitlements
codesign -fs "iPhone Developer: seu@email.com (XXXXXXXXXX)" \
  --entitlements entitlements.plist \
  Payload/IPAAPIServer.app

# Recriar IPA
zip -qr IPAAPIServer-signed.ipa Payload/
rm -rf Payload entitlements.plist profile.plist
```

### Método 3: Automático (Script)

```bash
#!/bin/bash

# sign-ipa.sh

IPA_FILE="IPAAPIServer.ipa"
CERTIFICATE="iPhone Developer: seu@email.com (XXXXXXXXXX)"
PROVISIONING_PROFILE="seu_profile.mobileprovision"

echo "🔐 Assinando IPA..."

# Descompactar
unzip -q "$IPA_FILE" -d Payload

# Copiar provisioning profile
cp "$PROVISIONING_PROFILE" Payload/IPAAPIServer.app/embedded.mobileprovision

# Assinar
codesign -fs "$CERTIFICATE" Payload/IPAAPIServer.app

# Recriar IPA
zip -qr "${IPA_FILE%.ipa}-signed.ipa" Payload/

# Limpar
rm -rf Payload

echo "✅ IPA assinado com sucesso!"
echo "📍 Arquivo: ${IPA_FILE%.ipa}-signed.ipa"
```

## ✅ Passo 5: Verificar Assinatura

```bash
# Verificar se o IPA foi assinado corretamente
codesign -v IPAAPIServer-signed.ipa

# Saída esperada:
# IPAAPIServer-signed.ipa: valid on disk
```

## 📱 Passo 6: Instalar no iPhone

### Opção 1: Xcode (Mais Fácil)

```bash
# 1. Conecte o iPhone
# 2. Abra o projeto no Xcode
# 3. Product → Run (Cmd+R)
```

### Opção 2: Apple Configurator 2

```bash
# 1. Abra Apple Configurator 2
# 2. Conecte o iPhone
# 3. Arraste o IPA para o device
# 4. Clique em "Install"
```

### Opção 3: ios-deploy

```bash
# Instalar ios-deploy
npm install -g ios-deploy

# Instalar IPA
ios-deploy -b IPAAPIServer-signed.ipa
```

### Opção 4: ideviceinstaller

```bash
# Instalar ideviceinstaller (macOS)
brew install libimobiledevice

# Instalar IPA
ideviceinstaller -i IPAAPIServer-signed.ipa
```

### Opção 5: Altstore (Sem Certificado)

Se você não quer usar certificado:

```bash
# 1. Baixe AltServer: https://altstore.io/
# 2. Instale AltStore no iPhone
# 3. Use AltStore para instalar o IPA
```

## 🔍 Verificar Instalação

```bash
# Listar apps instalados
ideviceinstaller -l

# Saída esperada:
# - com.seuapp.ipaserver - IPA API Server

# Abrir app no iPhone
open "itms-apps:///?action=openApp&bundleId=com.seuapp.ipaserver"
```

## 🐛 Troubleshooting

### Erro: "Certificate not found"

```bash
# Verificar certificados novamente
security find-identity -v -p codesigning

# Se não aparecer, reimportar:
security import seu_certificado.p12 -k ~/Library/Keychains/login.keychain-db
```

### Erro: "Invalid provisioning profile"

```bash
# Verificar se o perfil está correto
codesign -d --entitlements - Payload/IPAAPIServer.app

# Reinstalar o provisioning profile
rm ~/Library/MobileDevice/Provisioning\ Profiles/*
cp seu_profile.mobileprovision \
  ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Erro: "App not installed"

Possíveis causas:
- Certificado expirado
- Provisioning profile inválido
- Bundle ID não corresponde
- Device não confiável

Solução:
```bash
# Confiar no device
# No iPhone: Settings → General → Device Management → Trust

# Tentar reinstalar
ios-deploy -b IPAAPIServer-signed.ipa --uninstall
ios-deploy -b IPAAPIServer-signed.ipa
```

### Erro: "Code signing failed"

```bash
# Limpar cache de assinatura
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Tentar novamente
codesign -fs "CERTIFICATE_NAME" Payload/IPAAPIServer.app
```

## 📊 Checklist

- [ ] Certificado importado no Keychain
- [ ] Provisioning profile instalado
- [ ] IPA descompactado
- [ ] Provisioning profile copiado
- [ ] App assinado com certificado
- [ ] IPA recompactado
- [ ] Assinatura verificada
- [ ] iPhone conectado
- [ ] IPA instalado com sucesso
- [ ] App abre no iPhone

## 📞 Suporte

Para problemas:
1. Verifique [Apple Developer Support](https://developer.apple.com/support/)
2. Consulte [Stack Overflow](https://stackoverflow.com/questions/tagged/ios)
3. Veja logs do Xcode: Window → Devices and Simulators

---

**Desenvolvido por:** Ruan Dev  
**Última atualização:** 09/03/2026
