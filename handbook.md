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
Nel World Wide Web ogni risorsa viene identificata univocamente da un URL (Uniform Resource Locator)

Illustrazione formale:
![URL](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/URI_syntax_diagram.svg/1920px-URI_syntax_diagram.svg.png)

Esempio pratico:
![URL](/img/URL_esempio.png)

*Nota: la porta di default - quindi il valore valido se non specificato - è l'80, il fragment è di default l'inizio pagina. Le query string, o parametri, sono generalmente facoltativi. Le userinfo, ovvero username e password, non mostrati nell'esempio, si usano in protocolli diversi da quelli che vediamo tipicamente nel browser, come FTP*

Per evitare che nell'URL siano presenti caratteri riservati che potrebbero portare ad un'interpretazione indesiderata da parte del browser, viene usato l'URL encoding, ufficialmente percent-encoding. Se usati per un attacco è quindi utile ricordarsi di codificare gli URL in modo che nessuna parte  del "vettore d'attacco"/payload che abbiamo preparato vada persa. 