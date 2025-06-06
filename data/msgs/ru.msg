# ________________________ ru.msg _________________________ #
# Name:    ru.msg
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/29/2021
# Brief:   Handles Russian localization.
# License: MIT.

# ________________________  alited NS _________________________ #

namespace eval ::alited {

  ## ________________________ Common _________________________ ##

  ::msgcat::mcmset ru {
    {No name} {Без имени}
    "\"%f\" wasn't saved.\n\nSave it?" "\"%f\" не сохранен.\n\nСохранить?"
    {About} {О программе}
    {About...} {О программе...}
    {Error} {Ошибка}
    {Warning} {Предупреждение}
    {Question} {Вопрос}
    {Information} {Информация}
    {File} {Файл}
    {Edit} {Правка}
    {Search} {Поиск}
    {Tools} {Снасти}
    {Setup} {Опции}
    {Setup...} {Опции...}
    {Help} {Помощь}
    {Yes} {Да}
    {No} {Нет}
    {Cancel} {Отмена}
    {Close} {Закрыть}
    {New} {Новый}
    {Open...} {Открыть...}
    {Open Selected Files with} {Открыть выбранные файлы в}
    {Recent Files} {Недавние файлы}
    {Save} {Сохранить}
    {Save as...} {Сохранить как...}
    {Save All} {Сохранить все}
    {Save and Close} {Сохранить и закрыть}
    {Close and Delete} {Закрыть и удалить}
    {Detach} {Отцепить}
    {Detach Selected Files} {Отцепить выбранные файлы}
    {Preferences} {Настройки}
    {Preferences...} {Настройки...}
    {Quit} {Выход}
    {Put New Line} {Добавить строку}
    {Remove Trailing Whitespaces} {Удалить хвостовые пробелы}
    {Remove trailing whitespaces} {Удалить хвостовые пробелы}
    {Remove trailing whitespaces:} {Удалять хвостовые пробелы:}
    "Remove trailing whitespaces of all lines\nof \"%f\"?" "Удалить хвостовые пробелы во всех строках\nфайла \"%f\"?"
    {Indent} {Добавить отступ}
    {Unindent} {Убрать отступ}
    {Comment} {Закомментить}
    {Comment:} {Комментарий:}
    {Comments} {Комментарии}
    {Uncomment} {Раскомментить}
    {Find Next} {Искать дальше}
    {Look for Declaration} {Искать объявление}
    {Look for Word} {Искать слово}
    {Run} {Запуск}
    {Run...} {Запуск...}
    {Run as Is} {Запуск как есть}
    {in console} {в консоли}
    {in Tkcon} {в Tkcon}
    {as is} {как есть}
    {Moving} {Перемещение}
    {Color Picker} {Выбор цвета}
    {Date Picker} {Выбор даты}
    {Screen Loupe} {Экранная лупа}
    {Quitting alited.} {Выходим из alited.}
    {Wait a little ...} {Подождите ...}
    {Standard} {Стандарт}
    {Standard 2} {Стандарт 2}
    {Standard 3} {Стандарт 3}
    {Standard 4} {Стандарт 4}
    {Test} {Проверка}
    {Correct Indentation} {Править отступы}
    "Correct the indentation of \"%f\"\nwith indenting %i spaces?" "Править отступы \"%f\",\nпо %i на каждый?"
    {The line %n: unbalanced brace!} {Строка %n: несбалансированная скобка!}
    {Wrap Lines} {Сворачивать строки}
    {Default values for new projects:} {Опции по умолчанию для проектов:}
  }

  ::msgcat::mcmset ru {
    {Select} {Выбор}
    {Save as} {Сохранить как}
    {Files} {Файлы}
    {Line} {№ ст.}
    {Lines} {Строки}
    "All of \"%f\"" "Всё из \"%f\""
    "Not recommended for projects\nwith large files (>2000 LOC)!" "Не рекомендуется для проектов\nс большими файлами (>2000 строк)!"
    {Move Unit Up} {Поднять юнит}
    {Move Unit Down} {Опустить юнит}
    {Move File Up} {Переместить файл вверх}
    {Move File Down} {Переместить файл вниз}
    {Only files are moved by alited.} {Только файлы перемещает alited.}
    {Saved Lists of Favorites} {Сохраненные списки Избранного}
    {Last Visited} {Последние входы}
    {Switch to Unit Tree} {Перейти на список юнитов}
    {Switch to File Tree} {Перейти на список файлов}
    {Create File} {Создать файл}
    {Create File...} {Создать файл...}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Введите имя файла, создаваемого в:\n%d\n\nЕсли это каталог, включите опцию 'Каталог'.\nКаталог может включать подкаталоги (a/b/c)."
    {Delete File} {Удалить файл}
    "\nFile \"%f\" already exists in\n%d\n" "\nФайл \"%f\" уже существует в\n%d\n"
    "\nFile\n  \"%f\"\ndoesn't exist.\n" "\nФайл\n  \"%f\"\nне существует.\n"
    {Delete Unit(s)} {Удалить юнит(ы)}
    {No item selected.} {Запись не выбрана.}
    {Update Tree} {Обновить список}
    {Contract All} {Свернуть всё}
    {Expand All} {Развернуть всё}
    {Expand Selected} {Развернуть выбранные}
    "Move %f\nto\n%d\n?" "Переместить %f\nв\n%d\n?"
    {To Last Visited} {На последний вход}
    {To Matched Bracket} {На парную скобку}
    {Go to Line} {Перейти на строку}
    {Line number:} {Номер строки:}
    {    In unit:} {     В юните:}
    "\"%n\" contains unbalanced \{\}: %1!=%2" "\"%n\" имеет несогласованные \{\}: %1!=%2"
    {Back} {Откат}
    {Unit not found: %u} {Юнит не найден: %u}
    {Don't show anymore} {Больше не показывать}
    {%f is a directory} {%f - это каталог}
    {THE EXTERNAL FILE IS MOVED TO THE PROJECT!} {ВНЕШНИЙ ФАЙЛ ПЕРЕМЕЩАЕТСЯ В ПРОЕКТ!}
    {Drop Selected Units Here} {Кинуть сюда выбранные юниты}
    {Drop Selected Files Here} {Кинуть сюда выбранные файлы}
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open. This may be expensive!" "Все Tcl файлы каталога:\n  \"%f\"  \nбудут открыты. Эта операция может быть затратной!"
    {Select All} {Выделить все}
    {Do it in other Tcl files} {И в других файлах Tcl тоже}
    {Do it in other files} {И в других файлах тоже}
    {Selected files: %n} {Выделенных файлов: %n}
    {Configurations...} {Конфигурации...}
    {Tips on / off} {Подсказки вкл / выкл}
    {Exit} {Выход}
    {Encoding} {Кодировка}
    {Reload with EOL} {Загрузить с EOL}
    "Save the file:\n%F ?" "Сохранить файл:\n%F ?"
    {Reload with Encoding} {Загрузить в кодировке}
    "Saving and reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nSave the file:\n%F ?" "Сохранение и открытие \"%f\"\nв кодировке \"%e\" может оказаться ошибочным.\n\nСохранить файл:\n%F ?"
    "Reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nReload the file:\n%F ?" "Загрузка \"%f\"\nв кодировке \"%e\" может оказаться ошибочной.\n\nЗагрузить файл:\n%F ?"
    {Color Values #hhhhhh} {Значения цветов #hhhhhh}
    {Display Colors} {Отобразить цвета}
    {Hide Colors} {Скрыть цвета}
    {Display colors in the whole text?} {Отобразить цвета во всем тексте?}
    {check RE in Find/Replace box} {включите RE в окошке Поиск/Замена}
    {Context} {Контекстная}
    {Changes will be lost!} {Изменения будут потеряны!}
    {Marks} {Метки}
    "Left click sets / goes to a mark.\nRight click clears it." "Левый клик ставит / идет на метку.\nПравый клик очищает ее."
    {Clear All} {Очистить все}
    {Width} {Ширина}
    {Weeks in Calendar} {Недели в календаре}
  }

  ## ________________________ Moving a first unit up ________________________ ##
  ::msgcat::mcmset ru {
    {First Lines} {Первые строки}
    {Can't touch the first %n lines.} {Первые %n строк неподвижны.}
  }

  ## ________________________ Tree ________________________ ##
  ::msgcat::mcmset ru {
    "Click \"%t\"" "Кликните \"%t\""
    {Copy Declaration} {Копировать объявление}
    "Open All Tcl Files of \"%n\"" "Открыть все файлы Tcl из \"%n\""
    "Remove \"%n\"\nfrom \"%f\"?" "Удалить \"%n\"\nиз \"%f\"?"
    "Delete \"%f\"?" "Удалить \"%f\"?"
    {Rewrite} {Перезаписать}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "Файл \"%f\" был изменен другим приложением.\n\nОтменить вашу редакцию и перезагрузить файл?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "Файл \"%f\" был удален другим приложением.\n\nСохранить файл?"
    {Tip File Info} {Данные о файлах}
    {Rename File} {Переименовать файл}
    {Rename File...} {Переименовать файл...}
    {Clone File} {Клонировать файл}
    {Clone File...} {Клонировать файл...}
    {Clone...} {Клонировать...}
    {Select one file in the tree.} {Выберите один файл в списке.}
    {Open Selected Files} {Открыть выделенные файлы}
    {Close Selected Files} {Закрыть выделенные файлы}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset ru {
    {Template} {Шаблон}
    {Template:} {Шаблон:}
    {Templates} {Шаблоны}
    {Templates...} {Шаблоны...}
    {Type Templates} {Типовые шаблоны}
    {Current template:} {Текущий шаблон:}
    {New template:} {Новый шаблон:}
    {Hot keys} {Клавиши}
    {Add a template} {Добавить шаблон}
    {Change a template} {Изменить шаблон}
    {Delete a template} {Удалить шаблон}
    {Click a template} {Выберите какой-нибудь шаблон}
    {The template #%n added} {Шаблон #%n добавлен}
    {The template #%n updated} {Шаблон #%n изменен}
    {The template #%n removed} {Шаблон #%n удален}
    {Enter a name of the template} {Введите название шаблона}
    {Enter a text of the template} {Введите текст шаблона}
    "Choose a hot key combination\nfor the template insertion." "Выберите комбинацию клавиш\nдля вставки шаблона."
    {A template with the attribute(s) already exists.} {Шаблон с такими атрибутами уже существует.}
    {Place after:} {Вставить за:}
    {line} {строка}
    {unit} {юнит}
    {cursor} {курсор}
    {file's beginning} {начало файла}
    "Inserts a template\nbelow a current line" "Вставить шаблон\nследом за текущей строкой"
    "Inserts a template\nbelow a current unit" "Вставить шаблон\nследом за текущим юнитом"
    "Inserts a template at the cursor\n(good for one-liners)" "Вставить шиблон в позиции курсора\n(годится для однострочных шаблонов)"
    "Inserts a template after 1st line of a file\n(License, Introduction etc.)" "Вставить шаблон в начало файла\n(Лицензия, Вступление и пр.)"
    {Delete a template #%n ?} {Удалить шаблон #%n ?}
    "Import templates\nfrom external alited.ini" "Импортировать шаблоны\nиз внешнего alited.ini"
    {Number of imported templates: %n} {Число импортированных шаблонов: %n}
  }

  ## ________________________ Projects ________________________ ##
  ::msgcat::mcmset ru {
    {Projects} {Проекты}
    {Projects...} {Проекты...}
    {You are going to %n!} {Вы собираетесь %n!}
    {Add a project} {Добавить проект}
    {Change a project} {Изменить проект}
    {Delete a project} {Удалить проект}
    {Don't delete the current project!} {Не удаляйте текущий проект!}
    "The project \"%n\" added" "Проект \"%n\" добавлен"
    "The project \"%n\" updated" "Проект \"%n\" изменен"
    "The project \"%n\" removed" "Проект \"%n\" удален"
    {Options} {Опции}
    {Project:} {Проект:}
    {Root directory:} {Корневой каталог:}
    {Skip files/directories:} {Пропускать файлы/каталоги:}
    {Description:} {Описание:}
    {Indentation:} {Пробелов отступа:}
    {Auto detection} {Автоопределение}
    {End of line:} {Концы строк:}
    {Multi-line strings:} {Многострочные string:}
    {Unit lines per 1 red bar:} {Строк юнита на 1 красную полосу:}
    {List of files (%n):} {Список файлов (%n):}
    {Add} {Добавить}
    {Substitute} {Заменить}
    {Delete} {Удалить}
    {Don't change} {Не изменять}
    {Click a project} {Выберите проект}
    "Delete a project \"%n\" ?" "Удалить проект \"%n\" ?"
    "A project \"%n\" already exists." "Проект \"%n\" уже существует."
    "A project \"%n\" doesn't exists. Hit \[+\] button to create it." "Проект \"%n\" не существует. Чтобы создать, кликните \[+\]."
    "All modified files (%n) will be saved.\n\nDo you agree?" "Все измененные файлы (%n) будут сохранены.\n\nСогласны?"
    "All selected files (%n) will remain open\nin the project you are switching to.\n\nDo you agree?" "Все выделенные файлы (%n) останутся открытыми\nи в выбранном вами проекте.\n\nСогласны?"
    "Directory \"%d\"\ndoesn't exist.\n\nCreate it?" "Каталог \"%d\"\nне существует.\n\nСоздать его?"
    {Checking %d. Wait a little...} {Проверка %d. Ожидайте...}
    {Too big directory for a project: %n files or more.} {Слишком велик каталог проекта: %n файлов или более.}
    {Options for new projects are set in "Preferences/General/Projects"} {Опции для новых проектов берутся из "Опции/Общее/Проекты"}
    {Date} {Дата}
    {Reminder} {Напоминание}
    {Erase a text} {Стереть текст}
    {Paste a text} {Вставить текст}
    {Undo changes} {Отменить изменения}
    {Redo changes} {Переотменить изменения}
    {Undo} {Отменить изменения}
    {Redo} {Переотменить изменения}
    {Text of a reminder} {Текст напоминания}
    {TODO reminders for the past: %d.} {TODO напоминания прошлого: %d.}
    {No selected files} {Нет выделенных файлов}
    {Open file:} {Открыт файл:}
    {Open files: %n} {Открыто файлов: %n}
    {TODO previous day} {TODO на день раньше}
    {TODO previous week} {TODO на неделю раньше}
    {TODO next day} {TODO на день позже}
    {TODO next week} {TODO на неделю позже}
    on на
    {Incorrect name: "%n"} {Некорректное имя: "%n"}
    {The project template is empty!} {Шаблон проекта пуст!}
    {Incorrect indentation in Project template: %n} {Некорректний отступ в шаблоне проекта: %n}
    "Enter a tree of directories for the project template.\nIndent them by equal indents to mean subdirectories.\n\nFiles like README*, CHANGELOG* will be created blank.\nFiles like LICENSE* will be taken from the current project." "Укажите дерево каталогов для шаблона проекта.\nДелайте одинаковые отступы для указания подкаталогов.\n\nФайлы типа README*, CHANGELOG* будут создаваться пустыми.\nФайлы типа LICENSE* будут браться из текущего проекта."
    {Create a project by template} {Создать проект по шаблону}
    {Project directory} {Директория проекта}
    {Command} {Команда}
    {Commands} {Команды}
    {For project} {Для проекта}
    {%n commands will be executed!} {Будут выполнены %n команд!}
    {Maximum commands reached: %n, current: %i (see Project/Options)} {Достигнут максимум команд: %n, сейчас: %i (см. Проекты/Опции)}
    {Maximum Run commands} {Максимум команд "Запуск"}
    {The project directory already exists! It isn't created with templates.} {Директория проекта уже сушествует! Он не создается по шаблону.}
    {All files filter:} {Фильтр всех файлов:}
    {TODO days ahead:} {TODO дней впереди:}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset ru {
    {Current list of favorites} {Текущий список Избранного}
    {New list of favorites:} {Новый список Избранного:}
    {Add a list of favorites} {Добавить список Избранного}
    {Change a list of favorites} {Изменить список Избранного}
    {Delete a list of favorites} {Удалить список Избранного}
    {Click a list of favorites} {Выберите какой-нибудь список}
    {The list #%n added} {Список #%n добавлен}
    {The list #%n updated} {Список #%n изменен}
    {The list #%n removed} {Список #%n удален}
    {Enter a name of the list} {Введите название списка}
    {Favorites of the current list} {Избранное текущего списка}
    {The current list is empty!} {Текущий список пуст!}
    {This list already exists} {Этот список уже существует}
    "This list not saved to\n\"%f\"." "Этот список не сохранен в\n\"%f\"."
    {Non-favorite files to be:} {Файлы не Избранного должны:}
    {kept} {остаться}
    {closed} {закрыться}
    "Doesn't close any tab without favorites\nat choosing Favorites' list" "Не закрывать \"неизбранные\" закладки\nпри выборе списка Избранного"
    "Closes all tabs without favorites\nat choosing Favorites' list" "Закрывать \"неизбранные\" закладки\nпри выборе списка Избранного"
    "Sets a list of Favorites\nthat was active initially." "Восстанавливает список Избранного,\nдействовавший вначале."
    {Delete a favorites' list #%n ?} {Удалить список Избранного #%n ?}
    {Favorites} {Избранное}
    {Favorites Lists...} {Списки Избранного...}
    "Add \"%n\" of %f\nto Favorites?" "Добавить \"%n\" файла %f\nв Избранное?"
    "Item \"%n\" of %f\nis already in Favorites." "Юнит \"%n\" из %f\nуже есть в Избранном."
    "Remove \"%n\" of %f\nfrom Favorites?" "Удалить \"%n\" файла %f\nиз Избранного?"
    "\"%n\" unit of %f is not in the list." "Юнита \"%n\" файла %f нет в списке."
    {Add to Favorites} {Добавить в Избранное}
    {Rename} {Переименовать}
    {Favorite name:} {Название избранного:}
    {Delete} {Удалить}
    {Delete All} {Удалить всё}
    {Delete all of Favorites?} {Удалить всё из Избранного?}
    {Delete all of the last visited?} {Удалить всё из Последних входов?}
    {Favorites / Last Visited} {Избранное / Последние входы}
    {Opens files with current favorites.} {Открыть файлы с текущим Избранным.}
    {Number of files to open: %n} {Число открываемых файлов: %n}
    "Add .tcl files of current session\nas the favorites" "Добавить .tcl файлы текущего сеанса\nкак список Избранного"
    {No .tcl files found in the session} {Файлов .tcl в сессии не найдено}
    "\n Save as favorites list: selected (%s) or all (%a) files?\n" "\n Сохранить как список Избранного: выделенные (%s) либо все (%a) файлы?\n"
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset ru {
    "Create a file\nCtrl+N" "Создать файл\nCtrl+N"
    "Open a file\nCtrl+O" "Открыть файл\nCtrl+O"
    {Save the file} {Сохранить файл}
    "Save all files\nCtrl+Shift+S" "Сохранить все файлы\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Контекстная справка по Tcl/Tk\nF1"
    {Find / Replace} {Поиск / Замена}
    "Find / Replace\nCtrl+F" "Поиск / Замена\nCtrl+F"
    {Run the file} {Выполнить файл}
    {Run e_menu} {Вызов e_menu}
    "Undo changes\nCtrl+Z" "Отмена изменений\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Переотмена изменений\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset ru {
    {Find: } {Искать: }
    {Replace: } {Заменить: }
    {Match: } {Совпадение: }
    {Exact} {Точное}
    {Match whole word} {Только целые слова}
    {Match case} {Учет регистра букв}
    {Wrap} {По кругу}
    {Replace by blank} {Пустые замены}
    {Down} {Вниз}
    {Up} {Вверх}
    {Stay on top} {Поверх всех окон}
    {Stay on top:} {Поверх всех окон:}
    {Find} {Поиск}
    {Replace} {Замена}
    {All in text} {Все в тексте}
    {All in session} {Все в сеансе}
    {All in %n Files} {Все в %n файлах}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Позволяет использовать *, ?, \[, \]\nв строке поиска."
    "Allows to use the regular expressions\nin \"find\" string." "Позволяет использовать регулярные выражения\nв строке поиска."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Разрешает пустые замены,\nт.е. просто удаление строк поиска."
    "Keeps the dialogue above other windows." "Отображает диалог поиска\nповерх других окон."
    "Found %n matches for \"%s\"." "Найдено %n искомых \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "Сделано %n замен \"%s\" на \"%r\" в \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "Сделано %n замен \"%s\" на \"%r\" во всём сеансе."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "Заменить все \"%s\"\n\nна \"%r\"\n\nв \"%f\" ?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all%Stexts?" "Заменить все \"%s\"\n\nна \"%r\"\n\nво всех%Sтекстах?"
    {Don't focus a text after selecting in infobar} {Не переходить на текст при выборе в инфобаре}
    {Focus a text after selecting in infobar} {Переходить на текст при выборе в инфобаре}
    {Find by List} {Искать по списку}
    {List:} {Список:}
    { Enter a list of words divided by spaces:} { Введите список слов, разделенных пробелами:}
    {FOUND:} {НАЙДЕНЫ:}
    {NOT FOUND:} {НЕ НАЙДЕНЫ:}
    "Use this geometry of the dialogue\nby default" "Использовать эту геометрию диалога\nпо умолчанию"
    "Paste 'Find'\nCtrl+R" "Вставить искомое\nCtrl+R"
    {Not found: %s} {Не найдено: %s}
    {Resize} {Изменить размер}
    {Including RE2:} {Включающие RE2:}
    {Excluding RE2:} {Исключающие RE2:}
    "Including / excluding\nregular expressions." {Включающие / исключающие RE.}
  }

  ## ________________________ Start and update ________________________ ##
  ::msgcat::mcmset ru {
    {Choosing Directory for Settings} {Выбор каталога для настроек}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n" "\n Программе \"alited\" нужно указать каталог для сохранения своих настроек.\n Вы можете задавать его как аргумент при вызове alited.\n\n По умолчанию, каталог сохранения настроек - \"%d\".\n Это рекомендуемый каталог, позволяющий вызывать \"alited\" без аргументов.\n"
    {Choose a directory} {Выбор каталога}
    {Some things have been changed in alited %v.} {Кое-что изменилось в alited %v.}
    {Updating alited} {Обновление alited}
    " You are highly recommended to accept\n these changes in order to complete updating:" " Настоятельно рекомендуется принять\n эти изменения для завершения обновления:"
    {.em files for "Tools"} {.em файлы для "Снастей"}
    {.ini file for "Templates"} {.ini файл для "Шаблонов"}
    { Your previous files will be saved to:} { Ваши файлы сохранятся в:}
    {View Changes} {Просмотр изменений}
  }

  ## ________________________ "About" dialogue ________________________ ##
  ::msgcat::mcmset ru {
    {Written in pure Tcl/Tk.} {Сделан на чистом Tcl/Tk.}
    {And well fit for programming with it.} {И годен для программирования на нём.}
    {Details:} {Подробности:}
    {Authors:} {Авторы:}
    {License:} {Лицензия:}
    {Acknowledgements} {Благодарности}
    "Many thanks to the following people \
    \n who have contributed to this project \
    \n with their participation, advice and code"
    "Огромное спасибо всем этим людям, \
    \n внесшим свой вклад в этот проект \
    \n своими советами, соучастием и кодом"
    {Special thanks also to} {Особая благодарность также}
    {Packages} {Пакеты}
    {Packages used by <red>alited %ver</red>:} {Пакеты, использованные в <red>alited %ver</red>:}
  }

  ## ________________________ Preferences ________________________ ##
  ::msgcat::mcmset ru {
    {General} {Общее}
    {Editor} {Редактор}
    {Units} {Юниты}
    {Keys} {Клавиши}
    {Misc.} {Разное}
    {Saving} {Сохранение}
    {View} {Вид}
  }

  ### ________________________ General _________________________ ###
  ::msgcat::mcmset ru {
    {Ttk theme:} {Тема Ttk:}
    {Color scheme:} {Цветовая схема:}
    {Windows themes} {Темы Windows}
    {Darker:} {Темнее:}
    {Lighter:} {Светлее:}
    {Tint} {Оттенок}
    {Tint:} {Оттенок:}
    "For the settings to be active,\nalited application should be restarted." "Чтобы изменения вступили в силу,\nпрограмму alited надо перезапустить."
    {Preferable locale:} {Предпочтительная локаль:}
    "This is a language code: ru, uk, de...\nIn alited, \"en\" means American English." "Это код языка: ru, uk, de...\nВ alited \"en\" значит American English."
    {Small font size:} {Размер малого шрифта:}
    {Middle font size:} {Размер среднего шрифта:}
    {Cursor width:} {Ширина курсора:}
    {Color of cursor:} {Цвет курсора:}
    {Notes:} {Заметки:}
    "Sort of diary.\nList of TODOs etc." "Типа дневника.\nСписок TODO и пр."
    {Light / Dark} {Светлые / Темные}
    {Makes colors darker .. lighter} {Делает цвета темнее .. светлее}
    "These themes need\nlight / dark color schemes\naccordingly" "Этим темам нужны\nсветлые / темные цветовые схемы\nсоответственно"
    {Fit for theme} {Годится для темы}
    {No color scheme at all} {Никакой цветовой схемы вовсе}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset ru {
    {Font:} {Шрифт:}
    {Gutter's width:} {Ширина желобка}
    {Gutter's shift from text:} {Смещение желобка от текста:}
    {Space above lines:} {Отступ выше строк:}
    {Space below lines:} {Отступ ниже строк:}
    {Space between wraps:} {Отступ сворачиваемых строк:}
    {Tab bar label's length:} {Длина имен панели файлов:}
    {Tab bar tip's length:} {Длина подсказок панели файлов:}
    {Border for bar tabs:} {Кайма для панели файлов:}
    {Code snippet:} {Фрагмент кода:}
    {Blinking cursor:} {Мигание курсора:}
    {Translation} {Перевод}
    {Translation link:} {Сайт переводов:}
    {Adding translations:} {Добавление переводов:}
    {If OFF, replaces the original text.} {Если выключено, заменяет исходный текст.}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset ru {
    {Save before bar-menu runs:} {Сохранять при вызовах bar-menu:}
    {All files} {Все файлы}
    {Current} {Текущий}
    {None} {Ничего}
    {'Recent Files' length:} {Длина списка 'Недавние файлы':}
    {'Last Visited' length:} {Длина списка 'Последние входы':}
    {Maximum of project files:} {Число файлов проекта не более:}
    {Confirm exit:} {Подтверждать выход:}
    {Save configuration on} {Сохранять конфигурацию при}
    {opening a file:} {открытии файла:}
    {closing a file:} {закрытии файла:}
    {saving a file:} {сохранении файла:}
    {Back up files to a project's subdirectory:} {Резервные копии в каталоге проекта:}
    "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." "Подкаталог проекта, где сохранятся копии файлов.\nЕсли это поле пустое, копирования не будет."
    {  Maximum:} {  Максимум:}
    {Maximum of backup copies per a file} {Максимальное число копий файла}
    {Bell at warnings:} {Звук предупреждений:}
    {Port to listen alited:} {Порт слежения за alited:}
    "The empty value allows\nmultiple alited apps." "Пустая опция позволяет\nзапускать несколько alited."
  }

  ### ________________________ Keys _________________________ ###
  ::msgcat::mcmset ru {
    {Save File} {Сохранить файл}
    {Save File as} {Сохранить файл как}
    {Run e_menu} {Запуск e_menu}
    {Run File} {Запуск файла}
    {Double Selection} {Дублировать выделение}
    {Delete Line} {Удалить строку}
    {Highlight First} {Выделить первое}
    {Highlight Last} {Выделить последнее}
    {Find Next Match} {Найти следующее}
    {Item up} {Поднять элемент}
    {Item down} {Опустить элемент}
    {Complete Commands} {Дополнение команд}
  }

  ### ________________________ Templates tab _________________________ ###
  ::msgcat::mcmset ru {
    {Enter %U, %u, %m, %w, %d, %t wildcards of templates:} {Введите токены  %U, %u, %m, %w, %d, %t для шаблонов:}
    {User name:} {Имя пользователя:}
    {Login:} {Логин:}
    {Date format:} {Формат даты:}
    {Time format:} {Формат времени:}
  }

  ### ________________________ Syntax _________________________ ###
  ::msgcat::mcmset ru {
    {Tcl syntax} {Синтаксис Tcl}
    {C/C++ syntax} {Синтаксис C/C++}
    {Plain text} {Просто текст}
    {Tcl files' extensions:} {Расширения файлов Tcl:}
    {C/C++ files' extensions:} {Расширения файлов C/C++:}
    {Plain texts' extensions:} {Расширения текстовых файлов:}
    {Color of Tcl commands:} {Цвет команд Tcl:}
    {Color of Tk commands:} {Цвет команд Tk:}
    {Color of strings:} {Цвет значений строк:}
    {Color of variables:} {Цвет значений переменных:}
    {Color of comments:} {Цвет комментариев:}
    {Color of proc/methods:} {Цвет процедур/методов:}
    {Color of options:} {Цвет опций:}
    {Color of brackets:} {Цвет скобок:}
    {Color of C key words:} {Цвет ключевых слов C:}
    {Color of C++ key words:} {Цвет ключевых слов C++:}
    {Color of punctuation:} {Цвет знаков препинания:}
    {Color of return/goto:} {Цвет return/goto:}
    {Color of your key words:} {Цвет ваших ключевых слов:}
    {Colors} {Цвета}
    {Your commands:} {Ваши команды:}
    {Your key words:} {Ваши ключевые слова:}
  }

  ### ________________________ Units _________________________ ###
  ::msgcat::mcmset ru {
    {Branch's regexp:} {RE для ветки:}
    {Proc's regexp:} {RE для функции:}
    {Check branch's regexp:} {Проверка на ветку:}
    {Check proc's regexp:} {Проверка на функцию:}
    {Use leaf's regexp:} {Использовать RE листа:}
    {Leaf's regexp:} {RE листа:}
    {Unaffected top lines:} {Статичных начальных строк:}
    {For leaf units only!} {Только для юнитов листьев!}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset ru {
    {Open bar-menu settings} {Открыть настройки bar-menu}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Иконка включит запуск в тулбар.\nПустая или 'none' иконка исключит запуск из тулбара."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "Вызов команды для меню и/или тулбара.\nВыберите ее из команд e_menu."
    {Directory of menus:} {Каталог меню:}
    {Main menu:} {Главное меню:}
    {Projects (%PD wildcard):} {Проекты (%PD токен):}
    {Linux terminal:} {Терминал Linux:}
    {Diff tool:} {Команда diff:}
    {Path to man/tcl:} {Путь к man/tcl:}
    {tclsh, wish or tclkit:} {tclsh, wish или tclkit:}
    {Geometry:} {Геометрия:}
    {Run as external app:} {Как отдельное приложение:}
    {Delete an item} {Удалить элемент}
    {Moves an item up} {Поднять элемент}
    {Moves an item down} {Опустить элемент}
    {separator} {разделитель}
    {If 'yes', means a separator of the toolbar/menu.} {Если включено, означает разделитель в тулбаре/меню.}
    {For Start...} {Для старта...}
    " Enter commands to be run after starting alited.\n They can be Tcl or executables:" " Введите команды, выполняемые после старта alited,\n т.е. команды Tcl или внешние команды:"
    {By command:} {Командой:}
    {By #RUNF: / #EXEC:} {По #RUNF: / #EXEC:}
    {Run:} {Запуск:}
    {Run it} {Пуск}
    { OS or Tcl commands to be run before running a current file:} { Команды OS или Tcl, выполняемые перед запуском текущего файла:}
    { Also, you can set "forced command" to be run by "Run" tool:} { Также вы можете ввести "принудительную команду" для Запуска:}
    {Forcedly:} {Принудительно:}
    {e_menu's own} {своя в e_menu}
    {Select any of run item} {Выберите какую-нибудь команду}
    "Incorrect \"Preferences/Tools/tclsh...\"\nresults in the error:" "Некорректная настройка \"Настройки/Снасти/tclsh...\"\nприводит к ошибке:"
    {Set a Linux terminal in Preferences/Tools} {Установите терминал Linux в "Настройки/Снасти"}
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset ru {
    {Check Tcl} {Проверка Tcl}
    {Check Tcl...} {Проверка Tcl...}
    {Check} {Проверка}
    {Check:} {Проверить:}
    {Checks available:} {Возможные проверки:}
    {Consistency of {} } {Соответствие {}}
    {Consistency of []} {Соответствие []}
    {Consistency of ()} {Соответствие ()}
    {Consistency of ""} {Соответствие ""}
    {all of session files} {все файлы сеанса}
    {current file} {текущий файл}
    {Found %f file error(s), %u unit error(s).} {Найдено ошибок: %f файлов, %u юнитов.}
    {No errors found.} {Ошибок не найдено.}
    {Errors found in unit:} {Найдены ошибки в юните:}
    {Duplicate units} {Дубликатные юниты}
    {duplicate unit:} {дубликатный юнит:}
  }

  ## ________________________ Macros ________________________ ##
  ::msgcat::mcmset ru {
    "The macro is updated at its recording.\nPress %s to play it." "Макрос обновится по его записи.\nНажмите %s для его прокрутки."
    {Playing:} {Прокрутка:}
    {Recording:} {Запись:}
    {Play Macro} {Прокрутить макрос}
    {Record Macro} {Записать макрос}
    {Delete Macro} {Удалить макрос}
    {Record mouse} {Записать мышь}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset ru {
    "\"%f\" removed to \"%d\"" "\"%f\" удален в \"%d\""
    {File name:} {Имя файла:}
    {Directory} {Каталог}
    "The file \"%f\" seems to be not of types\n%s.\n\nStill do you want to open it?" "Файл \"%f\", похоже, не типа\n%s.\n\nВсё-таки открыть его?"
  }

  ## ________________________ Find units ________________________ ##
  ::msgcat::mcmset ru {
    {Find Unit} {Искать юнит}
    {in all} {во всех}
    {in current} {в текущем}
    "Use glob patterns to find units' declarations\ne.g. \"s*rt\" would find \"start\" and \"insert\".\nThe letter case is ignored." "Используйте шаблон glob для поиска юнитов:\nнапример, \"s*rt\" найдет \"start\" и \"insert\".\nРегистр букв не учитывается."
    {Incorrect name for a unit.} {Некорректное имя для юнита.}
  }

  ## ________________________ Abbreviations etc. ________________________ ##
  #   Line - 2nd column's title of unit tree
  ::msgcat::mcmset ru {
    {Row} {Стр.}
    {Row } {Стр }
    { Col } { Поз }
    {    Unit: } {   Юнит: }
  }

  ## ________________________ Bar of tabs ________________________ ##
  ::msgcat::mcmset ru {
    {(Un)Select} {Выделить / нет}
    {... Visible} {... видимые}
    {... All at Left} {... все слева}
    {... All at Right} {... все справа}
    {... All} {... все}
    {File List} {Список файлов}
    {Sort} {Сортировать}
    {Sort files} {Сортировать файлы}
    {Sorted} {Сортированный}
    {... by date} {... по дате}
    {... by size} {... по размеру}
    {... by extension} {... по расширению}
    {increasing} {возрастая}
    {decreasing} {убывая}
    {Files to Beginning} {Файлы в начало}
    "If it's checked, open files would be placed\nonto the beginning page of the bar." "Если эта опция включена, открываемые файлы\nразмещаются на первой странице списка."
  }

  ## ________________________ Paver _________________________ ##

  ::msgcat::mcmset ru {
    {For paveWindow's widget list to be recognized, set the cursor inside it.} {Поставьте курсор внутри списка виджетов paveWindow, чтоб список был опознан.}
    {Auto Update} {Обновлять автоматически}
    {Widget List} {Список виджетов}
  }

  ## ____________________ Rectangular selection ___________________ ##

  ::msgcat::mcmset ru {
    {Rectangular Selection} {Прямоугольное выделение}
    {Start} {Начать}
    {Cut} {Вырезать}
    {Copy} {Копировать}
    {Paste} {Вставить}
    {Move the cursor to select a rectangle.} {Переместите курсор для выделения прямоугольника.}
  }

  ## ________________________ Formats _________________________ ##

  ::msgcat::mcmset ru {
    {Formats} {Форматы}
    {Moving Unit Descriptions} {Перенос описаний юнитов}
    {Moving Unit Descriptions...} {Перенос описаний юнитов...}
    {Move Unit Descriptions} {Перенести описания юнитов}
    {Selected} {Выделенные}
    {Move proc/method descriptions:} {Перенести описания proc/method:}
    {From inside to out} {Внутренние наружу}
    {From out to inside} {Наружные внутрь}
    {Separator:} {Разделитель:}
    {Process .tcl file(s):} {Обработать .tcl файл(ы):}
    " Current leaf's RE\n\n   <r>%r1</r>\n\n is not equal to standard\n\n   <r>%r2</r>\n\n as set in Projects/Options and Preferences/Units."
    " Текущее RE юнита\n\n   <r>%r1</r>\n\n не равно стандартному\n\n   <r>%r2</r>\n\n согласно настройкам\n Проекты/Опции и Настройки/Опции."
    "The separator doesn't match to the regexp:\n\n  "
    "Разделитель не соответствует регулярному выражению:\n\n  "
    {Separator must contain "n" or "N" for unit name!}
    {Разделитель должен содержать "n" или "N" для имени юнита!}
    {The separator should be Tcl comment!} {Разделитель должен быть комментарием Tcl!}
    {Were all files properly backed up?} {Все ли файлы архивированы?}
    "PROJECT OPTION \"Use leaf's regexp\" SWITCHED TEMPORARILY TO "
    "ОПЦИЯ ПРОЕКТА \"Использовать RE листа\" временно переключена в "
    {Files processed successfully: %n} {Успешно обработано файлов: %n}
    {%f processed, units affected: %n} {%f обработан, затронуто юнитов: %n}
    {%f processed, units affected: %n - ALREADY PROCESSED?}
    {%f обработан, затронуто юнитов: %n - УЖЕ ОБРАБОТАН?}
    {ERROR} {ОШИБКА}
    {Strings} {Строки}
    {Keyboard} {Клавиатура}
    {Sorting lines} {Сортировка строк}
    {Misc} {Разное}
    {External} {Внешний}
    {Pluginable} {Подключаемый}
    {Applied to one selection only!} {Разрешено только одно выделение!}
    "Incorrect mapped 'from-to' in: %l" "Некорректное отображение 'с-на' в: %l"
    "'from' refers to previous 'to' in: %l (see: %n)" "'с' ссылается на предыдущее 'на' в: %l (см.: %n)"
    {Use %e to run "%m"} {Пользуйтесь %e для запуска "%m"}
    {%e is overlapped by formatter "%f"} {%e перекрывается форматером "%f"}
  }

  ## ________________________ Project printer _________________________ ##

  ::msgcat::mcmset ru {
    {Project Printer} {Печатник проекта}
    {Project Printer...} {Печатник проекта...}
    {Output directory:} {Каталог назначения:}
    {Markdown processor:} {Обработчик markdown:}
    {Directory title colors} {Цвета заголовка каталога}
    {Foreground:} {Текст:}
    {Background:} {Фон:}
    {File title colors} {Цвета заголовка файла}
    {Syntax colors:} {Цвета синтаксиса:}
    {Width of contents:} {Ширина содержимого:}
    {Final processor:} {Окончательный обработчик:}
    {Output directory cannot be cleared: alien files} {Невозможно очистить каталог назначения: чужие файлы}
    {Output directory cannot be cleared: alien %n} {Невозможно очистить каталог назначения: чужие %n}
    {Output directory cannot be cleared: alien directories} {Невозможно очистить каталог назначения: чужие каталоги}
    "The output directory\n  %n\ncontains %c subdirectories.\n\nAll will be replaced with the new!" "Каталог назначения\n  %n\nсодержит %c подкаталогов.\n\nВсе они будут замещены новыми!"
    {Sort units:} {Сортировать юниты:}
    {Runs the final processor.} {Запуск окончательного обработчика.}
  }

  ## ________________________ EONS alited _________________________ ##
}

# _ apave NS _ #

namespace eval ::apave {
  ::msgcat::mcmset ru {
    {Save text} {Сохранить текст}
    {Don't save} {Не сохранять}
    {Save changes made to the text?} {Сохранить измененный текст?}
  }
}

# _ bartabs NS _ #

namespace eval ::bartabs {

  ## ________________________ Popup menu _________________________ ##

  ::msgcat::mcmset ru {
    {List} {Список}
    {behind} {следом за}
    {Close} {Закрыть}
    {... All} {... все}
    {... All at Left} {... все слева}
    {... All at Right} {... все справа}
  }
}

# _________________________________ EOF _________________________________ #
