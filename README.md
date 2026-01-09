# hackST (hackingStaTion)

**RPi Zero W + Alpine Linux** alapú, minimalista, bash-központú **hálózati diagnosztikai állomás**.
CLI-vezérelt, moduláris felépítéssel (lib / modules / menus), kifejezetten alacsony erőforrású vasra.

> „Shielded. Silent. Ready to filter the world below.” 🛰️

## Fő funkciók (high level)

- 📜 **rendszer** – Alpine alap parancsok / gyors referenciák
- 🌐 **netdiag** – hálózati diagnosztika (Wi-Fi / IP / DNS / route / stb.)
- 💾 **ment** – konfigurációk mentése
- 🧠 **tmux?** – tmux cheat sheet / gyors segítség
- 🧰 **hackmenu** – a HackStation menürendszer / indítófelület

*(A pontos alfunkciók a `modules/` és `menus/` alatt vannak.)*

## Felépítés

A projekt könyvtárstruktúrája:

hackST/
├── data/ # statikus adatok / minták (nem generált output)
├── docs/ # dokumentációk, cheat sheet-ek
├── lib/ # közös bash könyvtárak (log, ui, helper, stb.)
├── menus/ # menük, entrypoint-ok, CLI UX
├── modules/ # funkcionális modulok (netdiag, backup, stb.)
└── outputs/ # generált kimenetek (logok, reportok) – tipikusan gitignore

## Telepítés / használat

### Ajánlott célrendszer
- Raspberry Pi Zero W
- Alpine Linux (custom/minimal)
- BusyBox / ash környezetben is működjön, ahol lehet (bash-ra optimalizálva)

### Függőségek (minimum)
- `bash`
- alap Unix eszközök: `coreutils`, `iproute2`, `procps` (ha kell), `util-linux`
- hálózati toolok (moduloktól függően): `iputils`, `bind-tools`, `iw`, `wireless-tools`, `tcpdump`, `nmap` stb.

> Megjegyzés: a tényleges csomaglista disztribúció- és modulfüggő.

## Indítás / CLI felület

A HackStation egy interaktív bash környezetet biztosít.
Belépéskor egy egyedi `.bashrc` konfiguráció töltődik be, amely:

- figyelmeztető bannert jelenít meg (RPi Zero W / Alpine Linux)
- gyors parancs aliasokat definiál
- egyedi, állapotjelző promptot használ (Wi-Fi, load average)
- elérhetővé teszi a HackStation menürendszert

### Fő parancsok (aliasok)

A következő parancsok aliasokon keresztül érhetők el:

- `hackmenu` – HackStation főmenü (CLI dashboard)
- `ment` – teljes rendszermentés (rsync + SSH)
- `rendszer` – rendszerinformációk / cheat sheet
- `netdiag` – hálózati diagnosztika cheat sheet
- `tmux?` – tmux gyors referencia

Az aliasok definíciója a felhasználó `.bashrc` fájljában található.

### Defensive OSINT / Audit menü

A főmenü 8-as pontja egy „defensive” jellegű OSINT / audit almenüt nyit,
amely gyors ellenőrzésekre szolgál saját infrastruktúrán:

- Public IP (+ opcionális GeoIP)
- WHOIS lookup (IP vagy domain)
- DNS ellenőrzés (A / AAAA / MX / SPF / DMARC)
- TLS tanúsítvány lejárat ellenőrzés
- Top IP-k kigyűjtése logfájlokból (nginx / auth)
- Fail2Ban státusz
- Logfájl megnyitása (`tail`)
- Audit bundle (DNS + TLS + WHOIS)

Az eredmények naplózása az `outputs/` könyvtárba történik.


### Mentés / backup (`ment`)

A `ment` funkció egy **rsync alapú teljes rendszer mentést** készít egy távoli mentőszerverre SSH-n keresztül.
A mentés kizárja a tipikusan nem mentendő / virtuális fájlrendszereket (`/proc`, `/sys`, `/dev`, stb.).

Megjegyzés: a mentési cél és SSH paraméterek **konfigból** jönnek (lásd `conf/ment.conf`), hogy ne legyenek hardcode-olt helyi hálózati adatok a repóban.


### Rendszereszközök menü

A főmenüből az `s` opció nyitja a “Rendszereszközök és beállítások” menüt, tipikusan:
- Log olvasó és karbantartó
- Jelszólista kiválasztása
- Hálózati diagnosztika
- Rendszermentés indítása

## Disclaimer

Ez a projekt hálózati diagnosztikai és audit célú eszközöket is tartalmazhat.
Csak olyan hálózatokon/rendszereken használd, ahol erre jogosultságod van.
A szerzők nem vállalnak felelősséget a nem rendeltetésszerű felhasználásért.
