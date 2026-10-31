local path
local dictionary
mp = {get_opt=function() return path end}
package.preload['mp.utils'] = function()
    return {parse_json=function() return dictionary end}
end
local function lookup() return dofile('scripts/mpv-i18n.lua') end
assert(lookup()('STOP') == 'STOP', 'Missing dictionary must retain English')
path = os.tmpname()
local file = assert(io.open(path, 'w')); file:write('{}'); file:close()
dictionary = {STOP='ZASTAVIT', AUDIO='ZVUK'}
local T = lookup()
assert(T('STOP') == 'ZASTAVIT')
assert(T('AUDIO') == 'ZVUK')
assert(T('Unknown') == 'Unknown')
dictionary = {STOP=''}
assert(lookup()('STOP') == 'STOP', 'Empty translations must not hide buttons')
dictionary = nil
assert(lookup()('STOP') == 'STOP', 'Corrupt JSON must retain English')
os.remove(path)
print('PASS: mpv dictionary lookup and English fallback')
