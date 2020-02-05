---
Author: Michael Hirschmuggl, Manuel Planton
title: Algorithmen 2
---

Untersuching der Klangqualität verschiedener Upmixingmethoden
==========================================

# Markdown Beispiele

*kursiv*

**fett**

1. Das

2. ist

3. eine

4. nummerierte Liste


[link](www.google.at)


# Überblick



# DirAC

- Was ist es?

![DirAC Überblick (Pulkki 2007)](pic/pulkki_dirac_flow.png)


# DirAC: Annahmen aus der Psychoakustik


# DirAC: Funktionsweise

# Ablauf in Matlab/Octave
- B-Format Ausgangssignal

- Fensterung mit Hanning im Zeitbereich

- STFT

- Analyse von Richtungs- und Diffusanteil

- Upmixing auf Lautsprecheranordnung
	- 12 Speaker (Produktionsstudio)
	- T-Design (Ambisonics 4ter Ordnung)

- Trennung/Filterung

- Optional: Dekorrelation

- ISTFT und Overlap-Add

# Trennung Direkt- und Diffusanteil 1
- W(k,n) ... Schalldruck (Omnidirektionales B-Format Signal)

![Schnellevektor](pic/schnellevektor.png){ width=200px }

- V(m,k,n) ... Schnelle und Schalleinfallsrichtung
	- Auch Blindanteile enthalten!

![Richtungsvektor](pic/richtung.png){ width=300px }

![Sphärische Koordinaten](pic/sph_koordinaten.png){ width=250px }

![Diffusität](pic/diffusitaet.png){ width=250px }

# Trennung Direkt- und Diffusanteil 2
- Kodierung auf Lautsprecheranordnung

- Filter für Richtungs- und Diffusanteil generieren
	- Array mit Gain-Werten für Lautsprecher
	- 1 Gain-Wert pro Frequenz-Bin und Speaker (= Matrix)
	- Filterung im Frequenzbereich

- Filterung im Frequenzbereich
	- Direkt und Diffusanteil aus omnidirektionalem Anteil erzeugen


# Mittelung


# Upmixing: Direktanteil


# Upmixing: Diffusanteil


# Dekorrelationsmethoden


# Hörversuch


# Erwartete Ergebnisse


# Ergebnisse
