--Battle Arena 0.1.4
--A 3Ra Gaming creation
--A Halo inspired concept
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
	player.print({"msg-intro1"})
	player.print({"msg-intro2"})
	player.print({"msg-intro3"})
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
       local player_on_team = false
      for k, check_player in pairs (global.online_players) do
        if player == check_player then
          player_on_team = true
          break
        end
      end
      
      if not player_on_team then
        table.insert(global.online_players, player)
        set_player(player, #global.online_players)
      end
      
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
end)

script.on_init(function ()
  load_global_tables()
  global.online_players = {}
  global.players_per_team = 1
  create_teams()
  game.surfaces[1].always_day = true
  set_spawns()
  spawn_loot()
end)

script.on_event(defines.events.on_entity_died, function(event)
 local entity = event.entity
	if entity.type == "player" then
	
	local pos = entity.surface.find_non_colliding_position(
		"steel-chest", entity.position, 8, 1)
		if not pos then return end
    
		local grave = entity.surface.create_entity{
		name="steel-chest", position=pos, force="neutral", spill=true}
		if protective_mode then
			grave.destructible = false
		end
			local grave_inv = grave.get_inventory(defines.inventory.chest)
			local count = 0
			for i, id in ipairs{
				defines.inventory.player_ammo,
				defines.inventory.player_quickbar,
				defines.inventory.player_main,
				defines.inventory.player_guns} do
				local inv = entity.get_inventory(id)
				for j = 1, #inv do
					if inv[j].valid_for_read then
						count = count + 1
						if count > #grave_inv then return end
						grave_inv[count].set_stack(inv[j])
					end
				end
			end	
		end		
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  give_starting_inventory(player)
  give_equipment(player)
end)

global.timer_value = 0
global.timer_wait = 300
global.timer_display = 1
global.loot_timer_value = 0
global.loot_timer_wait = 90
global.loot_timer_display = 1

script.on_event(defines.events.on_tick, function(event)
	local current_time = game.tick / 60 - global.timer_value
	local current_loot_time = game.tick / 60 - global.loot_timer_value
	local message_display = "test"
	local loot_message_display = "test"
	show_health()
	set_zoom()
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
	if current_loot_time >= global.loot_timer_wait then
		if global.timer_display == 1 then
			loot_message_display = {"msg-announce3"}
			global.loot_timer_display = 2
			spawn_loot()
		else
			loot_message_display = {"msg-announce3"}
			global.loot_timer_display = 1
			spawn_loot()
		end
		for k, player in pairs(game.players) do
			player.print(loot_message_display)
		end
		global.loot_timer_value = game.tick / 60
	end
end)

function create_teams()
  for k, force in pairs(global.force_list) do
    game.create_force(force.name)
  end
end

function set_teams()
	global.online_players = {}
	shuffle_table(global.force_list)
	for k, player in pairs(game.players) do
		if player.connected then
			table.insert(global.online_players, player)
		end
	end
	if #global.online_players > 0 then
		global.players_per_team = math.floor((#global.online_players)^0.5)
		else
		global.players_per_team = 1
	end
	shuffle_table(global.online_players)
	for k, player in pairs (global.online_players) do
		set_player(player,k)
	end
end
 
function set_zoom()
	for k, player in pairs(game.players) do
		player.zoom = 0.826
	end
end

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

function set_player(player,k)
  local index = math.ceil(k/global.players_per_team)
  if global.force_list[index] then
    player.force = global.force_list[index].name
    set_character(player, player.force)
    local c = global.force_list[index].color
    player.color = {r = c[1], g = c[2], b = c[3], a = c[4]}
	player.print("Welcome to the "..player.force.name.." team")
    give_equipment(player)
    give_starting_inventory(player)
  else
  player.print({"couldnt-place-on-team"})
  end
end

function set_character(player, force)
  if player.connected then
  player.character_reach_distance_bonus = 2
    player.force = force
    local character = player.surface.create_entity{name = "player", position = player.surface.find_non_colliding_position("player", player.force.get_spawn_position(player.surface), 10, 2), force = force}
    player.set_controller{type = defines.controllers.character, character = character}
  end
end

function give_starting_inventory(player)
  if player.connected then
    if player.character then
      for k, item in pairs (global.starting_inventories) do
        player.insert{name = item.name, count = item.count}
      end
    end
  end
end

function give_equipment(player)
  if player.connected then
      player.insert{name="power-armor-mk2", count = 1}
      local p_armor = player.get_inventory(5)[1].grid
      p_armor.put({name = "fusion-reactor-equipment"})
      p_armor.put({name = "exoskeleton-equipment"})
      p_armor.put({name = "exoskeleton-equipment"})
    end
  end
  
function format_time(ticks)
  local seconds = ticks / 60
  local minutes = math.floor((seconds)/60)
  local seconds = math.floor(seconds - 60*minutes)
  return string.format("%d:%02d", minutes, seconds)
end

function spawn_loot()
	local surface = game.surfaces["nauvis"]

	
	
			for k, object in pairs (surface.find_entities{{35,32},{36,33}}) do object.destroy() end
		global.loot_chest_c = surface.create_entity{name = "steel-chest", position = {35,32}, force = "neutral"}
		global.loot_chest_c.minable = false
		global.loot_chest_c.destructible = false
		global.loot_chest_c.insert{name = "cluster-grenade", count = 3}
		
	
	
			for k, object in pairs (surface.find_entities{{75,51},{76,52}}) do object.destroy() end
		global.loot_chest_b = surface.create_entity{name = "steel-chest", position = {76,51}, force = "neutral"}
		global.loot_chest_b.minable = false
		global.loot_chest_b.destructible = false
		global.loot_chest_b.insert{name = "exoskeleton-equipment",count = 1}
		
	
	
			for k, object in pairs (surface.find_entities{{-29,39},{-30,40}}) do object.destroy() end
		global.loot_chest_l = surface.create_entity{name = "steel-chest", position = {-29,39}, force = "neutral"}
		global.loot_chest_l.minable = false
		global.loot_chest_l.destructible = false
		global.loot_chest_l.insert{name = "gate", count = 6}
	
	
			for k, object in pairs (surface.find_entities{{95,36},{96,37}}) do object.destroy() end
		global.loot_chest_r = surface.create_entity{name = "steel-chest", position = {95,36}, force = "neutral"}
		global.loot_chest_r.minable = false
		global.loot_chest_r.destructible = false
		global.loot_chest_r.insert{name = "rocket-launcher", count=1}
		global.loot_chest_r.insert{name = "explosive-rocket", count = 5}
	
	
	
			for k, object in pairs (surface.find_entities{{52, 71},{53, 72}}) do object.destroy() end
		global.loot_chest_r = surface.create_entity{name = "steel-chest", position = {52, 71}, force = "neutral"}
		global.loot_chest_r.minable = false
		global.loot_chest_r.destructible = false
		global.loot_chest_r.insert{name = "flame-thrower", count = 1}
		global.loot_chest_r.insert{name = "flame-thrower-ammo", count = 5}
		
		
			for k, object in pairs (surface.find_entities{{88, 2},{89, 3}}) do object.destroy() end
		global.loot_chest_r = surface.create_entity{name = "steel-chest", position = {88, 2}, force = "neutral"}
		global.loot_chest_r.minable = false
		global.loot_chest_r.destructible = false
		global.loot_chest_r.insert{name = "distractor-capsule", count = 1}
		
		
			for k, object in pairs (surface.find_entities{{-15,-1},{-14,0}}) do object.destroy() end
		global.loot_chest_r = surface.create_entity{name = "steel-chest", position = {-15,-1}, force = "neutral"}
		global.loot_chest_r.minable = false
		global.loot_chest_r.destructible = false
		global.loot_chest_r.insert{name = "defender-capsule", count = 5}
		
		
		
			for k, object in pairs (surface.find_entities{{-16,90},{-15,89}}) do object.destroy() end
		global.loot_chest_r = surface.create_entity{name = "steel-chest", position = {-16,90}, force = "neutral"}
		global.loot_chest_r.minable = false
		global.loot_chest_r.destructible = false
		global.loot_chest_r.insert{name = "gun-turret", count = 1}		
end


function set_spawns()
s = game.surfaces["nauvis"]
	purple = game.forces["Purple"]
	red = game.forces["Red"]
	green = game.forces["Green"]
	blue = game.forces["Blue"]
	yellow = game.forces["Yellow"]
	pink = game.forces["Pink"]
	white = game.forces["White"]
	black = game.forces["Black"]
	gray = game.forces["Gray"]
	brown = game.forces["Brown"]
	cyan = game.forces["Cyan"]
	orange = game.forces["Orange"]
  game.forces.Blue.research_all_technologies()
  game.forces.Green.research_all_technologies()
  game.forces.Black.research_all_technologies()
  game.forces.Yellow.research_all_technologies()
  game.forces.Cyan.research_all_technologies()
  game.forces.Gray.research_all_technologies()
  game.forces.Purple.research_all_technologies()
  game.forces.Orange.research_all_technologies()
  game.forces.Pink.research_all_technologies()
  game.forces.White.research_all_technologies()
  game.forces.Brown.research_all_technologies()
  game.forces.Red.research_all_technologies()
	orange.set_spawn_position({-16,-46}, s)
	red.set_spawn_position({29,-46}, s)
	green.set_spawn_position({75,-46}, s)
	blue.set_spawn_position({113,-22}, s)
	yellow.set_spawn_position({113,25}, s)
	pink.set_spawn_position({113,73}, s)
	purple.set_spawn_position({78,114}, s)
	white.set_spawn_position({38,114}, s)
	black.set_spawn_position({-11,114}, s)
	gray.set_spawn_position({-47,-11}, s)
	brown.set_spawn_position({-47,79}, s)
	cyan.set_spawn_position({-47,39}, s)

end
	
function load_global_tables()

global.force_list = 
{
  {name = "Red", color = {0.9, 0.1, 0.1, 0.8}},
  {name = "Green", color = {0.1, 0.8, 0.1, 0.8}},
  {name = "Blue", color = {0.2, 0.2, 0.8, 0.7}},
  {name = "Orange", color = {0.8, 0.4, 0.0, 0.8}},
  {name = "Yellow", color = {0.8, 0.8, 0.0, 0.6}},
  {name = "Pink", color = {0.8, 0.2, 0.8, 0.2}},
  {name = "Purple", color = {0.8, 0.2, 0.8, 0.9}},
  {name = "White", color = {0.8, 0.8, 0.8, 0.5}},
  {name = "Black", color = {0.1, 0.1, 0.1, 0.8}},
  {name = "Gray", color = {0.4, 0.4, 0.4, 0.8}},
  {name = "Brown", color = {0.5, 0.3, 0.1, 0.8}},
  {name = "Cyan", color = {0.1, 0.9, 0.9, 0.8}}
}
global.starting_inventories = 
    {
      {name = "combat-shotgun", count = 1},
	  {name = "steel-axe", count = 1},
	  {name = "submachine-gun", count = 1},
      {name = "grenade", count=5},
      {name = "poison-capsule", count=5},
	  {name = "land-mine", count=5},
	  {name = "firearm-magazine", count=20},
	  {name = "piercing-shotgun-shell", count=20},
    }
end
