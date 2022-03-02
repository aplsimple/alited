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
    {Conversions} {Преобразования}
    {Change Encoding...} {Сменить кодировку...}
    {Change EOL...} {Сменить EOL...}
    {Tools} {Снасти}
    {Setup} {Опции}
    {Help} {Помощь}
    {Yes} {Да}
    {No} {Нет}
    {Cancel} {Отмена}
    {Close} {Закрыть}
    {New} {Новый}
    {Open...} {Открыть...}
    {Recent Files} {Недавние файлы}
    {Save} {Сохранить}
    {Save as...} {Сохранить как...}
    {Save All} {Сохранить все}
    {... All} {... все}
    {... All at Left} {... все слева}
    {... All at Right} {... все справа}
    {Preferences} {Настройки}
    {Preferences...} {Настройки...}
    {Restart} {Перезапуск}
    {Quit} {Выход}
    {Put New Line} {Добавить строку}
    {Indent} {Добавить отступ}
    {Unindent} {Убрать отступ}
    {Comment} {Закомментить}
    {Uncomment} {Раскомментить}
    {Find Next} {Искать дальше}
    {Look for Declaration} {Искать объявление}
    {Look for Word} {Искать слово}
    {Run} {Запуск}
    {Moving} {Перемещение}
    {Help of alited} {Помощь alited}
    {Color Picker} {Выбор цвета}
    {Date Picker} {Выбор даты}
    {Screen Loupe} {Экранная лупа}
    {Quit alited?} {Выйти из alited?}
    {Wait a little ...} {Подождите ...}
    {Default} {По умолчанию}
    {Default 2} {По умолчанию 2}
    {Default 3} {По умолчанию 3}
    {Default 4} {По умолчанию 4}
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
    {Lists of Favorites} {Списки Избранного}
    {Last Visited} {Последние входы}
    {Switch to Unit Tree} {Перейти на список юнитов}
    {Switch to File Tree} {Перейти на список файлов}
    {Create File} {Создать файл}
    "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)." "Введите имя файла, создаваемого в:\n%d\n\nЕсли это каталог, включите опцию 'Каталог'.\nКаталог может включать подкаталоги (a/b/c)."
    {Delete File} {Удалить файл}
    "File %f already exists in\n%d" "Файл %f уже существует в\n%d"
    {Remove Unit(s)} {Удалить юнит(ы)}
    {No item selected.} {Запись не выбрана.}
    {Update Tree} {Обновить список}
    {Contract All} {Свернуть всё}
    {Expand All} {Развернуть всё}
    "Move %f\nto\n%d\n?" "Переместить %f\nв\n%d\n?"
    {To Last Visited} {На последний вход}
    {To Matched Bracket} {На парную скобку}
    {Go to Line} {Перейти на строку}
    {Line number:} {Номер строки:}
    {    In unit:} {     В юните:}
    "\"%n\" contains unbalanced \{\}: %1!=%2" "\"%n\" имеет несогласованные \{\}: %1!=%2"
    {Back} {Откат}
    {File not found: %f} {Файл не найден: %f}
    {Unit not found: %u} {Юнит не найден: %u}
    {Don't show anymore} {Больше не показывать}
    {%f is a directory} {%f - это каталог}
    {THE EXTERNAL FILE IS MOVED TO THE PROJECT!} {ВНЕШНИЙ ФАЙЛ ПЕРЕМЕЩАЕТСЯ В ПРОЕКТ!}
    {Drop Selected Units Here} {Кинуть сюда выбранные юниты}
    {Drop Selected Files Here} {Кинуть сюда выбранные файлы}
    "All Tcl files of this directory:\n  \"%f\"  \nwill be open.\n\nThis may be expensive!" "Все Tcl файлы каталога:\n  \"%f\"  \nбудут открыты.\n\nЭта операция может быть затратной!"
    {Select All} {Выделить все}
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
    {An open file can not be deleted.} {Невозможно удалить открытый файл.}
    "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?" "Файл \"%f\" был изменен другим приложением.\n\nОтменить вашу редакцию и перезагрузить файл?"
    "File \"%f\" was deleted by some application.\n\nSave the file?" "Файл \"%f\" был удален другим приложением.\n\nСохранить файл?"
    {Tip File Info} {Данные о файлах}
    {Rename File} {Переименовать файл}
    {Select one file in the tree.} {Выберите один файл в списке.}
    {Open Selected File(s)} {Открыть выделенные файл(ы)}
    {Close Selected File(s)} {Закрыть выделенные файл(ы)}
  }

  ## ________________________ Templates ________________________ ##
  ::msgcat::mcmset ru {
    {Template} {Шаблон}
    {Templates} {Шаблоны}
    {List of Templates} {Список шаблонов}
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
  }

  ## ________________________ Projects ________________________ ##
  ::msgcat::mcmset ru {
    {Projects} {Проекты}
    {You are going to %n!} {Вы собираетесь %n!}
    {Add a project} {Добавить проект}
    {Change a project} {Изменить проект}
    {Delete a project} {Удалить проект}
    {Don't delete the current project!} {Не удаляйте текущий проект!}
    "The project \"%n\" added" "Проект \"%n\" добавлен"
    "The project \"%n\" updated" "Проект \"%n\" изменен"
    "The project \"%n\" removed" "Проект \"%n\" удален"
    {Options} {Опции}
    {Project name:} {Название проекта:}
    {Root directory:} {Корневой каталог:}
    {Skip subdirectories:} {Пропускать подкаталоги:}
    {Description:} {Описание:}
    {Indentation:} {Пробелов отступа:}
    {Auto detection} {Автоопределение}
    {End of line:} {Концы строк:}
    {Multi-line strings:} {Многострочные string:}
    {Unit lines per 1 red bar:} {Строк юнита на 1 красную полосу:}
    {List of files:} {Список файлов:}
    "You can\n  - add the current one to\n  - substitute with the current one\n  - delete\n  - not change\nthe file list of the project.\n" "Вы можете\n  - добавить текущий список файлов в\n  - заменить текущим списком\n  - удалить\n  - не изменять\nсписок файлов в проекте.\n"
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
    {Text of a reminder} {Текст напоминания}
    {TODO reminders for the past: %d. Delete them or try "Select".} {TODO напоминания прошлого: %d. Удалите их или попробуйте "Выбор".}
    "You may select file(s)\nand open them with a context menu.\n\nOr just double-click." "Вы можете выделить файл(ы)\nи через контекстное меню открыть их.\n\nИли откройте двойным кликом."
    {No selected files} {Нет выделенных файлов}
    {Open file:} {Открыт файл:}
    {Open files: %n} {Открываемых файлов: %n}
  }

  ## ________________________ Favorites ________________________ ##
  ::msgcat::mcmset ru {
    {Lists of favorites:} {Списки Избранного}
    {Current list of favorites:} {Текущий список Избранного}
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
    "Add \"%n\" of %f\nto Favorites?" "Добавить \"%n\" файла %f\nв Избранное?"
    "Item \"%n\" of %f\nis already in Favorites." "Юнит \"%n\" из %f\nуже есть в Избранном."
    "Remove \"%n\" of %f\nfrom Favorites?" "Удалить \"%n\" файла %f\nиз Избранного?"
    "\"%n\" unit of %f is not in the list." "Юнита \"%n\" файла %f нет в списке."
    {Add to Favorites} {Добавить в Избранное}
    {Remove} {Удалить}
    {Remove All} {Удалить всё}
    {Remove all of Favorites?} {Удалить всё из Избранного?}
    {Remove all of the last visited?} {Удалить всё из Последних входов?}
  }

  ## ________________________ Icons of toolbar: tips ________________________ ##
  ::msgcat::mcmset ru {
    "Create a file\nCtrl+N" "Создать файл\nCtrl+N"
    "Open a file\nCtrl+O" "Открыть файл\nCtrl+O"
    "Save the file\nF2" "Сохранить файл\nF2"
    "Save all files\nCtrl+Shift+S" "Сохранить все файлы\nCtrl+Shift+S"
    "Tcl/Tk help on the selection\nF1" "Контекстная справка по Tcl/Tk\nF1"
    {Find / Replace} {Поиск / Замена}
    "Find / Replace\nCtrl+F" "Поиск / Замена\nCtrl+F"
    "Run the file\nF5" "Выполнить файл\nF5"
    "Run e_menu\nF4" "Вызов e_menu\nF4"
    "Undo changes\nCtrl+Z" "Отмена изменений\nCtrl+Z"
    "Redo changes\nCtrl+Shift+Z" "Переотмена изменений\nCtrl+Shift+Z"
  }

  ## ________________________ Find-replace dialogue ________________________ ##
  ::msgcat::mcmset ru {
    {Find: } {Искать: }
    {Replace: } {Заменить: }
    {Match: } {Совпадение: }
    {Exact} {Точное}
    {Match whole word only} {Только целые слова}
    {Match case} {Учет регистра букв}
    {Wrap around} {По кругу}
    {Replace by blank} {Пустые замены}
    {Direction:} {Направление:}
    {Down} {Вниз}
    {Up} {Вверх}
    {Stay on top} {Поверх всех окон}
    {Stay on top:} {Поверх всех окон:}
    {Find} {Поиск}
    {Replace} {Замена}
    {All in Text} {Все в тексте}
    {All in Session} {Все в сеансе}
    {All in %n Files} {Все в %n файлах}
    "Allows to use *, ?, \[ and \]\nin \"find\" string." "Позволяет использовать *, ?, \[, \]\nв строке поиска."
    "Allows to use the regular expressions\nin \"find\" string." "Позволяет использовать регулярные выражения\nв строке поиска."
    "Allows replacements by the empty string,\nin fact, to erase the found ones." "Разрешает пустые замены,\nт.е. просто удаление строк поиска."
    "Keeps the dialogue above other windows." "Отображает диалог поиска\nповерх других окон."
    "Found %n matches for \"%s\"." "Найдено %n искомых \"%s\"."
    "Made %n replacements of \"%s\" with \"%r\" in \"%f\"." "Сделано %n замен \"%s\" на \"%r\" в \"%f\"."
    "Made %n replacements of \"%s\" with \"%r\" in all of session." "Сделано %n замен \"%s\" на \"%r\" во всём сеансе."
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?" "Заменить все \"%s\"\n\nна \"%r\"\n\nв \"%f\" ?"
    "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all texts?" "Заменить все \"%s\"\n\nна \"%r\"\n\nво всех текстах?"
    {Don't focus a text after selecting in infobar} {Не переходить на текст при выборе в инфобаре}
    {Focus a text after selecting in infobar} {Переходить на текст при выборе в инфобаре}
    {Find by List} {Искать по списку}
    {List:} {Список:}
    {\n Enter a list of words divided by spaces: \n} {\n Введите список слов, разделенных пробелами: \n}
    {FOUND:} {НАЙДЕНЫ:}
    {NOT FOUND:} {НЕ НАЙДЕНЫ:}
  }

  ## ________________________ Checking ini directory ________________________ ##
  ::msgcat::mcmset ru {
    {Choosing Directory for Settings} {Выбор каталога для настроек}
    "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n" "\n Программе \"alited\" нужно указать каталог для сохранения своих настроек.\n Вы можете задавать его как аргумент при вызове alited.\n\n По умолчанию, каталог сохранения настроек - \"%d\".\n Это рекомендуемый каталог, позволяющий вызывать \"alited\" без аргументов.\n"
    {Choose a directory} {Выбор каталога}
  }

  ## ________________________ "About" dialogue ________________________ ##
  ::msgcat::mcmset ru {
    {stands for} {означает}
    {Written in pure Tcl/Tk.} {Сделан на чистом Tcl/Tk.}
    {And well fit for programming with it.} {И годен для программирования на нём.}
    {Details:} {Подробности:}
    {Authors:} {Авторы:}
    {License:} {Лицензия:}
    {Acknowledgements} {Благодарности}
    "Many thanks to the following people\n who have contributed to this project" "Огромное спасибо всем людям,\n внесшим свой вклад в этот проект"
    {Special thanks also to} {Особая благодарность также}
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
    {Darker:} {Темнее:}
    {Lighter:} {Светлее:}
    {Tint} {Оттенок}
    {Tint:} {Оттенок:}
    "For the settings to be active\nthe application should be restarted.\n\nRestart it just now?" "Чтобы изменения вступили в силу,\nприложение надо перезапустить.\n\nСделать это прямо сейчас?"
    {Preferable locale:} {Предпочтительная локаль:}
    "This is a country code: ru, uk, de...\nIn alited, \"en\" means American English." "Это код страны: ru, uk, de...\nВ alited \"en\" значит American English."
    {Small font size:} {Размер малого шрифта:}
    {Middle font size:} {Размер среднего шрифта:}
    {Cursor width:} {Ширина курсора:}
    {Notes:} {Заметки:}
    "Sort of diary.\nList of TODOs etc." "Типа дневника.\nСписок TODO и пр."
    {Light / Dark} {Светлая / Темная}
    {Makes colors darker .. lighter} {Делает цвета темнее .. светлее}
  }

  ### ________________________ Editor _________________________ ###
  ::msgcat::mcmset ru {
    {Font:} {Шрифт:}
    {Font size:} {Размер шрифта:}
    {Gutter's width:} {Ширина желобка}
    {Gutter's shift from text:} {Смещение желобка от текста:}
    {Space above lines:} {Отступ выше строк:}
    {Space below lines:} {Отступ ниже строк:}
    {Space between wraps:} {Отступ сворачиваемых строк:}
    {Tab bar label's length:} {Длина имен панели файлов:}
    {Tab bar tip's length:} {Длина подсказок панели файлов:}
    {Color scheme's light changed.} {Тон цветовой схемы изменен.}
    {Code snippet:} {Фрагмент кода:}
  }

  ### ________________________ Saving _________________________ ###
  ::msgcat::mcmset ru {
    {Save before bar/menu runs:} {Сохранять при вызовах bar/menu:}
    {Current file} {Текущий файл}
    {All files} {Все файлы}
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

  ### ________________________ Templates _________________________ ###
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
    {Untouched top lines:} {Статичных начальных строк:}
  }

  ### ________________________ Tools _________________________ ###
  ::msgcat::mcmset ru {
    {Open bar/menu settings} {Открыть настройки bar/menu}
    "An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar." "Иконка включит запуск в тулбар.\nПустая или 'none' иконка исключит запуск из тулбара."
    "The run item for the menu and/or the toolbar.\nSelect it from the e_menu items." "Вызов команды для меню и/или тулбара.\nВыберите ее из команд e_menu."
    {Directory of menus:} {Каталог меню:}
    {Main menu:} {Главное меню:}
    {Projects (%PD wildcard):} {Проекты (%PD токен):}
    {Linux terminal:} {Терминал Linux:}
    {Diff tool:} {Команда diff:}
    {Path to man/tcl8.6:} {Путь к man/tcl8.6:}
    {tclsh, wish or tclkit:} {tclsh, wish или tclkit:}
    {Rows:} {Строк:}
    {Columns:} {Колонок:}
    {Geometry:} {Геометрия:}
    {Run as external app:} {Как отдельное приложение:}
    {Inserts a new line.} {Добавляет строку.}
    {Deletes a line.} {Удаляет строку.}
    {separator} {разделитель}
    {Item} {Пункт}
    {If 'yes', means a separator of the toolbar/menu.} {Если включено, означает разделитель в тулбаре/меню.}
    {After Start...} {После старта...}
    {Before Run...} {Перед Запуском...}
    {Commands:} {Команды:}
    {Commands after start} {Команды после старта}
    {Commands before "Run"} {Команды перед "Запуском"}
    "\n Enter commands to be run after starting alited. They can be Tcl or executables, e.g.\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n It can be necessary for a specific environment.\n" "\n Введите команды, выполняемые после старта alited,\n т.е. команды Tcl или внешние команды, например:\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n Это может потребоваться в некоторых окружениях.\n"
    "\n Enter commands to be run before running a current file with \"Tools/Run\". They can be Tcl or executables, e.g.\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n It can be necessary for a specific project. Something like an initialization before \"Run\".\n" "\n Введите команды, выполняемые перед \"Снасти/Запуск\",\n т.е. команды Tcl или внешние команды, например:\n   pwd\n   cd ~\n   after 1000 ::alited::raise_window\n\n Это может быть полезно в некоторых проектах. Что-то типа инициализации перед запуском.  \n"
    {e_menu's own} {своя в e_menu}
  }

  ## ________________________ Checks ________________________ ##
  ::msgcat::mcmset ru {
    {Check Tcl} {Проверка Tcl}
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
    {Duplicate units} {Дубликатные юниты}
    {duplicate unit:} {дубликатный юнит:}
  }

  ## ________________________ Misc. ________________________ ##
  ::msgcat::mcmset ru {
    "Can't backup \"%f\" to\n\"%d\"!\n\nDelete it anyway?" "Не могу сделать копию \"%f\" в\n\"%d\"!\n\nУдалить этот файл по-любому?"
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
  #   ind = indentation
  ::msgcat::mcmset ru {
    {ind} {отс}
    {Row} {Стр.}
    {Row: } {Стр: }
    { Col: } { Поз: }
    {    Unit: } {   Юнит: }
  }

  ## ________________________ Bar of tabs ________________________ ##
  ::msgcat::mcmset ru {
    {(Un)Select} {Выделить / нет}
    {... Visible} {... видимые}
    {... All at Left} {... все слева}
    {... All at Right} {... все справа}
    {... All} {... все}
  }

  ## ________________________ --EONS-- _________________________ ##
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

  ## ________________________ --EONS-- _________________________ ##
}

# _________________________________ EOF _________________________________ #
#RUNF1: tclsh ../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
