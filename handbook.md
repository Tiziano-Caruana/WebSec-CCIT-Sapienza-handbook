# Introduzione

Questa guida è dedicata ai partecipanti di CyberChallenge.IT e, una volta ampliata e approfondita, ai membri dei TRX e appassionati in generale. Questa risorsa mira a offrire una panoramica sull'esfiltrazione di dati nella web exploitation.

Mentre esistono già numerosi libri e risorse online sull'argomento, questa guida mira a fornire una versione italiana chiara e accessibile, adatta alle esigenze specifiche dei partecipanti a CyberChallenge e membri TRX.

È importante sottolineare che questa guida riflette esclusivamente le mie conoscenze e opinioni personali. Non ho esperienze dirette nell'ambito della sicurezza informatica e non mi assumo responsabilità per l'utilizzo improprio delle informazioni qui fornite al di fuori del contesto di CyberChallenge.IT e più in generale del mondo delle CTF.

I lettori sono invitati a saltare i capitoli o le sezioni che ritengono già familiari o non rilevanti per le loro esigenze.


# Capitolo 0
## Internet
Nel World Wide Web ogni risorsa viene identificata univocamente da un [URL](https://it.wikipedia.org/wiki/Uniform_Resource_Locator) (Uniform Resource Locator).

Per risorsa intendiamo un qualsiasi insieme di dati o informazioni che abbiano senso. Immagini, paragrafi testuali, video, audio, pagine web, risultati dell'elaborazione di un programma sono tutti esempi di risorsa. Wikipedia definisce le "risorse sul Web" come "tutte le fonti di informazioni e servizi disponibili in Rete, identificate dall'URL e fisicamente presenti e accessibili su web server tramite web browser dell'host client."

Se questa definizione non è chiara, sarà utile fare un ripasso del [modello client-server](https://it.wikipedia.org/wiki/Sistema_client/server)

Illustrazione formale:

![URL formale](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/URI_syntax_diagram.svg/1920px-URI_syntax_diagram.svg.png)

Esempio pratico:

![URL pratico](/img/capitolo0/URL_esempio.png)

*Nota: la porta di default - quindi il valore valido se non specificato - è l'80, il fragment è di default l'inizio pagina. Le query string, o parametri, sono generalmente facoltativi. Le userinfo, ovvero username e password, non mostrati nell'esempio, sono tipici di protocolli diversi da quelli che vediamo usualmente nel browser, come [FTP](https://it.wikipedia.org/wiki/File_Transfer_Protocol)*

### [URL-encoding](https://developer.mozilla.org/en-US/docs/Glossary/Percent-encoding)
Per evitare che nell'URL siano presenti caratteri riservati che potrebbero portare ad un'interpretazione indesiderata da parte del browser, viene usato l'URL encoding, ufficialmente percent-encoding. Se usati per un attacco è quindi utile ricordarsi di codificare gli URL in modo che nessuna parte  del ["vettore d'attacco"](https://www.akamai.com/it/glossary/what-is-attack-vector#:~:text=sfruttamento%20di%20API%20e%20applicazioni%20web)/payload che abbiamo preparato vada persa.

Prima dell'URL-encoding:

![URL pre-encoding](/img/capitolo0/PreEncoding.png)

Dopo l'URL-encoding (cosa riceve il server):

![URL post-encoding](/img/capitolo0/PostEncoding.png)

Da notare come solo il testo che può essere direttamente controllato dall'utente venga URL-encodato.

Ciò che viene fatto è una conversione dal carattere riservato alla sua rappresentazione ASCII esadecimale preceduta da un %.

### [HTTP](https://it.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
l'HyperText Transfer Protocol, HTTP, è un protocollo stateless, ovvero ogni richiesta è indipendente dalle richieste precedenti. Le due fasi previste sono l'HTTP request (il client fa una richiesta al server) e l'HTTP response (il server risponde).

In generale, ogni volta che il client ha bisogno di richiedere una risorsa al server, comunica utilizzando HTTP. 
Questo significa che per ogni risorsa che vorrai visualizzare, il tuo dispositivo dovrà effettuare un'HTTP request, e ricevere dal server un'HTTP response. 

Esempio di HTTP request:

![HTTP request](/img/capitolo0/HTTPrequest.png)

Esempio di HTTP response:

![HTTP response](/img/capitolo0/HTTPresponse.png)

In caso fosse necessario uno scambio di informazioni al di fuori del contesto degli header e delle query, queste possono essere incluse nel corpo del messaggio (body message). Nell'esempio di richiesta mostrato, apparirebbero "sotto" agli header. La struttura del body message varia a seconda della tecnologia utilizzata dallo specifico sito, ed è comunque facilmente individuabile durante l'esperienza pratica.


#### [Metodi HTTP comuni](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods):
- **GET** (ottieni la risorsa o informazioni su di essa)
- **POST** (azione/invia dati alla risorsa)
- **HEAD** (GET senza body message)
- **TRACE** (diagnostica)
- **OPTIONS** (visualizza metodi disponibili)
- **PUT** (crea nuova risorsa)
- **DELETE** (elimina risorsa specificata)
- **CONNECT** (crea un [tunnel](https://it.wikipedia.org/wiki/Protocollo_di_tunneling) in caso di [proxy](https://it.wikipedia.org/wiki/Proxy))
- **PATCH** (modifica la risorsa)

#### [Header HTTP comuni](https://blog.postman.com/what-are-http-headers/):
##### Request
- **Accept**: Definisce i [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types) che il client accetterà dal server, in ordine di preferenza. Ad esempio, `Accept: application/json, text/html` indica che il client preferisce ricevere risposte in [JSON](https://it.wikipedia.org/wiki/JavaScript_Object_Notation), ma le accetta anche in [HTML](https://it.wikipedia.org/wiki/HTML).
- **User-Agent**: Identifica il browser e/o il client che sta effettuando la richiesta.
- **Authorization**: Usato per l'invio di credenziali, utile quando si prova ad accedere ad una risorsa protetta.
- **Cookie**: Usato per inviare al server cookie precedentemente memorizzati. Utile per personalizzare l'esperienza dell'utente e "combattere" i limiti della natura stateless del protocollo HTTP.
- **Content-Type**: Definisce il MIME type del contenuto del request body.

##### Response
- **Content-Type**: Come sopra.
- **Server**: La controparte di `User-Agent`.
- **Set-Cookie**: Comunica al client che esso dovrebbe memorizzare un cookie con un certo nome, valore, e facoltativamente scadenza, dominio, percorso e flag di sicurezza. Esempio: `Set-Cookie: score=127`. Una volta che `Set-Cookie` viene ricevuto ed accettato, il client invierà al server il cookie ad ogni richiesta eseguita.
- **Content-Length**: Specifica la grandezza in byte del response body. In caso "apparisse" dal lato del richiedente, dobbiamo fare attenzione a specificare la lunghezza giusta in caso volessimo modificare i nostri payload.

Negli esempi mostrati precedentemente potete vedere come questi header vengono utilizzati in una comunicazione reale tra un web browser e un sito web statico.

Generalmente, quando un header inizia per `X-`, è custom.
È utile notare come il funzionamento di HTTP sia solo una convenzione, ed il server può decidere di implementare qualsiasi metodo e qualsiasi header (custom headers e methods). Questi elementi sono di nostro interesse, essendo implementati direttamente dal gestore del sito e quindi più facilmente soggetti ad errori di implementazione. Inoltre, nulla impedisce al programmatore di usare una GET per modificare dati, o una POST per fornire informazioni, nonostante questo sia ovviamente sconsigliato. Lo stesso vale per gli elementi mostrati successivamente in questo capitolo.

#### [Status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status):
- **1xx**: Risposte informative
- **2xx**: Successo
- **3xx**: Reindirizzamento
- **4xx**: Errore del client (tipicamente richieste sbagliate)
- **5xx**: Errore del server (errori di un programma ed eccezioni non gestite)

#### *Riassumendo*:

Possiamo pensare all'HTTP request come a una lettera che spediamo tramite posta. Nella riga della richiesta, noi come mittenti specifichiamo cosa vogliamo sia fatto e dove vogliamo sia fatto, come scrivessimo l'indirizzo e il tipo di servizio desiderato su una busta. Gli header della richiesta contengono informazioni su di noi e le nostre preferenze, simili a scrivere il nostro nome e il nostro indirizzo sul retro della busta. Se chi offre il servizio ha bisogno di un materiale o di un oggetto da utilizzare per soddisfare la nostra richiesta, possiamo includerlo nel body message, proprio come inviare un pacco insieme alla busta.

Il server, simile al destinatario della nostra lettera, riceve la richiesta, cerca di soddisfarla e ci invia una lettera di risposta. Nella riga dello stato della risposta, capiamo se tutto è andato bene o se c'è stato un problema, proprio come leggere l'indicazione di consegna sulla nostra busta postale. Negli header della risposta, otteniamo informazioni su chi ha eseguito il lavoro e come vorrebbe che ci comportassimo con il risultato. Infine, nel body message della risposta, riceviamo il prodotto richiesto, come se insieme alla busta ci venisse spedito un pacco contenente ciò che avevamo chiesto.


### [HTTP Cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
I cookie vengono spesso arricchiti da attributi, ed i principali sono:
- **Expires**: Specifica il tempo di scadenza in secondi per il cookie. Se non specificato, il cookie viene eliminato al termine della sessione (session cookie).
- **Secure**: I cookie con questa flag vengono inviati solo in richieste [HTTPS](https://it.wikipedia.org/wiki/HTTPS) (HTTP crittografato).
- **HttpOnly**: JavaScript non può accedere al cookie.
- **Domain**: Definisce il dominio per il quale il cookie è valido.
- **Path**: Stessa cosa ma col percorso.
- **Same-Site**: Specifica se il cookie può venire incluso in richieste che coinvolgono siti terzi. `SameSite=Strict` indica che il browser si rifiuterà di condividere il cookie con siti web diversi da quello che ci ha "detto" di settare il cookie. È una protezione che può scoraggiare attacchi CSRF.

Un cookie (nel browser: F12 -> Application -> Cookies):

![Esempio di cookie](img/capitolo0/CookieEsempio.png)

### [HTTP Authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)
Secondo gli standard del protocollo HTTP, la struttura della comunicazione tra un client che richiede una risorsa protetta e il server consiste nei seguenti step:
- Il client richiede la risorsa
- Il server risponde con lo status code `401 Unauthorized` (non autorizzato), specificando tramite l'header `WWW-Authenticate` il tipo di autenticazione richiesto. In questa fase possono essere inviate al client diverse informazioni, a seconda del metodo di autenticazione richiesto.
- Il client deve rispondere con l'header `Authorization` contenente le credenziali richieste.
- Il server risponde `200 OK` o `403 Forbidden` (accesso vietato).

`401 Unauthorized` = "non so chi sei", `403 Forbidden` = "non sei un utente che ha accesso alla risorsa".

#### Principali tipi di autenticazione:
- **Basic Authentication**: `username:password` vengono inviati encodati in [`base64`](https://it.wikipedia.org/wiki/Base64). L'encoding non offre nessun layer di sicurezza aggiuntivo, di conseguenza un'autenticazione `Basic` in HTTP è completamente insicura, come mandare le informazioni in chiaro.
- **Digest Authentication**: Offusca username e password usando anche altri parametri come `realm` e `nonce`
- **Bearer Authentication**: Usata soprattutto in contesti basati su [Oauth2](https://www.teranet.it/introduzione-ad-oauth-2). Di fatto, invece di fornire le credenziali al server che richiede l'autenticazione, ci autentichiamo presso un altro server del quale il server iniziale si fida. Questo è possibile perchè il server autenticante fornisce all'utente un token da usare come "cartellino d'ingresso" quando passiamo all'ultima fase del processo di autenticazione. Spesso i token sono generati come [JWT](https://en.wikipedia.org/wiki/JSON_Web_Token).

*Nota: I tipi di autenticazione potrebbero non essere chiari fin da subito, e non sono necessariamente spendibili in attacchi utili al contesto di CyberChallenge, ma l'utilizzo delle Bearer authentication è in continua crescita ed è un argomento che ritengo particolarmente importante. Ne consiglio caldamente l'approfondimento autonomo.*


### Conclusione del capitolo:
Quando difendiamo o attacchiamo un servizio, è utile ricordare che i cookies, gli header, il body content e il metodo della richiesta possono venire modificati dal client come esso vuole. Esistono strumenti (come BurpSuite) che permettono di modificare facilmente tutte le informazioni possibili che il server è in grado di ricevere. Fidarsi di ciò che viene inviato dal client significa accettare di gestire un servizio vulnerabile. Uno sviluppatore deve fare in modo di limitare per quanto possibile le funzionalità che richiedano una fiducia dell'utente. La natura stateless di HTTP costringe gli sviluppatori ad usare i cookie per l'autenticazione (immaginate di dover loggare ogni volta che cambiate reel), mettendoli in difficoltà e aprendo la possibilità a vari tipi di attacchi cross-site che vedremo più avanti.

*Challenge: Prime 6 di web security a partire da [questa](https://training.olicyber.it/challenges#challenge-41)*

<div style="page-break-after: always;"></div>

# Capitolo 0.5
## [Database relazionali](https://www.oracle.com/it/database/what-is-a-relational-database/) e [SQL](https://it.wikipedia.org/wiki/Structured_Query_Language)
I Relational Database Management System (DBMS) e lo Structured Query Language sono argomenti vastissimi ai quali vengono dedicati interi esami. Tuttavia, per ciò che ci serve, possiamo ottenere risultati soddisfacenti anche solo prendendo dimestichezza con pochi concetti e istruzioni.

### Modello relazionale
Nel modello relazionale, le informazioni vengono strutturate in tabelle, righe e colonne. 

Un database relazionale è quindi strutturato in modo molto simile ad un foglio di lavoro (esempio: Excel). Ogni foglio di lavoro è una tabella nella quale vengono archiviate informazioni. Le colonne rappresentano i vari attributi, e le righe i "record", le entità, in un certo senso sono i soggetti dei dati raccolti.

Esempio di tabella:

![Esempio tabella giocatori CTF](/img/capitolo0.5/EsempioTabella.png)

Quindi i record di una tabella condividono la stessa "struttura": per ognuno di essi abbiamo lo stesso tipo di informazione.

Per ogni tabella è definita una *chiave primaria*, ovvero un dato che identifica univocamente ogni riga o record.
La chiave primaria può essere definita da più colonne, o da un'informazione utile sul record, ma per semplicità si tende a definirla su una sola colonna, spesso creata per questo unico scopo, chiamata ID (o simili). Per semplicità potete ricordare la chiave primaria come identificatore univoco. È tuttavia utile ricordare l'eventualità che la chiave primaria possa essere multicolonna o (più plausibile) che essa sia un dato come un codice fiscale o numero di matricola.

Inoltre, ogni riga può essere utilizzata per creare una relazione tra diverse tabelle utilizzando una *chiave esterna*, ovvero la chiave primaria di un'altra tabella.

Esempio riassuntivo:

![Esempio primary e foreign key](/img/capitolo0.5/EsempioPrimaryForeignKey.png)

### DBMS
Una generica base di dati, o database, è una collezione di dati che viene gestita e organizzata dal DBMS (DataBase Management System). Gli RDBMS gestiscono database relazionali.

L'utente ha in mente uno schema logico di come dovrebbe essere un database (guarda gli esempi di prima), ma i record devono essere memorizzati fisicamente in qualche modo sotto forma di bit. Il DBMS si occupa di gestire i dati in sè, controllando gli accessi concorrenti, assicurando sicurezza e integrità dei dati e permettendo la loro migrazione, tutto questo permettendo all'utente di accedere ai dati attraverso uno schema concettuale piuttosto che ai dati presenti fisicamente in memoria.

tldr: permette l'astrazione assicurando al contempo rapidità di accesso ai dati e la loro integrità.


### SQL
SQL è il linguaggio standard per manipolare i database.

Andiamo per esempi. Prima di tutto, vediamo tutti i dati sui quali lavoreremo in questo tutorial:

`SELECT * FROM players;`

| ID | Username | Team |
| ----------- | ----------- | ----------- |
| 1 | Loldemort | 4 |
| 2 | Titto | 2 |
| 3 | marco | 3 |
| 4 | C0mm4nd_ | 1 |

`SELECT * FROM Teams;`

| ID | Name |
| ----------- | ----------- |
| 1 | MadrHacks |
| 2 | TRX |
| 3 | ZenHack |
| 4 | TeamItaly |

Vediamo i team. L'ID non ci serve a molto... Prendiamo solo i nomi:

`SELECT Name FROM Teams;`

| Name |
| ----------- |
| MadrHacks |
| TRX |
| ZenHack |
| TeamItaly |

E se volessimo vedere solamente il nome della seconda squadra inserita nel database?

`SELECT Name FROM Teams WHERE ID = 2;`

| Name |
| ----------- |
| TRX |

La struttura della `SELECT` è quindi: `SELECT [colonna/e] FROM [tabella] WHERE [condizione]`, e non è necessario selezionare una colonna per usarla come condizione, come abbiamo visto in quest'ultimo esempio

Ora invece selezioniamo tutti i team tranne i primi due:

`SELECT * FROM Teams WHERE ID > 2;`
`SELECT * FROM Teams WHERE ID >= 3;`

| ID | Name |
| ----------- | ----------- |
| 3 | ZenHack |
| 4 | TeamItaly |

Però ordiniamoli in ordine alfabetico:

`SELECT * FROM Teams WHERE ID >= 3 ORDER BY Name;`

| ID | Name |
| ----------- | ----------- |
| 4 | TeamItaly |
| 3 | ZenHack |

Ma la classifica era più bella prima...

`SELECT * FROM Teams WHERE ID >= 3 ORDER BY Name DESC;`

| ID | Name |
| ----------- | ----------- |
| 3 | ZenHack |
| 4 | TeamItaly |

Sintassi completa: ```SELECT column[s]
FROM table[s]
WHERE condition[s]
ORDER BY column[s] [asc/desc];```

Se inseriamo più colonne nell'ORDER BY, avrà importanza l'ordine nel quale le elenchiamo. Se per esempio volessimo selezionare dei giocatori in base al punteggio, e in caso di parità dare priorità al più giovane, potremmo usare questa *query*: `SELECT name, score FROM players ORDER BY score DESC, age ASC;`. Si possono inserire più condizioni in un `WHERE` usando gli operatori `OR` e `AND`.


### SQL for exploitation
Ci sono poi altre istruzioni e operatori che tornano particolarmente utili quando si eseguono SQL injection, un tipo di attacco che vedremo nel dettaglio nel prossimo capitolo.

`LIKE` ci permette di cercare una stringa che "assomiglia" a quella che viene fornita. Questo è possibile grazie alle *wildcards*. Le due wildcards più importanti per i nostri scopi sono l'underscore `_`, che rappresenta un solo carattere, e il percento `%`, che rappresenta nessuno o più caratteri. Degli esempi sulla tabella `Players`:

`SELECT * FROM Players WHERE Username LIKE "_arco"`

| ID | Username | Team |
| ----------- | ----------- | ----------- |
| 3 | marco | 3 |

`SELECT * FROM Players WHERE Username LIKE "%o"`

| ID | Username | Team |
| ----------- | ----------- | ----------- |
| 2 | Titto | 2 |
| 3 | marco | 3 |

`SELECT * FROM Players WHERE Username LIKE "%o%"`

| ID | Username | Team |
| ----------- | ----------- | ----------- |
| 1 | Loldemort | 4 |
| 2 | Titto | 2 |
| 3 | marco | 3 |

`SELECT * FROM Players WHERE Username LIKE "%Titto"`

| ID | Username | Team |
| ----------- | ----------- | ----------- |
| 2 | Titto | 2 |

Vi ricordate della `foreign key` e della `primary key`?

![Esempio primary e foreign key](/img/capitolo0.5/EsempioPrimaryForeignKey.png)

La `JOIN` è un'istruzione che ci permette di eseguire manipolazioni utili usando queste due informazioni. A noi per il momento interessa solamente ottenere informazioni da due tabelle diverse, indipendentemente dalla presenza o meno di un legame tra di esse, ed in questo ci aiuta la `UNION`. Per usarla, basta scrivere due `SELECT` relative a due tabelle diverse, e metterci una `UNION` in mezzo:


`SELECT Username FROM Players WHERE Username LIKE "L%" UNION SELECT Name FROM Teams WHERE ID = 2`

| Username |
| ----------- |
| Loldemort |
| TRX |

Quando eseguiamo una `UNION SELECT`, dobbiamo tenere a mente che:
- Ogni select deve avere lo stesso numero di colonne. `SELECT ID, Username FROM Players UNION SELECT Name FROM Teams` non è quindi valida.
- Le colonne devono riguardare tipi di dato "simili". Ad esempio, stringhe e varchar, pur non essendo lo stesso tipo, possono far parte della stessa colonna IN UNA QUERY `UNION`! `SELECT ID FROM Players UNION SELECT Name FROM Teams` restituisce un errore.
- Le colonne generate da una `UNION SELECT` avranno lo stesso nome delle colonne selezionate dalla prima tabella nominata. Questo non rappresenta di per sè un problema, ma può generare confusione quando ci vengono restituiti i risultati della query (nell'esempio di prima, i TRX appaiono nella colonna Username).

In quanto futuri xHackerZx, non possiamo scoraggiarci alle prime difficoltà. Ci sono delle scorciatoie che possiamo utilizzare, forzando delle funzionalità particolari messe a disposizione dalle query SQL.

#### "Ogni `SELECT` deve avere lo stesso numero di colonne"
In caso l'applicazione con la quale stiamo interagendo ci proponesse una query con troppe colonne (vogliamo sapere solo i nomi dei team tramite una union, ma nella tabella players viene selezionato anche l'ID), possiamo usare le mock columns.

Queste consistono nell'inserire dei valori fissi al posto del nome della colonna in modo che dalla query venga selezionata una colonna finta:

`SELECT ID, Username FROM Players UNION SELECT 1337, Name FROM Teams`

| ID | Username |
| ----------- | ----------- |
| 1 | Loldemort |
| 2 | Titto |
| 1337 | TeamItaly |
| 1337 | TRX |

etc...

Possiamo anche usare `"carattere"` se vogliamo creare una finta colonna di tipo `varchar`. 

Se invece avessimo a disposizione troppe poche colonne, possiamo sfruttare la concatenazione:

`SELECT Name FROM Teams UNION SELECT CONCAT(Username," ",Fullname) FROM Players`

Il metodo di concatenazione varia enormemente tra un DBMS e l'altro, quindi sarà necessario fare una nuova ricerca sulla concatenazione ogni qualvolta troveremo un nuovo DBMS.

Nel nostro caso però nella tabella Players non è presente il `Fullname`, oltre l'username ci sono solo ID e l'ID della squadra del giocatore come foreign key. Non avremmo potuto concatenare queste informazioni con `Username`, visto che queste altre sono interi e non varchar. In casi come questi, la scorciatoia presente nel prossimo paragrafo torna particolarmente utile

#### "Le colonne devono riguardare tipi di dato simili"
In questo caso possiamo fare affidamento al CASTing, che ci permette di trasformare i dati da un tipo all'altro quando possibile. Ad esempio, la query:

`SELECT Username FROM Players UNION SELECT CAST(ID as varchar) FROM Teams` è valida e restituisce

| Username |
| ----------- |
| Loldemort |
| Titto |
| "1" |
| "2" |

Anche il CASTing, come la concatenazione, può variare molto tra i vari DBMS. In generale questo è vero per quasi tutte le istruzioni che vanno oltre alla soddisfazione delle esigenze più che basilari del programmatore, come semplici `SELECT`. Per questo è più utile imparare a cercare le informazioni necessarie su internet che imparare a memoria la sintassi dello standard SQL.

#### "Le colonne generate da una `UNION SELECT` avranno lo stesso nome delle colonne selezionate dalla prima tabella nominata."
Come già detto, questo non rappresenta per noi un problema. Se lo si vuole risolvere, basta usare la keyword `AS` sulle prime colonne selezionate:

`SELECT Username FROM Players AS "UserAndTeamNames" UNION SELECT Name FROM Teams`

| UserAndTeamNames |
| ----------- |
| Loldemort |
| Titto |
| TRX |
| TeamItaly |

etc...

Come per la `SELECT`, se si devono rinominare più colonne, basta dividere i vari nomi con una virgola.

*Pratica: https://sqlbolt.com/*

<div style="page-break-after: always;"></div>

# Capitolo 1
## SQL injection