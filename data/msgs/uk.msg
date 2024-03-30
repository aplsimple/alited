# ________________________ uk.msg _________________________ #
# Name:    uk.msg
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    10/15/2021
# Brief:   Handles Ukranian localization.
# License: MIT.

# ________________________ Ukranian letters _________________________ #

# ҐґЄєІіЇї

# ________________________  alited NS _________________________ #

namespace eval ::alited {

  ## ________________________ Common _________________________ ##

  ::msgcat::mcmset uk {
    {No name} {Без імені}
    "\"%f\" wasn't saved.\n\nSave it?" "\"%f\" не збережений.\n\nЗберігти?"
    {About} {Про програму}
    {About...} {Про програму...}
    {Error} {Помилка}
    {Warning} {Попередження}
    {Question} {Запитання}
    {Information} {Інформація}
    {File} {Файл}
    {Edit} {Правка}
    {Search} {Пошук}
    {Tools} {Струменти}
    {Setup} {Опції}
    {Help} {Допомога}
    {Yes} {Так}
    {No} {Ні}
    {Cancel} {Відміна}
    {Close} {Закрити}
    {New} {Новий}
    {Open...} {Відкрити...}
    {Recent Files} {Нещодавні файли}
    {Save} {Зберегти}
    {Save as...} {Зберегти як...}
    {Save All} {Зберегти всі}
    {Save and Close} {Зберегти і закрити}
    {Close and Delete} {Закрити і видалити}
    {Preferences} {Настройки}
    {Preferences...} {Настройки...}
    {Quit} {Вихід}
    {Put New Line} {Додати рядок}
    {Remove Trailing Whitespaces} {Видалити хвостові пробіли}
    {Remove trailing whitespaces} {Видалити хвостові пробіли}
    {Remove trailing whitespaces:} {Видаляти хвостові пробіли:}
    "Remove trailing whitespaces of all lines\nof \"%f\"?" "Видалити хвостові пробіли у всіх рядках\nфайла \"%f\"?"
    {Indent} {Додати відступ}
    {Unindent} {Убрати відступ}
    {Comment} {Закоментувати}
    {Comment:} {Коментар:}
    {Comments} {Коментарі}
    {Uncomment} {Разкоментувати}
    {Find Next} {Шукати далі}
    {Look for Declaration} {Шукати декларацію}
    {Look for Word} {Шукати слово}
    {Run} {Запуск}
    {Run...} {Запуск...}
    {Run as Is} {Запуск як є}
    {in console} {у консолі}
    {in Tkcon} {у Tkcon}
    {Moving} {Переміщення}
    {Color Picker} {Вибір коліру}
    {Date Picker} {Вибір дати}
    {Screen Loupe} {Екранна лупа}
    {Quitting alited.} {Виходимо з alited.}
    {Wait a little ...} {Почекайте ...}
    {Standard} {Стандарт}
    {Standard 2} {Стандарт 2}
    {Standard 3} {Стандарт 3}
    {Standard 4} {Стандарт 4}
    {Test} {Перевірка}
    {Correct Indentation} {Правити відступи}
    "Correct the indentation of \"%f\"\nwith indenting %i spaces?" "Правити відступи \"%f\",\nпо %i на кожний?"
    {The line %n: unbalanced brace!} {Рядок %n: незбалансована скобка!}
    {Wrap Lines} {Згортати рядки}
    {Default values for new projects:} {Опції за замовчуванням для проектів:}
  }

  ::msgcat::mcmset uk {
    {Select} {Вибір}
    {Save as} {Зберігти як}
    {Files} {Файли}
    {Line} {№ ряд.}
    {Lines} {Рядки}
    "All of \"%f\"" "Все з \"%f\""
    "Not recommended for projects\nwith large files (>2000 LOC)!" "Не рекомендовано для проектів\nз великими файлами (>2000 рядків)!"
    {Move Unit Up} {Підняти юніт}
    {Move Unit Down} {Опустити юніт}
    {Move File Up} {Перемістити файл вгору}
    {Move File Down} {Перемістити файл вниз}
    {Only files are moved by alited.} {Тільки файли переміщує alited.}
    {Saved Lists of Favorites} {Збережені списки Вибраного}
    {Last Visited} {Останні вхіди}
    {Switch to Unit Tree} {Перейти на список юнітів}
    {Switch to File Tree} {Перейти на список файлів}
    {Create File} {Створити файл}
    {Create File...} {Створити файл...}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Введіть ім'я файлу, створюваного в:\n%d\n\nЯкщо це каталог, включіть опцію 'Каталог'.\nКаталог може включати підкаталоги (a/b/c)."
    {Delete File} {Видалити файл}
    "\nFile \"%f\" already exists in\n%d\n" "\nФайл \"%f\" вже існує в\n%d\n"
    "\nFile\n  \"%f\"\ndoesn't exist.\n" "\nФайл\n  \"%f\"\nне існує.\n"
    {Delete Unit(s)} {Видалити юніт(и)}
    {No item selected.} {Запис не выбраний.}
    {Update Tree} {Оновити список}
    {Contract All} {Згорнути все}
    {Expand All} {Розгорнути все}
    {Expand Selected} {Розгорнути вибрані}
    "Move %f\nto\n%d\n?" "Переместити %f\nу\n%d\n?"
    {To Last Visited} {На останній вхід}
    {To Matched Bracket} {На парну скобку}
    {Go to Line} {Перейти на рядок}
    {Line number:} {Номер рядку:}
    {    In unit:} {    У юніті:}
    "\"%n\" contains unbalanced \{\}: %1!=%2" "\"%n\" має незбалансовані \{\}: %1!=%2"
    {Back} {Відкат}
    {File not found: %f} {Файл не знайдений: %f}
    {Unit not found: %u} {Юніт не знайдений: %u}
    {Don't show anymore} {Більш не показувати}
    {%f is a directory} {%f - це каталог}
    {THE EXTERNAL FILE IS MOVED TO THE PROJECT!} {ЗОВНІШНІЙ ФАЙЛ ПЕРЕМЕЩУЄТЬСЯ У ПРОЕКТ!}
    {Drop Selected Units Here} {Кинути сюди вибрані юніти}
    {Drop Selected Files Here} {Кинути сюди вибрані файли}
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open. This may be expensive!" "Всі Tcl файли каталогу:\n  \"%f\"  \nбудуть відкриті.\n\nЦя операція може бути коштовною!"
    {Select All} {Виділити все}
    {Do it in other Tcl files} {Також і в інших файлах Tcl}
    {Do it in other files} {Також і в інших файлах}
    {Selected files: %n} {Виділених файлів: %n}
    {Configurations...} {Конфігурації...}
    {Tips on / off} {Підказки вкл / викл}
    {Exit} {Вихід}
    {Reload with EOL} {Завантажити з EOL}
    "Save the file:\n%F ?" "Зберегти файл:\n%F ?"
    {Reload with Encoding} {Завантажити у кодировці}
    {Encoding} {Кодировка}
    "Saving and reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nSave the file:\n%F ?" "Збереження та відкриття \"%f\"\nу кодировці \"%e\" може статися помилковим.\n\nЗберегти файл:\n%F ?"
    "Reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nReload the file:\n%F ?" "Завантаження \"%f\"\nу кодировці \"%e\" може статися помилковим.\n\nЗавантажити файл:\n%F ?"
    {Color Values #hhhhhh} {Значення кольорів #hhhhhh}
    {Display Colors} {Відобразити кольори}
    {Hide Colors} {Сховати кольори}
    {Display colors in the whole text?} {Відобразити кольори в усьому тексті?}
    {check RE in Find/Replace box} {включіть RE у віконці Пошук/Заміна}
    {Context} {Контекстна}
    {Mark} {Мітка}
    {Changes will be lost!} {Зміни будуть втрачені!}
    "Left click sets / goes to a mark.\nRight click clears it." "Лівий клік ставить / йде на мітку.\nПравий клік вичищає її."
    {Clear All} {Вичистити усе}
    {Width} {Ширина}
  }

  ## ________________________ Moving a first unit up ________________________ ##
  ::msgcat::mcmset uk {
    {First Lines} {Перші рядки}
    {Can't touch the first %n lines.} {Перші %n рядків нерухомі.}
  }

  ## ________________________ Tree ________________________ ##
  ::msgcat::mcmset uk {
    "Click \"%t\"" "Кликнить \"%t\""
    {Copy Declaration} {Копіювати декларацію}
    "Open All Tcl Files of \"%n\"" "Відкрити всі файли Tcl з \"%n\""
    "Remove \"%n\"\nfrom \"%f\"?" "Видалити \"%n\"\nз \"%f\"?"
    "Delete \"%f\"?" "Видалити \"%f\"?"
    {Rewrite} {Перезаписати}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "Файл \"%f\" був змінений іншою програмою.\n\nВідмінити вашу редакцію та завантажити файл знову?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "Файл \"%f\" був видалений іншою програмою.\n\nЗберігти файл?"
    {Tip File Info} {Дані про файли}
    {Rename File} {Перейменувати файл}
    {Rename File...} {Перейменувати файл...}
    {Clone File} {Клонувати файл}
    {Clone File...} {Клонувати файл...}
    {Clone...} {Клонувати...}
    {Select one file in the tree.} {Виберіть один файл у списку.}
    {Open Selected Files} {Відкрити виділені файли}
    {Close Selected Files} {Закрити виділені файли}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset uk {
    {Template} {Шаблон}
    {Template:} {Шаблон:}
    {Templates} {Шаблони}
    {Templates...} {Шаблони...}
    {Current template:} {Поточний шаблон:}
    {New template:} {Новий шаблон:}
    {Hot keys} {Клявіши}
    {Add a template} {Додати шаблон}
    {Change a template} {Змінити шаблон}
    {Delete a template} {Видалити шаблон}
    {Click a template} {Виберіть який-небудь шаблон}
    {The template #%n added} {Шаблон #%n доданий}
    {The template #%n updated} {Шаблон #%n змінений}
    {The template #%n removed} {Шаблон #%n видалений}
    {Enter a name of the template} {Введіть назву шаблону}
    {Enter a text of the template} {Введіть текст шаблону}
    "Choose a hot key combination\nfor the template insertion." "Виберіть комбинацію клявіш\nдля вставки шаблону."
    {A template with the attribute(s) already exists.} {Шаблон з такими атрибутами вже існує.}
    {Place after:} {Вставити за:}
    {line} {рядок}
    {unit} {юніт}
    {cursor} {курсор}
    {file's beginning} {початок файлу}
    "Inserts a template\nbelow a current line" "Вставити шаблон\nслід за поточним рядком"
    "Inserts a template\nbelow a current unit" "Вставити шаблон\nслід за поточним юнітом"
    "Inserts a template at the cursor\n(good for one-liners)" "Вставити шиблон у позиції курсору\n(підходить для однорядкових шаблонів)"
    "Inserts a template after 1st line of a file\n(License, Introduction etc.)" "Вставити шаблон у початку файла\n(Лицензия, Вступ та інше.)"
    {Delete a template #%n ?} {Видалити шаблон #%n ?}
    "Import templates\nfrom external alited.ini" "Імпортувати шаблони\nз зовнiшнього alited.ini"
    {Number of imported templates: %n} {Кiлькiсть iмпортованих шаблонiв: %n}

  }

  ## ________________________ Projects ________________________ ##
  ::msgcat::mcmset uk {
    {Projects} {Проекти}
    {Projects...} {Проекти...}
    {You are going to %n!} {Ви збираєтеся %n!}
    {Add a project} {Додати проект}
    {Change a project} {Змінити проект}
    {Delete a project} {Видалити проект}
    {Don't delete the current project!} {Не видаляйте поточний проект!}
    "The project \"%n\" added" "Проект \"%n\" доданий"
    "The project \"%n\" updated" "Проект \"%n\" змінений"
    "The project \"%n\" removed" "Проект \"%n\" видалений"
    {Options} {Опції}
    {Project:} {Проект:}
    {Root directory:} {Коріневий каталог:}
    {Skip subdirectories:} {Пропускати підкаталоги:}
    {Description:} {Опис:}
    {Indentation:} {Пробілів відступу:}
    {Auto detection} {Автовизначення}
    {End of line:} {Кінці рядків:}
    {Multi-line strings:} {Багаторядкові string:}
    {Unit lines per 1 red bar:} {Рядків юніта на 1 червону смужку:}
    {List of files (%n):} {Список файлів (%n):}
    {Add} {Додати}
    {Substitute} {Змінити}
    {Delete} {Видалити}
    {Don't change} {Не змінювати}
    {Click a project} {Виберіть проект}
    "Delete a project \"%n\" ?" "Видалити проект \"%n\" ?"
    "A project \"%n\" already exists." "Проект \"%n\" вже існує."
    "A project \"%n\" doesn't exists. Hit \[+\] button to create it." "Проект \"%n\" не існує. Щоб створити, клікніть \[+\]."
    "All modified files (%n) will be saved.\n\nDo you agree?" "Всі змінені файли (%n) будуть збережені.\n\nГаразд?"
    "All selected files (%n) will remain open\nin the project you are switching to.\n\nDo you agree?" "Всі виділені файли (%n) залишуться відкритими\nу вибраному вами проекті.\n\nГаразд?"
    "Directory \"%d\"\ndoesn't exist.\n\nCreate it?" "Каталог \"%d\"\nне існує.\n\nСтворити його?"
    {Checking %d. Wait a little...} {Перевірка %d. Чекайте...}
    {Too big directory for a project: %n files or more.} {Занадто великий каталог проекту: не менш, ніж %n файлів.}
    {Options for new projects are set in "Preferences/General/Projects"} {Опції для нових проектів беруться з "Опції/Загальне/Проекти"}
    {Date} {Дата}
    {Reminder} {Нагадування}
    {Erase a text} {Стерти текст}
    {Paste a text} {Вставити текст}
    {Undo changes} {Відмінити зміни}
    {Redo changes} {Перевідмінити зміни}
    {Text of a reminder} {Текст нагадування}
    {TODO reminders for the past: %d.} {TODO нагадування минулого: %d.}
    {No selected files} {Немає виділених файлів}
    {Open file:} {Відкрито файл:}
    {Open files: %n} {Відкрито файлів: %n}
    {TODO previous day} {TODO на день раніше}
    {TODO previous week} {TODO на тиждень раніше}
    {TODO next day} {TODO на день піздніше}
    {TODO next week} {TODO на тиждень піздніше}
    on на
    {Incorrect name: "%n"} {Некоректна назва: "%n"}
    {The project template is empty!} {Шаблон проекту пустий!}
    {Incorrect indentation in Project template: %n} {Некоректний відступ у шаблоні проекту: %n}
    "Enter a tree of directories for the project template.\nIndent them by equal indents to mean subdirectories.\n\nFiles like README*, CHANGELOG* will be created blank.\nFiles like LICENSE* will be taken from the current project." "Вкажіть дерево директорій для шаблона проекту.\nРобіть однакові відступи для вказівки піддиректорій.\n\nФайли типа README*, CHANGELOG* будуть створюватися пустими.\nФайли типа LICENSE* будуть братися з поточного проекту."
    {Create a project by template} {Створити проект по шаблону}
    {Project directory} {Директорія проекту}
    {Command} {Команда}
    {Commands} {Команди}
    {For project} {Для проекту}
    {%n commands will be executed!} {Буде виконано %n команд!}
    {Maximum commands reached: %n, current: %i (see Project/Options)} {Досягнуто максимуму команд: %n, зараз: %i (див. Проекти/Опції)}
    {Maximum Run commands} {Максимум команд "Запуск"}
    {The project directory already exists! It isn't created with templates.} {Директорія проекту вже існує! Він не створюється по шаблону.}
    {All files filter:} {Фільтр усіх файлів:}
    {TODO days ahead:} {TODO днів попереду:}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset uk {
    {Current list of favorites} {Поточний список Вибраного}
    {New list of favorites:} {Новий список Вибраного:}
    {Add a list of favorites} {Додати список Вибраного}
    {Change a list of favorites} {Змінити список Вибраного}
    {Delete a list of favorites} {Видалити список Вибраного}
    {Click a list of favorites} {Виберіть який-небудь список}
    {The list #%n added} {Список #%n доданий}
    {The list #%n updated} {Список #%n змінений}
    {The list #%n removed} {Список #%n видалений}
    {Enter a name of the list} {Введіть назву списку}
    {Favorites of the current list} {Вибране поточного списку}
    {The current list is empty!} {Поточний список пустий!}
    {This list already exists} {Цей список вже існує}
    "This list not saved to\n\"%f\"." "Цей список не збережений у\n\"%f\"."
    {Non-favorite files to be:} {Файли не Вибраного повинні:}
    {kept} {залишитися}
    {closed} {закритися}
    "Doesn't close any tab without favorites\nat choosing Favorites' list" "Не закривати \"невибрані\" заставки\nпри виборі списка Вибраного"
    "Closes all tabs without favorites\nat choosing Favorites' list" "Закрывати \"невибрані\" заставки\nпри виборі списка Вибраного"
    "Sets a list of Favorites\nthat was active initially." "Відновлює список Вибраного,\nщо діяв спочатку."
    {Delete a favorites' list #%n ?} {Видалити список Вибраного #%n ?}
    {Favorites} {Вибране}
    {Favorites Lists...} {Списки Вибраного...}
    "Add \"%n\" of %f\nto Favorites?" "Додати \"%n\" файлу %f\nу Вибране?"
    "Item \"%n\" of %f\nis already in Favorites." "Юніт \"%n\" з %f\nвже є у Вибраному."
    "Remove \"%n\" of %f\nfrom Favorites?" "Видалити \"%n\" файлу %f\nз Вибраного?"
    "\"%n\" unit of %f is not in the list." "Юніта \"%n\" файлу %f немає у списку."
    {Add to Favorites} {Додати до Вибраного}
    {Rename} {Перейменувати}
    {Favorite name:} {Назва вибраного:}
    {Delete} {Видалити}
    {Delete All} {Видалити все}
    {Delete all of Favorites?} {Видалити все з Вибраного?}
    {Delete all of the last visited?} {Видалити все з Останніх входів?}
    {Favorites / Last Visited} {Вибране / Останні входи}
    {Opens files with current favorites.} {Відкрити файли з поточним Вибраним.}
    {Number of files to open: %n} {Кількість файлів на відкриття: %n}
    "Add .tcl files of current session\nas the favorites" "Додати .tcl файли поточного сеансу\nяк список Вибраного"
    {No .tcl files found in the session} {Файлів .tcl у сессії не знайдено}
    "\n Save as favorites list: selected (%s) or all (%a) files?\n" "\n Зберегти як список Вибраного: вибрані (%s) або всі (%a) файли?\n"
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset uk {
    "Create a file\nCtrl+N" "Утворити файл\nCtrl+N"
    "Open a file\nCtrl+O" "Відкрити файл\nCtrl+O"
    {Save the file} {Зберегти файл}
    "Save all files\nCtrl+Shift+S" "Зберегти всі файли\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Контекстна допомога по Tcl/Tk\nF1"
    {Find / Replace} {Пошук / Заміна}
    "Find / Replace\nCtrl+F" "Пошук / Заміна\nCtrl+F"
    {Run the file} {Виконати файл}
    {Run e_menu} {Виклик e_menu}
    "Undo changes\nCtrl+Z" "Відміна змін\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Перевідміна змін\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset uk {
    {Find: } {Шукати: }
    {Replace: } {Замінити: }
    {Match: } {Збіг: }
    {Exact} {Точний}
    {Match whole word} {Тільки цілі слова}
    {Match case} {Регістр букв}
    {Wrap} {По кругу}
    {Replace by blank} {Пусті заміни}
    {Down} {Наниз}
    {Up} {Наверх}
    {Stay on top} {Над всіма вікнами}
    {Stay on top:} {Над всіма вікнами:}
    {Find} {Пошук}
    {Replace} {Заміна}
    {All in text} {Все у тексті}
    {All in session} {Все у сеансі}
    {All in %n Files} {Все у %n файлах}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Дозволяє використовувати *, ?, \[, \]\nу рядку пошуку."
    "Allows to use the regular expressions\nin \"find\" string." "Дозволяє використовувати регулярні вирази\nу пошуку."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Дозволяє пусті заміни,\nтобто просто видалення знайдених строк."
    "Keeps the dialogue above other windows." "Тримає діалог пошуку\nпонад іншими вікнами."
    "Found %n matches for \"%s\"." "Знайдено %n шуканих \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "Зроблено %n замін \"%s\" на \"%r\" в \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "Зроблено %n замін \"%s\" на \"%r\" в усьому сеансі."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "Замінити всі \"%s\"\n\nна \"%r\"\n\nу \"%f\" ?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all%Stexts?" "Замінити всі \"%s\"\n\nна \"%r\"\n\nв усіх%Sтекстах?"
    {Don't focus a text after selecting in infobar} {Не переходити на текст при виборі у інфобарі}
    {Focus a text after selecting in infobar} {Переходити на текст при виборі у інфобарі}
    {Find by List} {Шукати по списку}
    {List:} {Список:}
    { Enter a list of words divided by spaces:} { Введіть список слів, разділених пробілами:}
    {FOUND:} {ЗНАЙДЕНІ:}
    {NOT FOUND:} {НЕ ЗНАЙДЕНІ:}
    "Use this geometry of the dialogue\nby default" "Використовувати цю геометрію діалогу\nза замовчуванням"
    "Paste 'Find'\nCtrl+R" "Вставити шукане\nCtrl+R"
    {Not found: %s} {Не знайдено: %s}
    {Resize} {Змінити розмір}
    {Including RE2:} {Включаючі RE2:}
    {Excluding RE2:} {Виключаючі RE2:}
    "Including / excluding\nregular expressions." {Включаючі / виключаючі RE.}
  }

  ## ________________________ Start and update ________________________ ##
  ::msgcat::mcmset uk {
    {Choosing Directory for Settings} {Вибір каталогу для опцій}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n" "\n Програма \"alited\" мусить мати каталог для збереження своїх опцій.\n Ви можете задати його як аргумент при виклику alited.\n\n За замовчуванням, каталог збереження опцій - \"%d\".\n Це рекомендований каталог, що дозволяє викликати \"alited\" без аргументів.\n"
    {Choose a directory} {Вибір каталогу}
    {Some things have been changed in alited %v.} {Дещо змінилося у alited %v.}
    {Updating alited} {Оновлення alited}
    " You are highly recommended to accept\n these changes in order to complete updating:" " Наполегливо рекомендовано прийняти\n ці зміни для завершення оновлення:"
    {.em files for "Tools"} {.em файли для "Струментів"}
    {.ini file for "Templates"} {.ini файл для "Шаблонів"}
    { Your previous files will be saved to:} { Ваші файли будуть збережені у:}
    {View Changes} {Огляд змін}
  }

  ## ________________________ "About" dialogue ________________________ ##
  ::msgcat::mcmset uk {
    {stands for} {значить}
    {Written in pure Tcl/Tk.} {Зроблений на чистому Tcl/Tk.}
    {And well fit for programming with it.} {Та гідний для програмування на ньому.}
    {Details:} {Підробиці:}
    {Authors:} {Автори:}
    {License:} {Ліцензія:}
    {Acknowledgements} {Вдячності}
    "Many thanks to the following people \
    \n who have contributed to this project \
    \n with their participation, advice and code"
    "Щира подяка всім цим людям, \
    \n що внесли свій вклад в цей проект \
    \n своїми порадами, співучастю та кодом"
    {Special thanks also to} {Особлива вдячність також}
    {Packages} {Пакети}
    {Packages used by <red>alited %ver</red>:} {Пакети, використовані в <red>alited %ver</red>:}
  }

  ## ________________________ Preferences ________________________ ##
  ::msgcat::mcmset uk {
    {General} {Загальне}
    {Editor} {Редактор}
    {Units} {Юніти}
    {Keys} {Клавіши}
    {Misc.} {Різне}
    {Saving} {Збереження}
    {View} {Вигляд}
  }

  ### ________________________ General _________________________ ###
  ::msgcat::mcmset uk {
    {Ttk theme:} {Тема Ttk:}
    {Windows themes} {Теми Windows}
    {Color scheme:} {Колірна схема:}
    {Darker:} {Темніше:}
    {Lighter:} {Світліше:}
    {Tint} {Відтінок}
    {Tint:} {Відтінок:}
    "For the settings to be active,\nalited application should be restarted." "Щоб зміни вступили в силу,\nпрограму alited треба перезавантажити."
    {Preferable locale:} {Бажана локаль:}
    "This is a language code: ru, uk, de...\nIn alited, \"en\" means American English." "Це код мови: ru, uk, de...\nВ alited \"en\" значить American English."
    {Small font size:} {Розмір малого шрифту:}
    {Middle font size:} {Розмір середнього шрифту:}
    {Cursor width:} {Ширина курсора:}
    {Color of cursor:} {Колір курсору:}
    {Notes:} {Замітки:}
    "Sort of diary.\nList of TODOs etc." "Типа щоденника.\nСписок TODO та інше."
    {Light / Dark} {Світлі / Темні}
    {Makes colors darker .. lighter} {Робить коліри темніше .. світліше}
    "These themes need\nlight / dark color schemes\naccordingly" "Цим темам потрібні\nсвітлі / темні колірні схеми\nвідповідно"
    {Fit for theme} {Гідно для теми}
    {No color scheme at all} {Ніякої колірної схеми взагалі}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset uk {
    {Font:} {Шрифт:}
    {Gutter's width:} {Ширина жолобу}
    {Gutter's shift from text:} {Відступ жолобу від текста:}
    {Space above lines:} {Відступ над рядками:}
    {Space below lines:} {Відступ під рядками:}
    {Space between wraps:} {Відступ згортованих рядків:}
    {Tab bar label's length:} {Довжина назв панелі файлів:}
    {Tab bar tip's length:} {Довжина підказок панелі файлів:}
    {Border for bar tabs:} {Окравка для панелі файлів:}
    {Code snippet:} {Фрагмент коду:}
    {Blinking cursor:} {Мигання курсору:}
    {Translation} {Переклад}
    {Translation link:} {Лінк перекладів:}
    {Adding translations:} {Додавання перекладів:}
    {If OFF, replaces the original text.} {Якщо вимкнено, замінює оригінальний текст.}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset uk {
    {Save before bar-menu runs:} {Зберігати при викликах bar-menu:}
    {All files} {Всі файли}
    {Current} {Поточний}
    {None} {Нічого}
    {'Recent Files' length:} {Довжина списка 'Нещодавні файли':}
    {'Last Visited' length:} {Довжина списка 'Останні входи':}
    {Maximum of project files:} {Кількість файлів проекта не більше:}
    {Confirm exit:} {Підтверджувати вихід:}
    {Save configuration on} {Зберігати конфігурацію при}
    {opening a file:} {відкритті файлу:}
    {closing a file:} {закритті файлу:}
    {saving a file:} {зберіганні файлу:}
    {Back up files to a project's subdirectory:} {Резервні копії у каталозі проекту:}
    "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." "Підкаталог проекту, де зберігатимуться копії файлів.\nЯкщо це поле пусте, копіювань не буде."
    {  Maximum:} {  Максимум:}
    {Maximum of backup copies per a file} {Максимальна кількість копій файлу}
    {Bell at warnings:} {Звук попереджень:}
    {Port to listen alited:} {Порт слідкування за alited:}
    "The empty value allows\nmultiple alited apps." "Пуста опція дозволяє\nзапускати декілька alited."
  }

  ### ________________________ Keys _________________________ ###
  ::msgcat::mcmset uk {
    {Save File} {Зберегти файл}
    {Save File as} {Зберегти файл як}
    {Run e_menu} {Запуск e_menu}
    {Run File} {Запуск файлу}
    {Double Selection} {Дублювати виділене}
    {Delete Line} {Видалити рядок}
    {Highlight First} {Відокремити перше}
    {Highlight Last} {Відокремити останнє}
    {Find Next Match} {Знайти наступне}
    {Item up} {Підняти елемент}
    {Item down} {Опустити елемент}
    {Complete Commands} {Доповнення команд}
  }

  ### ________________________ Templates tab _________________________ ###
  ::msgcat::mcmset uk {
    {Enter %U, %u, %m, %w, %d, %t wildcards of templates:} {Введіть токени  %U, %u, %m, %w, %d, %t для шаблонів:}
    {User name:} {Ім'я користувача:}
    {Login:} {Логін:}
    {Date format:} {Формат дати:}
    {Time format:} {Формат часу:}
  }

  ### ________________________ Syntax _________________________ ###
  ::msgcat::mcmset uk {
    {Tcl syntax} {Синтаксис Tcl}
    {C/C++ syntax} {Синтаксис C/C++}
    {Plain text} {Просто текст}
    {Tcl files' extensions:} {Розширення файлів Tcl:}
    {C/C++ files' extensions:} {Розширення файлів C/C++:}
    {Plain texts' extensions:} {Розширення текстових файлів:}
    {Color of Tcl commands:} {Колір команд Tcl:}
    {Color of Tk commands:} {Колір команд Tk:}
    {Color of strings:} {Колір значень строк:}
    {Color of variables:} {Колір значень змінних:}
    {Color of comments:} {Колір коментарів:}
    {Color of proc/methods:} {Колір процедур/методів:}
    {Color of options:} {Колір опцій:}
    {Color of brackets:} {Колір скобок:}
    {Color of C key words:} {Колір ключевих слів C:}
    {Color of C++ key words:} {Колір ключевих слів C++:}
    {Color of punctuation:} {Колір знаків препинання:}
    {Color of return/goto:} {Колір return/goto:}
    {Color of your key words:} {Колір ваших ключевих слів:}
    {Colors} {Коліри}
    {Your commands:} {Ваші команди:}
    {Your key words:} {Ваші ключеві слова:}
  }

  ### ________________________ Units _________________________ ###
  ::msgcat::mcmset uk {
    {Branch's regexp:} {RE для гілці:}
    {Proc's regexp:} {RE для функції:}
    {Check branch's regexp:} {Перевірка на гілку:}
    {Check proc's regexp:} {Перевірка на функцію:}
    {Use leaf's regexp:} {Використовувати RE листа:}
    {Leaf's regexp:} {RE листа:}
    {Unaffected top lines:} {Статичних початкових рядків:}
    {For leaf units only!} {Тільки для юнітів листів!}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset uk {
    {Open bar-menu settings} {Відкрити настройки bar-menu}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Іконка включить запуск з тулбару.\nПуста або 'none' іконка виключить запуск з тулбару."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "Виклик команди для меню та/або тулбара.\nВиберіть ії з команд e_menu."
    {Directory of menus:} {Каталог меню:}
    {Main menu:} {Головне меню:}
    {Projects (%PD wildcard):} {Проекти (%PD токен):}
    {Linux terminal:} {Термінал Linux:}
    {Diff tool:} {Команда diff:}
    {Path to man/tcl:} {Шлях до man/tcl:}
    {tclsh, wish or tclkit:} {tclsh, wish або tclkit:}
    {Geometry:} {Геометрія:}
    {Run as external app:} {Як окрему програму:}
    {Delete an item} {Видалити елемент}
    {Move an item up} {Підняти елемент}
    {Move an item down} {Опустити елемент}
    {separator} {роздільник}
    {If 'yes', means a separator of the toolbar/menu.} {Якщо включено, значить роздільник у тулбарі/меню.}
    {For Start...} {Для старту...}
    " Enter commands to be run after starting alited.\n They can be Tcl or executables:" " Введіть команди, що мають виконатися після старту alited,\n тобто команди Tcl або зовнішні команди:"
    {By command:} {Командою:}
    {By command #RUNF:} {Командою #RUNF:}
    {Run:} {Запуск:}
    {Run it} {Пуск}
    { OS or Tcl commands to be run before running a current file:} { Команди OS або Tcl, що мають виконуватися перед запуском поточного файлу:}
    { Also, you can set "forced command" to be run by "Run" tool:} { Також ви можете ввести "примусову команду" для Запуску:}
    {Forcedly:} {Примусово:}
    {e_menu's own} {своя в e_menu}
    {Select any of run item} {Виберіть яку-небудь команду}
    "Incorrect \"Preferences/Tools/tclsh...\"\nresults in the error:" "Некоректна настройка \"Настройки/Струменти/tclsh...\"\nпризводить до помилки:"
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset uk {
    {Check Tcl} {Перевірка Tcl}
    {Check Tcl...} {Перевірка Tcl...}
    {Check} {Перевірка}
    {Check:} {Перевірити:}
    {Checks available:} {Можливі перевірки:}
    {Consistency of {} } {Відповідність {}}
    {Consistency of []} {Відповідність []}
    {Consistency of ()} {Відповідність ()}
    {Consistency of ""} {Відповідність ""}
    {all of session files} {всі файли сеансу}
    {current file} {поточний файл}
    {Found %f file error(s), %u unit error(s).} {Знайдено помилок: %f файлів, %u юнітів.}
    {No errors found.} {Помилок не знайдено.}
    {Errors found in unit:} {Знайдено помилки у юніті:}
    {Duplicate units} {Дублікатні юніти}
    {duplicate unit:} {дублікатний юніт:}
  }

  ## ________________________ Macros ________________________ ##
  ::msgcat::mcmset uk {
    "The macro is updated at its recording.\nPress %s to play it." "Макрос буде оновлено по його запису.\nНатисніть %s для його прокрутки."
    {Playing:} {Прокрутка:}
    {Recording:} {Запис:}
    {Play Macro} {Прокрутити макрос}
    {Record Macro} {Записати макрос}
    {Delete Macro} {Видалити макрос}
    {Record mouse} {Записати мишу}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset uk {
    "\"%f\" removed to \"%d\"" "\"%f\" видалений до \"%d\""
    {File name:} {Ім'я файлу:}
    {Directory} {Каталог}
    "The file \"%f\" seems to be not of types\n%s.\n\nStill do you want to open it?" "Файл \"%f\", здається, не типа\n%s.\n\nВсе одно відкрити його?"
  }

  ## ________________________ Find units ________________________ ##
  ::msgcat::mcmset uk {
    {Find Unit} {Шукати юніт}
    {in all} {у всіх}
    {in current} {у поточному}
    "Use glob patterns to find units' declarations\ne.g. \"s*rt\" would find \"start\" and \"insert\".\nThe letter case is ignored." "Користуйтеся шаблоном glob для пошуку юнітів:\nнаприклад, \"s*rt\" знайде \"start\" та \"insert\".\nРегістр букв не враховується."
    {Incorrect name for a unit.} {Некорректне ім'я для юніта.}
  }

  ## ________________________ Abbreviations etc. ________________________ ##
  #   Line - 2nd column's title of unit tree
  ::msgcat::mcmset uk {
    {Row} {Ряд.}
    {Row } {Ряд }
    { Col } { Поз }
    {    Unit: } {   Юніт: }
  }

  ## ________________________ Bar of tabs ________________________ ##
  ::msgcat::mcmset uk {
    {(Un)Select} {Відділити / ні}
    {... Visible} {... видимі}
    {... All at Left} {... всі злева}
    {... All at Right} {... всі зправа}
    {... All} {... всі}
    {File List} {Список файлів}
    {Sort} {Сортувати}
    {Sort files} {Сортувати файли}
    {Sorted} {Сортований}
    {... by date} {... по даті}
    {... by size} {... по розміру}
    {... by extension} {... по розширенню}
    {increasing} {зростаючи}
    {decreasing} {спадаючи}
    {Files to Beginning} {Файли у початок}
    "If it's checked, open files would be placed\nonto the beginning page of the bar." "Якщо ця опція включена, файли при відкритті\nрозташовуються на першій сторінці списку."
  }

  ## ________________________ Paver _________________________ ##

  ::msgcat::mcmset uk {
    {For paveWindow's widget list to be recognized, set the cursor inside it.} {Встановіть курсор усередині списку виджетів paveWindow, щоб список був упізнаним.}
    {Auto Update} {Оновляти автоматично}
    {Widget List} {Список виджетів}
  }

  ## ____________________ Rectangular selection ___________________ ##

  ::msgcat::mcmset uk {
    {Rectangular Selection} {Прямокутне виділення}
    {Start} {Почати}
    {Cut} {Вирізати}
    {Copy} {Копіювати}
    {Paste} {Вставити}
    {Move the cursor to select a rectangle.} {Рухайте курсор для виділення прямокутника.}
  }

  ## ________________________ Formats _________________________ ##

  ::msgcat::mcmset uk {
    {Formats} {Формати}
    {Moving Unit Descriptions} {Перенесення описів юнитів}
    {Moving Unit Descriptions...} {Перенесення описів юнитів...}
    {Move Unit Descriptions} {Перенести описи юнитів}
    {Selected} {Виділені}
    {Move proc/method descriptions:} {Перенести описи proc/method:}
    {From inside to out} {Внутрішні у зовнішні}
    {From out to inside} {Зовнішні у внутрішні}
    {Separator:} {Сепаратор:}
    {Process .tcl file(s):} {Обробити .tcl файл(и):}
    " Current leaf's RE\n\n   <r>%r1</r>\n\n is not equal to standard\n\n   <r>%r2</r>\n\n as set in Projects/Options and Preferences/Units."
    " Поточний RE юніта\n\n   <r>%r1</r>\n\n не рівен стандартному\n\n   <r>%r2</r>\n\n згідно з настройками\n Проекти/Опції та Настройки/Опції."
    "The separator doesn't match to the regexp:\n\n  "
    "Сепаратор не відповідає регулярному виразу:\n\n  "
    {Separator must contain "n" or "N" for unit name!}
    {Сепаратор повинен включати "n" або "N" для назви юніта!}
    {The separator should be Tcl comment!} {Сепаратор повинен бути коментарем Tcl!}
    {Were all files properly backed up?} {Всі файли архівовані?}
    "PROJECT OPTION \"Use leaf's regexp\" SWITCHED TEMPORARILY TO "
    "ОПЦІЯ ПРОЕКТУ \"Використовувати RE листа\" терміново переключена у "
    {Files processed successfully: %n} {Успішно оброблено файлів: %n}
    {%f processed, units affected: %n} {%f оброблений, зачеплено юнітів: %n}
    {%f processed, units affected: %n - ALREADY PROCESSED?}
    {%f оброблений, зачеплено юнітів: %n - ВЖЕ ОБРОБЛЕНИЙ?}
    {ERROR} {ПОМИЛКА}
    {Strings} {Стрічки}
    {Keyboard} {Клавіатура}
    {Sorting lines} {Сортування рядків}
    {Misc} {Різне}
    {External} {Зовнішній}
    {Pluginable} {Підмикний}
    {Applied to one selection only!} {Припустиме тільки одне виділення!}
    "Incorrect mapped 'from-to' in: %l" "Некоректне відображення 'з-на' у: %l"
    "'from' refers to previous 'to' in: %l (see: %n)" "'з' посилається на попереднє 'на' у: %l (див.: %n)"
    {Use %e to run "%m"} {Користуйтесь %e для запуску "%m"}
    {%e is overlapped by formatter "%f"} {%e перекривається форматером "%f"}
  }

  ## ________________________ Project printer _________________________ ##

  ::msgcat::mcmset uk {
    {Project Printer} {Друкар проекту}
    {Project Printer...} {Друкар проекту...}
    {Output directory:} {Каталог призначення:}
    {Markdown processor:} {Обробник markdown:}
    {Directory title colors} {Коліри заголовку каталога}
    {Foreground:} {Текст:}
    {Background:} {Фон:}
    {File title colors} {Коліри заголовку файла}
    {Syntax colors:} {Коліри синтаксису:}
    {Width of contents:} {Ширина змісту:}
    {Final processor:} {Остаточний обробник:}
    {Output directory cannot be cleared: alien files} {Каталог призначення неможливо вичистити: чужі файли}
    {Output directory cannot be cleared: alien %n} {Каталог призначення неможливо вичистити: чужі %n}
    {Output directory cannot be cleared: alien directories} {Каталог призначення неможливо вичистити: чужі каталоги}
    "The output directory\n  %n\ncontains %c subdirectories.\n\nAll will be replaced with the new!" "Каталог призначення\n  %n\nмає %c підкаталогів.\n\nВсі вони будуть заміщені новими!"
    {Sort units:} {Сортувати юніти:}
    {Runs the final processor.} {Запуск остаточного обробника.}
  }

  ## ________________________ EONS alited _________________________ ##
}

# _ apave NS _ #

namespace eval ::apave {
  ::msgcat::mcmset uk {
    {Save text} {Зберегти текст}
    {Don't save} {Не зберігати}
    {Save changes made to the text?} {Зберегти змінений текст?}
  }
}

# _ bartabs NS _ #

namespace eval ::bartabs {

  ## ________________________ Popup menu _________________________ ##

  ::msgcat::mcmset uk {
    {List} {Список}
    {behind} {слід за}
    {Close} {Закрити}
    {... All} {... всі}
    {... All at Left} {... всі злева}
    {... All at Right} {... всі зправа}
  }
}

# _________________________________ EOF _________________________________ #
