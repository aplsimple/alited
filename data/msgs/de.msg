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
    {Save and Close} {Speichern und Schließen}
    {Close and Delete} {Schließen und Löschen}
    {Preferences} {Einstellungen}
    {Preferences...} {Einstellungen ...}
    {Quit} {Beenden}
    {Put New Line} {Neue Zeile einfügen}
    {Remove Trailing Whitespaces} {Rechte Leerzeichen löschen}
    {Remove trailing whitespaces} {Rechte Leerzeichen löschen}
    {Remove trailing whitespaces:} {Rechte Leerzeichen löschen:}
    "Remove trailing whitespaces of all lines\nof \"%f\"?" "Rechte Leerzeichen aller Zeilen\nvon \"%f\" löschen?"
    {Indent} {Einrücken}
    {Unindent} {Nicht einrücken}
    {Comment} {Kommentieren}
    {Comment:} {Kommentar:}
    {Comments} {Kommentaren}
    {Uncomment} {Auskommentieren}
    {Find Next} {Finde Nächsten}
    {Look for Declaration} {Suche nach Erklärung}
    {Look for Word} {Suche nach Wort}
    {Run} {Ausführen}
    {Run...} {Ausführen...}
    {Run as Is} {Ausführen wie ist}
    {in console} {in Konsole}
    {in Tkcon} {in Tkcon}
    {as is} {wie es ist}
    {Moving} {Verschieben}
    {Color Picker} {Farbauswahl}
    {Date Picker} {Datumsausawahl}
    {Screen Loupe} {Bildschirmlupe}
    {Quitting alited.} {Beenden von alited.}
    {Wait a little ...} {Einen Augenblick ...}
    {Standard} {Standard}
    {Standard 2} {Standard 2}
    {Standard 3} {Standard 3}
    {Standard 4} {Standard 4}
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
    {Saved Lists of Favorites} {Gespeicherte Favoritenlisten}
    {Last Visited} {Zuletzt Besuchte}
    {Switch to Unit Tree} {Wechsel zu Einheitenbaum}
    {Switch to File Tree} {Wechsel zu Dateibaum}
    {Create File} {Datei erzeugen}
    {Create File...} {Datei erzeugen...}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Einen Namen eingeben für eine Datei, die erzeugt wird in:\n%d\n\nWenn es ein Verzeichnis ist, wähle 'Verzeichnis'-Box aus. Das Verzeichnis kann Unterverzeichnisse enthalten (a/b/c)."
    {Delete File} {Datei löschen}
    "\nFile \"%f\" already exists in\n%d\n" "\nDatei \"%f\" existinert schon in\n%d\n"
    "\nFile\n  \"%f\"\ndoesn't exist.\n" "\nDatei\n  \"%f\"\nexistiert nicht.\n"
    {Delete Unit(s)} {Einheit(en) löschen}
    {No item selected.} {Kein Element ausgewählt}
    {Update Tree} {Baum aktualisieren}
    {Contract All} {Alle kolabieren}
    {Expand All} {Alle erweitern}
    {Expand Selected} {Ausgewählte erweitern}
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
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open. This may be expensive!" "Alle Tcl-Dateien des Verzeichnisses:\n  \"%f\"  \nwerden geöffnet.\n\nDas kann aufwändig sein!"
    {Select All} {Alles auswählen}
    {Do it in other Tcl files} {Auch in anderer Tcl-Dateien}
    {Do it in other files} {Auch in anderer Dateien}
    {Selected files: %n} {Ausgewählten Dateien: %n}
    {Configurations...} {Konfigurationen...}
    {Tips on / off} {Tipps ein / aus}
    {Exit} {Ausgang}
    {Encoding} {Kodierung}
    {Reload with EOL} {Öffne mit EOL}
    "Save the file:\n%F ?" "Werden Sie die Datei speichern:\n%F ?"
    {Reload with Encoding} {Öffne mit die Kodierung}
    "Saving and reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nSave the file:\n%F ?" "Das Speichern und erneute Laden von \"%f\"\nmit der Kodierung \"%e\" kann falsch sein.\n\nWerden Sie die Datei speichern:\n%F ?"
    "Reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nReload the file:\n%F ?" "Das erneute Laden von \"%f\"\nmit der Kodierung \"%e\" kann falsch sein.\n\nWerden Sie die Datei laden:\n%F ?"
    {Color Values #hhhhhh} {Farbwerte #hhhhhh}
    {Display Colors} {Farben hervorheben}
    {Hide Colors} {Farben ausblenden}
    {Display colors in the whole text?} {Farben im gesamten Text hervorheben?}
    {check RE in Find/Replace box} {aktivieren Sie RE im Suchen/Ersetzen}
    {Context} {Kontext}
    {Changes will be lost!} {Änderungen werden verloren gehen!}
    {Marks} {Markierung}
    "Left click sets / goes to a mark.\nRight click clears it." "Linksklick setzt / geht zu eine Markierung.\nRechtsklick löscht es."
    {Clear All} {Alles löschen}
    {Width} {Breite}
    {Weeks in Calendar} {Wochen im Kalender}
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
    {Rewrite} {Überschreiben}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "Datei \"%f\" wurde durch eine Applikation geändert.\n\nBearbeitung beenden und Datei neu laden?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "Datei \"%f\" wurde durch eine Applikation gelöscht.\n\nDatei speichern?"
    {Tip File Info} {Tip-Datei Info}
    {Rename File} {Datei umbenennen}
    {Rename File...} {Datei umbenennen...}
    {Clone File} {Datei klonen}
    {Clone File...} {Datei klonen...}
    {Clone...} {Klonen...}
    {Select one file in the tree.} {Wähle eine Datei im Baum.}
    {Open Selected Files} {Öffne ausgewählte Dateien}
    {Close Selected Files} {Schliesse ausgewählte Dateien}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset de {
    {Template} {Vorlage}
    {Template:} {Vorlage:}
    {Templates} {Vorlagen}
    {Templates...} {Vorlagen...}
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
    {Project:} {Projekt:}
    {Root directory:} {Basisverzeichnis:}
    {Skip files/directories:} {Überspringe Dateien/Verzeichnisse:}
    {Description:} {Beschreibung:}
    {Indentation:} {Einrücken:}
    {Auto detection} {Autoerkennung}
    {End of line:} {Zeilenende:}
    {Multi-line strings:} {Mehrzeilige Zeichenketten:}
    {Unit lines per 1 red bar:} {Einheitenlinien pro roten Balken:}
    {List of files (%n):} {Dateiliste (%n):}
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
    "Directory \"%d\"\ndoesn't exist.\n\nCreate it?" "Verzeichnis \"%d\"\nexistiert nicht.\n\nErzeugen?"
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
    {TODO reminders for the past: %d.} {TODO Erinnerungen an die Vergangenheit: %d.}
    {No selected files} {Keine ausgewählte(n) Datei(en)}
    {Open file:} {Ausgewählt Datei:}
    {Open files: %n} {Ausgewählten Dateien: %n}
    {TODO previous day} {TODO auf vorherigen Tag}
    {TODO previous week} {TODO auf vorherige Woche}
    {TODO next day} {TODO auf folgenden Tag}
    {TODO next week} {TODO auf folgende Woche}
    on zum
    {Incorrect name: "%n"} {Inkorrekter Name: "%n"}
    {The project template is empty!} {Die Projektvorlage ist leer!}
    {Incorrect indentation in Project template: %n} {Inkorrekt Einrücken in der Projektvorlage: %n}
    "Enter a tree of directories for the project template.\nIndent them by equal indents to mean subdirectories.\n\nFiles like README*, CHANGELOG* will be created blank.\nFiles like LICENSE* will be taken from the current project." "Geben Sie einen Verzeichnisbaum für die Projektvorlage ein.\nVersehen Sie ihn mit gleichem Einrücken, um Unterverzeichnisse zu bedeuten.\n\nDateien wie README*, CHANGELOG* werden leer erstellt.\nDateien wie LICENSE* werden aus dem aktuellen Projekt übernommen."
    {Create a project by template} {Ein Projekt nach Vorlage erstellen}
    {Project directory} {Projektverzeichnis}
    {Command} {Befehl}
    {Commands} {Befehle}
    {For project} {Für dem Project}
    {%n commands will be executed!} {%n Befehle werden ausgeführt!}
    {Maximum commands reached: %n, current: %i (see Project/Options)} {Maximal Befehle erreicht: %n, aktuell: %i (sehen Sie Projekt/Optionen)}
    {Maximum Run commands} {Maximal Ausführen Befehle}
    {The project directory already exists! It isn't created with templates.} {Das Projektverzeichnis existiert bereits! Es wird nicht mit Vorlagen erstellt.}
    {All files filter:} {Alle Dateien filtern:}
    {TODO days ahead:} {TODO Tage vorwärts:}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset de {
    {Current list of favorites} {Aktuelle Favoritenliste}
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
    {Favorites Lists...} {Favoritenliste...}
    "Add \"%n\" of %f\nto Favorites?" "Füge \"%n\" von %f\nzu Favoriten hinzu?"
    "Item \"%n\" of %f\nis already in Favorites." "Element \"%n\" von %f\nexistiert schon in Favoriten."
    "Remove \"%n\" of %f\nfrom Favorites?" "Lösche \"%n\" von  %f\naus Favoriten?"
    "\"%n\" unit of %f is not in the list." "Einheit \"%n\" von %f ist nicht in der Liste"
    {Add to Favorites} {Zu Favoriten hinzufügen}
    {Favorite name:} {Favoritename:}
    {Rename} {Umbenennen}
    {Delete} {Löschen}
    {Delete All} {Alles löschen}
    {Delete all of Favorites?} {Alle Favoriten löschen?}
    {Delete all of the last visited?} {Alle zuletzt Besuchten löschen?}
    {Favorites / Last Visited} {Favoriten / Zuletzt Besuchten}
    {Opens files with current favorites.} {Öffnet Dateien mit aktuellen Favoriten.}
    {Number of files to open: %n} {Anzahl der zu öffnenden Dateien: %n}
    "Add .tcl files of current session\nas the favorites" "Hinzufügen .tcl Dateien der aktuellen Sitzung\nals Favoriten"
    {No .tcl files found in the session} {Keine .tcl Dateien in der Sitzung gefunden}
    "\n Save as favorites list: selected (%s) or all (%a) files?\n" "\n Speichern als Favoritenliste: ausgewählt (%s) oder alle (%a) Dateien?\n"
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset de {
    "Create a file\nCtrl+N" "Datei erzeugen\nCtrl+N"
    "Open a file\nCtrl+O" "Datei öffnen\nCtrl+O"
    {Save the file} {Datei speichern}
    "Save all files\nCtrl+Shift+S" "Alle Dateien speichern\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Tcl/Tk-Hilfe auf die Auswahl anwenden\nF1"
    {Find / Replace} {Suchen / Ersetzen}
    "Find / Replace\nCtrl+F" "Suchen / Ersetzen\nCtrl+F"
    {Run the file} {Datei ausführen}
    {Run e_menu} {Führe e_menu aus}
    "Undo changes\nCtrl+Z" "Änderungen zurücknehmen\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Wiederherstellen\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset de {
    {Find: } {Finde: }
    {Replace: } {Ersetze: }
    {Match: } {Entsprechen: }
    {Exact} {Exakt}
    {Match whole word} {Ganze Wörter vergleichen}
    {Match case} {Groß.-/Kleinschreibung}
    {Wrap} {Fortsetze}
    {Replace by blank} {Ersetzte durch freie Stelle}
    {Down} {Abwärts}
    {Up} {Aufwärts}
    {Stay on top} {Bleibe oben}
    {Stay on top:} {Bleibe oben:}
    {Find} {Finde}
    {Replace} {Ersetze}
    {All in text} {Alle in Text}
    {All in session} {Alle in Sitzung}
    {All in %n Files} {Alle in %n Dateien}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Erlaubt die Verwendung von *, ?, \[ und \]\n  im Suchstring."
    "Allows to use the regular expressions\nin \"find\" string." "Erlaubt die Verwendung von RE\n  im Suchstring."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Erlaubt das Ersetzen durch eine leere Zeichenkette,\num faktisch die Funde zu löschen."
    "Keeps the dialogue above other windows." "Behält Dialoge oberhalb anderer Fenster."
    "Found %n matches for \"%s\"." "%n Treffer gefunden für \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "%n Ersetzungen von \"%s\" mit \"%r\" in \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "%n Ersetzungen von \"%s\" mit \"%r\" in allen Dateien der Sitzung."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "Ersetzte alle Vorkommen von \"%s\"\n\n mit \"%r\"\n\n in \"%f\" ?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all%Stexts?" "Ersetzte alle Vorkommen von \"%s\"\n\n mit \"%r\"\n\n in allen%SDateien der Sitzung?"
    {Don't focus a text after selecting in infobar} {Nicht den Text fokussieren nach der Auswahl in der Infoleiste}
    {Focus a text after selecting in infobar} {Fokussiere den Text nach Auswahl in der Infoleiste}
    {Find by List} {Suche nach Liste}
    {List:} {Liste:}
    { Enter a list of words divided by spaces:} { Eine Liste von durch Leerzeichen getrennten Wörter eingeben:}
    {FOUND:} {TREFFER:}
    {NOT FOUND:} {KEIN TREFFER:}
    "Use this geometry of the dialogue\nby default" "Standardmäßig diese Geometrie\ndes Dialogs verwenden"
    "Paste 'Find'\nCtrl+R" "'Finde' einfügen\nCtrl+R"
    {Not found: %s} {Nicht gefunden: %s}
    {Resize} {Ändere Grössen}
    {Including RE2:} {Einschließende RE2:}
    {Excluding RE2:} {Ausschließende RE2:}
    "Including / excluding\nregular expressions." {Einschließende / ausschließende RE.}
  }

  ## ________________________ Start and update ________________________ ##
  ::msgcat::mcmset de {
    {Choosing Directory for Settings} {Verzeichnis für die Konfiguration auswählen}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n"
    "\n \"alited\" benötigt ein Konfigurationsverzeichnis um die Einstellungen zu speichern.\n Du kannst den Namen an alited als Argument übergeben.\n\n Das vorgegebene Konfigurationsverzeichnis ist \"%d\".\n Dies ist zu bevorzugen um  \"alited\" ohne Argumente zu benuzten.\n"
    {Choose a directory} {Verzeichnis auswählen}
    {Some things have been changed in alited %v.} {Im alited %v hat sich etwas geändert.}
    {Updating alited} {Aktualisierung alited}
    " You are highly recommended to accept\n these changes in order to complete updating:" " Es wird dringend empfohlen, diese Änderungen zu akzeptieren,\n um die Aktualisierung abzuschließen:"
    {.em files for "Tools"} {.em Dateien für "Werkzeugen"}
    {.ini file for "Templates"} {.ini Datei für "Vorlagen"}
    { Your previous files will be saved to:} { Ihre Dateien gesichert werden zu:}
    {View Changes} {Zeigen Änderungen}
  }

  ## ________________________ "About" dialogue ________________________ ##
  ::msgcat::mcmset de {
    {Written in pure Tcl/Tk.} {Nur in Tcl/Tk geschrieben.}
    {And well fit for programming with it.} {Und gut geeignet um damit zu Programmierung.}
    {Details:} {Details:}
    {Authors:} {Authoren:}
    {License:} {Lizens:}
    {Acknowledgements} {Anerkennungen}
    "Many thanks to the following people \
    \n who have contributed to this project \
    \n with their participation, advice and code"
    "Vielen Dank an die folgenden Personen, \
    \n die zu diesem Projekt beigetragen haben \
    \n mit ihrer Teilnahme, Beratung und Code"
    {Special thanks also to} {Besonderen Dank auch an}
    {Packages} {Pakete}
    {Packages used by <red>alited %ver</red>:} {Von <red>alited %ver</red> verwendete Pakete:}
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
    {Windows themes} {Windows Themen}
    {Darker:} {Dunkler:}
    {Lighter:} {Heller:}
    {Tint} {Farbton}
    {Tint:} {Farbton:}
    "For the settings to be active,\nalited application should be restarted." "Damit die Konfigurationsänderunge aktiv werden\nmuss die Applikation alited neu gestartet werden."
    {Preferable locale:} {Bevorzugte Sprache:}
    "This is a language code: ru, uk, de...\nIn alited, \"en\" means American English." "Das ist einer der folgenden Sprachenkodes: ru, uk, de...\nIn alited \"en\" bedeutet American English."
    {Small font size:} {Schmaler Zeichensatz:}
    {Middle font size:} {Mittlerer Zeichensatz:}
    {Cursor width:} {Kursorbreite:}
    {Color of cursor:} {Kursorfarbe:}
    {Notes:} {Notizen:}
    "Sort of diary.\nList of TODOs etc." "Eine Art Tagebuch.\nListe offener Punkte usw."
    {Light / Dark} {Hell / Dunkel}
    {Makes colors darker .. lighter} {Macht Farben dunkler .. heller}
    "These themes need\nlight / dark color schemes\naccordingly" "Diese Themen benötigen\nhelle / dunkle Farbschemas\nentsprechend"
    {Fit for theme} {Gut geeignet zu Theme}
    {No color scheme at all} {Keine Farbschema überhaupt}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset de {
    {Font:} {Zeichensatz:}
    {Gutter's width:} {Breite Zwischensteg}
    {Gutter's shift from text:} {Zwischensteg's Verschiebung von Text:}
    {Space above lines:} {Platz über Zeilen:}
    {Space below lines:} {Platz unter Zeilen:}
    {Space between wraps:} {Platz zwischen Umbrüche:}
    {Tab bar label's length:} {Tab-Leiste Beschriftungslänge:}
    {Tab bar tip's length:} {Tab-Leiste Tiplänge:}
    {Border for bar tabs:} {Borte für Tab-Leiste:}
    {Code snippet:} {Codeausschnitt:}
    {Blinking cursor:} {Blinkender Cursor:}
    {Translation} {Übersetzung}
    {Translation link:} {Übersetzungslink:}
    {Adding translations:} {Übersetzungen hinzufügen:}
    {If OFF, replaces the original text.} {Wenn AUS, ersetzt den Originaltext.}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset de {
    {Save before bar-menu runs:} {Speichern bevor bar-menu ausgeführt wird:}
    {All files} {Alle Dateien}
    {Current} {Aktuelle}
    {None} {Keine}
    {'Recent Files' length:} {Maximale Anzahl 'Letzte Dateien':}
    {'Last Visited' length:} {Maximale Anzahl 'Zuletzt besuchte':}
    {Maximum of project files:} {Maximale Anzahl Projetdateien:}
    {Confirm exit:} {Bestätige beenden:}
    {Save configuration on} {Speicher Konfiguration}
    {opening a file:} {Öffne eine Datei:}
    {closing a file:} {Schließe eine Datei:}
    {saving a file:} {Sichere eine Datei}
    {Back up files to a project's subdirectory:} {Sichere Dateien in ein Unterverzeichnis des Projektes:}
    "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." "Ein Unterverzeichnis von Projekten indem Sicherungskopien der Dateien gesichert werden.\nFeld leeren um Backup abzubrechen."
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

  ### ________________________ Templates tab _________________________ ###
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
    {Branch's regexp:} {RE für Zweige:}
    {Proc's regexp:} {RE für Prozeduren:}
    {Check branch's regexp:} {Prüfe RE für Zweige:}
    {Check proc's regexp:} {Prüfe RE für Prozeduren:}
    {Use leaf's regexp:} {Benutze RE für Endpunkte:}
    {Leaf's regexp:} {RE für Endpunkte:}
    {Unaffected top lines:} {Unveränderte obere Zeilen:}
    {For leaf units only!} {Nur für Endpunkten!}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset de {
    {Open bar-menu settings} {Öffne bar-menu Einstellungen}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Ein Icon fügt das Ausführelement der Symbolleiste hinzu.\nLeer oder 'none' entfernt es aus der Symbolleiste."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "Das Ausführungselement für das Menü und/oder die Symbolleiste.\nWähle Du es aus dem e_menu-Einträgen aus."
    {Directory of menus:} {Menüverzeichnis:}
    {Main menu:} {Hauptmenü:}
    {Projects (%PD wildcard):} {Projekte (%PD Platzhalter):}
    {Linux terminal:} {Linux Terminal:}
    {Diff tool:} {Diff-Werkzeug:}
    {Path to man/tcl:} {Pfad von man/tcl:}
    {tclsh, wish or tclkit:} {tclsh, wish oder tclkit:}
    {Geometry:} {Geometrie:}
    {Run as external app:} {Eine externe App ausführen:}
    {Delete an item} {Ein Eintrag löschen}
    {Move an item up} {Ein Eintrag verschieben abwärts}
    {Move an item down} {Ein Eintrag verschieben aufwärts}
    {separator} {Trennezichen}
    {If 'yes', means a separator of the toolbar/menu.} {'ja' bedeutet Trennzeichen in der Werkzeugliste/Menü.}
    {For Start...} {Für dem Starten...}
    " Enter commands to be run after starting alited.\n They can be Tcl or executables:" " Geben Sie Befehle ein, die nach dem Starten von alited ausgeführt werden sollen,\n das heißt Tcl Befehle oder ausführbare Dateien:"
    {By command:} {Durch Befehl:}
    {By #RUNF: / #EXEC:} {Durch #RUNF: / #EXEC:}
    {Run:} {Ausführe:}
    {Run it} {Ausführe}
    { OS or Tcl commands to be run before running a current file:} {OS oder Tcl Befehle, die ausgeführt werde bevor die aktuelle Datei ausgeführt wird:}
    { Also, you can set "forced command" to be run by "Run" tool:} { Ebenfalls, können Sie festlegen "erzwungener Befehl" für Ausführen:}
    {Forcedly:} {Zwangsweise:}
    {e_menu's own} {e_menu eigen}
    {Select any of run item} {Wähle ein Ausführens Element}
    "Incorrect \"Preferences/Tools/tclsh...\"\nresults in the error:" "Falsche \"Einstellungen/Werkzeuge/tclsh...\"\nergibt den Fehler:"
    {Set a Linux terminal in Preferences/Tools} {Legen Sie ein Linux Terminal in den Einstellungen/Werkzeuge fest}
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset de {
    {Check Tcl} {Überprüfe Tcl}
    {Check Tcl...} {Überprüfe Tcl...}
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
    {Errors found in unit:} {Fehlern gefunden in Einheit:}
    {Duplicate units} {Dupliziere Einheit}
    {duplicate unit:} {Dupliziere Einheit:}
  }

  ## ________________________ Macros ________________________ ##
  ::msgcat::mcmset de {
    "The macro is updated at its recording.\nPress %s to play it." "Das Makro wird bei der Aufnahme aktualisiert.\nDrücken Sie %s, um es wiederzugeben."
    {Playing:} {Wiedergabe:}
    {Recording:} {Aufnahme:}
    {Play Macro} {Makro wiedergeben}
    {Record Macro} {Makro aufnehmen}
    {Delete Macro} {Makro löschen}
    {Record mouse} {Maus aufnahmen}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset de {
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
  ::msgcat::mcmset de {
    {Row} {Zeile}
    {Row } {Zeil }
    { Col } { Spal }
    {    Unit: } {   Einheit: }
  }

  ## ________________________ Bar of tabs ________________________ ##
  ::msgcat::mcmset de {
    {(Un)Select} {Auswählen/Abwählen}
    {... Visible} {... sichtbar}
    {... All} {... alles}
    {... All at Left} {... alles links}
    {... All at Right} {... alles rechts}
    {File List} {Liste von Dateien}
    {Sort} {Sortieren}
    {Sort files} {Sortieren Dateien}
    {Sorted} {Sortiert}
    {... by date} {... nach Datum}
    {... by size} {... nach Grösse}
    {... by extension} {... nach Dateiendung}
    {increasing} {ansteigend}
    {decreasing} {absteigend}
    {Files to Beginning} {Dateien zum Anfang}
    "If it's checked, open files would be placed\nonto the beginning page of the bar." "Wenn das ist aktiviert, geöffnete Dateien\nauf der Anfangsseite der Leiste platziert werden."
  }

  ## ________________________ Paver _________________________ ##

  ::msgcat::mcmset de {
    {For paveWindow's widget list to be recognized, set the cursor inside it.} {Damit die Widget-Liste von paveWindow erkannt wird, setzen Sie den Cursor hinein.}
    {Auto Update} {Automatische Aktualisierung}
    {Widget List} {Widget-Liste}
  }

  ## ____________________ Rectangular selection ___________________ ##

  ::msgcat::mcmset de {
    {Rectangular Selection} {Rechteckige Auswahl}
    {Start} {Beginnen}
    {Cut} {Schneiden}
    {Copy} {Kopieren}
    {Paste} {Einfügen}
    {Move the cursor to select a rectangle.} {Bewegen Sie den Cursor, um ein Rechteck auszuwählen.}
  }

  ## ________________________ Formats _________________________ ##

  ::msgcat::mcmset de {
    {Formats} {Formate}
    {Moving Unit Descriptions} {Einheitebeschreibungen verschieben}
    {Moving Unit Descriptions...} {Einheitebeschreibungen verschieben...}
    {Move Unit Descriptions} {Einheitebeschreibungen verschieben}
    {Selected} {Ausgewählt}
    {Move proc/method descriptions:} {Verschieben proc/method Beschreibungen:}
    {From inside to out} {Von innen nach außen}
    {From out to inside} {Von außen nach innen}
    {Separator:} {Separator:}
    {Process .tcl file(s):} {Bearbeiten .tcl Datei(en):}
    " Current leaf's RE\n\n   <r>%r1</r>\n\n is not equal to standard\n\n   <r>%r2</r>\n\n as set in Projects/Options and Preferences/Units."
    " Aktuel Endpunktes RE\n\n   <r>%r1</r>\n\n ist nicht gleich standard\n\n   <r>%r2</r>\n\n wie gesetzt in Projekte/Optionen und Einstellungen/Einheiten."
    "The separator doesn't match to the regexp:\n\n  "
    "Der Separator passt nicht dazu RE:\n\n  "
    {Separator must contain "n" or "N" for unit name!}
    {Separator muss "n" oder "N" für Einheitsname enthalten!}
    {The separator should be Tcl comment!} {Der Separator sollte Tcl Kommentar sein!}
    {Were all files properly backed up?} {Waren alle Dateien richtig gesichert?}
    "PROJECT OPTION \"Use leaf's regexp\" SWITCHED TEMPORARILY TO "
    "PROJECTS OPTION \"Benutze RE für Endpunkte\" VORÜBERGEHEND UMGESCHALTET ZU "
    {Files processed successfully: %n} {Erfolgreich verarbeitete Dateien: %n}
    {%f processed, units affected: %n} {%f bearbeitet, Einheiten berührt: %n}
    {%f processed, units affected: %n - ALREADY PROCESSED?}
    {%f bearbeitet, Einheiten berührt: %n - BEREITS VERARBEITET?}
    {ERROR} {FEHLER}
    {Strings} {Zeichenketten}
    {Keyboard} {Schlüsselanhänger}
    {Sorting lines} {Sortieren der Zeilen}
    {Misc} {Diverses}
    {External} {Extern}
    {Pluginable} {Steckbar}
    {Applied to one selection only!} {Nur auf eine Auswahl angewendet!}
    "Incorrect mapped 'from-to' in: %l" "Inkorrekt kartiert 'von-zu' in: %l"
    "'from' refers to previous 'to' in: %l (see: %n)" "'von' bezieht sich auf vorherige 'zu' in: %l (sehen Sie: %n)"
    {Use %e to run "%m"} {Benutze %e um "%m" auszuführen}
    {%e is overlapped by formatter "%f"} {%e wird vom Formatierer "%f" überlappt}
  }

  ## ________________________ Project printer _________________________ ##

  ::msgcat::mcmset de {
    {Project Printer} {Projektdrucker}
    {Project Printer...} {Projektdrucker...}
    {Output directory:} {Ausgabeverzeichnis:}
    {Markdown processor:} {Markdown-Prozessor:}
    {Directory title colors} {Farben für Verzeichnistitel}
    {Foreground:} {Vordergrund:}
    {Background:} {Hintergrund:}
    {File title colors} {Farben für Dateititel}
    {Syntax colors:} {Farben für Syntax:}
    {Width of contents:} {Breite des Inhalts:}
    {Final processor:} {Endverarbeiter:}
    {Output directory cannot be cleared: alien files} {Ausgabeverzeichnis dies kann nicht gelöscht werden: fremde Dateien}
    {Output directory cannot be cleared: alien %n} {Ausgabeverzeichnis dies kann nicht gelöscht werden: fremde %n}
    {Output directory cannot be cleared: alien directories} {Ausgabeverzeichnis kann nicht gelöscht werden: fremde Verzeichnisse}
    "The output directory\n  %n\ncontains %c subdirectories.\n\nAll will be replaced with the new!" "Ausgabeverzeichnis\n  %n\nenthält %c Unterverzeichnisse.\n\nAlle werden durch die neuen ersetzt!"
    {Sort units:} {Sortieren Einheiten:}
    {Runs the final processor.} {Führt den Endverarbeiter aus.}
  }

  ## ________________________ EONS alited _________________________ ##
}

# _ apave NS _ #

namespace eval ::apave {
  ::msgcat::mcmset de {
    {Save text} {Text speichern}
    {Don't save} {Nicht speichern}
    {Save changes made to the text?} {Änderungen am Text speichern?}
  }
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
}

# _________________________________ EOF _________________________________ #
