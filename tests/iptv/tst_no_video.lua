-- Exercise the real OSC script against track/event transitions without a display.
package.preload['mp.assdraw'] = function() return {} end
package.preload['mp.utils'] = function() return {} end
local events, observers, tracks, overlays
local function setup(enabled)
    events, observers, tracks, overlays = {}, {}, {}, {}
    mp = {
        get_opt = function(key) if enabled and key == 'iptv-no-video' then return 'yes' end end,
        observe_property = function(key, kind, fn) observers[key] = fn end,
        register_event = function(name, fn)
            events[name] = events[name] or {}
            table.insert(events[name], fn)
        end,
        register_script_message = function() end,
        add_key_binding = function() end,
        add_forced_key_binding = function() end,
        get_property_native = function() return tracks end,
        create_osd_overlay = function()
            local overlay = {visible = false}
            function overlay:update() self.visible = true end
            function overlay:remove() self.visible = false end
            table.insert(overlays, overlay)
            return overlay
        end
    }
    dofile('scripts/mpv-osc.lua')
end
local function event(name)
    for _, callback in ipairs(events[name] or {}) do callback() end
end
setup(true)
assert(#overlays == 1)
local overlay = overlays[1]
tracks = {{type='audio', selected=true}}
observers['track-list']()
assert(not overlay.visible, 'Must not label a stream while it is loading')
event('file-loaded')
assert(overlay.visible and overlay.data:find('NO VIDEO', 1, true), 'Audio-only media needs a label')
tracks = {{type='audio', selected=true}, {type='video', selected=true}}
observers['track-list']()
assert(not overlay.visible, 'Video must hide the label')
tracks[2].selected = false
observers['track-list']()
assert(overlay.visible, 'Disabling video while audio plays must restore the label')
event('start-file')
assert(not overlay.visible, 'A channel change must clear stale state')
event('file-loaded')
assert(overlay.visible)
event('end-file')
assert(not overlay.visible, 'End of playback must clear the label')
tracks = {{type='video', selected=true}}
event('file-loaded')
assert(not overlay.visible, 'Video-only media must not be labelled audio-only')
setup(false)
assert(#overlays == 0, 'Other modules must remain unchanged')
print('PASS: NO VIDEO overlay lifecycle and opt-in isolation')
