###########################################################
# Name:    es.msg
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    11/02/2023
# Brief:   Handles Spanish localization.
# License: MIT.
###########################################################

# ________________________  alited NS _________________________ #

namespace eval ::alited {

  ## ________________________ Common _________________________ ##

  ::msgcat::mcmset es {
    {No name} {Sin nombre}
    "\"%f\" wasn't saved.\n\nSave it?" "\"%f\" no se guardó.\n\n¿Guardarlo?"
    {About} {Acerca de}
    {About...} {Acerca de...}
    {Error} {Error}
    {Warning} {Advertencia}
    {Question} {Pregunta}
    {Information} {Información}
    {File} {Archivo}
    {Edit} {Editar}
    {Search} {Buscar}
    {Tools} {Herramientas}
    {Setup} {Configuración}
    {Help} {Ayuda}
    {Yes} {Sí}
    {No} {No}
    {Cancel} {Cancelar}
    {Close} {Cerrar}
    {New} {Nuevo}
    {Open...} {Abrir...}
    {Recent Files} {Archivos recientes}
    {Save} {Guardar}
    {Save as...} {Guardar como...}
    {Save All} {Guardar todos}
    {Save and Close} {Guardar y cerrar}
    {Close and Delete} {Cerrar y borrar}
    {Preferences} {Preferencias}
    {Preferences...} {Preferencias...}
    {Quit} {Salir}
    {Put New Line} {Crear línea}
    {Remove Trailing Whitespaces} {Borrar espacios finales}
    {Remove trailing whitespaces} {Borrar espacios finales}
    {Remove trailing whitespaces:} {Borrar espacios finales:}
    "Remove trailing whitespaces of all lines\nof \"%f\"?" "¿Borrar los espacios finales de todas las líneas\nde \"%f\"?"
    {Indent} {Indénter}
    {Unindent} {Desindénter}
    {Comment} {Comentar}
    {Uncomment} {Descomentar}
    {Find Next} {Buscar siguiente}
    {Look for Declaration} {Buscar declaración}
    {Look for Word} {Buscar palabra}
    {Run} {Ejecutar}
    {Run...} {Ejecutar...}
    {in console} {en terminal}
    {in Tkcon} {en Tkcon}
    {Moving} {Mudanza}
    {Color Picker} {Selector de color}
    {Date Picker} {Selector de fecha}
    {Screen Loupe} {Lupa de pantalla}
    {Quitting alited.} {Dejar alited.}
    {Wait a little ...} {Espera un poco ...}
    {Standard} {Standard}
    {Standard 2} {Standard 2}
    {Standard 3} {Standard 3}
    {Standard 4} {Standard 4}
    {Test} {Ensayar}
    {Correct Indentation} {Correctar sangría}
    "Correct the indentation of \"%f\"\nwith indenting %i spaces?" "¿Corregir la sangría de \"%f\"\ncon sangría de espacios %i?"
    {The line %n: unbalanced brace!} {¡La línea %n: abrazadera desequilibrada!}
    {Wrap Lines} {Enrollar líneas}
    {Default values for new projects:} {Valores predeterminados para nuevos proyectos:}
  }

  ::msgcat::mcmset es {
    {Select} {Seleccionar}
    {Save as} {Guardar como}
    {Files} {Archivos}
    {Line} {Línea}
    {Lines} {Líneas}
    "All of \"%f\"" "Todo de \"%f\""
    "Not recommended for projects\nwith large files (>2000 LOC)!" "¡No recomendado para proyectos con archivos grandes (>2000 LOC)!"
    {Move Unit Up} {Mover la unidad hacia arriba}
    {Move Unit Down} {Mover la unidad hacia abajo}
    {Move File Up} {Mover archivo hacia arriba}
    {Move File Down} {Mover archivo hacia abajo}
    {Only files are moved by alited.} {Solo los archivos son movidos por alited.}
    {Saved Lists of Favorites} {Listas de favoritos guardadas}
    {Last Visited} {Últimas visitas}
    {Switch to Unit Tree} {Cambiar por árbol de unidades}
    {Switch to File Tree} {Cambiar por árbol de archivos}
    {Create File} {Crear archivo}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Introduzca un nombre de archivo para crear en:\n %d\n\nSi es una carpeta, marque 'Carpeta'.\nLa carpeta puede incluir subcarpetas (a/b/c)."
    {Delete File} {Borrar archivo}
    "\nFile \"%f\" already exists in\n%d\n" "\nEl archivo \"%f\" ya existe en\n%d\n"
    "\nFile\n  \"%f\"\ndoesn't exist.\n" "\nEl archivo\n  \"%f\"\nno existe.\n"
    {Delete Unit(s)} {Borrar unidad(es)}
    {No item selected.} {No hay ningún elemento seleccionado.}
    {Update Tree} {Actualizar árbol}
    {Contract All} {Contratar todo}
    {Expand All} {Expandir todo}
    "Move %f\nto\n%d\n?" "¿Mover %f\nen\n%d\n?"
    {To Last Visited} {A la última visita}
    {To Matched Bracket} {Al corchete emparejado}
    {Go to Line} {Ir a la línea}
    {Line number:} {Fila de línea:}
    {    In unit:} {    En unidad:}
    "\"%n\" contains unbalanced {}: %1!=%2" "\"%n\" contiene desequilibrado {}: %1!=%2"
    {Back} {Atrás}
    {File not found: %f} {Archivo no encontrado: %f}
    {Unit not found: %u} {Unidad no encontrada: %u}
    {Don't show anymore} {No mostrar más}
    {%f is a directory} {%f es una carpeta}
    {THE EXTERNAL FILE IS MOVED TO THE PROJECT!} {¡EL ARCHIVO EXTERNO SE MUEVE AL PROYECTO!}
    {Drop Selected Units Here} {Colocar las unidades seleccionadas aquí}
    {Drop Selected Files Here} {Colocar los archivos seleccionados aquí}
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open. This may be expensive!" "Todos los archivos Tcl de esta carpeta:\n  \"%f\" \nse abrirán. ¡Esto puede ser costoso!"
    {Select All} {Seleccionar todo}
    {Do it in other Tcl files} {Hazlo en otros archivos Tcl}
    {Do it in other files} {Hazlo en otros archivos}
    {Selected files: %n} {Archivos seleccionados: %n}
    {Configurations...} {Configuraciones...}
    {Tips on / off} {Sugerencias on / off}
    {Exit} {Salida}
    {Encoding} {Codificación}
    {Reload with EOL} {Recargar con EOL}
    "Save the file:\n%F ?" "¿Guardar el archivo:\n%F ?"
    {Reload with Encoding} {Recargar con codificación}
    "Saving and reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nSave the file:\n%F ?" "Guardar y recargar \"%f\"\ncon la codificación \"%e\" puede resultar incorrecto.\n\n¿Guardar el archivo:\n%F ?"
    "Reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nReload the file:\n%F ?" "Recargar \"%f\"\ncon la codificación \"%e\" puede resultar incorrecto.\n\n¿Recargar el archivo:\n%F ?"
    {Color Values #hhhhhh} {Valores de color #hhhhhh}
    {Display Colors} {Mostrar colores}
    {Hide Colors} {Apagar colores}
    {Display colors in the whole text?} {¿Mostrar colores en todo el texto?}
    {check RE in Find/Replace box} {marque RE en Buscar/Reemplazar}
    {Context} {Contexto}
    {Changes will be lost!} {¡Los cambios se perderán!}
  }

  ## ________________________ Moving a first unit up ________________________ ##
  ::msgcat::mcmset es {
    {First Lines} {Primeras líneas}
    {Can't touch the first %n lines.} {No se pueden tocar las primeras %n líneas.}
  }

  ## ________________________ Tree ________________________ ##
  ::msgcat::mcmset es {
    "Click \"%t\"" "Haga clic en\"%t\""
    {Copy Declaration} {Copiar la declaración}
    "Open All Tcl Files of \"%n\"" "Abrir todos los archivos Tcl de\"%n\""
    "Remove \"%n\"\nfrom \"%f\"?" "¿Borrar \"%n\"\nde \"%f\"?"
    "Delete \"%f\"?" "¿Borrar \"%f\"?"
    {Rewrite} {Reescribir}
    {An open file can not be deleted:} {Un archivo abierto no se puede borrar:}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "El archivo \"%f\" fue modificado por alguna aplicación.\n\n¿Cancelar la edición y recargar el archivo?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "El archivo \"%f\" fue borrado por alguna aplicación.\n\n¿Guardar el archivo?"
    {Tip File Info} {Información del archivo}
    {Rename File} {Renombrar archivo}
    {Select one file in the tree.} {Seleccionar un archivo en el árbol.}
    {Open Selected Files} {Abrir archivos seleccionados}
    {Close Selected Files} {Cerrar archivos seleccionados}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset es {
    {Template} {Plantilla}
    {Template:} {Plantilla:}
    {Templates} {Plantillas}
    {Templates...} {Plantillas...}
    {List of Templates} {Lista de plantillas}
    {Current template:} {Plantilla actual:}
    {New template:} {Nueva plantilla:}
    {Hot keys} {Teclas rápidas}
    {Add a template} {Añadir una plantilla}
    {Change a template} {Cambiar una plantilla}
    {Delete a template} {Borrar una plantilla}
    {Click a template} {Haga clic en una plantilla}
    {The template #%n added} {La plantilla #%n añadida}
    {The template #%n updated} {La plantilla #%n actualizada}
    {The template #%n removed} {La plantilla #%n borrada}
    {Enter a name of the template} {Introduzca un nombre de la plantilla}
    {Enter a text of the template} {Introduzca un texto de la plantilla}
    "Choose a hot key combination\nfor the template insertion." "Elija una combinación de teclas rápidas\npara la inserción de la plantilla."
    {A template with the attribute(s) already exists.} {Ya existe una plantilla con estos atributos.}
    {Place after:} {Colocar después:}
    {line} {línea}
    {unit} {unidad}
    {cursor} {cursor}
    {file's beginning} {comienzo del archivo}
    "Inserts a template\nbelow a current line" "Inserta una plantilla\ndebajo de una línea actual"
    "Inserts a template\nbelow a current unit" "Inserta una plantilla debajo de una unidad actual"
    "Inserts a template at the cursor\n(good for one-liners)" "Inserta una plantilla en el cursor\n(bueno para plantillas de una sola línea)"
    "Inserts a template after 1st line of a file\n(License, Introduction etc.)" "Inserta una plantilla después de la primera línea de un archivo\n (Licencia, Introducción, etc.)"
    {Delete a template #%n ?} {¿Borrar una plantilla #%n ?}
    "Import templates\nfrom external alited.ini" "Importar plantillas desde alited.ini externo"
    {Number of imported templates: %n} {Número de plantillas importadas: %n}
    "Indents a template at inserting,\nby an insertion line's indentation." "Indénta una plantilla al insertar,\npor la sangría de una línea de inserción."
  }

  ## ________________________ Projects ________________________ ##
  ::msgcat::mcmset es {
    {Projects} {Proyectos}
    {Projects...} {Proyectos...}
    {You are going to %n!} {¡Vas a %n!}
    {Add a project} {Añadir un proyecto}
    {Change a project} {Cambiar un proyecto}
    {Delete a project} {Borrar un proyecto}
    {Don't delete the current project!} {¡No borre el proyecto actual!}
    "The project \"%n\" added" "El proyecto \"%n\" añadido"
    "The project \"%n\" updated" "El proyecto \"%n\" actualizado"
    "The project \"%n\" removed" "El proyecto \"%n\" borrado"
    {Options} {Opciones}
    {Project:} {Proyecto:}
    {Root directory:} {Carpeta raíz:}
    {Skip subdirectories:} {Omitir subcarpetas:}
    {Description:} {Descripción:}
    {Indentation:} {Sangría:}
    {Auto detection} {Detección automática}
    {End of line:} {Fin de línea:}
    {Multi-line strings:} {Cadenas multilínea:}
    {Unit lines per 1 red bar:} {Líneas de unidad por 1 marca roja:}
    {List of files (%n):} {Lista de archivos (%n):}
    {Add} {Añadir}
    {Substitute} {Substituir}
    {Delete} {Borrar}
    {Don't change} {No cambies}
    {Click a project} {Haga clic en un proyecto}
    "Delete a project \"%n\" ?" "¿Borrar un proyecto \"%n\" ?"
    "A project \"%n\" already exists." "Ya existe un proyecto \"%n\"."
    "A project \"%n\" doesn't exists. Hit \[+\] button to create it." "Un proyecto \"%n\" no existe. Pulse el botón \[+\] para crearlo."
    "All modified files (%n) will be saved.\n\nDo you agree?" "Se guardarán todos los archivos modificados (%n).\n\n¿Estás de acuerdo?"
    "All selected files (%n) will remain open\nin the project you are switching to.\n\nDo you agree?" "Todos los archivos seleccionados (%n) permanecerán abiertos en el proyecto por que está cambiando.\n\n¿Estás de acuerdo?"
    "Directory \"%d\"\ndoesn't exist.\n\nCreate it?" "La carpeta \"%d\"\nno existe.\n\n¿Crearla?"
    {Checking %d. Wait a little...} {Comprobando %d. Espere un poco...}
    {Too big directory for a project: %n files or more.} {Carpeta demasiado grande para un proyecto: %n archivos o más.}
    {Options for new projects are set in "Preferences/General/Projects"} {Las opciones para nuevos proyectos se establecen en "Preferencias/General/Proyectos"}
    {Date} {Fecha}
    {Reminder} {Recordatorio}
    {Erase a text} {Borrar un texto}
    {Paste a text} {Pegar un texto}
    {Undo changes} {Deshacer cambios}
    {Redo changes} {Rehacer cambios}
    {Text of a reminder} {Texto de un recordatorio}
    {TODO reminders for the past: %d.} {Recordatorios del pasado: %d.}
    {No selected files} {No hay archivos seleccionados}
    {Open file:} {Abrir archivo:}
    {Open files: %n} {Abrir archivos: %n}
    {TODO previous day} {TODO día anterior}
    {TODO previous week} {TODO semana anterior}
    {TODO next day} {TODO día siguiente}
    {TODO next week} {TODO semana siguienta}
    {on} {en}
    {Incorrect name: \"%n\"} {Nombre incorrecto: \"%n\"}
    {The project template is empty!} {¡La plantilla del proyecto está vacía!}
    {Incorrect indentation in Project template: %n} {Sangría incorrecta en la plantilla de proyecto: %n}
    "Enter a tree of directories for the project template.\nIndent them by equal indents to mean subdirectories.\n\nFiles like README*, CHANGELOG* will be created blank.\nFiles like LICENSE* will be taken from the current project." "Introduzca un árbol de carpetas para la plantilla de proyecto.\nIndéntelos con sangrías iguales para significar subcarpetas.\n\nArchivos como README*, CHANGELOG* se crearán en blanco.\nArchivos como LICENSE* se tomarán del proyecto actual."
    {Create a project by template} {Crear un proyecto por plantilla}
    {Project directory} {Carpeta de proyecto}
    {Command} {Comando}
    {Commands} {Comandos}
    {For project} {Para el proyecto}
    {%n commands will be executed!} {¡%n comandos serán ejecutados!}
    {Maximum commands reached: %n, current: %i (see Project/Options)} {Máximo de comandos alcanzados: %n, actual: %i (ver Proyecto/Opciones)}
    {Maximum Run commands} {Máximo de comandos de ejecución}
    {The project directory already exists! It isn't created with templates.} {¡El directorio del proyecto ya existe! No se crea con plantillas.}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset es {
    {Current list of favorites} {Lista actual de favoritos}
    {New list of favorites:} {Nueva lista de favoritos:}
    {Add a list of favorites} {Añadir una lista de favoritos}
    {Change a list of favorites} {Cambiar una lista de favoritos}
    {Delete a list of favorites} {Borrar una lista de favoritos}
    {Click a list of favorites} {Haga clic en una lista de favoritos}
    {The list #%n added} {La lista #%n añadida}
    {The list #%n updated} {La lista #%n actualizada}
    {The list #%n removed} {La lista #%n borrada}
    {Enter a name of the list} {Introduzca un nombre de la lista}
    {Favorites of the current list} {Favoritos de la lista actual}
    {The current list is empty!} {¡La lista actual está vacía!}
    {This list already exists} {Esta lista ya existe}
    "This list not saved to\n\"%f\"." "Esta lista no se guarda en\n\"%f\"."
    {Non-favorite files to be:} {Archivos no favoritos para ser:}
    {kept} {quedó}
    {closed} {cerrado}
    "Doesn't close any tab without favorites\nat choosing Favorites' list" "No cierra ninguna pestaña sin favoritos\nal elegir la lista de favoritos"
    "Closes all tabs without favorites\nat choosing Favorites' list" "Cierra todas las pestañas sin favoritos\nal elegir la lista de favoritos"
    "Sets a list of Favorites\nthat was active initially." "Establece una lista de favoritos\nque estaba activo inicialmente."
    {Delete a favorites' list #%n ?} {¿Borrar una lista de favoritos #%n ?}
    {Favorites Lists...} {Listas de favoritos...}
    "Add \"%n\" of %f\nto Favorites?" "¿Añadir \"%n\" de %f\na favoritos?"
    "Item \"%n\" of %f\nis already in Favorites." "El elemento \"%n\"de %f\nya está en favoritos."
    "Remove \"%n\" of %f\nfrom Favorites?" "¿Borrar \"%n\" de %f\nde favoritos?"
    "\"%n\" unit of %f is not in the list." "La unidad \"%n\" de %f no está en la lista."
    {Add to Favorites} {Añadir a favoritos}
    {Rename} {Renombrar}
    {Favorite name:} {Nombre de favorito:}
    {Delete} {Borrar}
    {Delete All} {Borrar todos}
    {Delete all of Favorites?} {¿Borrar todos los favoritos?}
    {Delete all of the last visited?} {¿Borrar todos las últimas visitas?}
    {Favorites / Last Visited} {Favoritos / Últimas visitas}
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset es {
    "Create a file\nCtrl+N" "Crear un archivo\nCtrl+N"
    "Open a file\nCtrl+O" "Abrir un archivo\nCtrl+O"
    {Save the file} {Guardar el archivo}
    "Save all files\nCtrl+Shift+S" "Guardar todos los archivos\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Ayuda de Tcl/Tk por la selección\nF1"
    {Find / Replace} {Buscar / Reemplazar}
    "Find / Replace\nCtrl+F" "Buscar / Reemplazar\nCtrl+F"
    {Run the file} {Ejecutar el archivo}
    {Run e_menu} {Ejecutar e_menu}
    "Undo changes\nCtrl+Z" "Deshacer cambios\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Rehacer cambios\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset es {
    {Find: } {Buscar:}
    {Replace: } {Reemplazar:}
    {Match: } {Coincidir:}
    {Exact} {Exacto}
    {Match whole word} {Coincidencia de palabra}
    {Match case} {Caso de letras}
    {Wrap} {Enrollar}
    {Replace by blank} {Reemplazar por blanco}
    {Down} {Abajo}
    {Up} {Arriba}
    {Stay on top} {Encima de todos}
    {Stay on top:} {Encima de todos:}
    {Find} {Buscar}
    {Replace} {Reemplazar}
    {All in Text} {Todo en Texto}
    {All in Session} {Todo en Sesión}
    {All in %n Files} {Todo en archivos %n}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Permite usar *, ?, \[ y \]\nen la cadena buscada."
    "Allows to use the regular expressions\nin \"find\" string." "Permite usar las expresiones regulares\nen la cadena buscada."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Permite reemplazos por la cadena vacía,\de hecho, para borrar las encontradas."
    "Keeps the dialogue above other windows." "Mantiene el diálogo por encima de otras ventanas."
    "Found %n matches for \"%s\"." "%n coincidencias para \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "Reemplazos %n de \"%s\" con \"%r\" en \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "Reemplazos %n de \"%s\" por \"%r\" en la sesión."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "¿Reemplazar todos \"%s\"\n\ncon \"%r\"\n\nen \"%f\"?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all%Stexts?" "¿Reemplazar todos \"%s\"\n\ncon \"%r\"\n\nen todos los%Stextos?"
    {Don't focus a text after selecting in infobar} {No enfocar un texto después de selección en infobar}
    {Focus a text after selecting in infobar} {Enfocar un texto después de selección en infobar}
    {Find by List} {Buscar por lista}
    {List:} {Lista:}
    { Enter a list of words divided by spaces:} { Introduzca una lista de palabras divididas por espacios:}
    {FOUND:} {ENCONTRADO:}
    {NOT FOUND:} {NO ENCONTRADO:}
    "Use this geometry of the dialogue\nby default" "Usar esta geometría del diálogo\npor defecto"
    "Paste 'Find'\nCtrl+R" "Pegar 'Buscar'\nCtrl+R"
    {Not found: %s} {No encontrado: %s}
    {Resize} {Redimensionar}
    {Including RE2:} {Inclusivas RE2:}
    {Excluding RE2:} {Excluyentes RE2:}
    "Including / excluding\nregular expressions." {Inclusivas / excluyentes RE.}
  }

  ## ________________________ Start and update ________________________ ##
  ::msgcat::mcmset es {
    {Choosing Directory for Settings} {Elección de carpeta para la configuración}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n" "\n El \"alited\" necesita una carpeta para guardar su configuración.\n Puede pasar su nombre a alited como argumento.\n\n La carpeta de configuración predeterminado es \"%d\".\n Es preferible como se usa para ejecutar \"alited\" sin argumentos.\n"
    {Choose a directory} {Elija una carpeta}
    {Some things have been changed in alited %v.} {Algunas cosas han cambiado en alited %v.}
    {Updating alited} {Actualización de alited}
    " You are highly recommended to accept\n these changes in order to complete updating:" " Se recomienda urgentemente que acepte\n estos cambios para completar la actualización:"
    {.em files for \"Tools\"} {archivos .em para \"Herramientas\"}
    {.ini file for \"Templates\"} {archivo .ini para \"Plantillas\"}
    { Your previous files will be saved to:} { Sus archivos anteriores se guardarán en:}
    {View Changes} {Ver cambios}
  }

  ## ________________________ "About" dialogue ________________________ ##
  ::msgcat::mcmset es {
    {stands for} {significa}
    {Written in pure Tcl/Tk.} {Escrito en Tcl/Tk puro.}
    {And well fit for programming with it.} {Y bien apto para programar con él.}
    {Details:} {Detalles:}
    {Authors:} {Autores:}
    {License:} {Licencia:}
    {Acknowledgements} {Agradecimientos}
    "Many thanks to the following people\n who have contributed to this project\n with their participation, advice and code" "Muchas gracias a las siguientes personas\n que han contribuido a este proyecto\n con su participación, consejos y código"
    {Special thanks also to} {Un agradecimiento especial también a}
    {Packages} {Paquetes}
    {Packages used by <red>alited %ver</red>:} {Paquetes usados por <red>alited %ver</red>:}
  }

  ## ________________________ Preferences ________________________ ##
  ::msgcat::mcmset es {
    {General} {General}
    {Editor} {Editor}
    {Units} {Unidades}
    {Keys} {Teclas}
    {Misc.} {Misc.}
    {Saving} {Guardando}
    {View} {Vista}
  }

  ### ________________________ General _________________________ ###
  ::msgcat::mcmset es {
    {Ttk theme:} {Tema Ttk:}
    {Color scheme:} {Esquema de colores:}
    {Windows themes} {Temas de Windows}
    {Darker:} {Más oscuro:}
    {Lighter:} {Más claro:}
    {Tint} {Tinte}
    {Tint:} {Tinte:}
    "For the settings to be active,\nalited application should be restarted." "Para que la configuración esté activa, la aplicación\nalited debe reiniciarse."
    {Preferable locale:} {Locale preferible:}
    "This is a language code: ru, uk, de...\nIn alited, \"en\" means American English." "Este es un código de lengua: ru, uk, de...\nEn alited,\"en\" significa inglés americano."
    {Small font size:} {Tamaño de font pequeño:}
    {Middle font size:} {Tamaño de font medio:}
    {Cursor width:} {Ancho del cursor:}
    {Color of cursor:} {Color del cursor:}
    {Notes:} {Notas:}
    "Sort of diary.\nList of TODOs etc." "Una especie de diario.\nLista de TODOs, etc."
    {Light / Dark} {Claro / Oscuro}
    {Makes colors darker .. lighter} {Los colores más oscuro .. más claro}
    "These themes need\nlight / dark color schemes\naccordingly" "Estos temas necesitan esquemas de color claro / oscuro"
    {Fit for theme} {Apto para el tema}
    {No color scheme at all} {Sin esquema de color en absoluto}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset es {
    {Font:} {Font:}
    {Gutter's width:} {Ancho de canaleta:}
    {Gutter's shift from text:} {Sangría de canaleta del texto:}
    {Space above lines:} {Espacio por encima de las líneas:}
    {Space below lines:} {Espacio debajo de las líneas:}
    {Space between wraps:} {Espacio entre enrollaras:}
    {Tab bar label's length:} {Longitud de nombre de la barra de pestañas:}
    {Tab bar tip's length:} {Longitud de la sugerencia de la barra de pestañas:}
    {Border for bar tabs:} {Borde de pestañas de barra:}
    {Code snippet:} {Fragmento de código:}
    {Blinking cursor:} {Cursor parpadeante:}
    {Translation} {Traducción}
    {Translation link:} {Enlace de traducción:}
    {Adding translations:} {Adición de traducciones:}
    {If OFF, replaces the original text.} {Si está desactivado, reemplaza el texto original.}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset es {
    {Save before bar-menu runs:} {Guardar antes de que se ejecute bar-menu:}
    {Current file} {Archivo actual}
    {All files} {Todos los archivos}
    {'Recent Files' length:} {Longitud de 'Archivos recientes':}
    {'Last Visited' length:} {Longitud de 'Últimas visitas':}
    {Maximum of project files:} {Máximo de archivos de proyecto:}
    {Confirm exit:} {Confirmar la salida:}
    {Save configuration on} {Guardar la configuración en}
    {opening a file:} {abrir un archivo:}
    {closing a file:} {cerrar un archivo:}
    {saving a file:} {guardar un archivo:}
    {Back up files to a project's subdirectory:} {Copias de seguridad en la subcarpeta de proyecto:}
    "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." "Una subcarpeta de proyectos en el que se guardarán las copias de seguridad de los archivos.\nEstablezca el campo en blanco para cancelar las copias de seguridad."
    {  Maximum:} {  Máximo:}
    {Maximum of backup copies per a file} {Máximo de copias de seguridad por archivo}
    {Bell at warnings:} {Sonido en advertencias:}
    {Port to listen alited:} {Puerto para escuchar alited:}
    "The empty value allows\nmultiple alited apps." "El valor vacío permite\nmúltiples aplicaciones alited."
  }

  ### ________________________ Keys _________________________ ###
  ::msgcat::mcmset es {
    {Save File} {Guardar archivo}
    {Save File as} {Guardar archivo como}
    {Run e_menu} {Ejecutar e_menu}
    {Run File} {Ejecutar archivo}
    {Double Selection} {Doblar selección}
    {Delete Line} {Borrar línea}
    {Highlight First} {Resaltar primero}
    {Highlight Last} {Resaltar último}
    {Find Next Match} {Buscar la siguienta coincidencia}
    {Item up} {Elemento arriba}
    {Item down} {Elemento abajo}
    {Complete Commands} {Completar comandos}
  }

  ### ________________________ Templates tab _________________________ ###
  ::msgcat::mcmset es {
    {Enter %U, %u, %m, %w, %d, %t wildcards of templates:} {Introduzca %U, %u, %m, %w, %d, %t marcadores de plantillas:}
    {User name:} {Nombre de usuario:}
    {Login:} {Login:}
    {Date format:} {Formato de fecha:}
    {Time format:} {Formato de hora:}
  }

  ### ________________________ Syntax _________________________ ###
  ::msgcat::mcmset es {
    {Tcl syntax} {Sintaxis de Tcl}
    {C/C++ syntax} {Sintaxis de C/C++}
    {Plain text} {Texto sin formato}
    {Tcl files' extensions:} {Extensiones de archivos Tcl:}
    {C/C++ files' extensions:} {Extensiones de archivos C/C++:}
    {Plain texts' extensions:} {Extensiones de texto sin formato:}
    {Color of Tcl commands:} {Color de los comandos Tcl:}
    {Color of Tk commands:} {Color de los comandos Tk:}
    {Color of strings:} {Color de las cadenas:}
    {Color of variables:} {Color de las variables:}
    {Color of comments:} {Color de los comentarios:}
    {Color of proc/methods:} {Color de los proc/métodos:}
    {Color of options:} {Color de las opciones:}
    {Color of brackets:} {Color de los corchetes:}
    {Color of C key words:} {Color de las palabras C:}
    {Color of C++ key words:} {Color de las palabras de C++ :}
    {Color of punctuation:} {Color de puntuación:}
    {Color of return/goto:} {Color de return/goto:}
    {Color of your key words:} {Color de sus palabras:}
    {Colors} {Colores}
    {Your commands:} {Sus comandos:}
    {Your key words:} {Sus palabras:}
  }

  ### ________________________ Units _________________________ ###
  ::msgcat::mcmset es {
    {Branch's regexp:} {Expresión regular para rama:}
    {Proc's regexp:} {Expresion regular para proc:}
    {Check branch's regexp:} {Expresión regular para probar de rama:}
    {Check proc's regexp:} {Expresión regular para probar de proc:}
    {Use leaf's regexp:} {Usar la expresión regular para hoja:}
    {Leaf's regexp:} {Expresión regular para hoja:}
    {Untouched top lines:} {Líneas superiores intactas:}
    {For leaf units only!} {¡Solo para hojas!}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset es {
    {Open bar-menu settings} {Abrir configuración del bar-menu}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Un icono inserta la ejecución en la barra de herramientas.\nBlank o 'none' lo excluye de la barra de herramientas."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "El elemento ejecutado por el menú y/o la barra de herramientas.\nSelecciónelo de los elementos de e_menu."
    {Directory of menus:} {Carpeta de menús:}
    {Main menu:} {Menú principal:}
    {Projects (%PD wildcard):} {Proyectos (marcador %PD):}
    {Linux terminal:} {Terminal de Linux:}
    {Diff tool:} {Herramienta Diff:}
    {Path to man/tcl:} {Camino al man/tcl:}
    {tclsh, wish or tclkit:} {tclsh, wish o tclkit:}
    {Geometry:} {Geometría:}
    {Run as external app:} {Ejecutar como una aplicación externa:}
    {Delete an item} {Eliminar un elemento}
    {Move an item up} {Mover un elemento hacia arriba}
    {Move an item down} {Mover un elemento hacia abajo}
    {separator} {separador}
    {If 'yes', means a separator of the toolbar/menu.} {Si 'sí', significa un separador de la barra de herramientas / menú.}
    {For Start...} {Para inicio...}
    " Enter commands to be run after starting alited.\n They can be Tcl or executables:" " Introduzca los comandos que se ejecutarán después de inicio de alited.\n Pueden ser Tcl o ejecutables:"
    {By command:} {Por comando:}
    {By command #RUNF:} {Por comando #RUNF:}
    {Run:} {Ejecutar:}
    {Run it} {Ejecutar}
    { OS or Tcl commands to be run before running a current file:} { Comandos del sistema operativo o Tcl que se ejecutarán antes de ejecutar un archivo actual:}
    { Also, you can set \"forced command\" to be run by \"Run\" tool:} { Además, puede configurar \"comando forzado\" para que lo ejecute la herramienta \"Ejecutar\":}
    {Forcedly:} {A la forza:}
    {e_menu's own} {e_menu propio}
    {Select any of run item} {Seleccione cualquiera de los elementos ejecutados}
    "Incorrect \"Preferences/Tools/tclsh...\"\nresults in the error:" "Resultado incorrecto \"Preferencias/Herramientas/tclsh...\"\nen el error:"
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset es {
    {Check Tcl} {Comprobar Tcl}
    {Check Tcl...} {Comprobar Tcl...}
    {Check} {Comprobar}
    {Check:} {Comprobar:}
    {Checks available:} {Pruebas disponiblas:}
    {Consistency of {} } {Consistencia de {}}
    {Consistency of []} {Consistencia de []}
    {Consistency of ()} {Consistencia de ()}
    {Consistency of \"\"} {Consistencia de \"\"}
    {all of session files} {todos los archivos de sesión}
    {current file} {archivo actual}
    {Found %f file error(s), %u unit error(s).} {Encontrado %f error(es) de archivo, %u error(es) de unidad.}
    {No errors found.} {No se encontraron errores.}
    {Errors found in unit:} {Errores encontrados en la unidad:}
    {Duplicate units} {Unidades duplicadas}
    {duplicate unit:} {unidad duplicada:}
  }

  ## ________________________ Macros ________________________ ##
  ::msgcat::mcmset es {
    "The macro is updated at its recording.\nPress %s to play it." "La macro se actualiza en su grabación.\nPulse %s para reproducirlo."
    {Playing:} {Reproducción:}
    {Recording:} {Grabación:}
    {Play Macro} {Reproducir macro}
    {Record Macro} {Grabar macro}
    {Delete Macro} {Borrar macro}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset es {
    "\"%f\" removed to \"%d\"" "\"%f \"borrado a \"%d\""
    {File name:} {Nombre de archivo:}
    {Directory} {Carpeta}
    "The file \"%f\" seems to be not of types\n%s.\n\nStill do you want to open it?" "El archivo \"%f\" parece no ser del tipo\n%s.\n\n¿Todavía quieres abrirlo?"
  }

  ## ________________________ Find units ________________________ ##
  ::msgcat::mcmset es {
    {Find Unit} {Buscar unidad}
    {in all} {en todos}
    {in current} {en le actual}
    "Use glob patterns to find units' declarations\ne.g. \"s*rt\" would find \"start\" and \"insert\".\nThe letter case is ignored." "Usar patrónes de glob para buscar declaraciones de unidades\npor ejemplo, \"s*rt\" encontraría \"start\" e \"insert\".\nSe ignore el caso de las letras."
    {Incorrect name for a unit.} {Nombre incorrecto de una unidad.}
  }

  ## ________________________ Abbreviations etc. ________________________ ##
  #   Line - 2nd column's title of unit tree
  ::msgcat::mcmset es {
    {Row} {Fila}
    {Row: } {Fila: }
    { Col: } { Col: }
    {    Unit: } {    Unidad: }
  }

  ## ________________________ Bar of tabs ________________________ ##
  ::msgcat::mcmset es {
    {(Un)Select} {(De)Seleccionar}
    {... Visible} {... Visible}
    {... All at Left} {... Todos a la izquierda}
    {... All at Right} {... Todos a la derecha}
    {... All} {... Todos}
    {File List} {Lista de archivos}
    {Sort} {Ordenar}
    {Sort files} {Ordenar archivos}
    {Sorted} {Ordenados}
    {... by date} {... por fecha}
    {... by size} {... por tamaño}
    {... by extension} {... por extensión}
    {increasing} {aumentando}
    {decreasing} {disminuyendo}
    {Files to Beginning} {Archivos en comienzo}
    "If it's checked, open files would be placed\nonto the beginning page of the bar." "Si está marcada, los archivos abiertos se colocarían\nen la página inicial de la barra."
  }

  ## ________________________ Paver _________________________ ##

  ::msgcat::mcmset es {
    {For paveWindow's widget list to be recognized, set the cursor inside it.} {Para que se reconozca la lista de widgets de paveWindow, coloque el cursor dentro de ella.}
    {Auto Update} {Actualización automática}
    {Widget List} {Lista de widgets}
  }

  ## ____________________ Rectangular selection ___________________ ##

  ::msgcat::mcmset es {
    {Rectangular Selection} {Selección rectangular}
    {Start} {Inicio}
    {Cut} {Cortar}
    {Copy} {Copiar}
    {Paste} {Pegar}
    {Move the cursor to select a rectangle.} {Mueve el cursor para seleccionar un rectángulo.}
  }

  ## ________________________ EONS alited _________________________ ##
}

# _ apave NS _ #

namespace eval ::apave {
  ::msgcat::mcmset es {
    {Save text} {Guardar texto}
    {Don't save} {No guarda}
    {Save changes made to the text?} {¿Guardar los cambios realizados en el texto?}
  }
}

# _ bartabs NS _ #

namespace eval ::bartabs {

  ## ________________________ Popup menu _________________________ ##

  ::msgcat::mcmset es {
    {List} {Lista}
    {behind} {detrás}
    {Close} {Cerrar}
    {... All} {... Todos}
    {... All at Left} {... Todos a la izquierda}
    {... All at Right} {... Todos a la derecha}
  }
}

# _________________________________ EOF _________________________________ #
