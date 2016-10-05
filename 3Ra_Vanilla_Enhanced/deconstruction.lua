deconstruction_limit = 30
player_deconstruction_counter = {}
deconstruction_refresh_rate = 60
script.on_event(defines.events.on_marked_for_deconstruction, function (event)
    local player = game.players[event.player_index]
    if player_deconstruction_counter[player] == nil
      player_deconstruction_counter[player] = 0
    end
    player_deconstruction_counter[player] = player_deconstruction_counter[player] + 1
    if player_deconstruction_counter[player] > deconstruction_limit
      event.entity.cancel_deconstruction(player.force)
      game.print(player.name.."you are not allowed to deconstruct that much at once, wait a bit and try again")
    end
  end)

script.on_event(defines.events.on_tick, function(event)
    if game.tick % deconstruction_refresh_rate == 0
      player_deconstruction_counter = {}
    end
  end)
