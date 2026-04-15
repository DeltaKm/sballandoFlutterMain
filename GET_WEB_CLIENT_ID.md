# 🔑 Come Ottenere il Web Client ID per Google Sign-In su Android

## Problema
L'`idToken` è `null` su Android perché manca il **Web Client ID** nella configurazione di `GoogleSignIn`.

---

## ✅ Soluzione: Ottieni il Web Client ID

### **Metodo 1: Da Firebase Console (RACCOMANDATO)**

1. Vai su **[Firebase Console](https://console.firebase.google.com)**
2. Seleziona il progetto: **sballando-df89d**
3. Menu laterale → **Authentication**
4. Tab **Sign-in method**
5. Trova **Google** e clicca sulla matita per modificare
6. Scorri giù fino a **Web SDK configuration**
7. Troverai:
   ```
   Web client ID: XXXXX-YYYYYY.apps.googleusercontent.com
   Web client secret: ZZZZZ
   ```
8. **Copia il Web client ID** (il primo)

---

### **Metodo 2: Da Google Cloud Console**

1. Vai su **[Google Cloud Console](https://console.cloud.google.com)**
2. Seleziona il progetto: **sballando-df89d** (Project ID: `8699556000`)
3. Menu → **APIs & Services** → **Credentials**
4. Cerca un **OAuth 2.0 Client ID** con tipo **Web application**
   - Potrebbe chiamarsi "Web client (auto created by Google Service)"
5. Copia il **Client ID** che termina con `.apps.googleusercontent.com`

---

### **Metodo 3: Crea un Nuovo Web Client (se non esiste)**

Se non trovi il Web Client:

1. Vai su **Google Cloud Console** → **APIs & Services** → **Credentials**
2. Clicca **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Application type: **Web application**
4. Name: `Web client (Sballando)`
5. Authorized JavaScript origins: (lascia vuoto per ora)
6. Authorized redirect URIs: (lascia vuoto per ora)
7. Clicca **CREATE**
8. Copia il **Client ID** generato

---

## 🔧 Aggiorna il Codice

Una volta ottenuto il Web Client ID, aggiornalo in:

**File:** `lib/components/sb_login_google.dart`

```dart
static const String _webClientId = 'IL_TUO_WEB_CLIENT_ID.apps.googleusercontent.com';
```

Sostituisci `'8699556000-cqmhdbvqsjvq293aq15bh7ians0tb4mb.apps.googleusercontent.com'` con il **vero Web Client ID**.

---

## 📱 Test

Dopo aver aggiornato:

```bash
flutter clean
flutter pub get
flutter run
```

Guarda i log:
```
=== TOKEN DEBUG ===
idToken presente: true  ← Deve essere TRUE
JWT segments: 3  ← Deve essere 3
accessToken presente: true
```

---

## ⚠️ NOTA IMPORTANTE

Il Client ID attualmente nel codice è quello di **iOS**:
```
8699556000-cqmhdbvqsjvq293aq15bh7ians0tb4mb.apps.googleusercontent.com
```

Questo NON funzionerà per Android! Devi ottenere il **Web Client ID** (tipo 3) che è diverso.

---

## 🎯 Verifica Finale

Dopo aver configurato tutto correttamente, vedrai nei log:

```
✅ Login Google riuscito per: user@example.com
=== TOKEN DEBUG ===
idToken presente: true
idToken length: 850+
idToken (primi 50 char): eyJhbGciOiJSUzI1NiIsImtpZCI6IjdlMDNkZWM2YzU1...
JWT segments: 3 (dovrebbe essere 3)
accessToken presente: true
accessToken length: 200+
==================
```

E il backend non darà più l'errore **"Wrong number of segments"**! 🎉
