\version "2.16.1"

x = {
  \grace { \xNotesOn cis16 \xNotesOff }
}
xx = {
  \grace { \xNotesOn cis16 cis16 \xNotesOff }
}
pre_chorus = {
  gis,8 gis8 r8 cis4 r8 \grace { \xNotesOn gis16 gis16 \xNotesOff } gis8 gis8 |
}

% Intro
intro = \relative c {
  cis4^"intro" r8 e r gis r cis8 | r4. e,8 r8 fis4. |
  cis4 r8 e r cis'4 r8 | \pre_chorus
  \break
}

% Verse
verse = \relative c {
  cis4^"verse" r8 e r gis r cis8 | r4. e,8 r8 fis4. |
  cis4 r8 e r cis'4 r8 | gis,8 gis8 r8 gis8 r8 gis8 r8 gis8 |
  \break
  cis4 r8 e r gis r g | fis4 r8 a r cis4. |
  cis,4 r8 e r cis'4 r8 | \pre_chorus
  \break
}

% Chorus
chorus_octaves = {
  cis4  r4. cis'8 r4 | cis,4 r4. cis'8 r4 |
  cis,4 r4. cis'8 r4 | \grace { \xNotesOn cis,16 cis16 \xNotesOff } cis4 r2. |
  \break
}
chorus_main = {
  cis4^"chorus" r \x cis8 cis r4 | \x cis4 r \xx gis8 gis r4 |
  \x cis4          r \x cis8 cis r4 | \x gis4 r \x cis cis | 
  \break
  cis4          r \x cis8 cis r4 | \x cis8 cis8 r4 \x e4 e4 |
  a,8 a a a a a a a gis gis gis gis gis gis gis b |
  \break
}
main_arp = {
  cis4 r8 e r gis r cis8 | r4. e,8 r8 fis4. |
}
outro = {
  cis4^"outro" r8 e r gis r cis8 | r4. e,8 r8 fis4. |
  \main_arp
  \break
  \main_arp
  \main_arp
  \break
  \main_arp
  \main_arp
  \break
  \main_arp
  \main_arp
  \break
  \main_arp
  \main_arp
  \break
}
chorus = \relative c {
  \chorus_main
  \chorus_octaves
}
final_chorus = \relative c {
  \chorus_main
  \outro
}

% Bridge
bridge = \relative c {
  cis4^"bridge" r8 e r gis r cis8 | r4. e,8 r8 fis4. |
  cis4          r8 e r gis r cis8 | r4. e,8 r8 e8 f4 |
  \break
  fis4 r8 a r cis r fis, | fis4 r8 a r cis r cis |
  c4 r8 gis r c r dis | dis4 r8 c r cis4. |
}

% Structure -------------------------------------------------------------------
\header {
  title = "Gimme A Simple Song"
}

{
  \clef "bass"
  \key cis \minor
  \time 4/4

  \intro
  \verse
  \chorus
  \verse
  \chorus
  \bridge
  \verse
  \final_chorus
}
