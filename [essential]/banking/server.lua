require "resources/mysql-async/lib/MySQL"

-- HELPER FUNCTIONS
function bankBalance(player)
  return tonumber(MySQL.Sync.fetchScalar("SELECT bankbalance FROM users WHERE identifier = @name", {['@name'] = player}))
end

function bankdBalance(player)
  return tonumber(MySQL.Sync.fetchScalar("SELECT dirtymoney FROM users WHERE identifier = @name", {['@name'] = player}))
end

function deposit(player, amount)
  local bankbalance = bankBalance(player)
  local new_balance = bankbalance + amount
  MySQL.Async.execute("UPDATE users SET `bankbalance`=@value WHERE identifier = @identifier", {['@value'] = new_balance, ['@identifier'] = player})
end

function withdraw(player, amount)
  local bankbalance = bankBalance(player)
  local new_balance = bankbalance - amount
  MySQL.Async.execute("UPDATE users SET `bankbalance`=@value WHERE identifier = @identifier", {['@value'] = new_balance, ['@identifier'] = player})
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.abs(math.floor(num * mult + 0.5) / mult)
end

RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local rounded = round(tonumber(amount), 0)
    if(string.len(rounded) >= 9) then
      TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Amount too high^0")
      CancelEvent()
    else
      if(tonumber(rounded) <= tonumber(user:money)) then
        user:removeMoney((rounded))
        local player = user.identifier
        deposit(player, rounded)
        local new_balance = bankBalance(player)
        TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Deposit: ~g~$".. rounded .." ~n~~s~New Balance: ~g~$" .. new_balance)
        TriggerClientEvent("banking:updateBalance", source, new_balance)
        TriggerClientEvent("banking:addBalance", source, rounded)
        CancelEvent()
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Not enough money!^0")
        CancelEvent()
      end
    end
  end)
end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local rounded = round(tonumber(amount), 0)
    if(string.len(rounded) >= 9) then
      TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Amount too high^0")
      CancelEvent()
    else
      local player = user.identifier
      local bankbalance = bankBalance(player)
      if(tonumber(rounded) <= tonumber(bankbalance)) then
        withdraw(player, rounded)
        user:addMoney((rounded))
        local new_balance = bankBalance(player)
        TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Withdrawal: ~g~$".. rounded .." ~n~~s~New Balance: ~g~$" .. new_balance)
        TriggerClientEvent("banking:updateBalance", source, new_balance)
        TriggerClientEvent("banking:removeBalance", source, rounded)
        CancelEvent()
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Not enough money in the account!^0")
        CancelEvent()
      end
    end
  end)
end)

RegisterServerEvent('bank:remove')
AddEventHandler('bank:remove', function(amount, source)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local rounded = round(tonumber(amount), 0)
    local player = user.identifier
    local bankbalance = bankBalance(player)
    withdraw(player, rounded)
    local new_balance = bankBalance(player)
    TriggerClientEvent("banking:updateBalance", source, new_balance)
    TriggerClientEvent("banking:removeBalance", source, rounded)
    CancelEvent()
  end)
end)

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(fromPlayer, toPlayer, amount)
  if tonumber(fromPlayer) == tonumber(toPlayer) then
    TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Can not transfer to yourself^0")
    CancelEvent()
  else
    TriggerEvent('es:getPlayerFromId', fromPlayer, function(user)
      local rounded = round(tonumber(amount), 0)
      if(string.len(rounded) >= 9) then
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Amount too high^0")
        CancelEvent()
      else
        local player = user.identifier
        local bankbalance = bankBalance(player)
        if(tonumber(rounded) <= tonumber(bankbalance)) then
          withdraw(player, rounded)
          local new_balance = bankBalance(player)
          TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Transfer: ~r~-$".. rounded .." ~n~~s~New Balance: ~g~$" .. new_balance)
          TriggerClientEvent("banking:updateBalance", source, new_balance)
          TriggerClientEvent("banking:removeBalance", source, rounded)
          TriggerEvent('es:getPlayerFromId', toPlayer, function(user2)
            local recipient = user2.identifier
            deposit(recipient, rounded)
            new_balance2 = bankBalance(recipient)
            TriggerClientEvent("es_freeroam:notify", toPlayer, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Received: ~g~$".. rounded .." ~n~~s~New Balance: ~g~$" .. new_balance2)
            TriggerClientEvent("banking:updateBalance", toPlayer, new_balance2)
            TriggerClientEvent("banking:addBalance", toPlayer, rounded)
            CancelEvent()
          end)
          CancelEvent()
        else
          TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Not enough money in the account^0")
          CancelEvent()
        end
      end
    end)
  end
end)

-- DOUBLE CALLBACK
-- RegisterServerEvent('bank:givecash')
-- AddEventHandler('bank:givecash', function(toPlayer, amount)
-- 	TriggerEvent('es:getPlayerFromId', source, function(user)
-- 		if (tonumber(user.money) >= tonumber(amount)) then
-- 			local player = user.identifier
-- 			user:removeMoney(amount)
-- 			TriggerEvent('es:getPlayerFromId', toPlayer, function(recipient)
-- 				recipient:addMoney(amount)
-- 				TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Argent donné: ~r~-$".. amount .." ~n~~s~Porte-monnaie: ~g~$" .. user.money)
-- 				TriggerClientEvent("es_freeroam:notify", toPlayer, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Argent reçu: ~g~$".. amount .." ~n~~s~Porte-monnaie: ~g~$" .. recipient.money)
-- 			end)
-- 		else
-- 			if (tonumber(user.money) < tonumber(amount)) then
--         TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Pas assez d'argent dans votre porte-monnaie^0")
--         CancelEvent()
-- 			end
-- 		end
-- 	end)
-- end)

RegisterServerEvent("banking:getBalance")
AddEventHandler('banking:getBalance', function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.identifier
    local bankbalance = bankBalance(player)
    TriggerClientEvent("banking:f_getBalance", source, bankbalance)
  end)
end)

AddEventHandler('es:playerLoaded', function(source)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.identifier
    local bankbalance = bankBalance(player)
    local bankdbalance = bankdBalance(player)
    TriggerClientEvent("banking:updateBalance", source, bankbalance)
    TriggerClientEvent("banking:updatedBalance", source, bankdbalance)
  end)
end)
