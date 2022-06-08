# ________________________ uk.msg _________________________ #
# Name:    uk.msg
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    10/15/2021
# Brief:   Handles Ukranian localization.
# License: MIT.



# ________________________ Ukranian vs Russian _________________________ #

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
    {Conversions} {Перетворення}
    {Change Encoding...} {Змінити кодировку...}
    {Change EOL...} {Змінити EOL...}
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
    {... All} {... всі}
    {... All at Left} {... всі злева}
    {... All at Right} {... всі справа}
    {Preferences} {Настройки}
    {Preferences...} {Настройки...}
    {Restart} {Перезапуск}
    {Quit} {Вихід}
    {Put New Line} {Додати рядок}
    {Remove Trailing Whitespaces} {Видалити хвостові пробіли}
    {Remove trailing whitespaces} {Видалити хвостові пробіли}
    {Remove trailing whitespaces:} {Видаляти хвостові пробіли:}
    "Remove trailing whitespaces of all lines\nof \"%f\"?" "Видалити хвостові пробіли у всіх рядках\nфайла \"%f\"?"
    {Indent} {Додати відступ}
    {Unindent} {Убрати відступ}
    {Comment} {Закоментувати}
    {Uncomment} {Разкоментувати}
    {Find Next} {Шукати далі}
    {Look for Declaration} {Шукати декларацію}
    {Look for Word} {Шукати слово}
    {Run} {Запуск}
    {Run...} {Запуск...}
    {In console} {У консолі}
    {In Tkcon} {У Tkcon}
    {Moving} {Переміщення}
    {Help of alited} {Допомога alited}
    {Color Picker} {Вибір коліру}
    {Date Picker} {Вибір дати}
    {Screen Loupe} {Екранна лупа}
    {Quit alited?} {Вийти з alited?}
    {Wait a little ...} {Почекайте ...}
    {Default} {За замовчуванням}
    {Default 2} {За замовчуванням 2}
    {Default 3} {За замовчуванням 3}
    {Default 4} {За замовчуванням 4}
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
    {Lists of Favorites} {Списки Вибраного}
    {Last Visited} {Останні вхіди}
    {Switch to Unit Tree} {Перейти на список юнітів}
    {Switch to File Tree} {Перейти на список файлів}
    {Create File} {Створити файл}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Введіть ім'я файлу, створюваного в:\n%d\n\nЯкщо це каталог, включіть опцію 'Каталог'.\nКаталог може включати підкаталоги (a/b/c)."
    {Delete File} {Видалити файл}
    "File %f already exists in\n%d" "Файл %f вже існує в\n%d"
    {Remove Unit(s)} {Видалити юніт(и)}
    {No item selected.} {Запис не выбраний.}
    {Update Tree} {Оновити список}
    {Contract All} {Згорнути все}
    {Expand All} {Розгорнути все}
    "Move %f\nto\n%d\n?" "Переместити %f\nу\n%d\n?"
    {To Last Visited} {На останній вхід}
    {To Matched Bracket} {На парну скобку}
    {Go to Line} {Перейти на рядок}
    {Line number:} {Номер рядку:}
    {    In unit:} {    У юніті:}
    "\"%n\" contains unbalanced \{\}: %1!=%2" "\"%n\" має незбалансовані \{\}: %1!=%2"
    {Back} {Откат}
    {File not found: %f} {Файл не знайдений: %f}
    {Unit not found: %u} {Юніт не знайдений: %u}
    {Don't show anymore} {Більш не показувати}
    {%f is a directory} {%f - це каталог}
    {THE EXTERNAL FILE IS MOVED TO THE PROJECT!} {ЗОВНІШНІЙ ФАЙЛ ПЕРЕМЕЩУЄТЬСЯ У ПРОЕКТ!}
    {Drop Selected Units Here} {Кинути сюди вибрані юніти}
    {Drop Selected Files Here} {Кинути сюди вибрані файли}
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open.\n\nThis may be expensive!" "Всі Tcl файли каталогу:\n  \"%f\"  \nбудуть відкриті.\n\nЦя операція може бути коштовною!"
    {Select All} {Виділити все}
    {Do it in other Tcl files} {Також і в інших файлах Tcl}
    {Do it in other files} {Також і в інших файлах}
    "File \"%f\" doesn't exist." "Файл \"%f\" не існує."
    {Selected files: %n} {Виділених файлів: %n}
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
    {An open file can not be deleted.} {Неможливо видалити відкритий файл.}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "Файл \"%f\" був змінений іншою програмою.\n\nВідмінити вашу редакцію та завантажити файл знову?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "Файл \"%f\" був видалений іншою програмою.\n\nЗберігти файл?"
    {Tip File Info} {Дані про файли}
    {Rename File} {Перейменувати файл}
    {Select one file in the tree.} {Виберіть один файл у списку.}
    {Open Selected File(s)} {Відкрити виділені файл(и)}
    {Close Selected File(s)} {Закрити виділені файл(и)}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset uk {
    {Template} {Шаблон}
    {Templates} {Шаблони}
    {Templates...} {Шаблони...}
    {List of Templates} {Список шаблонів}
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
    {Project name:} {Назва проекту:}
    {Root directory:} {Коріневий каталог:}
    {Skip subdirectories:} {Пропускати підкаталоги:}
    {Description:} {Опис:}
    {Indentation:} {Пробілів відступу:}
    {Auto detection} {Автовизначення}
    {End of line:} {Кінці рядків:}
    {Multi-line strings:} {Багаторядкові string:}
    {Unit lines per 1 red bar:} {Рядків юніта на 1 червону смужку:}
    {List of files:} {Список файлів:}
    "You can\n  - add the current one to\n  - substitute with the current one\n  - delete\n  - not change\nthe file list of the project.\n" "Ви можете\n  - додати поточний список файлів до\n  - замінити поточним списком\n  - видалити\n  - не змінювати\nсписок файлів у проекті.\n"
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
    {TODO reminders for the past: %d. Delete them or try "Select".} {TODO нагадування минулого: %d. Видалите їх або спробуйте "Вибір".}
    "You may select file(s)\nand open them with a context menu.\n\nOr just double-click." "Ви можете виділити файл(и)\nта через контекстне меню відкрити їх.\n\nАбо ж відкрийте подвійним кліком."
    {No selected files} {Немає виділених файлів}
    {Open file:} {Відкрито файл:}
    {Open files: %n} {Файлів на відкриття: %n}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset uk {
    {Lists of favorites:} {Списки Вибраного}
    {Current list of favorites:} {Поточний список Вибраного}
    {New list of favorites:} {Новий список Вибраного:}
    {Add a list of favorites} {Додатиь список Вибраного}
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
    {Favorites...} {Вибране...}
    "Add \"%n\" of %f\nto Favorites?" "Додати \"%n\" файлів %f\nу Вибране?"
    "Item \"%n\" of %f\nis already in Favorites." "Юніт \"%n\" з %f\nвже є у Вибраному."
    "Remove \"%n\" of %f\nfrom Favorites?" "Видалити \"%n\" файлів %f\nз Вибраного?"
    "\"%n\" unit of %f is not in the list." "Юніта \"%n\" файлу %f немає у списку."
    {Add to Favorites} {Додати до Вибраного}
    {Remove} {Видалити}
    {Remove All} {Видалити все}
    {Remove all of Favorites?} {Видалити все з Вибраного?}
    {Remove all of the last visited?} {Видалити все з Останніх входів?}
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset uk {
    "Create a file\nCtrl+N" "Утворити файл\nCtrl+N"
    "Open a file\nCtrl+O" "Відкрити файл\nCtrl+O"
    "Save the file\nF2" "Зберегти файл\nF2"
    "Save all files\nCtrl+Shift+S" "Зберегти всі файли\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Контекстна допомога по Tcl/Tk\nF1"
    {Find / Replace} {Пошук / Заміна}
    "Find / Replace\nCtrl+F" "Пошук / Заміна\nCtrl+F"
    "Run the file\nF5" "Виконати файл\nF5"
    "Run e_menu\nF4" "Виклик e_menu\nF4"
    "Undo changes\nCtrl+Z" "Відміна змін\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Перевідміна змін\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset uk {
    {Find: } {Шукати: }
    {Replace: } {Замінити: }
    {Match: } {Збіг: }
    {Exact} {Точний}
    {Match whole word only} {Тільки цілі слова}
    {Match case} {Регістр букв}
    {Wrap around} {По кругу}
    {Replace by blank} {Пусті заміни}
    {Direction:} {Напрямок:}
    {Down} {Наниз}
    {Up} {Наверх}
    {Stay on top} {Над всіма вікнами}
    {Stay on top:} {Над всіма вікнами:}
    {Find} {Пошук}
    {Replace} {Заміна}
    {All in Text} {Все у тексті}
    {All in Session} {Все у сеансі}
    {All in %n Files} {Все у %n файлах}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Дозволяє використовувати *, ?, \[, \]\nу рядку пошуку."
    "Allows to use the regular expressions\nin \"find\" string." "Дозволяє використовувати регулярні вирази\nу пошуку."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Дозволяє пусті заміни,\nтобто просто видалення знайдених строк."
    "Keeps the dialogue above other windows." "Тримає діалог пошуку\nпонад іншими вікнами."
    "Found %n matches for \"%s\"." "Знайдено %n шуканих \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "Зроблено %n замін \"%s\" на \"%r\" в \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "Зроблено %n замін \"%s\" на \"%r\" в усьому сеансі."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "Замінити всі \"%s\"\n\nна \"%r\"\n\nу \"%f\" ?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all texts?" "Замінити всі \"%s\"\n\nна \"%r\"\n\nв усіх текстах?"
    {Don't focus a text after selecting in infobar} {Не переходити на текст при виборі у інфобарі}
    {Focus a text after selecting in infobar} {Переходити на текст при виборі у інфобарі}
    {Find by List} {Шукати по списку}
    {List:} {Список:}
    {\n Enter a list of words divided by spaces: \n} {\n Введіть список слів, разділених пробілами: \n}
    {FOUND:} {ЗНАЙДЕНІ:}
    {NOT FOUND:} {НЕ ЗНАЙДЕНІ:}
  }

  ## ________________________ Checking ini directory ________________________ ##
  ::msgcat::mcmset uk {
    {Choosing Directory for Settings} {Вибір каталогу для опцій}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n" "\n Програма \"alited\" мусить мати каталог для збереження своїх опцій.\n Ви можете задати його як аргумент при виклику alited.\n\n За замовчуванням, каталог збереження опцій - \"%d\".\n Це рекомендований каталог, що дозволяє викликати \"alited\" без аргументів.\n"
    {Choose a directory} {Вибір каталогу}
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
    "Many thanks to the following people\n who have contributed to this project" "Щира подяка всім цим людям,\n що внесли свій вклад в цей проект"
    {Special thanks also to} {Особлива вдячність також}
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
    {Color scheme:} {Колірна схема:}
    {Darker:} {Темніше:}
    {Lighter:} {Світліше:}
    {Tint} {Відтінок}
    {Tint:} {Відтінок:}
    "For the settings to be active\nthe application should be restarted.\n\nRestart it just now?" "Щоб зміни вступили в силу,\nпрограму треба перезавантажити.\n\nЗробити це прямо зараз?"
    {Preferable locale:} {Бажана локаль:}
    "This is a country code: ru, uk, de...\nIn alited, \"en\" means American English." "Це код держави: ru, uk, de...\nВ alited \"en\" значить American English."
    {Small font size:} {Розмір малого шрифту:}
    {Middle font size:} {Розмір середнього шрифту:}
    {Cursor width:} {Ширина курсора:}
    {Notes:} {Замітки:}
    "Sort of diary.\nList of TODOs etc." "Типа щоденника.\nСписок TODO та інше."
    {Light / Dark} {Світла / Темна}
    {Makes colors darker .. lighter} {Робить коліри темніше .. світліше}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset uk {
    {Font:} {Шрифт:}
    {Font size:} {Розмір шрифта:}
    {Gutter's width:} {Ширина жолобу}
    {Gutter's shift from text:} {Відступ жолобу від текста:}
    {Space above lines:} {Відступ над рядками:}
    {Space below lines:} {Відступ під рядками:}
    {Space between wraps:} {Відступ згортованих рядків:}
    {Tab bar label's length:} {Довжина назв панелі файлів:}
    {Tab bar tip's length:} {Довжина підказок панелі файлів:}
    {Code snippet:} {Фрагмент коду:}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset uk {
    {Save before bar/menu runs:} {Зберігати при викликах bar/menu:}
    {Current file} {Поточний файл}
    {All files} {Всі файли}
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

  ### ________________________ Templates _________________________ ###
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
    {Untouched top lines:} {Статичних початкових рядків:}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset uk {
    {Open bar/menu settings} {Відкрити настройки bar/menu}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Іконка включить запуск з тулбару.\nПуста або 'none' іконка виключить запуск з тулбару."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "Виклик команди для меню та/або тулбара.\nВиберіть ії з команд e_menu."
    {Directory of menus:} {Каталог меню:}
    {Main menu:} {Головне меню:}
    {Projects (%PD wildcard):} {Проекти (%PD токен):}
    {Linux terminal:} {Термінал Linux:}
    {Diff tool:} {Команда diff:}
    {Path to man/tcl8.6:} {Шлях до man/tcl8.6:}
    {tclsh, wish or tclkit:} {tclsh, wish або tclkit:}
    {Rows:} {Рядків:}
    {Columns:} {Колонок:}
    {Geometry:} {Геометрія:}
    {Run as external app:} {Як окрему програму:}
    {Inserts a new line.} {Додає рядок.}
    {Deletes a line.} {Видаляє рядок.}
    {separator} {роздільник}
    {Item} {Пункт}
    {If 'yes', means a separator of the toolbar/menu.} {Якщо включено, значить роздільник у тулбарі/меню.}
    {After Start...} {Після старту...}
    {Before Run...} {Перед Запуском...}
    {Commands:} {Команди:}
    {Commands after start} {Команди після старту}
    {Commands before "Run"} {Команди перед "Запуском"}
    "\n Enter commands to be run after starting alited. They can be Tcl or executables, e.g.\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n It can be necessary for a specific environment.\n" "\n Введіть команди, що мають виконатися після старту alited,\n тобто команди Tcl або зовнішні команди, наприклад:\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n Це може бути потрібно у деяких середовищах.\n"
    "\n Enter commands to be run before running a current file with \"Tools/Run\". They can be Tcl or executables, e.g.\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n It can be necessary for a specific project. Something like an initialization before \"Run\".\n" "\n Введіть команди, виконувані перед \"Струменти/Запуск\",\n тобто команди Tcl або зовнішні команди, наприклад:\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n Це може бути корисно у деяких проектах. Щось типа ініціалізації перед запуском.  \n"
    {e_menu's own} {своя в e_menu}
    {(if ON, Tcl scripts run in console, otherwise in tkcon)} {(якщо ON, скрипти Tcl запускаються в консолі, інакше - в tkcon)}
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset uk {
    {Check Tcl} {Перевірка Tcl}
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
    {Duplicate units} {Дублікатні юніти}
    {duplicate unit:} {дублікатний юніт:}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset uk {
    "Can't backup \"%f\" to\n\"%d\"!\n\nDelete it anyway?" "Не можу зробити копію \"%f\" в\n\"%d\"!\n\nВидалити цей файл все одно?"
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
    {Row: } {Ряд: }
    { Col: } { Поз: }
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
  }

  ## ________________________ --EONS-- _________________________ ##
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

  ## ________________________ --EONS-- _________________________ ##
}

# _________________________________ EOF _________________________________ #
#RUNF1: ../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
