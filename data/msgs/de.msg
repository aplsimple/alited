# ________________________ de.msg _________________________ #
# Name:    de.msg
# Author:  Holger Ewert  (holger.ewert.wiki@arcor.de)
# Date:    2021-12-31
# Brief:   Handles German localization.
# License: MIT.


# ________________________  alited NS _________________________ #

namespace eval ::alited {

  ## ________________________ Common _________________________ ##

  ::msgcat::mcmset de {
    {No name} {Ohne Name}
    "\"%f\" wasn't saved.\n\nSave it?" "\"%f\" wurde nicht gespeichert\n\nJetzt speichern?"
    {About} {Über}
    {About...} {Über ...}
    {Error} {Fehler}
    {Warning} {Warnung}
    {Question} {Frage}
    {Information} {Information}
    {File} {Datei}
    {Edit} {Bearbeiten}
    {Search} {Suchen}
    {Conversions} {Umwandlungen}
    {Change Encoding...} {Ändere Encoding ...}
    {Change EOL...} {Ändere EOL ...}
    {Tools} {Werkzeuge}
    {Setup} {Einstellungen}
    {Help} {Hilfe}
    {Yes} {Ja}
    {No} {Nein}
    {Cancel} {Abbrechen}
    {Close} {Schließen}
    {New} {Neu}
    {Open...} {Öffnen ...}
    {Recent Files} {Jüngste Dateien}
    {Save} {Speichern}
    {Save as...} {Speichern unter...}
    {Save All} {Alles speichern}
    {... All} {... alles}
    {... All at Left} {... alles links}
    {... All at Right} {... alles rechts}
    {Preferences} {Einstellungen}
    {Preferences...} {Einstellungen ...}
    {Restart} {Neustart}
    {Quit} {Beenden}
    {Put New Line} {Neue Zeile einfügen}
    {Remove Trailing Whitespaces} {Rechte Leerzeichen löschen}
    {Remove trailing whitespaces} {Rechte Leerzeichen löschen}
    {Remove trailing whitespaces:} {Rechte Leerzeichen löschen:}
    "Remove trailing whitespaces of all lines\nof \"%f\"?" "Rechte Leerzeichen aller Zeilen\nvon \"%f\" löschen?"
    {Indent} {Einrücken}
    {Unindent} {Nicht einrücken}
    {Comment} {Kommentieren}
    {Uncomment} {Auskommentieren}
    {Find Next} {Finde Nächsten}
    {Look for Declaration} {Suche nach Erklärung}
    {Look for Word} {Suche nach Wort}
    {Run} {Ausführen}
    {Run...} {Ausführen...}
    {In console} {In Konsole}
    {In Tkcon} {In Tkcon}
    {Moving} {Verschieben}
    {Help of alited} {Hilfe von alited}
    {Color Picker} {Farbauswahl}
    {Date Picker} {Datumsausawahl}
    {Screen Loupe} {Bildschirmlupe}
    {Quit alited?} {Alited beenden?}
    {Wait a little ...} {Einen Augenblick ...}
    {Default} {Voreinstellung}
    {Default 2} {Voreinstellung 2}
    {Default 3} {Voreinstellung 3}
    {Default 4} {Voreinstellung 4}
    {Test} {Test}
    {Correct Indentation} {Richtig einrücken}
    "Correct the indentation of \"%f\"\nwith indenting %i spaces?" "Das Einrücken von \"%f\" anpassen\ndurch Einrückem mit %i Leerzeichen?"
    {The line %n: unbalanced brace!} {Zeile %n: Fehlende Klammer!}
    {Wrap Lines} {Zeilenumbruch}
    {Default values for new projects:} {Voreinstellungen für neue Projekte:}
  }

  ::msgcat::mcmset de {
    {Select} {Auswählen}
    {Save as} {Speichern unter}
    {Files} {Dateien}
    {Line} {Zeile}
    {Lines} {Zeilen}
    "All of \"%f\"" "Alle aus \"%f\""
    "Not recommended for projects\nwith large files (>2000 LOC)!" "Nicht für Projekte mit großen\nDateien (>2000 LOC) empfohlen!"
    {Move Unit Up} {Verschiebe Einheit aufwärts}
    {Move Unit Down} {Verschiebe Einheit abwärts}
    {Move File Up} {Verschiebe Datei aufwärts}
    {Move File Down} {Verschiebe Datei abwärts}
    {Only files are moved by alited.} {Nur Dateien verschoben durch alited.}
    {Lists of Favorites} {Liste der Favoriten}
    {Last Visited} {Zuletzt Besuchte}
    {Switch to Unit Tree} {Wechsel zu Einheitenbaum}
    {Switch to File Tree} {Wechsel zu Dateibaum}
    {Create File} {Datei erzeugen}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Einen Namen eingeben für eine Datei, die erzeugt wird in:\n%d\n\nWenn es ein Verzeichnis ist, wähle 'Verzeichnis'-Box aus. Das Verzeichnis kann Unterverzeichnisse enthalten (a/b/c)."
    {Delete File} {Datei löschen}
    "File %f already exists in\n%d" "Datei %f existinert schon in\n%d"
    {Remove Unit(s)} {Einheit(en) löschen}
    {No item selected.} {Kein Element ausgewählt}
    {Update Tree} {Baum aktualisieren}
    {Contract All} {Alle kolabieren}
    {Expand All} {Alle erweitern}
    "Move %f\nto\n%d\n?" "Verschiebe %f\nnach\n%d\n?"
    {To Last Visited} {Zu zuletzt Besuchten}
    {To Matched Bracket} {Zur passenden Klammer}
    {Go to Line} {Gehe zu Zeile}
    {Line number:} {Zeilennummer:}
    {    In unit:} {  In Einheit:}
    "\"%n\" contains unbalanced \{\}: %1!=%2" "\"%n\" unausgeglichene  \{\}: %1!=%2"
    {Back} {Zurück}
    {File not found: %f} {Datei nicht gefunden: %f}
    {Unit not found: %u} {Einheit nicht gefunden: %u}
    {Don't show anymore} {Nicht mehr anzeigen}
    {%f is a directory} {%f ist ein Verzeichnis}
    {THE EXTERNAL FILE IS MOVED TO THE PROJECT!} {DIE EXTERNE DATEI IST IN DAS PROJEKT VERSCHOBEN WORDEN!}
    {Drop Selected Units Here} {Ausgewählte Einheiten hier ablegen}
    {Drop Selected Files Here} {Ausgewählte Dateien hier ablegen}
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open.\n\nThis may be expensive!" "Alle Tcl-Dateien des Verzeichnisses:\n  \"%f\"  \nwerden geöffnet.\n\nDas kann aufwändig sein!"
    {Select All} {Alles auswählen}
    {Do it in other Tcl files} {Auch in anderer Tcl-Dateien}
    {Do it in other files} {Auch in anderer Dateien}
  }

  ## ________________________ Moving a first unit up ________________________ ##
  ::msgcat::mcmset de {
    {First Lines} {Erste Zeilen}
    {Can't touch the first %n lines.} {Kann die ersten %n Zeilen nicht erreichen.}
  }

  ## ________________________ Tree ________________________ ##
  ::msgcat::mcmset de {
    "Click \"%t\"" "Drücke \"%t\""
    {Copy Declaration} {Kopiere Deklaration}
    "Open All Tcl Files of \"%n\"" "Öffne alle Tcl-Dateien in \"%n\""
    "Remove \"%n\"\nfrom \"%f\"?" "Entferne \"%n\"\nvon \"%f\"?"
    "Delete \"%f\"?" "Lösche \"%f\"?"
    {An open file can not be deleted.} {Eine offene Datei kann nicht gelöscht werden.}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "Datei \"%f\" wurde durch eine Applikation geändert.\n\nBearbeitung beenden und Datei neu laden?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "Datei \"%f\" wurde durch eine Applikation gelöscht.\n\nDatei speichern?"
    {Tip File Info} {Tip-Datei Info}
    {Rename File} {Datei umbenennen}
    {Select one file in the tree.} {Wähle eine Datei im Baum.}
    {Open Selected File(s)} {Öffne ausgewählte Datei(en)}
    {Close Selected File(s)} {Schliesse ausgewählte Datei(en)}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset de {
    {Template} {Vorlage}
    {Templates} {Vorlagen}
    {Templates...} {Vorlagen...}
    {List of Templates} {Liste der Vorlagen}
    {Current template:} {Aktuell Vorlage:}
    {New template:} {Neue Vorlage:}
    {Hot keys} {Hotkey}
    {Add a template} {Vorlage hinzufügen}
    {Change a template} {Vorlage ändern}
    {Delete a template} {Vorlage löschen}
    {Click a template} {Vorlage auswählen}
    {The template #%n added} {Vorlage #%n hinzugefügt}
    {The template #%n updated} {Vorlage #%n aktualisiert}
    {The template #%n removed} {Vorlage #%n entfernt}
    {Enter a name of the template} {Name für die Vorlage eingeben}
    {Enter a text of the template} {Text für die Vorlage eingeben}
    "Choose a hot key combination\nfor the template insertion." "Wähle eine Hotkey-Kombination\nfür das Vorlageneinfügen."
    {A template with the attribute(s) already exists.} {Eine Vorlage mit diesen Attributen existiert schon.}
    {Place after:} {Platziere nach:}
    {line} {Linie}
    {unit} {Einheit}
    {cursor} {Kursor}
    {file's beginning} {Datei started}
    "Inserts a template\nbelow a current line" "Einfügen einer Vorlage\nunterhalb der aktuellen Zeile"
    "Inserts a template\nbelow a current unit" "Einfügen einer Vorlage\nunterhalb der aktuellen Einheit"
    "Inserts a template at the cursor\n(good for one-liners)" "Einfügen einer Vorlage beim Kursor \n(gut für Einzeiler)"
    "Inserts a template after 1st line of a file\n(License, Introduction etc.)" "Einfügen einer Vorlage nach der 1. Zeile einer Datei\n(Lizenz, Bedienungsanleitung usw.)"
    {Delete a template #%n ?} {Eine Vorlage #%n löschen ?}
    "Import templates\nfrom external alited.ini" "Importieren die Vorlagen\nvon extern alited.ini"
    {Number of imported templates: %n} {Anzahl der importierten Vorlagen: %n}
  }

  ## ________________________ Projects ________________________ ##
  ::msgcat::mcmset de {
    {Projects} {Projekte}
    {Projects...} {Projekte...}
    {You are going to %n!} {Du wirst %n!}
    {Add a project} {Ein Projekt hinzufügen}
    {Change a project} {Ein Projekt ändern}
    {Delete a project} {Ein Projekt löschen}
    {Don't delete the current project!} {Das aktuelle Projekt nicht löschen!}
    "The project \"%n\" added" "Projekt \"%n\" hinzugefügt"
    "The project \"%n\" updated" "Projekt \"%n\" aktualisiert"
    "The project \"%n\" removed" "Projekt \"%n\" entfernt"
    {Options} {Optionen}
    {Project name:} {Projektname}
    {Root directory:} {Basisverzeichnis:}
    {Skip subdirectories:} {Überspringe Unterverzeichnisse:}
    {Description:} {Beschreibung:}
    {Indentation:} {Einrücken:}
    {Auto detection} {Autoerkennung}
    {End of line:} {Zeilenende:}
    {Multi-line strings:} {Mehrzeilige Zeichenketten:}
    {Unit lines per 1 red bar:} {Einheitenlinien pro roten Balken:}
    {List of files:} {Dateiliste:}
    "You can\n  - add the current one to\n  - substitute with the current one\n  - delete\n  - not change\nthe file list of the project.\n" "Du kannst\n  - die aktuelle hinzufügen zu\n  - ersetzen mit der aktuellen\n  - löschen\n  - nicht ändern\ndie Dateiliste des Projektes.\n"
    {Add} {Hinzufügen}
    {Substitute} {Ersetzen}
    {Delete} {Löschen}
    {Don't change} {Nicht ändern}
    {Click a project} {Wähle ein Projekt}
    "Delete a project \"%n\" ?" "Lösche ein Projekt \"%n\" ?"
    "A project \"%n\" already exists." "Ein Projekt \"%n\" existiert schon."
    "A project \"%n\" doesn't exists. Hit \[+\] button to create it." "Ein Projekt \"%n\" existiert nicht. Drücke \[+\]-Taste um es zu erzeugen."
    "All modified files (%n) will be saved.\n\nDo you agree?" "Alle ausgewählten Dateien (%n) werden gespeichert.\n\nBist Du einverstanden?"
    "All selected files (%n) will remain open\nin the project you are switching to.\n\nDo you agree?" "Alle ausgewählten Dateien (%n) bleiben im Projekt, wohin Du wechselst, offen.\n\nBist Du einverstanden?"
    "Directory \"%d\"\ndoesn't exist.\n\nCreate it?" "Verzeichnis \"%d\"\nexistinert nicht.\n\nErzeugen?"
    {Checking %d. Wait a little...} {%d. prüfen. Bitte warten ...}
    {Too big directory for a project: %n files or more.} {Verzeichnis zu groß für ein Projekt: %n Dateien oder mehr.}
    {Options for new projects are set in "Preferences/General/Projects"} {Optionen für neue Projekte in "Preferences/General/Projects" gesetzt}
    {Date} {Datum}
    {Reminder} {Erinnerung}
    {Erase a text} {Text löschen}
    {Paste a text} {Text einfügen}
    {Undo changes} {Änderungen zurücknehmen}
    {Redo changes} {Änderungen wiederherstellen}
    {Text of a reminder} {Text einer Erinnerung}
    {TODO reminders for the past: %d. Delete them or try "Select".} {TODO Erinnerungen an die Vergangenheit: %d. Lösche sie oder versuche "Auswählen".}
    "You may select file(s)\nand open them with a context menu.\n\nOr just double-click." "Datei(en) auswählen\nund über das Kontextmenü öffnen.\n\nOder öffne sie mit Double-click."
    {No selected files} {Keine ausgewählte(n) Datei(en)}
    {Open file:} {Ausgewählt Datei:}
    {Open files: %n} {Dateien zu öffnen: %n}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset de {
    {Lists of favorites:} {Favoritenliste}
    {Current list of favorites:} {Aktuelle Favoritenliste}
    {New list of favorites:} {Neue Favoritenliste:}
    {Add a list of favorites} {Eine Favoritenliste hinzufügen}
    {Change a list of favorites} {Ändere eine Favoritenliste}
    {Delete a list of favorites} {Lösche eine Favoritenliste}
    {Click a list of favorites} {Wähle eine Favoritenliste}
    {The list #%n added} {Die Liste #%n hinugefügt}
    {The list #%n updated} {Die Liste #%n wurde aktualisiert}
    {The list #%n removed} {Die Liste #%n wurde entfernt}
    {Enter a name of the list} {Listenname eingeben}
    {Favorites of the current list} {Favoriten der aktuellen Liste}
    {The current list is empty!} {Die aktuelle Liste ist leer!}
    {This list already exists} {Diese Liste existiert schon}
    "This list not saved to\n\"%f\"." "Diese Liste wurde nicht gespeichert nach\n\"%f\"."
    {Non-favorite files to be:} {Nicht-Favoriten-Datei sein:}
    {kept} {behalten}
    {closed} {geschlossen}
    "Doesn't close any tab without favorites\nat choosing Favorites' list" "Kein Tab ohne Favoriten schliessen\nwenn Favoriten Liste ausgewählt wurde"
    "Closes all tabs without favorites\nat choosing Favorites' list" "Alle Tabs ohne Favoriten löschen\nwenn Favoriten Liste ausgewählt wurde"
    "Sets a list of Favorites\nthat was active initially." "Eine Liste von Favoriten setzen,\ndie beim starten geladen wird."
    {Delete a favorites' list #%n ?} {Eine Favoritenliste löschen #%n ?}
    {Favorites} {Favoriten}
    {Favorites...} {Favoriten...}
    "Add \"%n\" of %f\nto Favorites?" "Füge \"%n\" von %f\nzu Favoriten hinzu?"
    "Item \"%n\" of %f\nis already in Favorites." "Element \"%n\" von %f\nexistiert schon in Favoriten."
    "Remove \"%n\" of %f\nfrom Favorites?" "Lösche \"%n\" von  %f\naus Favoriten?"
    "\"%n\" unit of %f is not in the list." "Einheit \"%n\" von %f ist nicht in der Liste"
    {Add to Favorites} {Zu Favoriten hinzufügen}
    {Remove} {Löschen}
    {Remove All} {Alles löschen}
    {Remove all of Favorites?} {Alle Favoriten löschen?}
    {Remove all of the last visited?} {Alle zuletzt Besuchten löschen?}
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset de {
    "Create a file\nCtrl+N" "Datei erzeugen\nCtrl+N"
    "Open a file\nCtrl+O" "Datei öffnen\nCtrl+O"
    "Save the file\nF2" "Datei speichern\nF2"
    "Save all files\nCtrl+Shift+S" "Alle Dateien speichern\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Tcl/Tk-Hilfe auf die Auswahl anwenden\nF1"
    {Find / Replace} {Suchen / Ersetzen}
    "Find / Replace\nCtrl+F" "Suchen / Ersetzen\nCtrl+F"
    "Run the file\nF5" "Datei ausführen\nF5"
    "Run e_menu\nF4" "Führe e_menu aus\nF4"
    "Undo changes\nCtrl+Z" "Änderungen zurücknehmen\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Wiederherstellen\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset de {
    {Find: } {Finde: }
    {Replace: } {Ersetze: }
    {Match: } {Entsprechen: }
    {Exact} {Exakt}
    {Match whole word only} {Nur ganze Wörter vergleichen}
    {Match case} {Groß.-/Kleinschreibung}
    {Wrap around} {Fortsetze am Ende/Anfang}
    {Replace by blank} {Ersetzte durch freie Stelle}
    {Direction:} {Richtung:}
    {Down} {Abwärts}
    {Up} {Aufwärts}
    {Stay on top} {Bleibe oben}
    {Stay on top:} {Bleibe oben:}
    {Find} {Finde}
    {Replace} {Ersetze}
    {All in Text} {Alle in Text}
    {All in Session} {Alle in Sitzung}
    {All in %n Files} {Alle in %n Dateien}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Erlaubt die Verwendung von *, ?, \[ und \]\n  im Suchstring."
    "Allows to use the regular expressions\nin \"find\" string." "Erlaubt die Verwendung von regulären Ausdrücken\n  im Suchstring."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Erlaubt das Ersetzen durch eine leere Zeichenkette,\num faktisch die Funde zu löschen."
    "Keeps the dialogue above other windows." "Behält Dialoge oberhalb anderer Fenster."
    "Found %n matches for \"%s\"." "%n Treffer gefunden für \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "%n Ersetzungen von \"%s\" mit \"%r\" in \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "%n Ersetzungen von \"%s\" mit \"%r\" in allen Dateien der Sitzung."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "Ersetzte alle Vorkommen von \"%s\"\n\n mit \"%r\"\n\n in \"%f\" ?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all texts?" "Ersetzte alle Vorkommen von \"%s\"\n\n mit \"%r\"\n\n in allen Dateien der Sitzung?"
    {Don't focus a text after selecting in infobar} {Nicht den Text fokussieren nach der Auswahl in der Infoleiste}
    {Focus a text after selecting in infobar} {Fokussiere den Text nach Auswahl in der Infoleiste}
    {Find by List} {Suche nach Liste}
    {List:} {Liste:}
    {\n Enter a list of words divided by spaces: \n} {\n Eine Liste von durch Leerzeichen getrennten Wörter eingeben: \n}
    {FOUND:} {TREFFER:}
    {NOT FOUND:} {KEIN TREFFER:}
  }

  ## ________________________ Checking ini directory ________________________ ##
  ::msgcat::mcmset de {
    {Choosing Directory for Settings} {Verzeichnis für die Konfiguration auswählen}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n"
    "\n \"alited\" benötigt ein Konfigurationsverzeichnis um die Einstellungen zu speichern.\n Du kannst den Namen an alited als Argument übergeben.\n\n Das vorgegebene Konfigurationsverzeichnis ist \"%d\".\n Dies ist zu bevorzugen um  \"alited\" ohne Argumente zu benuzten.\n"
    {Choose a directory} {Verzeichnis auswählen}
  }

  ## ________________________ "About" dialogue ________________________ ##
  ::msgcat::mcmset de {
    {stands for} {steht für}
    {Written in pure Tcl/Tk.} {Nur in Tcl/Tk geschrieben.}
    {And well fit for programming with it.} {Und gut geeignet um damit zu Programmierung.}
    {Details:} {Details:}
    {Authors:} {Authoren:}
    {License:} {Lizens:}
    {Acknowledgements} {Anerkennungen}
    "Many thanks to the following people\n who have contributed to this project" "Vielen Dank an die folgenden Personen,\n die zu diesem Projekt beigetragen haben"
    {Special thanks also to} {Besonderen Dank auch an}
  }

  ## ________________________ Preferences ________________________ ##
  ::msgcat::mcmset de {
    {General} {Allgemein}
    {Editor} {Editor}
    {Units} {Einheiten}
    {Keys} {Tastenbelegung}
    {Misc.} {Sonst.}
    {Saving} {Speichern}
    {View} {Zeigen}
  }

  ### ________________________ General _________________________ ###
  ::msgcat::mcmset de {
    {Ttk theme:} {Ttk Theme:}
    {Color scheme:} {Farbschema:}
    {Darker:} {Dunkler:}
    {Lighter:} {Heller:}
    {Tint} {Farbton}
    {Tint:} {Farbton:}
    "For the settings to be active\nthe application should be restarted.\n\nRestart it just now?" "Damit die Konfigurationsänderunge aktiv werden\nmuss die Applikation neu gestartet werden.\n\nJetzt neu starten?"
    {Preferable locale:} {Bevorzugte Sprache:}
    "This is a country code: ru, uk, de...\nIn alited, \"en\" means American English." "Das ist einer der folgenden Länderkodes: ru, uk, de...\nIn alited \"en\" bedeutet American English."
    {Small font size:} {Schmaler Zeichensatz:}
    {Middle font size:} {Mittlerer Zeichensatz:}
    {Cursor width:} {Kursorbreite:}
    {Notes:} {Notizen:}
    "Sort of diary.\nList of TODOs etc." "Eine Art Tagebuch.\nListe offener Punkte usw."
    {Light / Dark} {Hell / Dunkel}
    {Makes colors darker .. lighter} {Macht Farben dunkler .. heller}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset de {
    {Font:} {Zeichensatz:}
    {Font size:} {Zeichensatz Grösse:}
    {Gutter's width:} {Breite Zwischensteg}
    {Gutter's shift from text:} {Zwischensteg's Verschiebung von Text:}
    {Space above lines:} {Platz über Zeilen:}
    {Space below lines:} {Platz unter Zeilen:}
    {Space between wraps:} {Platz zwischen Umbrüche:}
    {Tab bar label's length:} {Tab-Leiste Beschriftungslänge:}
    {Tab bar tip's length:} {Tab-Leiste Tiplänge:}
    {Code snippet:} {Codeausschnitt:}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset de {
    {Save before bar/menu runs:} {Speichern bevor bar/menu ausgeführt wird:}
    {Current file} {Aktuelle Datein}
    {All files} {Alle Dateien}
    {'Recent Files' length:} {Maximale Anzahl 'Letzte Dateien':}
    {'Last Visited' length:} {Maximale Anzahl 'Zuletzt besuchte':}
    {Maximum of project files:} {Maximale Anzahl Projetdateien:}
    {Confirm exit:} {Bestätige beenden:}
    {Save configuration on} {Speicher Konfiguration}
    {opening a file:} {Öffne eine Datei:}
    {closing a file:} {Schließe eine Datei:}
    {saving a file:} {Sichere eine Datei}
    {Back up files to a project's subdirectory:} {Sichere Dateien in ein Unterverzeichnis des Projektes:}
    "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." "Ein Unterverzeichnis von Projekten indem Sicherungskopien der Dateien gesichert werden..\nFeld leeren um Backup abzubrechen."
    {  Maximum:} {  Мaximum:}
    {Maximum of backup copies per a file} {Maximale Anzahl von Sicherungen pro Datei}
    {Bell at warnings:} {Klingel bei Warnungen:}
    {Port to listen alited:} {Port um zu hören alited:}
    "The empty value allows\nmultiple alited apps." "Der leere Wert erlaubt\nmehrere alited Anwendungen."

  }

  ### ________________________ Keys _________________________ ###
  ::msgcat::mcmset de {
    {Save File} {Speicher Datei}
    {Save File as} {Speicher Datei als}
    {Run e_menu} {e_menu ausführen}
    {Run File} {Datei ausführen}
    {Double Selection} {Mehrfachauswahl}
    {Delete Line} {Zeile löschen}
    {Highlight First} {Hebe Erstes hervor}
    {Highlight Last} {Hebe letzte hervor}
    {Find Next Match} {Zum nächsten Treffer}
    {Item up} {Element aufwärts}
    {Item down} {Element abwärts}
    {Complete Commands} {Vervollständige Befehle}
  }

  ### ________________________ Templates _________________________ ###
  ::msgcat::mcmset de {
    {Enter %U, %u, %m, %w, %d, %t wildcards of templates:} {Gebe  %U, %u, %m, %w, %d, %t ein als Platzhalter in Vorlagen:}
    {User name:} {Anwendername:}
    {Login:} {Anmeldung:}
    {Date format:} {Datumsformat:}
    {Time format:} {Zeitformat:}
  }

  ### ________________________ Syntax _________________________ ###
  ::msgcat::mcmset de {
    {Tcl syntax} {Schreibweise Tcl}
    {C/C++ syntax} {Schreibweise C/C++}
    {Plain text} {Nur Text}
    {Tcl files' extensions:} {Dateiendung Tcl:}
    {C/C++ files' extensions:} {Dateiendung C/C++:}
    {Plain texts' extensions:} {Dateiendung Nur Text:}
    {Color of Tcl commands:} {Farbe für Tcl-Befehle:}
    {Color of Tk commands:} {Farbe für Tk-Befehle:}
    {Color of strings:} {Farbe für Zeichenketten:}
    {Color of variables:} {Farbe für Variablen:}
    {Color of comments:} {Farbe für Kommentare:}
    {Color of proc/methods:} {Farbe für proc/methods:}
    {Color of options:} {Farbe für Optionen:}
    {Color of brackets:} {Farbe für Klammern:}
    {Color of C key words:} {Farbe für C Schlüsselworte:}
    {Color of C++ key words:} {Farbe für C++ Schlüsselworte:}
    {Color of punctuation:} {Farbe für Zeichensetzung:}
    {Color of return/goto:} {Farbe für return/goto:}
    {Color of your key words:} {Farbe für Deine Schlüsselworte:}
    {Colors} {Farben}
    {Your commands:} {Deine Befehle:}
    {Your key words:} {Deine Schlüsselworte:}
  }

  ### ________________________ Units _________________________ ###
  ::msgcat::mcmset de {
    {Branch's regexp:} {Regulärere Ausdruck für Zweige:}
    {Proc's regexp:} {Regulärere Ausdruck für Prozeduren:}
    {Check branch's regexp:} {Prüfe regulären Ausdrück für Zweige:}
    {Check proc's regexp:} {Prüfe regulären Ausdrück für Prozeduren:}
    {Use leaf's regexp:} {Benutze regulären Ausdruck für Endpunkte:}
    {Leaf's regexp:} {Regulärere Ausdruck für Endpunkte:}
    {Untouched top lines:} {Unveränderte obere Zeilen:}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset de {
    {Open bar/menu settings} {Öffne Leiste/Menü Einstellungen}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Ein Icon fügt das Ausführelement der Symbolleiste hinzu.\nLeer oder 'none' entfernt es aus der Symbolleiste."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "Das Ausführungselement für das Menü und/oder die Symbolleiste.\nWähle Du es aus dem e_menu-Einträgen aus."
    {Directory of menus:} {Menüverzeichnis:}
    {Main menu:} {Hauptmenü:}
    {Projects (%PD wildcard):} {Projekte (%PD Platzhalter):}
    {Linux terminal:} {Linux Terminal:}
    {Diff tool:} {Diff-Werkzeug:}
    {Path to man/tcl8.6:} {Pfad von man/tcl8.6:}
    {tclsh, wish or tclkit:} {tclsh, wish oder tclkit:}
    {Rows:} {Zeilen:}
    {Columns:} {Spalten:}
    {Geometry:} {Geometrie:}
    {Run as external app:} {Eine externe App ausführen:}
    {Inserts a new line.} {Eine neue Zeile einfügen.}
    {Deletes a line.} {Löscht eine Zeile.}
    {separator} {Trennezichen}
    {Item} {Element}
    {If 'yes', means a separator of the toolbar/menu.} {'ja' bedeutet Trennzeichen in der Werkzeugliste/Menü.}
    {After Start...} {Nach dem Starten...}
    {Before Run...} {Bevor Ausführen ...}
    {Commands:} {Befehle:}
    {Commands after start} {Befehle nach dem Starten}
    {Commands before "Run"} {Befehle vor "Ausführen"}
    "\n Enter commands to be run after starting alited. They can be Tcl or executables, e.g.\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n It can be necessary for a specific environment.\n" "\n Geben Sie Befehle ein, die nach dem Starten von alited ausgeführt werden sollen,\n das heißt Tcl Befehle oder ausführbare Dateien, z.B.:\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n Es kann für eine bestimmte Umgebung notwendig sein.\n"
    "\n Enter commands to be run before running a current file with \"Tools/Run\". They can be Tcl or executables, e.g.\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n It can be necessary for a specific project. Something like an initialization before \"Run\".\n" "\n Eingabe von Befehlen, die ausgeführt werde bevor die aktuelle Datei ausgeführt wird mit \"Werkzeuge/ausführen\",\n das heißt Tcl Befehle oder ausführbare Dateien, z.B.:\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n Dies kann für bestimmte Projekte notwendig sein. Das entspricht in etwa einer Initialisierung bevor \"Ausführen\". \n"
    {e_menu's own} {e_menu eigen}
    {(if ON, Tcl scripts run in console, otherwise in tkcon)} {(wenn ON, werden Skripte in der Konsole ausgeführt, sonst in tkcon)}
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset de {
    {Check Tcl} {Überprüfe Tcl}
    {Check} {Überprüfung}
    {Check:} {Überprüfung:}
    {Checks available:} {Vorhandene Überprüfungen:}
    {Consistency of {} } {Konsistenz von {}}
    {Consistency of []} {Konsistenz von []}
    {Consistency of ()} {Konsistenz von ()}
    {Consistency of ""} {Konsistenz von ""}
    {all of session files} {Alle Dateien der Sitzung}
    {current file} {Aktuelle Datei}
    {Found %f file error(s), %u unit error(s).} {%f Dateifehler und %u Fehler in Einheiten gefunden.}
    {No errors found.} {Kein Fehler gefunden.}
    {Duplicate units} {Dupliziere Einheit}
    {duplicate unit:} {Dupliziere Einheit:}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset de {
    "Can't backup \"%f\" to\n\"%d\"!\n\nDelete it anyway?" "Datei \"%f\" kann nicht nach \n\"%d\" gesichert werden!\n\nTrotzdem löschen?"
    "\"%f\" removed to \"%d\"" "\"%f\" entfernt aus \"%d\""
    {File name:} {Dateiname:}
    {Directory} {Verzeichnis}
    "The file \"%f\" seems to be not of types\n%s.\n\nStill do you want to open it?" "Die Datei \"%f\" scheint nicht von Typ \n%s zu sein.\n\nSoll sie wirklich geöffnet werden?"
  }

  ## ________________________ Find units ________________________ ##
  ::msgcat::mcmset de {
    {Find Unit} {Einheit finden}
    {in all} {in allen}
    {in current} {in aktuell}
    "Use glob patterns to find units' declarations\ne.g. \"s*rt\" would find \"start\" and \"insert\".\nThe letter case is ignored." "Glob-Muster verwenden, um Deklarationen von Einheiten zu finden:\nzum Beispiel, \"s*rt\" findet \"start\" und \"insert\".\nGroß.-/Kleinschreibung wird ignoriert."
    {Incorrect name for a unit.} {Inkorrekter Name für eine Einheit.}
  }

  ## ________________________ Abbreviations etc. ________________________ ##
  #   Line - 2nd column's title of unit tree
  #   ind = indentation
  ::msgcat::mcmset de {
    {ind} {einr}
    {Row} {Zeile}
    {Row: } {Zeil: }
    { Col: } { Spal: }
    {    Unit: } {   Einheit: }
  }

  ## ________________________ Bar of tabs ________________________ ##
  ::msgcat::mcmset de {
    {(Un)Select} {auswählen/abwählen}
    {... Visible} {... sichtbar}
    {... All} {... alles}
    {... All at Left} {... alles links}
    {... All at Right} {... alles rechts}
    {File List} {Liste von Dateien}
  }

  ## ________________________ --EONS-- _________________________ ##
}

# _ bartabs NS _ #

namespace eval ::bartabs {

  ## ________________________ Popup menu _________________________ ##

  ::msgcat::mcmset de {
    {List} {Liste}
    {behind} {hinter}
    {Close} {Schließen}
    {... All} {... alles}
    {... All at Left} {... alles links}
    {... All at Right} {... alles rechts}
  }

  ## ________________________ --EONS-- _________________________ ##
}

# _________________________________ EOF _________________________________ #
#RUNF1: ../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
