# Introduction

This guide is dedicated to CyberChallenge.IT participants and, once expanded and deepened, to TRX members and enthusiasts in general. This resource aims to provide an overview of data exfiltration in web exploitation.

It is important to emphasize that this guide reflects solely my knowledge and personal opinions. I do not have direct experience in the field of cybersecurity and do not take responsibility for the misuse of the information provided here outside the context of CyberChallenge.IT and more broadly the world of CTFs.

Readers are encouraged to skip chapters or sections they already find familiar or irrelevant to their needs.

# Chapter 0.5
## Internet
In the World Wide Web, each resource is uniquely identified by a [URL](https://en.wikipedia.org/wiki/Uniform_Resource_Locator) (Uniform Resource Locator).

By resource, we mean any set of data or information that makes sense. Images, text paragraphs, videos, audios, web pages, program processing results are all examples of resources. Wikipedia defines "Web resources" as "all sources of information and services available on the Internet, identified by URL and physically present and accessible on web servers through the web browser of the client host."

If this definition is not clear, it will be useful to review the [client-server model](https://en.wikipedia.org/wiki/Client%E2%80%93server_model).

Formal illustration:

![Formal URL](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/URI_syntax_diagram.svg/1920px-URI_syntax_diagram.svg.png)

Practical example:

![Practical URL](/img/chapter0/URL_example.png)

*Note: the default port - therefore the valid value if not specified - is 80, the fragment is by default the beginning of the page. The query strings, or parameters, are generally optional. Userinfo, i.e., username and password, not shown in the example, are typical of protocols other than those commonly seen in the browser, such as [FTP](https://en.wikipedia.org/wiki/File_Transfer_Protocol).*

### [URL-encoding](https://developer.mozilla.org/en-US/docs/Glossary/Percent-encoding)
To avoid reserved characters in the URL that could lead to unintended interpretation by the browser, URL encoding is used, officially called percent-encoding. If used for an attack, it is therefore useful to remember to encode URLs so that no part of the prepared "attack vector"/payload is lost.

Before URL-encoding:

![Pre-encoding URL](/img/chapter0/PreEncoding.png)

After URL-encoding (what the server receives):

![Post-encoding URL](/img/chapter0/PostEncoding.png)

Note how only the text that can be directly controlled by the user is URL-encoded.

What is done is a conversion from the reserved character to its hexadecimal ASCII representation preceded by a %.

### [HTTP](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
The Hypertext Transfer Protocol, HTTP, is a stateless protocol, meaning that each request is independent of previous requests. The two phases provided are the HTTP request (the client makes a request to the server) and the HTTP response (the server responds).

In general, every time the client needs to request a resource from the server, it communicates using HTTP.
This means that for every resource you want to view, your device must make an HTTP request and receive an HTTP response from the server.

Example of an HTTP request:

![HTTP request](/img/chapter0/HTTPrequest.png)

Example of an HTTP response:

![HTTP response](/img/chapter0/HTTPresponse.png)

If there is a need for information exchange outside the context of headers and queries, these can be included in the body of the message. In the shown request example, they would appear "underneath" the headers. The structure of the body message varies depending on the technology used by the specific site and is easily identifiable during practical experience.

#### [Common HTTP Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods):
- **GET** (retrieve the resource or information about it)
- **POST** (action/send data to the resource)
- **HEAD** (GET without a body message)
- **TRACE** (diagnostic)
- **OPTIONS** (view available methods)
- **PUT** (create a new resource)
- **DELETE** (delete specified resource)
- **CONNECT** (establish a [tunnel](https://en.wikipedia.org/wiki/Tunneling_protocol) in case of a [proxy](https://en.wikipedia.org/wiki/Proxy_server))
- **PATCH** (modify the resource)

#### [Common HTTP Headers](https://blog.postman.com/what-are-http-headers/):
##### Request
- **Accept**: Defines the [MIME types](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types) that the client will accept from the server, in order of preference. For example, `Accept: application/json, text/html` indicates that the client prefers to receive responses in [JSON](https://en.wikipedia.org/wiki/JSON) but also accepts them in [HTML](https://en.wikipedia.org/wiki/HTML).
- **User-Agent**: Identifies the browser and/or client making the request.
- **Authorization**: Used for sending credentials, useful when trying to access a protected resource.
- **Cookie**: Used to send previously stored cookies to the server. Useful for personalizing the user experience and "combating" the limitations of the stateless nature of the HTTP protocol.
- **Content-Type**: Defines the MIME type of the request body content.

##### Response
- **Content-Type**: As above.
- **Server**: The counterpart of `User-Agent`.
- **Set-Cookie**: Informs the client that it should store a cookie with a certain name, value, and optionally expiration, domain, path, and security flag. Example: `Set-Cookie: score=127`. Once `Set-Cookie` is received and accepted, the client will send the cookie to the server with every request made.
- **Content-Length**: Specifies the size in bytes of the response body. If it "appears" from the requester's side, we must be careful to specify the correct length if we want to modify our payloads.

In the examples shown above, you can see how these headers are used in real communication between a web browser and a static website.

Generally, when a header begins with `X-`, it is custom.
It is useful to note that the operation of HTTP is just a convention, and the server can decide to implement any method and any header (custom headers and methods). These elements are of interest to us, as they are implemented directly by the site manager and therefore more easily subject to implementation errors. Furthermore, nothing prevents the programmer from using a GET to modify data or a POST to provide information, although this is obviously not recommended. The same goes for the elements shown later in this chapter.

#### [Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status):
- **1xx**: Informational responses
- **2xx**: Success
- **3xx**: Redirection
- **4xx**: Client error (typically bad requests)
- **5xx**: Server error (program errors and unhandled exceptions)

#### *Summarizing*:

We can think of the HTTP request as a letter we send via mail. In the request line, we as senders specify what we want to be done and where we want it to be done, like writing the address and type of service desired on an envelope. The request headers contain information about us and our preferences, similar to writing our name and address on the back of the envelope. If the service provider needs material or an object to fulfill our request, we can include it in the body message, just like sending a package along with the envelope.

The server, similar to the recipient of our letter, receives the request, tries to fulfill it, and sends us a response letter. In the response status line, we understand whether everything went well or if there was a problem, just like reading the delivery indication on our postal envelope. In the response headers, we get information about who did the job and how they would like us to behave with the result. Finally, in the response body message, we receive the requested product, as if a package containing what we asked for were sent along with the envelope.

### [HTTP Cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
Cookies are often enriched with attributes, and the main ones are:
- **Expires**: Specifies the expiration time in seconds for the cookie. If not specified, the cookie is deleted at the end of the session (session cookie).
- **Secure**: Cookies with this flag are only sent in [HTTPS](https://en.wikipedia.org/wiki/HTTPS) requests (encrypted HTTP).
- **HttpOnly**: JavaScript cannot access the cookie.
- **Domain**: Defines the domain for which the cookie is valid.
- **Path**: Same as above but with the path.
- **Same-Site**: Specifies if the cookie can be included in requests involving third-party sites. `SameSite=Strict` indicates that the browser will refuse to share the cookie with websites other than the one that "told" us to set the cookie. It is a protection that can discourage CSRF attacks.

A cookie (in the browser: F12 -> Application -> Cookies):

![Example of a cookie](img/capitolo0/CookieExample.png)

### [HTTP Authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)
According to the HTTP protocol standards, the structure of communication between a client requesting a protected resource and the server consists of the following steps:
- The client requests the resource.
- The server responds with the status code `401 Unauthorized`, specifying through the `WWW-Authenticate` header the type of authentication required. At this stage, various information can be sent to the client, depending on the authentication method required.
- The client must respond with the `Authorization` header containing the requested credentials.
- The server responds with `200 OK` or `403 Forbidden` (access denied).

`401 Unauthorized` = "I don't know who you are", `403 Forbidden` = "You are not a user who has access to the resource".

#### Main authentication types:
- **Basic Authentication**: `username:password` are sent encoded in [`base64`](https://en.wikipedia.org/wiki/Base64). The encoding provides no additional security layer, so `Basic` authentication over HTTP is completely insecure, like sending information in plaintext.
- **Digest Authentication**: Obscures username and password using other parameters like `realm` and `nonce`.
- **Bearer Authentication**: Mainly used in contexts based on [OAuth2](https://www.ory.sh/oauth2-for-everyone). In essence, instead of providing credentials to the server requesting authentication, we authenticate ourselves to another server that the initial server trusts. This is possible because the authenticating server provides the user with a token to use as a "pass" when we move to the final stage of the authentication process. Tokens are often generated as [JWT](https://en.wikipedia.org/wiki/JSON_Web_Token).

*Note: Authentication types may not be immediately clear, and they may not necessarily be exploitable in attacks useful to the CyberChallenge context, but the use of Bearer authentication is on the rise and is an especially important topic. I strongly recommend further independent study.*

### Chapter Conclusion:
When defending or attacking a service, it is useful to remember that cookies, headers, body content, and the request method can be modified by the client as it wishes. There are tools (like BurpSuite) that allow easy modification of all possible information that the server is able to receive. Trusting what is sent by the client means accepting to manage a vulnerable service. A developer must ensure to limit as much as possible the functionalities that require user trust. The stateless nature of HTTP forces developers to use cookies for authentication (imagine having to log in every time you change a reel), putting them in difficulty and opening up the possibility for various types of cross-site attacks that we will see later.

*Challenge: First 6 web security challenges starting from [this](https://training.olicyber.it/challenges#challenge-41)*

# Chapter 1
## [Python requests](https://realpython.com/python-requests/)

## Installation
```bash
pip install requests
from requests import *
pip install beautifulsoup4
from bs4 import BeautifulSoup
```

## Methods
In the requests library, each HTTP method corresponds to a function.

Calling the function of an HTTP method, for example `get`:
```python
response = get('https://api.github.com')
```
returns a `Response` object that contains a lot of information about the response we received, including:
- ## Status code: `response.status_code`
Note that `response.status_code` is an integer, while `response` is `True` if the status code is between 200 and 400, `False` otherwise. (If you want to understand how this is possible, you can take a look at [method overloading](https://realpython.com/operator-function-overloading/#making-your-objects-truthy-or-falsey-using-bool))
- ## Content: `response.text`
This allows us to see what was returned by the server, what we would have seen if we had visited the same link from a browser. `response.content` does the same thing but returns bytes instead of a string.
- ## JSON Content: `response.json()`
Particularly useful when dealing with [APIs](https://www.azionadigitale.com/api-cosa-sono-e-come-funzionano/). We would get the same result by using `.text` and deserializing the result with `json.loads(response)`
- ## Headers: `response.headers`
Which returns an object similar to a dictionary but with case-insensitive keys. So if we want to access a particular header, we can specify it: `response.headers['content-type']`

## Request Customization
As seen in the previous chapter, there are different types of information exchange that allow customization of a request:

- ### Query string parameters
```python
response = get(
    'https://it.wikipedia.org/w/index.php',
    params={'search': 'capture+the+flag'},
)
```

- ### Headers
```python
response = get(
    'https://it.wikipedia.org/w/index.php',
    params={'search': 'capture+the+flag'},
    headers={'User-Agent': 'Mozilla/5.0'},
)
```

## Other Methods
```python
post('https://httpbin.org/post', data={'key':'value'})
put('https://httpbin.org/put', data={'key':'value'})
delete('https://httpbin.org/delete')
head('https://httpbin.org/get')
patch('https://httpbin.org/patch', data={'key':'value'})
options('https://httpbin.org/get')
```

## Sessions
If it is necessary to perform multiple actions through a single connection (e.g., passing through multiple APIs that assign and check cookies/headers), you can use the [`Session`](https://requests.readthedocs.io/projects/it/it/latest/user/advanced.html#oggetti-session) object.

```python
s = Session()

s.get('http://httpbin.org/cookies/set/sessioncookie/123456789')
r = s.get("http://httpbin.org/cookies")

print(r.text)
# '{"cookies": {"sessioncookie": "123456789"}}'
```

Among the many possible use cases, sessions can be particularly useful in attacks and defenses that propose services where you need to register/login to obtain the flag. In these cases, it may be convenient to use sessions leveraging [`context managers`](https://realpython.com/python-with-statement/):

```python
with requests.Session() as session:
    session.auth = ('randomuser', 'randompass')

    session.post('https://api.cyberchallenge.it/pwnedwebsite/register')
    session.post('https://api.cyberchallenge.it/pwnedwebsite/login')
    response = session.get('https://api.cyberchallenge.it/pwnedwebsite/idor/flag')
```

## Cookies
As mentioned, if cookies are involved in the process to be automated, it is advisable to use sessions so as not to have to do any manual intervention.

If we want to view or add cookies, just know that they are saved in a dictionary, so to get them just use `session.cookies.get_dict()`

For a "clean" visualization of the various cookie parameters (thanks [Bobby](https://bobbyhadz.com/blog/how-to-use-cookies-in-python-requests)):

```python
import requests

response = requests.get('http://google.com', timeout=30)

# {'AEC': 'Ad49MVE4KO7sQX_pRIifPtDvL666jJcj34BmOFeETG9YU_1mu1SINQN-Q_A'}
print(response.cookies.get_dict())

result = [
    {'name': c.name, 'value': c.value, 'domain': c.domain, 'path': c.path}
    for c in response.cookies
]

# [{'name': 'AEC', 'value': 'Ad49MVGjcnQKK55wgCKVdZpw4PDgEgicIVB278lObJdf4eXaYChtDZcGLA', 'domain': '.google.com', 'path': '/'}]
print(result)
```

##### Adding a Cookie to the Session
The requests library uses CookieJar to manage cookies. To add a cookie to the session's CookieJar, you can use the `update` method:
```python
from requests import *
s = Session()
s.cookies.update({'username': 'Francesco Titto'})
response = s.get('http://ctf.cyberbootcamp.it:5077/')
```

In particular, the `session.cookie.XYZ` methods help interface with the CookieJar. There are many useful methods, but what has been covered so far is sufficient for the purpose of this guide.

#### Tips&Tricks
##### Checking "Allowed" Methods
As seen in the previous chapter, the `OPTIONS` method allows you to view the available methods. To do this, after executing an `OPTIONS` request, the desired result will be returned in the `Allow` header: `response.headers['allow']`

##### Using the Right Parameters
We have seen the different ways to send data to the server. It is important not to confuse `params`, which sends query parameters, `data`, which sends information in the request body, and `json` which does the same thing by converting the dictionary we give it into JSON and setting the `Content-Type` header to `application/json`. Note that inserting JSON into the `json` parameter, for example: `json=json.dumps(data)` will result in double dumping (and therefore various errors that are difficult to understand).

##### `robots.txt` and `sitemap.xml`
In some blackbox challenges of CyberChallenge (but especially OliCyber), it may happen that some necessary information for solving the challenge (including source code) is indicated in the `robots.txt` or `sitemap`. Checking costs you nothing and can save you a lot of time. It is much rarer in other CTFs (I have never found anything in it).

##### Timeout
To prevent the program from freezing due to a wrong request or an infrastructure problem, the `Timeout` was introduced: `get('https://api.github.com', timeout=1.5)`. You can insert the number of seconds (int or float) to wait before an error is triggered. When combined with `Try/Except`, it can be useful for time-based attacks (encryption, SQL, and more).

## [DOM](https://en.wikipedia.org/wiki/Document_Object_Model)
Pressing F12 in major browsers opens the developer tools. The first section shown by default is `elements`, which allows us to interactively explore the Document Object Model (DOM).

The DOM is a multi-platform and language-independent structure, but in our case, the following definition is sufficient: the DOM is an interface that treats HTML as a tree structure where each node is an object representing part of the document.

If you have never dealt with HTML and/or the concept of DOM, the best way to understand how it works and get comfortable with it is to visit sites you know well (for example, an article on [Wikipedia](https://en.wikipedia.org/wiki/Capture_the_flag_(computer_security))) and use the `elements` section of the developer tools.

![Example of using developer tools](img/capitolo1/DOMelements.png)

Hovering over one of the elements will highlight it.

In the example shown, `h3` is the [tag](https://developer.mozilla.org/en-US/docs/Glossary/Tag) of the [element](https://developer.mozilla.org/en-US/docs/Glossary/Element), `post-title` is the class. There may also be an `id`, which uniquely identifies the element.

### [BeautifulSoup](https://realpython.com/beautiful-soup-web-scraper-python/)
BeautifulSoup is an extremely useful library for [web scraping](https://en.wikipedia.org/wiki/Web_scraping). It is used together with the `requests` library to automatically obtain a series of data of interest.

#### Creating a BeautifulSoup object and printing it
```python
import requests
from bs4 import BeautifulSoup

URL = "https://theromanxpl0.it/"
page = requests.get(URL)

soup = BeautifulSoup(page.content, "html.parser")

print(soup.prettify())
```

#### Finding an element by ID
```python
results = soup.find(id="penguin-login writeup")
```

#### Finding elements by tag and/or class/text
```python
results = soup.find_all("h3", class_="post-title")
resText = soup.find_all("h3", string="penguin")

for result in results:
    print(result.prettify(), end="\n")

for result in resText:
    print(result.prettify(), end="\n")
```

#### Extracting text from an element
```python
print(result.text, end="\n")
```

For the structure of the DOM, it has a hierarchy, meaning the contents are nested within each other (what we see are all children of the element with the `HTML` tag).

#### Accessing the parent of an element
```python
result = soup.find("h3", class_="post-title")
result = result.parent
print(result.text, end="\n")
```

#### Extracting links
The `a` elements roughly represent a link, which is found as an `href` attribute.

```python
import requests
from bs4 import BeautifulSoup

URL = "https://theromanxpl0.it/"
page = requests.get(URL)

soup = BeautifulSoup(page.content, "html.parser")

links = soup.find_all("a")
for link in links:
    link_url = link["href"]
    print(f"writeup link: {link_url}\n")
```

*Exercises: First 16 starting from this one: https://ctf.cyberchallenge.it/challenges#challenge-255*
*In case you don't have access to the CyberChallenge platform, there is a public alternative here: https://training.olicyber.it/challenges#challenge-340*

*The introduction is very concise and more oriented towards examples as the topic can become very large depending on how much you want to delve into it, and I don't expect you to use this library very often, even less so if it's not a superficial use.*

# Chapter 1.5
## [Relational Databases](https://www.oracle.com/database/what-is-a-relational-database/) and [SQL](https://en.wikipedia.org/wiki/Structured_Query_Language)

Relational Database Management Systems (DBMS) and Structured Query Language are vast topics that are the subject of entire exams. However, for what we need, we can achieve satisfactory results by simply getting familiar with a few concepts and instructions.

### Relational Model
In the relational model, information is structured into tables, rows, and columns.

A relational database is structured very similarly to a spreadsheet (e.g., Excel). Each spreadsheet is a table where information is stored. The columns represent various attributes, and the rows represent "records," entities, in a sense they are the subjects of the collected data.

Example of a table:

![Example of CTF players table](/img/chapter1.5/ExampleTable.png)

So, the records in a table share the same "structure": for each of them, we have the same type of information.

For each table, a *primary key* is defined, which is a piece of data that uniquely identifies each row or record.
The primary key can be defined by multiple columns or by useful information about the record, but for simplicity, it tends to be defined on a single column, often created for this sole purpose, called ID (or similar). For simplicity, you can remember the primary key as a unique identifier. However, it is useful to remember that the primary key can be multi-column or (more likely) that it is a piece of data such as a tax code or registration number.

Furthermore, each row can be used to create a relationship between different tables using a *foreign key*, which is the primary key of another table.

Summary example:

![Example of primary and foreign key](/img/chapter1.5/ExamplePrimaryForeignKey.png)

### DBMS
A generic database is a collection of data managed and organized by the DBMS (Database Management System). RDBMS manages relational databases.

The user has in mind a logical schema of how a database should be (look at the examples above), but the records must be physically stored somehow as bits. The DBMS takes care of managing the data itself, controlling concurrent access, ensuring data security and integrity, and allowing data migration, all the while allowing the user to access the data through a conceptual schema rather than the data physically present in memory.

tldr: It allows abstraction while ensuring fast access to data and their integrity.

### SQL
SQL is the standard language for manipulating databases.

Let's go through some examples. First of all, let's see all the data we will work with in this tutorial:

#### SELECT/FROM

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

Let's see the teams. The ID doesn't tell us much... Let's only take the names:

`SELECT Name FROM Teams;`

| Name |
| ----------- |
| MadrHacks |
| TRX |
| ZenHack |
| TeamItaly |

And what if we wanted to see only the name of the second team entered in the database?

#### WHERE

`SELECT Name FROM Teams WHERE ID = 2;`

| Name |
| ----------- |
| TRX |

So, the structure of the `SELECT` is: `SELECT [column/s] FROM [table] WHERE [condition]`, and it is not necessary to select a column to use it as a condition, as we saw in this last example.

Now let's select all the teams except the first two:

`SELECT * FROM Teams WHERE ID > 2;`
`SELECT * FROM Teams WHERE ID >= 3;`

| ID | Name |
| ----------- | ----------- |
| 3 | ZenHack |
| 4 | TeamItaly |

But let's order them alphabetically:

`SELECT * FROM Teams WHERE ID >= 3 ORDER BY Name;`

| ID | Name |
| ----------- | ----------- |
| 4 | TeamItaly |
| 3 | ZenHack |

But the ranking was nicer before...

#### ORDER BY

`SELECT * FROM Teams WHERE ID >= 3 ORDER BY Name DESC;`

| ID | Name |
| ----------- | ----------- |
| 3 | ZenHack |
| 4 | TeamItaly |

Full syntax: 
```sql
SELECT column[s]
FROM table[s]
WHERE condition[s]
ORDER BY column[s] [asc/desc];
```

#### Multiple conditions

If we insert multiple columns in the ORDER BY, the order in which we list them will matter. For example, if we wanted to select players based on their score and in case of a tie give priority to the younger one, we could use this query: `SELECT name, score FROM players ORDER BY score DESC, age ASC;`. Multiple conditions can be included in a `WHERE` using the `OR` and `AND` operators.

### SQL for Exploitation
There are other statements and operators that are particularly useful when performing SQL injection, a type of attack that we will delve into in detail in the next chapter.

#### LIKE and Wildcards

`LIKE` allows us to search for a string that "resembles" the one provided. This is possible thanks to *wildcards*. The two most important wildcards for our purposes are the underscore `_`, which represents a single character, and the percent `%`, which represents none or more characters. Some examples on the `Players` table:

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

#### UNION SELECT

Do you remember about `foreign key` and `primary key`?

![Example of primary and foreign key](/img/chapter1.5/ExamplePrimaryForeignKey.png)

`JOIN` is a statement that allows us to perform useful manipulations using these two pieces of information. For now, we are only interested in obtaining information from two different tables, regardless of whether there is a relationship between them, and the `UNION` helps us with that. To use it, simply write two `SELECT` statements related to two different tables, and put a `UNION` in between:

`SELECT Username FROM Players WHERE Username LIKE "L%" UNION SELECT Name FROM Teams WHERE ID = 2`

| Username |
| ----------- |
| Loldemort |
| TRX |

When executing a `UNION SELECT`, we need to keep in mind that:
- Each select statement must have the same number of columns. `SELECT ID, Username FROM Players UNION SELECT Name FROM Teams` is not valid.
- The columns must involve "similar" data types. For example, strings and varchar, although not the same type, can be part of the same column IN A UNION QUERY! `SELECT ID FROM Players UNION SELECT Name FROM Teams` returns an error.
- The columns generated by a `UNION SELECT` will have the same name as the columns selected from the first named table. This is not a problem in itself, but it can be confusing when the query results are returned (in the previous example, TRX appears in the Username column).

As future xHackerZx, we cannot be discouraged by the first difficulties. There are shortcuts we can use, forcing special features provided by SQL queries.

#### Mock Columns
**"Each `SELECT` must have the same number of columns"**
If the application we are interacting with proposes a query with too many columns (we want to know only the team names through a union, but in the players table, the ID is also selected), we can use mock columns.

These consist of inserting fixed values instead of the column name so that a fake column is selected from the query:

`SELECT ID, Username FROM Players UNION SELECT 1337, Name FROM Teams`

| ID | Username |
| ----------- | ----------- |
| 1 | Loldemort |
| 2 | Titto |
| 1337 | TeamItaly |
| 1337 | TRX |

etc...

We can also use `"character"` if we want to create a fake `varchar` column.

#### Concatenation

If we have too few columns available, we can exploit concatenation:

`SELECT Name FROM Teams UNION SELECT CONCAT(Username," ",Fullname) FROM Players`

The concatenation method varies greatly between different DBMS, so it will be necessary to do a new search on concatenation whenever we encounter a new DBMS.

In our case, however, the Players table does not contain the `Fullname`, besides the username there are only ID and the player's team ID as a foreign key. We couldn't concatenate this information with `Username`, since these others are integers and not varchar. In cases like these, the shortcut presented in the next paragraph is particularly useful

#### CASTing
**"The columns must involve similar data types"**
In this case, we can rely on CASTing, which allows us to transform data from one type to another when possible. For example, the query:

`SELECT Username FROM Players UNION SELECT CAST(ID as varchar) FROM Teams` is valid and returns

| Username |
| ----------- |
| Loldemort |
| Titto |
| "1" |
| "2" |

CASTing, like concatenation, can vary greatly between different DBMS. In general, this is true for almost all statements that go beyond satisfying the most basic needs of the programmer, such as simple `SELECT`. For this reason, it is more useful to learn to search for the necessary information on the internet than to memorize the syntax of the SQL standard.

#### AS
**"The columns generated by a `UNION SELECT` will have the same name as the columns selected from the first named table."**
As already mentioned, this is not a problem for us. If you want to solve it, just use the `AS` keyword on the first selected columns:

`SELECT Username FROM Players AS "UserAndTeamNames" UNION SELECT Name FROM Teams`

| UserAndTeamNames |
| ----------- |
| Loldemort |
| Titto |
| TRX |
| TeamItaly |

etc...

As with `SELECT`, if you need to rename multiple columns, just separate the various names with a comma.

*Practice: [SQLBolt](https://sqlbolt.com/)*

# Chapter 2

#### Patching, Remediation, Mitigation, Blackbox, Whitebox
The term "patch" refers to modifications made to a program's code to mitigate or remove a vulnerability.
Remediation = removal of a vulnerability.
Mitigation = reduction of the impact of a vulnerability, or increasing the difficulty of launching an attack. They are common in [attack and defense](https://2022.faustctf.net/information/attackdefense-for-beginners/) competitions, where time is a particularly valuable resource.

*Blackbox* tests are performed without having access to the code, unlike *whitebox* tests.

## SQL Injection

SQL injection is a type of *code injection* vulnerability, allowing an attacker to write and execute code on the host server. It is as simple (to exploit and avoid) as it is potentially destructive.

### Logic SQL Injection

#### Vulnerability Presentation

Take a moment to think about how you would implement a web application that allows the user to execute a query. Let's take the following code as an example:

```sql
query = "SELECT id, name, points FROM teams WHERE name = '" + request.form['query'] + "'"
conn = sqlite3.connect("file:CTF_scoreboard.db", uri=True)
cursor = conn.cursor()

cursor.execute(query)
results = cursor.fetchall()
str_res = str(results)
```

With `request.form['query']`, the program accepts user input, then executes the query and returns the result. Take some time and try to understand where the error is.

The program itself works perfectly, but the fact that the string provided by the user is simply concatenated to the query allows the user to close the parenthesis related to the `name` string and do whatever they want. To retrieve the entire contents of the table, all they have to do is ensure that the condition is always true, for example by entering into the `query` field:

`' or 'a'='a`
And thus, the query `SELECT id, name, points FROM teams WHERE name = '' or 'a'='a'` would be executed.

#### Comments
What is commonly done, when possible, is to comment out the rest of the query instead of trying to complete it perfectly. In this case, we had to resort to string comparisons in order to "use" the last apostrophe, but it is common to use this type of payload:

`' or 1=1 -- `, which means execute `SELECT id, name, points FROM teams WHERE name = '' or 1=1 -- '`.

In SQL, the way to write comments may vary depending on the DBMS, but `-- ` (note the space after the hyphens) should give you the desired result in every situation. This way, we can write the commands we want without worrying about what is written after our payload, which is particularly useful in *blackbox* attacks where, in fact, we wander in the dark.

*Sample Challenge: https://training.olicyber.it/challenges#challenge-48*

Union-Based SQL Injection
Once we are confident in our discovery, we can push further. The Logic SQLi just shown allows us "only" to obtain the content of the selected table or bypass boolean checks, but there are also commands, such as `UNION`, that allow us to obtain data from multiple tables.

In a *whitebox* context, we are not required to perform any acrobatics. Just remember the syntax of the command, check the table and column names in the code, and we have access to a leak of the entire database. By entering into the `query` field:

`' UNION SELECT * FROM players -- `
The query `SELECT id, name, points FROM teams WHERE name = '' UNION SELECT * FROM players -- '` will be executed, thus *leaking* the data of the entire players table.

