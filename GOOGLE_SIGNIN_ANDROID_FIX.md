# 🔧 Fix Google Sign-In per Android

## Problema
Google Sign-In funziona su iOS ma non su Android. L'`idToken` risulta `null` solo su Android.

## Causa
Android richiede che i certificati SHA-1 e SHA-256 siano configurati nella Firebase Console.

---

## ✅ Soluzione - Segui questi passi:

### **1. Aggiungi i certificati SHA a Firebase Console**

#### Certificati da aggiungere:

**DEBUG (per test in sviluppo):**
- SHA-1: `05:C0:0B:4B:8F:2F:70:53:49:5A:42:FB:74:74:C5:EA:2C:0D:1F:E3`
- SHA-256: `84:D5:78:21:A8:7D:12:1D:08:BB:47:16:FA:9E:66:FF:AD:56:B8:64:75:EA:47:EA:C7:11:C1:9B:2F:8C:13:B2`

**RELEASE (per build di produzione):**
- SHA-1: `F0:2B:15:5D:33:04:72:53:92:B2:50:F0:31:92:34:02:BB:23:37:15`
- SHA-256: `ED:B0:16:84:2D:7D:12:33:9D:17:8D:8C:14:57:E3:CF:48:12:75:2B:D4:E3:0B:B0:F0:89:D0:55:C4:91:78:34`

#### Come aggiungerli:

1. Vai su **[Firebase Console](https://console.firebase.google.com)**
2. Seleziona il progetto **sballando-df89d**
3. Clicca sull'**icona ingranaggio** ⚙️ in alto a sinistra → **Project Settings**
4. Scorri fino alla sezione **Your apps**
5. Trova l'app Android: `it.sballando.app`
6. Clicca su **Add fingerprint**
7. Aggiungi **TUTTI E 4** i certificati (uno alla volta)
8. Clicca **Save** dopo ogni aggiunta

---

### **2. Scarica il nuovo google-services.json**

1. Nella stessa pagina, sotto i fingerprint
2. Clicca sul pulsante **Download google-services.json**
3. **Sostituisci** il file esistente in:
   ```
   android/app/google-services.json
   ```

---

### **3. Verifica OAuth 2.0 Client ID**

1. Vai su **[Google Cloud Console](https://console.cloud.google.com)**
2. Seleziona il progetto **sballando-df89d**
3. Menu → **APIs & Services** → **Credentials**
4. Verifica che ci sia un **OAuth 2.0 Client ID** di tipo:
   - **Android** (con il package name `it.sballando.app`)
   - **Web client** (per ottenere l'idToken)

Se non ci sono, **Firebase li crea automaticamente** quando aggiungi i fingerprint!

---

### **4. Pulisci e Ricompila l'App**

```bash
# Pulisci la build
cd android
./gradlew clean
cd ..

# Ricompila l'app
flutter clean
flutter pub get
flutter run
```

---

### **5. Test**

1. Disinstalla l'app dal dispositivo Android
2. Ricompila e installa da zero
3. Prova il login con Google
4. Controlla i log:
   ```
   flutter logs
   ```

Dovresti vedere:
```
=== Google Auth Debug ===
Email: user@example.com
ID Token null: false  ← Questo dovrebbe essere FALSE
Access Token null: false
```

---

## 🆘 Se il problema persiste:

### Opzione A: Aggiungi manualmente il Web Client ID

1. Vai su Firebase Console → Authentication → Sign-in method → Google
2. Copia il **Web client ID** sotto "Web SDK configuration"
3. Aggiorna il file `lib/components/sb_login_google.dart`:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: 'IL_TUO_WEB_CLIENT_ID.apps.googleusercontent.com',
);
```

### Opzione B: Verifica Package Name

Assicurati che il package name sia corretto:
- In `android/app/build.gradle.kts`: `namespace = "it.sballando.app"`
- In Firebase Console: deve essere `it.sballando.app`

---

## 📝 Note Importanti

- ⚠️ I cambiamenti a Firebase possono richiedere **fino a 5 minuti** per propagarsi
- ⚠️ Devi **disinstallare e reinstallare** l'app per applicare i nuovi certificati
- ✅ Su iOS funziona subito perché usa un sistema di autenticazione diverso
- ✅ Dopo questa configurazione funzionerà su entrambe le piattaforme

---

## ✅ Checklist Finale

- [ ] Tutti e 4 i certificati SHA aggiunti a Firebase
- [ ] Nuovo `google-services.json` scaricato e sostituito
- [ ] App pulita con `flutter clean`
- [ ] App disinstallata dal dispositivo
- [ ] App reinstallata da zero
- [ ] Test del login Google su Android
- [ ] Verifica log: `ID Token null: false`

---

**Fatto? Il Google Sign-In dovrebbe funzionare anche su Android! 🎉**
