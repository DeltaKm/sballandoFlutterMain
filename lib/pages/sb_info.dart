import 'package:flutter/material.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbInfo extends StatefulWidget {
  const SbInfo({super.key});

  @override
  State<SbInfo> createState() => SbInfoState();
}

class SbInfoState extends State<SbInfo> {
  TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allFaqList = [
    {
      'question': 'Cos’è Sballando?',
      'answer': 'Sballando è una piattaforma che rivoluziona la nightlife con strumenti per utenti, PR e locali.'
    },
    {
      'question': 'Come posso trovare un evento su Sballando?',
      'answer': 'Puoi cercare eventi per zona, data o genere musicale direttamente nell’app.'
    },
    {
      'question': 'Cosa posso prenotare con Sballando?',
      'answer': 'Puoi prenotare biglietti, tavoli e drink prepagati.'
    },
    {
      'question': 'Come accedo a un evento dopo l’acquisto?',
      'answer': 'Riceverai un QR Code digitale che ti permette di accedere all’evento.'
    },
    {
      'question': 'Cos’è la Lobby?',
      'answer': 'È una chat pubblica attiva durante l’evento, accessibile dopo l’ingresso, dove puoi parlare con altri partecipanti e inviare regali.'
    },
    {
      'question': 'Cos’è il sistema Fairplay?',
      'answer': 'È un sistema meritocratico che premia utenti, PR e locali in base alla loro attività e affidabilità.'
    },
    {
      'question': 'Come guadagno punti Fairplay?',
      'answer': 'Partecipando agli eventi come utente, lavorando bene come PR o gestendo eventi di qualità come locale.'
    },
    {
      'question': 'Cosa posso fare come PR su Sballando?',
      'answer': 'Gestire liste ospiti, inviare notifiche, trasferire biglietti, monitorare vendite e accumulare Fairplay.'
    },
    {
      'question': 'Chi può diventare PR su Sballando?',
      'answer': 'Chiunque voglia lavorare nella nightlife in modo serio e professionale.'
    },
    {
      'question': 'I locali devono essere verificati?',
      'answer': 'Sì, solo locali verificati possono usare Sballando, garantendo eventi sicuri e reali.'
    },
    {
      'question': 'Come funziona la sezione “locale verificato”?',
      'answer': 'Sballando verifica l’identità e la qualità degli eventi prima di abilitare un locale nella piattaforma.'
    },
    {
      'question': 'Cosa succede nella Lobby dell’evento?',
      'answer': 'Dopo il check-in con QR, puoi chattare con gli altri partecipanti, inviare drink o accedere a promozioni esclusive.'
    },
    {
      'question': 'Sballando è disponibile per tutti gli smartphone?',
      'answer': 'Sì, l’app è disponibile su App Store e Google Play.'
    },
    {
      'question': 'Un PR può monitorare le sue performance?',
      'answer': 'Sì, nella dashboard può vedere vendite, tavoli assegnati, ospiti confermati e guadagni Fairplay.'
    },
    {
      'question': 'Un locale può assegnare ruoli diversi ai collaboratori?',
      'answer': 'Sì, ogni PR o collaboratore può avere un ruolo specifico nell’organizzazione dell’evento.'
    },
    {
      'question': 'Posso creare eventi privati visibili solo su invito?',
      'answer': 'Sì, Sballando consente di creare eventi pubblici, su invito o con accesso riservato.'
    },
    {
      'question': 'Quali vantaggi ho come utente attivo?',
      'answer': 'Più Fairplay accumuli, più accedi a eventi esclusivi, promozioni e benefit speciali.'
    },
    {
      'question': 'Che tipo di notifiche posso ricevere come PR?',
      'answer': 'Ricevi aggiornamenti in tempo reale su vendite, conferme ospiti e gestione tavoli.'
    },
    {
      'question': 'Sballando è anche una community?',
      'answer': 'Sì, grazie alla Lobby e alle interazioni durante gli eventi, si crea una community viva e connessa.'
    },
    {
      'question': 'Quali metodi di pagamento sono disponibili sull’app?',
      'answer': 'Puoi pagare direttamente tramite app per biglietti, tavoli o prodotti, con metodi digitali sicuri.'
    },
    {
      'question': 'Posso usare Sballando in tutta Italia?',
      'answer': 'Sì, l’app funziona su tutto il territorio nazionale, ma gli eventi disponibili dipendono dalle città attive in piattaforma.'
    },
    {
      'question': 'Serve essere maggiorenni per usare Sballando?',
      'answer': 'Sì, l’accesso agli eventi è riservato a utenti maggiorenni, secondo le normative vigenti.'
    },
    {
      'question': 'Cosa significa “evento visibile solo su invito”?',
      'answer': 'Significa che solo chi riceve l’invito da un PR o dal locale può vedere e prenotare l’evento.'
    },
    {
      'question': 'Come posso invitare amici a un evento?',
      'answer': 'Puoi condividere il link dell’evento o creare un gruppo tavolo e invitare i tuoi amici direttamente dall’app.'
    },
    {
      'question': 'Cosa vedono gli altri utenti nella Lobby?',
      'answer': 'Solo messaggi pubblici degli utenti presenti all’evento, regali inviati e promozioni in corso.'
    },
    {
      'question': 'Come si fa a creare un evento come locale?',
      'answer': 'Accedi come gestore, vai nella dashboard e clicca su “Crea evento”, impostando data, orari, ingressi e offerte.'
    },
    {
      'question': 'I PR possono trasferire i biglietti ad altri?',
      'answer': 'Sì, i PR hanno la possibilità di trasferire biglietti, drink o tavoli a ospiti della loro lista.'
    },
    {
      'question': 'Sballando invia notifiche automatiche agli utenti?',
      'answer': 'Sì, per ricordare eventi imminenti, conferme e promozioni attive legate ai tuoi interessi.'
    },
    {
      'question': 'Cosa succede se il locale cancella un evento?',
      'answer': 'In caso di cancellazione, riceverai una notifica e un eventuale rimborso, secondo le condizioni dell’organizzatore.'
    },
    {
      'question': 'Devo stampare il biglietto per entrare?',
      'answer': 'No, basta mostrare il QR Code direttamente dal tuo wallet sull’app.'
    },
    {
      'question': 'Chi gestisce le classifiche PR?',
      'answer': 'Sballando calcola automaticamente la classifica in base all’attività e ai risultati ottenuti dai PR.'
    },
    {
      'question': 'Sballando organizza direttamente gli eventi?',
      'answer': 'No, l’app mette in contatto locali, PR e utenti, ma non organizza eventi direttamente.'
    },
    {
      'question': 'Come faccio a diventare partner di Sballando?',
      'answer': 'Scrivici attraverso il sito ufficiale o l’email info@sballando.it per avviare una collaborazione.'
    },
    {
      'question': 'Posso usare l’app anche senza registrarmi?',
      'answer': 'No, per prenotare, accedere alla Lobby o lavorare come PR è necessaria la registrazione.'
    },
    {
      'question': 'Posso usare l’app con un solo account per più ruoli?',
      'answer': 'Sì, puoi registrarti come utente e poi attivare il profilo PR o locale dallo stesso account.'
    },
    {
      'question': 'La app funziona anche all’estero?',
      'answer': 'Attualmente Sballando è attiva in Italia. In futuro potrebbero essere supportate nuove città e paesi.'
    },
    {
      'question': 'Cosa succede se non riesco a partecipare a un evento prenotato?',
      'answer': 'La gestione delle prenotazioni dipende dalle regole del singolo evento. Verifica sempre le condizioni prima di acquistare.'
    },
    {
      'question': 'Posso inviare un drink a un altro partecipante?',
      'answer': 'Sì, puoi acquistare drink nell’app e inviarli ad altri partecipanti durante l’evento attraverso la Lobby.'
    },
    {
      'question': 'Cosa trovo nella sezione “wallet” dell’app?',
      'answer': 'Troverai tutti i biglietti, tavoli e prodotti acquistati, pronti da mostrare all’ingresso.'
    },
    {
      'question': 'Posso usare Sballando anche se non sono un PR o un organizzatore?',
      'answer': 'Certo! Puoi usare Sballando come semplice utente per vivere al meglio gli eventi notturni.'
    },
    {
      'question': 'Sballando funziona anche per eventi privati?',
      'answer': 'Sì, puoi organizzare eventi privati visibili solo agli invitati selezionati.'
    },
    {
      'question': 'Come posso salire nella classifica PR?',
      'answer': 'Più ospiti porti, più attività gestisci e più vendite fai, più punti Fairplay ottieni e sali di livello.'
    },
    {
      'question': 'Un PR può collaborare con più locali contemporaneamente?',
      'answer': 'Sì, un PR può lavorare con diversi locali, gestendo eventi diversi anche in parallelo.'
    },
    {
      'question': 'È possibile inviare notifiche ai miei contatti?',
      'answer': 'Sì, come PR puoi inviare notifiche ai tuoi follower per informarli dei tuoi eventi.'
    },
    {
      'question': 'Quali strumenti ha un locale per controllare l’evento?',
      'answer': 'Dashboard eventi, gestione PR, tracciamento ingressi, vendite, tavoli e statistiche dettagliate.'
    },
    {
      'question': 'Cosa significa che un evento è “certificato da Sballando”?',
      'answer': 'Significa che è organizzato da un locale verificato che ha superato i controlli di qualità e sicurezza.'
    },
    {
      'question': 'Posso accedere alla Lobby prima dell’ingresso all’evento?',
      'answer': 'No, puoi accedere alla Lobby solo dopo che il tuo QR Code è stato validato all’ingresso.'
    },
    {
      'question': 'Sballando è adatto anche a piccoli locali?',
      'answer': 'Sì, anche locali più piccoli possono usare Sballando per organizzare eventi con più controllo e visibilità.'
    },
    {
      'question': 'Cosa devo fare per diventare un locale verificato?',
      'answer': 'Contattaci tramite il sito o app, invia i tuoi dati e verrai guidato nella procedura di verifica.'
    },
    {
      'question': 'Come posso aumentare la mia visibilità su Sballando?',
      'answer': 'Accumulando Fairplay, lavorando bene e collaborando a eventi di successo.'
    },
    {
      'question': 'I miei dati sono al sicuro su Sballando?',
      'answer': 'Sì, utilizziamo protocolli di sicurezza e accedono solo locali verificati e professionisti autorizzati.'
    },
    {
      'question': 'Sballando ha costi di iscrizione?',
      'answer': 'No, registrarsi come utente o PR è gratuito. I locali possono scegliere tra piani e servizi dedicati.'
    },
    {
      'question': 'Cosa succede se il mio QR Code non funziona all’ingresso?',
      'answer': 'Puoi contattare l’assistenza direttamente dall’app o mostrare la ricevuta dell’acquisto.'
    },
    {
      'question': 'Posso usare Sballando in tutta Italia?',
      'answer': 'Sì, l’app funziona su tutto il territorio nazionale, ma gli eventi disponibili dipendono dalle città attive in piattaforma.'
    },
    {
      'question': 'Serve essere maggiorenni per usare Sballando?',
      'answer': 'Sì, l’accesso agli eventi è riservato a utenti maggiorenni, secondo le normative vigenti.'
    },
    {
      'question': 'Cosa significa “evento visibile solo su invito”?',
      'answer': 'Significa che solo chi riceve l’invito da un PR o dal locale può vedere e prenotare l’evento.'
    },
    {
      'question': 'Come posso invitare amici a un evento?',
      'answer': 'Puoi condividere il link dell’evento o creare un gruppo tavolo e invitare i tuoi amici direttamente dall’app.'
    },
    {
      'question': 'Cosa vedono gli altri utenti nella Lobby?',
      'answer': 'Solo messaggi pubblici degli utenti presenti all’evento, regali inviati e promozioni in corso.'
    },
    {
      'question': 'Come si fa a creare un evento come locale?',
      'answer': 'Accedi come gestore, vai nella dashboard e clicca su “Crea evento”, impostando data, orari, ingressi e offerte.'
    },
    {
      'question': 'I PR possono trasferire i biglietti ad altri?',
      'answer': 'Sì, i PR hanno la possibilità di trasferire biglietti, drink o tavoli a ospiti della loro lista.'
    },
    {
      'question': 'Sballando invia notifiche automatiche agli utenti?',
      'answer': 'Sì, per ricordare eventi imminenti, conferme e promozioni attive legate ai tuoi interessi.'
    },
    {
      'question': 'Cosa succede se il locale cancella un evento?',
      'answer': 'In caso di cancellazione, riceverai una notifica e un eventuale rimborso, secondo le condizioni dell’organizzatore.'
    },
    {
      'question': 'Devo stampare il biglietto per entrare?',
      'answer': 'No, basta mostrare il QR Code direttamente dal tuo wallet sull’app.'
    },
    {
      'question': 'Chi gestisce le classifiche PR?',
      'answer': 'Sballando calcola automaticamente la classifica in base all’attività e ai risultati ottenuti dai PR.'
    },
    {
      'question': 'Sballando organizza direttamente gli eventi?',
      'answer': 'No, l’app mette in contatto locali, PR e utenti, ma non organizza eventi direttamente.'
    },
    {
      'question': 'Come faccio a diventare partner di Sballando?',
      'answer': 'Scrivici attraverso il sito ufficiale o l’email info@sballando.it per avviare una collaborazione.'
    },
    {
      'question': 'Posso usare l’app anche senza registrarmi?',
      'answer': 'No, per prenotare, accedere alla Lobby o lavorare come PR è necessaria la registrazione.'
    },
    {
      'question': 'Posso usare l’app con un solo account per più ruoli?',
      'answer': 'Sì, puoi registrarti come utente e poi attivare il profilo PR o locale dallo stesso account.'
    },
    {
      'question': 'La app funziona anche all’estero?',
      'answer': 'Attualmente Sballando è attiva in Italia. In futuro potrebbero essere supportate nuove città e paesi.'
    },
    {
      'question': 'Come funziona il sistema di invio regali durante l’evento?',
      'answer': 'Durante l’evento puoi selezionare un utente presente e inviargli un drink o prodotto, acquistabile direttamente in app.'
    },
    {
      'question': 'È possibile chattare con un PR o organizzatore prima dell’evento?',
      'answer': 'Attualmente la chat diretta non è disponibile, ma puoi ricevere notifiche dai PR e contattarli tramite social o link esterni.'
    },
    {
      'question': 'Posso salvare i miei eventi preferiti?',
      'answer': 'Sì, puoi aggiungere eventi alla tua lista preferiti per tenere traccia e ricevere notifiche.'
    },
    {
      'question': 'Come vengono scelti i PR per un evento?',
      'answer': 'I locali selezionano i PR in base alla loro affidabilità, visibilità e punteggio Fairplay.'
    },
    {
      'question': 'Cos’è il badge “Verified Club”?',
      'answer': 'È un’etichetta che identifica i locali verificati da Sballando per qualità, sicurezza e gestione professionale.'
    },
    {
      'question': 'Posso nascondere il mio profilo dalla Lobby?',
      'answer': 'No, nella Lobby sei visibile solo durante l’evento in corso e solo agli altri partecipanti presenti.'
    },
    {
      'question': 'Cosa succede se un PR non rispetta gli accordi?',
      'answer': 'I locali possono segnalarlo e, se confermato, il punteggio Fairplay verrà ridotto fino alla sospensione dell’account.'
    },
    {
      'question': 'È possibile ottenere visibilità come nuovo PR?',
      'answer': 'Sì, basta iniziare a collaborare e dimostrare affidabilità: la classifica è dinamica e meritocratica.'
    },
    {
      'question': 'Sballando funziona solo di notte?',
      'answer': 'No, anche se pensata per nightlife, può essere usata per qualsiasi evento con accesso controllato.'
    },
    {
      'question': 'Posso vedere le recensioni di un evento o locale?',
      'answer': 'Non sono presenti recensioni pubbliche, ma la qualità è garantita dal sistema di verifica e Fairplay.'
    },
    {
      'question': 'È possibile acquistare pacchetti con più ingressi?',
      'answer': 'Sì, i locali possono attivare offerte speciali e pacchetti multipli disponibili nella pagina evento.'
    },
    {
      'question': 'Cosa trovo nella mia dashboard personale?',
      'answer': 'Statistiche, Fairplay accumulato, storico eventi, biglietti acquistati, e stato delle collaborazioni.'
    },
    {
      'question': 'Chi può vedere i miei acquisti o attività?',
      'answer': 'Solo tu puoi visualizzare i tuoi dati. I PR vedono solo le informazioni utili per gestire la tua prenotazione.'
    },
    {
      'question': 'Come posso contattare l’assistenza Sballando?',
      'answer': 'Puoi scrivere a info@sballando.it oppure usare la sezione supporto in app.'
    },
    {
      'question': 'Sballando è adatta anche per eventi aziendali o privati?',
      'answer': 'Sì, l’app può essere usata anche per eventi aziendali, lanci privati o feste su invito.'
    },
    {
      'question': 'Quanto tempo prima posso prenotare un evento?',
      'answer': 'Dipende dal locale, ma solitamente gli eventi sono visibili anche con settimane di anticipo.'
    },
    {
      'question': 'Cosa succede se disinstallo l’app? Perdo i biglietti?',
      'answer': 'No, i tuoi acquisti sono associati al tuo account e li ritroverai appena accedi di nuovo.'
    },
    {
      'question': 'Sballando richiede l’accesso alla posizione GPS?',
      'answer': 'Solo se vuoi visualizzare eventi vicino a te. Puoi anche cercare manualmente per città.'
    },
    {
      'question': 'Cosa vuol dire “trasferire un ingresso”?',
      'answer': 'Significa cedere un biglietto o prodotto acquistato a un altro utente tramite app, utile per PR e locali.'
    },
    {
      'question': 'I biglietti hanno scadenza o validità limitata?',
      'answer': 'Sì, ogni biglietto è valido solo per l’evento e la data specifica acquistata.'
    },
    {
      'question': 'Cosa succede se mi presento con un QR già utilizzato?',
      'answer': 'Il sistema rileva automaticamente i QR duplicati: non sarà possibile entrare due volte con lo stesso codice.'
    },
    {
      'question': 'Posso gestire più eventi contemporaneamente come locale?',
      'answer': 'Sì, la dashboard permette la gestione multi-evento, con statistiche e collaboratori separati.'
    },
    {
      'question': 'Come faccio a sapere se un PR è affidabile?',
      'answer': 'Controlla il suo punteggio Fairplay: più è alto, più è attivo e professionale.'
    },
    {
      'question': 'Cosa fare se un utente invia messaggi molesti nella Lobby?',
      'answer': 'Puoi segnalarlo tramite app. I comportamenti scorretti portano alla sospensione dell’account.'
    },
    {
      'question': 'Posso visualizzare eventi in altre città o regioni?',
      'answer': 'Sì, puoi usare i filtri per cercare eventi in qualunque città disponibile in piattaforma.'
    },
    {
      'question': 'Quanto dura una chat nella Lobby?',
      'answer': 'La chat della Lobby è attiva solo durante l’evento e viene chiusa al termine.'
    },
    {
      'question': 'Cosa differenzia un evento “top” da uno normale?',
      'answer': 'Gli eventi “top” sono accessibili solo a utenti con punteggio Fairplay elevato o su invito.'
    },
    {
      'question': 'Ci sono limiti nel numero di PR che un locale può assegnare?',
      'answer': 'No, ogni locale può assegnare più PR e differenziarne i ruoli.'
    },
    {
      'question': 'I miei dati sono condivisi con altri utenti?',
      'answer': 'No, i tuoi dati personali non sono visibili agli altri utenti né condivisi senza consenso.'
    },
    {
      'question': 'Cosa succede se non rispetto il mix uomo/donna richiesto all’ingresso?',
      'answer': 'Potresti non essere ammesso se l’evento ha criteri di selezione attiva per il bilanciamento del pubblico.'
    },
    {
      'question': 'Un PR può lavorare senza essere assegnato a un evento?',
      'answer': 'No, deve essere selezionato da un locale per essere attivo sull’evento specifico.'
    },
    {
      'question': 'Che vantaggi ho ad acquistare un tavolo rispetto al biglietto standard?',
      'answer': 'Più spazio, servizio dedicato, bottiglie incluse e visibilità privilegiata all’interno dell’evento.'
    },
    {
      'question': 'Quali sono i requisiti per creare un profilo locale su Sballando?',
      'answer': 'Devi fornire i dati legali, accettare le condizioni di qualità e superare la verifica di identità e attività.'
    },
    {
      'question': 'Posso usare l’app anche se non vado agli eventi?',
      'answer': 'Sì, puoi seguirli, esplorarli, monitorare i PR o locali preferiti e rimanere aggiornato con le notifiche.'
    },
    {
      'question': 'I locali ricevono un report dopo ogni evento?',
      'answer': 'Sì, un report dettagliato su ingressi, vendite, performance dei collaboratori e guadagni stimati.'
    },
    {
      'question': 'Chi può vedere la classifica Fairplay?',
      'answer': 'È visibile pubblicamente per i PR; gli utenti possono solo vedere il proprio punteggio.'
    },
    {
      'question': 'Sballando funziona anche per eventi diurni?',
      'answer': 'Sì, anche se pensato per nightlife, è adatto anche a brunch, pool party, aperitivi e serate pomeridiane.'
    },
    {
      'question': 'Sballando funziona anche per eventi gratuiti?',
      'answer': 'Sì, è possibile creare eventi gratuiti con prenotazione tramite QR Code, per gestire l’accesso in modo ordinato.'
    },
    {
      'question': 'È possibile usare Sballando per eventi all’aperto?',
      'answer': 'Sì, l’app può essere utilizzata anche per beach party, eventi in piazza o altre location outdoor.'
    },
    {
      'question': 'Posso usare lo stesso QR Code per più eventi?',
      'answer': 'No, ogni QR Code è unico e valido solo per l’evento e la data specifica prenotata.'
    },
    {
      'question': 'I PR possono vedere i dati degli utenti in lista?',
      'answer': 'Vedono solo i dati essenziali per la gestione (nome, stato prenotazione), nel rispetto della privacy.'
    },
    {
      'question': 'È possibile rimuovere un PR da un evento?',
      'answer': 'Sì, il locale può revocare l’assegnazione in qualsiasi momento, in base al comportamento o alle performance.'
    },
    {
      'question': 'Cosa succede se cambio smartphone?',
      'answer': 'Accedendo con lo stesso account, troverai tutti i tuoi dati e acquisti sincronizzati.'
    },
    {
      'question': 'Sballando ha una funzione calendario?',
      'answer': 'Sì, puoi consultare i tuoi eventi futuri direttamente nella sezione dedicata del tuo profilo.'
    },
    {
      'question': 'Come viene calcolato il punteggio Fairplay?',
      'answer': 'È basato su attività reali: partecipazioni, ospiti confermati, puntualità, affidabilità e feedback ricevuti.'
    },
    {
      'question': 'Un locale può vedere in tempo reale chi è entrato?',
      'answer': 'Sì, ogni ingresso scannerizzato viene registrato in tempo reale nella dashboard del locale.'
    },
    {
      'question': 'Posso eliminare il mio account Sballando?',
      'answer': 'Sì, puoi richiederlo in app nella sezione impostazioni > gestione account, oppure scrivendo all’assistenza.'
    },
    {
      'question': 'Come vengono gestite le promozioni visibili solo nella Lobby?',
      'answer': 'Sono offerte esclusive visibili solo ai presenti e attivabili dal locale in tempo reale durante l’evento.'
    },
    {
      'question': 'Un PR può lavorare in eventi di città diverse?',
      'answer': 'Sì, può operare ovunque ci siano eventi attivi, anche in più città contemporaneamente.'
    },
    {
      'question': 'La prenotazione garantisce sempre l’ingresso?',
      'answer': 'L’ingresso è garantito salvo violazioni del regolamento o selezioni specifiche dell’evento (es. dress code, mix).'
    },
    {
      'question': 'I drink acquistati in app sono rimborsabili?',
      'answer': 'Dipende dal regolamento dell’evento. In genere non sono rimborsabili se non utilizzati.'
    },
    {
      'question': 'Sballando invia report anche al PR dopo l’evento?',
      'answer': 'Sì, il PR può consultare le sue performance tramite la dashboard personale.'
    },
    {
      'question': 'Qual è la differenza tra biglietto e ingresso su invito?',
      'answer': 'Il biglietto è acquistabile, l’ingresso su invito è gratuito ma riservato a utenti selezionati dal locale o PR.'
    },
    {
      'question': 'I PR possono inviare promemoria ai propri ospiti?',
      'answer': 'Sì, tramite notifiche automatiche o link condivisibili associati alla lista personale.'
    },
    {
      'question': 'Esiste una modalità dark nell’app?',
      'answer': 'Sì, è disponibile un tema scuro per migliorare l’esperienza notturna e risparmiare batteria.'
    },
    {
      'question': 'L’app può essere usata anche in modalità offline?',
      'answer': 'Puoi mostrare il QR offline, ma per prenotare o accedere alla Lobby serve una connessione internet.'
    },
    {
      'question': 'Posso collegare il mio profilo a Instagram o altri social?',
      'answer': 'Sì, puoi inserire il tuo handle social per farti trovare dagli altri o promuovere eventi.'
    }
  ];
  List<Map<String, String>> filteredFaqList = [];
  @override
  void initState() {
    super.initState();
    filteredFaqList = List.from(allFaqList);
  }

  void filterFaq(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFaqList = List.from(allFaqList);
      } else {
        filteredFaqList = allFaqList.where((faq) {
          final q = faq['question']!.toLowerCase();
          final a = faq['answer']!.toLowerCase();
          final input = query.toLowerCase();
          return q.contains(input) || a.contains(input);
        }).toList();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              style: TextStyle(
                color: textColor, // Cambia qui il colore del testo
                fontSize: 16,      // Puoi anche personalizzare il font
              ),
              controller: searchController,
              onChanged: (value) => filterFaq(value),
             
              decoration: InputDecoration(
                hintText: "Cerca",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(500),
                  borderSide: BorderSide(color: Colors.grey)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(500),
                  borderSide: BorderSide(color: mainColor, width: 2.0)
                ),              
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                   
                    setState(() {});
                  },
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SbButtonMaincolor(
                  fullWidth: true,
                   label: 'Vedi Intro',
                   function: () {
                     Navigator.pushNamed(context, '/onboarding');
                   },
                 ),
                 const SizedBox(height: 20),
                Text(
                  'FAQ',
                  style: TextStyle(
                    fontSize: textHight,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                ...filteredFaqList.map((faq) => ExpansionTile(
                  title: Text(
                    faq['question']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: textMid,
                      color: textColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Text(
                        faq['answer']!,
                        style: TextStyle(
                          fontSize: textMid,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
