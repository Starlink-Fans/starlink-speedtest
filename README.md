## Starlink Speedtest Stats
Speedtest.StarlinkFans.eu je portál, na zhromažďovanie štatistík satelitného internetu Starlink jeho používateľmi. Zhromažďované sú vďaka dobrovoľníkom, ktorí
si na zariadenie vo svojej sieti nasadili skript, ktorý v pravidelných intervaloch meria niekoľko faktorov pripojenia a odosiela ich na náš server.

## :warning: Pozor na zvýšené používanie dát! :warning:
Jeden rýchlostný test može spotrebovať ať 500MB dát, čo pri 15 minútovom intervale meraní môže dosiahnuť až 48GB spotrebovaných dát za 24 hodín. Toto môže užívateľom, ktorí nemajú neobmedzené dáta, rýhclo vyčerpať limit!

## Čo potrebujem?
- Pripojenie cez satelitný internet Starlink (náš server automaticky overuje, či bol test vykonaný z IP adresy Starlinku)
- Zariadenie (zatiaľ) s operačným systémom Linux, pripojené v sieti káblom (bezdrôtové testy môžu štatistiky výrazne skresliť)
- Nainštalovať potrebný softvér a stihanuť skript
- Zaregistrovať si účet zdarma na [speedtest.starlinkfans.eu](https://speedtest.starlinkfans.eu/)
 
## Testované na
- Debian 11
- Ubuntu 22.04

## Inštalácia softvéru
```
sudo apt-get install jq curl
```

### Speedtest
Verzia Ookla Speedtest pre príkazový riadok (ďalšie informácie nájdete na webe [speedtest.net](https://www.speedtest.net/apps/cli))

```
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest

```
### GO SDK
Pre ištaláciu je potrebné mať nainštalované GO SDK. Ak túto podmienku spĺňate pokračujte na inštaláciu gRPCurl
```
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

Otestujte spustením
```
go version
```

### gRPCurl
Na komunikáciu so Starlink terminálom (dishy).
```
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
sudo cp ./go/bin/grpcurl /usr/bin
```
## Inštalácia skriptu
Stiahnite si skript _starlink_speedtest_stats.sh_

```
wget https://raw.githubusercontent.com/Starlink-Fans/starlink-speedtest/main/starlink_speedtest_stats.sh
chmod +x starlink_speedtest_stats.sh
```
## Prepínače skriptu
__-k__ - API Key z [speedtest.starlinkfans.eu](https://speedtest.starlinkfans.eu/) (povinné)  
__-s__ - vykoná Speedtest (potrebný nainštalovaný Speedtest CLI)  
__-d__ - získanie údajov z terminálu (dishy) (potrebný nainštalovaný gRPCurl)  
__-h__ - zobrazenie pomocníka
 
## Nastavenie pravidelného spúšťania (CRON)
Zápis, ktorý spustí meranie každých 15 minút. 
```
crontab -e
*/15 * * * * ~/path/to/starlink_speedtest_stats.sh -k 'APIKEY' -s -d
```
