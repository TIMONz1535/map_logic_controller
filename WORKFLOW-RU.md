
# Используемые плагины для VS Code

`Lua Language Server` - https://marketplace.visualstudio.com/items?itemName=sumneko.lua
- Комплексное решение с собственной "диагностикой" кода.
- Лучше всех сканирует и обнаруживает источники функций. Базовое определение типов.
- Поддерживает формат описания `EmmyLua`, но сейчас имеет свой, заметно модифицированный.
- Не такая крутая подсветка кода как у `EmmyLua`, можно активировать вместе, но описания будут дублироваться.
- Имеет форматтер `EmmyLuaCodeStyle`, но в некоторых моментах не устраивает.
- Настройки плагина представлены в `.luarc.jsonc` и применяются автоматически при открытии папки.

`vscode-lua` - https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua
- Форматтер на основе `lua-fmt`. Довольно старый, но наиболее приятный.
- Статический анализатор `luacheck`, требуется указать путь до экзешника.
- Свежий `luacheck` качать из **lunarmodules community fork** - https://github.com/lunarmodules/luacheck
- Настройки плагина:
```json
{
	"lua.format.lineWidth": 125,
	"lua.targetVersion": "5.2",
	"lua.luacheckPath": "C:/.../luacheck.exe",
	"lua.preferLuaCheckErrors": true,
}
```

`Local Lua Debugger` - https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode
- Дебагер для луа кода. Позволяет запускать открытый файл по F5.

Форматирование через `vscode-lua`, доп. анализатор `luacheck`, дебагер `Local Lua Debugger`, все остальное `Lua Language Server`.


# Другие неактуальные плагины для VS Code

`EmmyLua` - https://marketplace.visualstudio.com/items?itemName=tangzx.emmylua
- Хорошая подсветка кода, подсветка глобальных переменных.
- Слабая подсказка по коду. Не умеет определять типы.

`LuaHelper` - https://marketplace.visualstudio.com/items?itemName=yinfei.luahelper
- Комплексное решение с форматтером `LuaFormatter`.
- Форматтер форсирует вид таблиц (столбик/строка), но хочется и так и так.
- Форматтер переносит длинные вызовы функций как clang-format, но хочется аргументы в столбик.
- Не находит определение функций, которые модифицируют глобальные таблицы.

`EmmyLuaCodeStyle` - https://marketplace.visualstudio.com/items?itemName=CppCXY.emmylua-codestyle
- Форматтер с гибкими настройками.
- Не умеет убирать лишние пустые строки между функциями/строками кода.
- По сравнению с `lua-fmt` разрешает разный способ форматирования функций, что довольно плохо. Хочется более строгий.

`StyLua` - https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua
- Очень строгий форматтер, которые не имеет настроек.
- Аргументы функций всегда в столбик, что делает код громоздким.
- Выставляет пробелы в таблице перед фигурными скобками.
