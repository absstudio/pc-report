# PC Report Generator

Un script batch Windows qui génère un rapport complet de votre PC :
système, CPU, **GPU et VRAM exacte**, barrettes RAM, disques (SSD/HDD et santé),
partitions, carte mère/BIOS, réseau et pilotes.

## Utilisation
1. Téléchargez `PC_Report.bat`
2. Double-cliquez dessus
3. Le rapport `PC_Report.txt` s'ouvre dans le Bloc-notes (placé sur le Bureau)

## Fonctionnalités
- VRAM exacte même au-delà de 4 Go (lecture registre)
- Détection SSD/HDD + état de santé (`Get-PhysicalDisk`)
- Section nvidia-smi si GPU NVIDIA présent
- Aucune installation requise (Windows + PowerShell natifs)

## Compatibilité
Windows 10 / 11 (64 bits)

## Licence
MIT
