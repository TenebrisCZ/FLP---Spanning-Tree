# FLP Projekt 2: Kostra grafu

**Jméno:** Pavel Osinek

**Login:** xosine00

---

## Úvod

Cílem projektu bylo implementovat program, který ze vstupního popisu neorientovaného grafu nalezne a vypíše **všechny možné kostry** (spanning trees) daného grafu.

## Popis implementace

Program je implementován v jazyce Prolog. Čte hrany grafu ze standardního vstupu a vypisuje všechny možné kostry neorientovaného grafu.

* **Načtení vstupu** :
* Každý validní řádek je zpracován na hranu (předpokládá se tvar `V1 V2`).
  * Pro čtení a zpracování řádků byly použity predikáty ze souboru `input2.pl`.
  * Nevalidní řádky na vstupu jsou ignorovány.
  * Hrany jsou normalizovány (lexikografické seřazení vrcholů v hraně, odstranění self-loop hran, odstranění duplicitních hran).
* **Výpočet všech koster** :
* Program generuje všechny možné podmnožiny hran o velikosti `|V| - 1`, kde `|V|` je počet vrcholů (`select_k_elements/3`).
* Pro každou kombinaci hran je kontrolováno:
  * Zda pokrývá všechny vrcholy (`covers_all_nodes/2`).
  * Zda tvoří souvislý graf bez cyklů (`is_valid_tree/2` + `is_connected/2`).
    * Souvislost grafu je testována pomocí BFS průchodu grafem.
    * Nepřítomnost cyklů je ověřována tím, že počet hran v kombinaci je přesně `|V| - 1`.

### Použité predikáty

| Predikát                                                                                                                             | Účel                                                                |
| :------------------------------------------------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------- |
| `start/0`                                                                                                                           | Hlavní vstupní bod programu: načítá vstup a spouští výpočet. |
| `read_lines/1`,<br />`split_lines/2`,<br />`filter_lines/2`,,<br />`read_line/1`,`split_line/2`,<br />`valid_edge_line/2` | Čtení, parsování (`input2.pl`) a filtrace vstupních dat.      |
| `normalize_edges/2`                                                                                                                 | Normalizace a deduplikace hran.                                       |
| `extract_nodes/2`                                                                                                                   | Extrakce všech vrcholů ze seznamu hran.                             |
| `select_k_elements/3`                                                                                                               | Vygenerování kombinací hran o délce `k`.                        |
| `spanning_tree/3`                                                                                                                   | Hledání možných koster grafu.                                     |
| `covers_all_nodes/2`                                                                                                                | Kontrola, zda hrany pokrývají všechny vrcholy.                     |
| `is_valid_tree/2`                                                                                                                   | Ověření, že graf tvoří strom (souvislý a bez cyklů).          |
| `is_connected/2`,<br />`reachable/3,`<br />`bfs/4`                                                                              | Implementace průchodu grafem (BFS) pro test souvislosti.             |
| `print_spanning_trees/2`,<br />`print_tree/1`,<br />`print_edge/1`                                                              | Výpis koster grafu.                                                  |

---

## Návod k použití

### Překlad programu

Program je přeložen pomocí přiloženého Makefilu:

```bash
make
```

Vytvoří se spustitelný soubor `flp24-log`.

### Spuštění programu s vlastním vstupem

Příklad:

```bash
./flp24-log < vstup.txt
```

Soubor `vstup.txt` musí obsahovat neorientované hrany v podobě:

```
A B
B C
C D
A D
```

Výstup:

```
A-B B-C C-D
A-B B-D D-C
...
```

> **Poznámka** : Pořadí hran v rámci jedné kostry i pořadí vypsaných koster je libovolné.

### Vyčištění pracovního adresáře

Odstranění přeložených souborů:

```bash
make clean
```

### Vytvoření archivu pro odevzdání

Vytvoření ZIP archivu:

```bash
make zip
```

### Spuštění testů

Automatické spuštění testovacího skriptu:

```bash
make test
```

nebo ručně:

```bash
chmod +x run_tests.sh
./run_tests.sh
```

Testovací skript:

* Spustí program na všech `.in` souborech ve složce `tests/`.
* Porovná výstup s očekávanými `.out` soubory.
* Výstup normalizuje a toleruje libovolné pořadí hran a vrcholů.

---

## Ukázkový vstup a výstup

### Vstup (soubor `example.in`)

```
A B
A C
B C
B D
C D
```

### Výstup

```
A-B B-D D-C
A-B B-C B-D
A-C C-B B-D
A-C C-D D-B
...
```

(Každý řádek představuje jednu kostru grafu.)
