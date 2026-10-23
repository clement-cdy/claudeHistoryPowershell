# claudeHistory

Retrouvez, cherchez, reprenez et transférez **toutes vos sessions [Claude Code](https://claude.com/claude-code)** depuis un seul terminal.

Claude Code range ses conversations par dossier de projet dans `~/.claude/projects`. `claudeHistory` les rassemble toutes : un sélecteur interactif (TUI) pour reprendre n'importe quelle session en un appui sur Entrée, une recherche plein texte, et un export / import pour les emporter sur un autre PC.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/davidnurdin/claudeHistory/main/install.sh | sh
```

Ou avec `wget` :

```bash
wget -qO- https://raw.githubusercontent.com/davidnurdin/claudeHistory/main/install.sh | sh
```

Le script installe `claudeHistory` dans `~/.local/bin`, avec trois raccourcis : `selectSessions`, `exportClaudeHistory` et `importClaudeHistory`. Pour choisir un autre dossier :

```bash
curl -fsSL https://raw.githubusercontent.com/davidnurdin/claudeHistory/main/install.sh | CLAUDE_HISTORY_BIN=/usr/local/bin sh
```

**Prérequis :** Linux ou macOS, `python3` (aucune dépendance supplémentaire), et Claude Code installé.

## Le sélecteur interactif

```bash
claudeHistory        # ou : selectSessions
```

```
 Sessions Claude  (76/76)  ↑↓ naviguer · Entrée reprendre · tape pour filtrer · Échap quitter
 /                                                                 │ Correction de l'export CSV
 10-23 15:35 Ajout du mode sombre                         mon-site │ Dossier : ~/projets/facturation
 10-23 11:28 Correction de l'export CSV                facturation │ Branche : main
 10-23 09:58 Migration vers PostgreSQL                         api │ Période : 2026-10-23 10:46 → 11:28
 10-22 21:23 Tests HTTPS avec certificat ignoré            scripts │ Dernier prompt :
 ...                                                               │ ajoute un test pour les montants négatifs…
 F2 exporter la session · F3 exporter la liste affichée · F5 exportClaudeHistory (tout) · F6 importClaudeHistory
```

- **À gauche** : toutes les sessions, des plus récentes aux plus anciennes (date, titre, dossier).
- **À droite** : le détail de la session sélectionnée — titre, dossier complet, branche git, période, nombre de prompts, dernier prompt et dernière réponse de Claude.
- **Entrée** : se place dans le dossier du projet et lance `claude -r <id>`. En quittant Claude, vous revenez dans votre terminal d'origine.

| Touche | Action |
|---|---|
| ↑ ↓ · PgPréc PgSuiv · Début Fin | Naviguer |
| *n'importe quel texte* | Filtrer en direct (titre, dossier, prompts) |
| Retour arrière | Effacer une lettre du filtre |
| Entrée | Reprendre la session dans son dossier |
| **F2** | Exporter la session sélectionnée |
| **F3** | Exporter la liste affichée (filtre appliqué) |
| **F5** | Exporter **toutes** les sessions (`exportClaudeHistory`) |
| **F6** | Importer une archive (`importClaudeHistory`) |
| Échap | Vider le filtre, puis quitter |

Pour l'export et l'import, une ligne de saisie propose un chemin : modifiez-le si besoin, Entrée pour valider, Échap pour annuler.

## Recherche

```bash
claudeHistory search postgres
claudeHistory search export csv     # plusieurs mots = expression exacte
```

Cherche (sans tenir compte de la casse) dans vos prompts, les réponses de Claude, les titres et les dossiers. Pour chaque session trouvée : jusqu'à 3 extraits avec le mot surligné, et la ligne à copier pour y retourner :

```
2026-10-23 09:58 5927860d Migration vers PostgreSQL ~/projets/api (75 prompts)
    Toi : …migre la base SQLite vers Postgres en gardant les données existantes…
    ↻ cd '/home/moi/projets/api' && claude -r 5927860d-1869-4bda-8f29-0b46f71423cf
```

## Liste et lecture

```bash
claudeHistory list                # toutes les sessions (plus récentes en bas)
claudeHistory list -n 20          # les 20 dernières
claudeHistory list -g motclé      # filtre sur titre, dossier et prompts
claudeHistory list -p mon-site    # filtre sur le dossier du projet
claudeHistory list -a             # inclut les sessions vides (sans prompt)
claudeHistory list --json         # sortie JSON
claudeHistory -s 5927860d         # relire une conversation (début d'id suffisant)
claudeHistory -s 5927860d -f      # … avec les réponses complètes de Claude
```

Chaque session affichée se termine par sa commande de reprise `↻ cd … && claude -r …`.

## Transférer ses sessions vers un autre PC

Sur l'ancien PC :

```bash
exportClaudeHistory                         # → ~/claude-history-AAAAMMJJ-HHMMSS.tar.gz
exportClaudeHistory /media/cle/claude.tar.gz
```

Sur le nouveau PC (après l'installation ci-dessus) :

```bash
importClaudeHistory ~/Téléchargements/claude-history-20261023-154112.tar.gz
importClaudeHistory                         # sans argument : dernière archive trouvée
```

- L'archive contient toutes les sessions (y compris leurs sous-agents) et un manifeste.
- **Rien n'est écrasé** : une session déjà présente est ignorée, on peut relancer l'import sans risque.
- **Changement de dossier personnel** (ex. `/home/alice` → `/home/bob`) : les chemins des projets sont adaptés automatiquement pour que `claude -r` retrouve le bon dossier.
- Les dossiers de vos projets eux-mêmes ne sont **pas** copiés : placez-les au même endroit sur le nouveau PC pour pouvoir y reprendre vos sessions.

Équivalents : `claudeHistory export [fichier]` et `claudeHistory import [fichier]`.

## Fonctionnement

- Lit les fichiers `*.jsonl` de `~/.claude*/projects`, de `$CLAUDE_CONFIG_DIR` s'il est défini, et des autres comptes du PC s'ils sont lisibles.
- Le titre affiché est celui généré par Claude Code (ou le titre personnalisé de la session).
- Un cache (`~/.cache/claudeHistory/index.json`) évite de relire tous les fichiers : le premier lancement peut prendre quelques secondes, les suivants sont instantanés. Seules les sessions modifiées sont relues.
- Tout reste en local : aucune donnée n'est envoyée nulle part.

## Désinstallation

```bash
cd ~/.local/bin && rm -f claudeHistory selectSessions exportClaudeHistory importClaudeHistory
rm -rf ~/.cache/claudeHistory
```

## Licence

MIT
