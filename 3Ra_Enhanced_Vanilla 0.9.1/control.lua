--Enhanced Vanilla
--A 3Ra Gaming compilation
--New Player Join
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=20}
  player.insert{name="burner-mining-drill", count = 2}
  player.insert{name="stone-furnace", count = 2}
  player.print({"msg-intro1"})
  player.print({"msg-intro2"})
  player.print({"msg-intro3"})
end)

--Any player joined
--for Admin Spectate option
script.on_event(defines.events.on_player_joined_game, function(event)
	local player = game.players[event.player_index]	
	if player.admin == true then
        if player.gui.left.spectate == nil then
            local adminframe = player.gui.left.add{name = "spectate", type = "button", direction = "horizontal", caption = "spectate"}
        end
		for k, p in pairs (game.players) do
			p.print("All Hail Admin "..player.name)
		end
	end
 end)

--Gui event for admin spectate press
script.on_event(defines.events.on_gui_click, function(event)
	local p = game.players[event.player_index]
    local i = event.player_index
    local e = event.element.name
	if p.gui.left.spectate ~= nil then
        if e ~= nil then
            if e == "spectate" then
				if not p.admin then
					p.gui.left.spectate.destroy()
					p.print("You are no longer an admin. Nub")
					return
				end
                force_spectators(i)
            end
        end
    end
end)

--Function to check if a player is still admin (called before "admin only" functions are to be called)

--Function to spectate or bring back to character
function force_spectators(index)
    local player = game.players[index]
    if global.player_spectator_state == nil then global.player_spectator_state = {} end
    if global.player_spectator_character == nil then global.player_spectator_character = {}  end
    if global.player_spectator_force == nil then global.player_spectator_force = {} end
    if global.player_spectator_state[index] then
        --remove spectator mode
        if player.character == nil and global.player_spectator_character[index] ~= nil then
            local pos = player.position
			player.set_controller{type=defines.controllers.character, character=global.player_spectator_character[index]}
            player.teleport(pos)
		end
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.print("Summoning your character")
    else
        --put player in spectator mode
        if player.character then
            global.player_spectator_character[index] = player.character
            global.player_spectator_force[index] = player.force
    		player.set_controller{type = defines.controllers.god}
        end
        if not game.forces["Spectators"] then game.create_force("Spectators") end
		player.force = game.forces["Spectators"]
        global.player_spectator_state[index] = true
		player.print("You are now a spectator")
    end
end

-- Announcement Scripts
global.timer_wait = 600
global.timer_display = 1
global.timer_value = 0

-- events on tick
script.on_event(defines.events.on_tick, function(event)
	local current_time = game.tick / 60 - global.timer_value
	local message_display = "test"
	show_health()
	if current_time >= global.timer_wait then
		if global.timer_display == 1 then
			message_display = {"msg-announce1"}
			global.timer_display = 2
		else
			message_display = {"msg-announce2"}
			global.timer_display = 1
		end
		for k, player in pairs(game.players) do
			player.print(message_display)
		end
		global.timer_value = game.tick / 60
	end
end)

--Health text float
function show_health()
    for k, player in pairs(game.players) do
		if player.connected then
			if player.character then
				if player.character.health == nil then return end
				local index = player.index
				local health = math.ceil(player.character.health)
				if global.player_health == nil then global.player_health = {} end
				if global.player_health[index] == nil then global.player_health[index] = health end
				if global.player_health[index] ~= health then
					global.player_health[index] = health
					if health < 80 then
						if health > 50 then
							player.surface.create_entity{name="flying-text", color={b = 0.2, r= 0.1, g = 1, a = 0.8}, text=(health), position= {player.position.x, player.position.y-2}}
						elseif health > 29 then
							player.surface.create_entity{name="flying-text", color={r = 1, g = 1, b = 0}, text=(health), position= {player.position.x, player.position.y-2}}
						else
							player.surface.create_entity{name="flying-text", color={b = 0.1, r= 1, g = 0, a = 0.8}, text=(health), position= {player.position.x, player.position.y-2}}
						end
					end
				end
            end
        end
    end 
end	

--Gravestone Scripts
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.type == "player" then
		local pos = entity.surface.find_non_colliding_position("steel-chest", entity.position, 8, 1)
		if not pos then return end
    
		local grave = entity.surface.create_entity{name="steel-chest", position=pos, force="neutral"}
		if protective_mode then
			grave.destructible = false
		end
		local grave_inv = grave.get_inventory(defines.inventory.chest)
		local count = 0
		for i, id in ipairs{
		defines.inventory.player_armor,
		defines.inventory.player_quickbar,
		defines.inventory.player_ammo,
		defines.inventory.player_tools,
		defines.inventory.player_guns,
		defines.inventory.player_main,
		defines.inventory.player_trash} do
			local inv = entity.get_inventory(id)
			for j = 1, #inv do
				if inv[j].valid_for_read then
					count = count + 1
					if count > #grave_inv then
						print("Not enough room in chest. You've lost some stuff...")
						return 
					end
					grave_inv[count].set_stack(inv[j])
				end
			end
		end
	end
end)

---------------------------------------------------------------------
--Put new scripts above these ones
--Player Spawn after Death
script.on_event(defines.events.on_player_respawned, function(event)
	local player = game.players[event.player_index]
	player.insert{name="pistol", count=1}
	player.insert{name="firearm-magazine", count=10}
end)

--Satellite Launch -free play script-
script.on_event(defines.events.on_rocket_launched, function(event)
	local force = event.rocket.force
	if event.rocket.get_item_count("satellite") > 0 then
		if global.satellite_sent == nil then
			global.satellite_sent = {}
		end
		if global.satellite_sent[force.name] == nil then
			game.set_game_state{game_finished=true, player_won=true, can_continue=true}
			global.satellite_sent[force.name] = 1
		else
			global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1
		end
		for index, player in pairs(force.players) do
			if player.gui.left.rocket_score == nil then
				local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
				frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
				frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
			else
				player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
			end
		end
	else
		if (#game.players <= 1) then
			game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
		else
			for index, player in pairs(force.players) do
				player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
			end
		end
	end
end)
