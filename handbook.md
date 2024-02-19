# Introduzione

Questo "manuale" vuole essere una guida utile all'arte della web exploitation per quanto riguarda i programmi seguiti da CyberChallenge negli anni antecedenti al 2025. 

Nel mondo sono già disponibili diversi libri che approfondiscono questa materia come merita, e pullulla di write-up e repository da leggere e dalle quali copiare payload da usare e modificare come più ci piace.

La mia intenzione è quella di creare un testo soddisfacente in lingua italiana (nei limiti imposti dalla terminologia tecnica) che copra solamente gli argomenti relativi all'esfiltrazione di dati, così come richiesto dal programma e dagli obiettivi di CyberChallenge.

È ovvio che la sicurezza web non si limiti solo a questo: per un'azienda anche il solo fatto di avere un sito web non disponibile può provocare milioni di euro di danni, per non parlare delle possibili ricadute sulla sua immagine.

Volevo però fare in modo di mettere a disposizione un testo dritto al punto e che non risultasse troppo verboso, toccando solamente i temi necessari al programma in modo da risparmiare tempo a chi deciderà di non approfondire questo ambito per conto proprio, e allo stesso tempo permettere agli appassionati di acquisire una base tecnica sufficiente ad affrontare temi più entusiasmanti e decisamente più complessi.

Mi sembra doveroso sottolineare che questo progetto è legato solamente a me, Tiziano Caruana, e che nè le persone affiliate al progetto CyberChallenge.IT, nè i dipendenti e gli studenti di Sapienza me escluso, nè nessun'altra persona sono legate a questo progetto. Inoltre io, ovvero l'autore di questo "manuale", non ho esperienze dirette nell'ambito della sicurezza informatica nè mi sono posto l'obiettivo di raggiungere con le mie parole professionisti, dilettanti o studenti che abbiano l'intenzione di approcciare applicazioni reali, che sia per motivi professionali o meno. Non mi prendo quindi responsabilità sulle ripercussioni che le conoscenze acquisite durante la lettura di questo "manuale", o i codici inseriti nello stesso, possono avere se utilizzate al di fuori del contesto per cui sono state create, ovvero per la risoluzione di challenge nel contesto di CyberChallenge.IT, che sia negli addestramenti o nelle gare.

Le note sono degli approfondimenti inseriti per completezza che possono tornare utili in challenge particolari e situazioni specifiche, ma che non sono fondamentali per la risoluzione delle challenge proposte nel training interno nè per la comprensione degli argomenti successivi.


# Capitolo 0
## Internet
Nel World Wide Web ogni risorsa viene identificata univocamente da un [URL](https://it.wikipedia.org/wiki/Uniform_Resource_Locator) (Uniform Resource Locator)

Illustrazione formale:
![URL formale](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/URI_syntax_diagram.svg/1920px-URI_syntax_diagram.svg.png)

Esempio pratico:
![URL pratico](/img/chapter0/URL_esempio.png)

*Nota: la porta di default - quindi il valore valido se non specificato - è l'80, il fragment è di default l'inizio pagina. Le query string, o parametri, sono generalmente facoltativi. Le userinfo, ovvero username e password, non mostrati nell'esempio, sono tipici di protocolli diversi da quelli che vediamo usualmente nel browser, come [FTP](https://it.wikipedia.org/wiki/File_Transfer_Protocol)*

### [URL-encoding](https://developer.mozilla.org/en-US/docs/Glossary/Percent-encoding)
Per evitare che nell'URL siano presenti caratteri riservati che potrebbero portare ad un'interpretazione indesiderata da parte del browser, viene usato l'URL encoding, ufficialmente percent-encoding. Se usati per un attacco è quindi utile ricordarsi di codificare gli URL in modo che nessuna parte  del ["vettore d'attacco"](https://www.akamai.com/it/glossary/what-is-attack-vector#:~:text=sfruttamento%20di%20API%20e%20applicazioni%20web)/payload che abbiamo preparato vada persa.

Prima dell'URL-encoding:
![URL pre-encoding](/img/chapter0/PreEncoding.png)

Dopo l'URL-encoding (cosa riceve il server):
![URL post-encoding](/img/chapter0/PostEncoding.png)

Da notare come solo il testo che può essere direttamente controllato dall'utente venga URL-encodato.

Ciò che viene fatto è una conversione dal carattere riservato alla sua rappresentazione ASCII esadecimale preceduta da un %.

### [HTTP](https://it.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
l'HyperText Transfer Protocol, HTTP, è un protocollo stateless, ovvero ogni richiesta è indipendente dalle richieste precedenti. Le due fasi previste sono l'HTTP request (il client fa una richiesta al server) e l'HTTP response (il server risponde).

Esempio di HTTP request:
![HTTP request](/img/chapter0/HTTPrequest.png)

Esempio di HTTP response:
![HTTP request](/img/chapter0/HTTPresponse.png)

In caso fosse necessario uno scambio di informazioni al di fuori del contesto degli header e delle query, queste possono essere incluse nel corpo del messaggio (body message). Nell'esempio di richiesta mostrato, apparirebbero "sotto" agli header. La struttura del body message varia a seconda della tecnologia utilizzata dallo specifico sito, ed è comunque facilmente individuabile durante l'esperienza pratica.


#### [Metodi HTTP comuni](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods):
- **GET** (ottenimento informazioni della risorsa)
- **POST** (azione/invio dati alla risorsa)
- **HEAD**(GET senza body message)
- **TRACE** (diagnostica)
- **OPTIONS** (visualizza metodi disponibili)
- **PUT** (crea nuova risorsa)
- **DELETE** (elimina risorsa specificata)
- **CONNECT** (crea un tunnel in caso di proxy)
- **PATCH** (modifica la risorsa)

#### [Header HTTP comuni](https://blog.postman.com/what-are-http-headers/):
##### request
- **Accept**: Definisce i [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types) che il client accetterà dal server, in ordine di preferenza. Ad esempio, `Accept: application/json, text/html` indica che il client preferisce ricevere risponse in JSON, ma le accetta anche in HTML.
- **User-Agent**: Identifica il browser e/o il client che sta effettuando la richiesta.
- **Authorization**: Usato per l'invio di credenziali, utile quando si prova ad accedere ad una risorsa protetta.
- **Content-Type**: Definisce il MIME type del contenuto del request body.
- **Cookie**: Usato per inviare al server cookie precedentemente memorizzati. Utile per personalizzare l'esperienza dell'utente e "combattere" i limiti della natura stateless del protocollo HTTP.

##### response
- **Content-Type**: Come sopra.
- **Server**: La controparte di `User-Agent`.
- **Set-Cookie**: Comunica al client che dovrebbe memorizzare un cookie con un certo nome, valore, e facoltativamente scadenza, dominio, percorso e flag di sicurezza. Esempio: `Set-Cookie: score=127`.
- **Content-Length**: Specifica la grandezza in byte del response body. In caso "apparisse" dal lato del richiedente, dobbiamo fare attenzione a specificare la lunghezza giusta in caso volessimo modificare i nostri payload.

#### [Status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status):
- **1xx**: Risposte informative
- **2xx**: Successo
- **3xx**: Reindirizzamento
- **4xx**: Errore del client
- **5xx**: Errore del server


Negli esempi mostrati precedentemente potete vedere come questi header vengono utilizzati in una comunicazione reale tra un web browser e un sito web statico.

Generalmente, quando un header inizia per `X-`, è custom.
È utile notare come il funzionamento di HTTP sia solo una convenzione, ed il server può decidere di implementare qualsiasi metodo e qualsiasi header (custom headers e methods). Questi elementi sono di nostro interesse, essendo implementati direttamente dal gestore del sito e quindi più facilmente soggetti ad errori di implementazione. Inoltre, nulla impedisce al programmatore di usare una GET per modificare dati, o una POST per fornire informazioni.

#### *Riassumendo*:

Pensiamo all'HTTP request come a una lettera che spediamo tramite posta. Nella riga della richiesta, noi come mittenti specifichiamo cosa vogliamo sia fatto e dove vogliamo sia fatto, come scrivessimo l'indirizzo e il tipo di servizio desiderato su una busta. Gli header della richiesta contengono informazioni su di noi e le nostre preferenze, simili a scrivere il nostro nome e il nostro indirizzo sul retro della busta. Se chi offre il servizio ha bisogno di un materiale o di un oggetto da utilizzare per soddisfare la nostra richiesta, possiamo includerlo nel body message, proprio come inviare un pacco insieme alla busta.

Il server, simile al destinatario della nostra lettera, riceve la richiesta, cerca di soddisfarla e ci invia una lettera di risposta. Nella riga dello stato della risposta, capiamo se tutto è andato bene o se c'è stato un problema, proprio come leggere l'indicazione di consegna sulla nostra busta postale. Negli header della risposta, otteniamo informazioni su chi ha eseguito il lavoro e come vorrebbe che ci comportassimo con il risultato. Infine, nel body message della risposta, riceviamo il prodotto richiesto, come se insieme alla busta ci venisse spedito un pacco contenente ciò che avevamo chiesto.