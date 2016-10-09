--[[ list of inventories to save - constants from api reference]]--
local storeinventories = {
    defines.inventory.player_vehicle,
    defines.inventory.player_armor,
    defines.inventory.player_tools,
    defines.inventory.player_guns,
    defines.inventory.player_ammo,
    defines.inventory.player_quickbar,
    defines.inventory.player_main,
    defines.inventory.player_trash,
}

players = {}

function get_player_inventories(player)
    local inventories = {}
    for i = 1, #storeinventories, 1 do
        local inventoryid = storeinventories[i]
        local playerinventory = player.get_inventory(inventoryid)
        table.insert(inventories,playerinventory)
    end	--[[ end for #storeinventories ]]--
    return inventories
end

script.on_event(defines.events.on_preplayer_mined_item, function (event)
    local player = game.players[event.player_index]
    local author = event.entity.last_user
--    if player ~= author then
        event.entity.clear_items_inside()
        players[event.player_index] = true
--    end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
    local player = game.players[event.player_index]
    local item_count = event.item_stack.count
    if players[event.player_index] then
        players[event.player_index] = nil
        for i = 1, #storeinventories, 1 do
            local inventoryid = storeinventories[i]
            local playerinventory = player.get_inventory(inventoryid)
            if playerinventory then
                item_count = item_count - playerinventory.remove({name=event.item_stack.name,count=item_count})
            end
            if item_count == 0 then
                break
            end
        end	--[[ end for #storeinventories ]]--
    end
end)

