local CHUNK_SIZE = 32

local function removeDecorationsArea(surface, area )
    for _, entity in pairs(surface.find_entities_filtered{area = area, type="decorative"}) do
        entity.destroy()
    end
end

local function removeDecorations(surface, x, y, width, height )
    removeDecorationsArea(surface, {{x, y}, {x + width, y + height}})
end

local function clearDecorations()
    local surface = game.surfaces["nauvis"]
    for chunk in surface.get_chunks() do
        removeDecorations(surface, chunk.x * CHUNK_SIZE, chunk.y * CHUNK_SIZE, CHUNK_SIZE - 1, CHUNK_SIZE - 1)
    end
    
    for _, player in pairs(game.players) do
        player.print("Decorations removed")
    end
end

Event.register(defines.events.on_chunk_generated, function(event)
    removeDecorationsArea( event.surface, event.area )
end)

Event.register(defines.events.on_tick, function(event)

    if not global.fullClear then
        clearDecorations()
        global.fullClear = true
    end
    
    Event.register(defines.events.on_tick, nil)
end)
