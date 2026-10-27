# Installe claudeHistory et ses commandes associées (version Windows / PowerShell).
#   irm https://raw.githubusercontent.com/clement-cdy/claudeHistoryPowershell/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$RepoRaw = 'https://raw.githubusercontent.com/clement-cdy/claudeHistoryPowershell/main'
$BinDir  = if ($env:CLAUDE_HISTORY_BIN) { $env:CLAUDE_HISTORY_BIN } else { Join-Path $HOME '.local\bin' }
# Les symlinks Unix reposent sur argv[0] : sous Windows, chaque alias devient un .cmd qui passe la sous-commande.
$Aliases = [ordered]@{ selectSessions = 'select'; exportClaudeHistory = 'export'; importClaudeHistory = 'import' }

# Recherche d'un Python 3 fonctionnel (en écartant l'alias factice du Microsoft Store).
$PyExe = $null
foreach ($cand in @(@('py', '-3'), @('python3'), @('python'))) {
    if (-not (Get-Command $cand[0] -ErrorAction SilentlyContinue)) { continue }
    $exe = $cand[0]; $pre = @($cand | Select-Object -Skip 1)
    try {
        $out = & $exe @pre -c 'import sys; print(sys.executable) if sys.version_info[0] == 3 else sys.exit(1)' 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) { $PyExe = "$out".Trim(); break }
    } catch {}
}
if (-not $PyExe) { throw "✗ python3 est requis." }

New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$tmp = [System.IO.Path]::GetTempFileName()
try {
    Write-Host "→ Téléchargement de claudeHistory…"
    Invoke-WebRequest -UseBasicParsing -Uri "$RepoRaw/claudeHistory" -OutFile $tmp

    & $PyExe -m py_compile $tmp 2>$null
    if ($LASTEXITCODE -ne 0) { throw "✗ Fichier téléchargé invalide." }
    Copy-Item -Force $tmp (Join-Path $BinDir 'claudeHistory.py')
} finally {
    Remove-Item -Force -ErrorAction SilentlyContinue $tmp
}

# Wrappers .cmd (équivalents des exécutables / symlinks)
$enc = New-Object System.Text.ASCIIEncoding
[System.IO.File]::WriteAllText((Join-Path $BinDir 'claudeHistory.cmd'),
    "@`"$PyExe`" `"%~dp0claudeHistory.py`" %*`r`n", $enc)
foreach ($name in $Aliases.Keys) {
    [System.IO.File]::WriteAllText((Join-Path $BinDir "$name.cmd"),
        "@`"$PyExe`" `"%~dp0claudeHistory.py`" $($Aliases[$name]) %*`r`n", $enc)
}

# Le sélecteur interactif utilise curses, absent de Python sous Windows.
& $PyExe -c 'import curses' 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "→ Installation de windows-curses (requis pour le sélecteur interactif)…"
    & $PyExe -m pip install --user --quiet windows-curses
    if ($LASTEXITCODE -ne 0) { Write-Warning "windows-curses non installé : 'selectSessions' ne fonctionnera pas." }
}

Write-Host "✓ Installé dans $BinDir : claudeHistory $($Aliases.Keys -join ' ')"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (($env:Path + ';' + $userPath).Split(';') -contains $BinDir)) {
    Write-Warning "$BinDir n'est pas dans votre PATH. Pour l'ajouter (utilisateur courant) :"
    Write-Host "    [Environment]::SetEnvironmentVariable('Path', `"$BinDir;`" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')"
}
Write-Host "Lancez : claudeHistory"
