TriggerEvent("es:addGroup", "admin", "user", function(group) end)

--Help Commands
TriggerEvent('es:addCommand', 'help', function(source, args, user)
  TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "Player Commands ")
	TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "-------------------------------------------------------")
	TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "Press F7 for all the options")
	TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "/911: to call for help")
	TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "/ooc: out of character chat")
	TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "/dispatch: dispatcher message")
	TriggerClientEvent("chatMessage", source, "^3SYSTEM", {255, 255, 255}, "/pm: personal message to a player")

end)

TriggerEvent('es:addCommand', 'changename', function(source, args, user)
			local nom = user:getNom()
			local prenom = user:getPrenom()
			if nom == "Citizen" and prenom == "Citizen" then
				if(args[2] ~= nil and args[3] ~= nil) then
					if (string.match(args[2], '[a-z]') and string.match(args[3], '[a-z]')) then
						TriggerEvent("es:updateName", source, args[2], args[3])
						user:setNom(tostring(args[3]))
						user:setPrenom(tostring(args[2]))
					else
						TriggerClientEvent("chatMessage", source,  "^3SYSTEM", {255, 255, 255},  "Last name and first name must contain only letters")
					end
				else
					TriggerClientEvent("chatMessage", source,  "^3SYSTEM", {255, 255, 255}, "Usage : /changename [First Name] [Last Name]")
				end
			else
				TriggerClientEvent("chatMessage", source,  "^3SYSTEM", {255, 255, 255}, "You have already changed your name")
			end
end)

TriggerEvent('es:addCommand', 'group', function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Group: ^2" .. user.group.group)
end)

-- Kicking
TriggerEvent('es:addGroupCommand', 'kick', "admin", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					reason = "Kicked: You have been kicked from the server"
				else
					reason = "Kicked: " .. table.concat(reason, " ")
				end

				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been kicked(^2" .. reason .. "^0)")
				DropPlayer(player, reason)
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)


TriggerEvent('es:addCommand', 'rmwanted', function(source)
  TriggerEvent("es:getPlayerFromId", source, function(user)
    if(user.money > 100) then
			user:removeMoney((100))
			TriggerClientEvent('es_freeroam:wanted', source)
			TriggerClientEvent("es_freeroam:notify", source, "CHAR_LESTER", 1, "Lester", false, "Troubles in paradise are fixed")
		else
			TriggerClientEvent("es_freeroam:notify", source, "CHAR_LESTER", 1, "Lester", false, "Sorry but you need more cash before i can help you")
		end
	end)
end)
