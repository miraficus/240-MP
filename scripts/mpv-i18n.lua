-- Shared translation lookup for external mpv scripts. Qt supplies a UTF-8 JSON
-- dictionary; a missing dictionary or untranslated key keeps the English UI.
local translations = {}
local path = mp.get_opt('i18n-file')
if path then
    local file = io.open(path, 'r')
    if file then
        local parsed = require('mp.utils').parse_json(file:read('*a') or '')
        file:close()
        if type(parsed) == 'table' then translations = parsed end
    end
end
return function(source)
    local value = translations[source]
    return type(value) == 'string' and value ~= '' and value or source
end
