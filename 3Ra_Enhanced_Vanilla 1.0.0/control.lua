--Enhanced Vanilla
--A 3Ra Gaming compilation
if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end
--config and event must be called first.
require "config"
require "event"
require "admin"
require "announcements"
require "gravestone"
require "rocket"
require "autodeconstruct"
require "undecorator"

--Give starting items.
function player_joined(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=20}
  player.insert{name="burner-mining-drill", count = 2}
  player.insert{name="stone-furnace", count = 2}
end

--Give player weapons after they die.
function player_respawned(event)
	local player = game.players[event.player_index]
	player.insert{name="pistol", count=1}
	player.insert{name="firearm-magazine", count=10}
end

Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)
