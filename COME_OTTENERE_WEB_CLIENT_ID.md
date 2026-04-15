# 🔑 COME OTTENERE IL WEB CLIENT ID PER ANDROID

## ❓ Perché Android non ha l'idToken?

**RISPOSTA SEMPLICE:** 
Android ha bisogno del **Web Client ID** configurato nel codice per ottenere l'idToken da Google.
Senza questo, Google ti dà SOLO l'accessToken.

---

## 📋 GUIDA PASSO-PASSO

### **METODO 1: Firebase Console** (RACCOMANDATO) ⭐

#### Step 1️⃣: Apri Firebase Console
```
https://console.firebase.google.com
```
- Seleziona progetto: **sballando-df89d**

#### Step 2️⃣: Vai su Authentication
- Menu laterale → **Authentication**
- Tab in alto → **Sign-in method**

#### Step 3️⃣: Modifica Google
- Trova **Google** nella lista
- Clicca sull'**icona matita** (✏️) a destra

#### Step 4️⃣: Copia il Web Client ID
- Scorri fino a **"Web SDK configuration"**
- Vedrai:
  ```
  Web client ID: 8699556000-xxxxxxxxxxxxx.apps.googleusercontent.com
  Web client secret: xxxxxxxxx
  ```
- **COPIA** il **Web client ID** (prima riga)

---

### **METODO 2: Google Cloud Console** (Alternativo)

#### Step 1️⃣: Apri Google Cloud Console
```
https://console.cloud.google.com
```
- Seleziona progetto: **sballando-df89d**

#### Step 2️⃣: Vai su Credentials
- Menu (☰) → **APIs & Services** → **Credentials**

#### Step 3️⃣: Trova Web Client
- Sezione **OAuth 2.0 Client IDs**
- Cerca tipo: **Web application**
- Nome potrebbe essere: "Web client (auto created by Google Service)"

#### Step 4️⃣: Copia il Client ID
- Clicca sul nome del client
- Copia il **Client ID** che vedi in alto

---

## 🔧 DOVE INCOLLARE IL WEB CLIENT ID

### File da modificare:
```
lib/components/sb_login_google.dart
```

### Trova questa riga:
```dart
static const String _webClientId = 'IL_TUO_WEB_CLIENT_ID.apps.googleusercontent.com';
```

### Sostituisci con:
```dart
static const String _webClientId = '8699556000-xxxxxxxx.apps.googleusercontent.com';
```
(Usa il Web Client ID che hai copiato)

---

## ⚠️ ERRORI COMUNI

### Errore: `ApiException: 10` (DEVELOPER_ERROR)
**Causa:** Web Client ID sbagliato o non configurato correttamente

**Soluzione:**
1. Verifica che il Web Client ID sia quello corretto da Firebase
2. Assicurati di aver aggiunto gli SHA-1/SHA-256 a Firebase (già fatto ✅)
3. Disinstalla e reinstalla l'app dopo aver modificato il codice

### Errore: `idToken è ancora NULL`
**Causa:** Stai usando il client ID sbagliato (es. quello iOS o Android invece del Web)

**Soluzione:**
- Devi usare il **Web client** (tipo 3), NON il client Android (tipo 1) o iOS (tipo 2)
- Verifica nella Firebase Console che il Web Client ID sia quello della sezione "Web SDK configuration"

---

## ✅ COME VERIFICARE CHE FUNZIONA

Dopo aver aggiornato il codice:

```bash
flutter clean
flutter pub get
flutter run
```

Nei log dovresti vedere:

```
✅ Login Google riuscito per: user@example.com
=== TOKEN DEBUG ===
idToken: ✅ PRESENTE (850 char)    ← Deve essere PRESENTE!
accessToken: ✅ PRESENTE (253 char)
JWT segments: 3 (dovrebbe essere 3)  ← Deve essere 3!
```

Se vedi ancora `idToken: ❌ NULL`, il Web Client ID non è corretto!

---

## 🎯 CHECKLIST FINALE

- [ ] Ho ottenuto il Web Client ID da Firebase Console
- [ ] Ho verificato che sia quello della sezione "Web SDK configuration"
- [ ] Ho incollato il Web Client ID in `lib/components/sb_login_google.dart`
- [ ] Ho fatto `flutter clean && flutter pub get`
- [ ] Ho disinstallato l'app dal dispositivo
- [ ] Ho reinstallato l'app con `flutter run`
- [ ] Nei log vedo `idToken: ✅ PRESENTE`

---

## 📞 SE SERVE AIUTO

Se continua a non funzionare, manda questi dati:

1. Il Web Client ID che stai usando (primi e ultimi 10 caratteri)
2. I log completi dopo il login
3. Screenshot della pagina Firebase > Authentication > Google > Web SDK configuration

---

**NOTA IMPORTANTE:**
- ✅ Gli SHA-1/SHA-256 sono già configurati correttamente
- ✅ Il `google-services.json` è aggiornato  
- ❌ Manca SOLO il Web Client ID nel codice!

Una volta aggiunto, Android avrà l'idToken come iOS! 🚀
