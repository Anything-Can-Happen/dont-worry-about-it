-- MAIN VARS / DO NOT TOUCH -- 
local is_player_in_vehicle = false;
local seatbelt_status = false;
local isUiOpen = false;
local speedBuffer = {}
local vol = {}


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local class = GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    if(class == 21 or class == 19 or class == 16 or class == 15 or class == 14 or  class == 13 or class == 8) then 
      SendNUIMessage({displayWindow = 'false'})
      isUiOpen = false
      seatbelt_status = false;
    else 
      if vehicle ~= 0 and (is_player_in_vehicle or checkclass(vehicle) and not checkvehicle(vehicle)) then
        is_player_in_vehicle = true
        if isUiOpen == false and not IsPlayerDead(PlayerId()) then
          SendNUIMessage({displayWindow = 'true'})
          isUiOpen = true
        end
  
        if seatbelt_status then 
          DisableControlAction(0, 75, true)
          DisableControlAction(27, 75, true)
          if IsDisabledControlJustPressed(0, 75) and IsVehicleStopped(vehicle) then
            ShowInfo("~w~You must unbuckle your ~y~seatbelt~w~ in order to exit your vehicle.")
          end
        end
      
        speedBuffer[2] = speedBuffer[1]
        speedBuffer[1] = GetEntitySpeed(vehicle)
  
        if not seatbelt_status and speedBuffer[2] ~= nil and GetEntitySpeedVector(vehicle, true).y > 1.0 and speedBuffer[1] > (100.0 / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
          local co = GetEntityCoords(ped)
          local fw = Fwv(ped)
          SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
          SetEntityVelocity(ped, vol[2].x, vol[2].y, vol[2].z)
          Citizen.Wait(1)
          SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
        end
          
        vol[2] = vol[1]
        vol[1] = GetEntityVelocity(vehicle)
          
        if IsControlJustReleased(0, Config.keybind) then
          seatbelt_status = not seatbelt_status 
          if seatbelt_status then
            Citizen.Wait(1)
            TriggerServerEvent('NAT2K15:SERVERPLAY', 'buckle', 0.7)
            ShowInfo("~w~Seatbelt ~g~buckled drive safe")
            SendNUIMessage({displayWindow = 'true'})
            isUiOpen = true 
          else 
            ShowInfo("~w~Seatbelt ~r~unbuckled")
            TriggerServerEvent('NAT2K15:SERVERPLAY', 'unbuckle', 0.7)
            SendNUIMessage({displayWindow = 'false'})
            isUiOpen = true  
          end
        end
      
      elseif is_player_in_vehicle then
        is_player_in_vehicle = false
        seatbelt_status = false
        speedBuffer[1], speedBuffer[2] = 0.0, 0.0
        if isUiOpen == true and not IsPlayerDead(PlayerId()) then
          SendNUIMessage({displayWindow = 'false'})
          isUiOpen = false 
        end
      end
    end
  end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    if is_player_in_vehicle then
      local Vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
      local speed = GetEntitySpeed(Vehicle) * 3.6;
      if speed > 20 then
        ShowWindow = true
      else
        ShowWindow = false
      end
      if IsPlayerDead(PlayerId()) or IsPauseMenuActive() then
        if isUiOpen == true then
          SendNUIMessage({displayWindow = 'false'})
        end
      elseif not seatbelt_status and is_player_in_vehicle and not IsPauseMenuActive() and not IsPlayerDead(PlayerId()) then
        if ShowWindow and speed > 5 then
          SendNUIMessage({displayWindow = 'true'})
          DisplayHelpText("~w~Press ~INPUT_REPLAY_SHOWHOTKEY~ to ~y~buckle ~w~your seatbelt.")
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
	  Citizen.Wait(1000)
      if not seatbelt_status and is_player_in_vehicle and not IsPauseMenuActive() then
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        local primary, secondary = GetVehicleColours(vehicle)
        local ped = GetPlayerPed(-1)
        local model = GetEntityModel(vehicle)
        local displaytext = GetDisplayNameFromVehicleModel(model)
        local class = GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1), false))
        local plate = GetVehicleNumberPlateText(vehicle)
        primary = Config.colorNames[tostring(primary)] 
        TriggerServerEvent("NAT2K15:SENDNOT", primary, displaytext, class, plate)
    end
  end
end)


-- EVENTS --

RegisterNetEvent("NAT2K15:NOTIFY")
AddEventHandler("NAT2K15:NOTIFY", function(id, primary, displaytext, class, plate)
  local clientid = PlayerId()
  local serverid = GetPlayerFromServerId(id)
  if clientid ~= serverid then
    if GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1), false)) == 18 then 
      if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(clientid)), GetEntityCoords(GetPlayerPed(serverid)), true) < 19.999 then
        if(class == 21 or class == 19 or class == 16 or class == 15 or class == 14 or  class == 13 or class == 8) then 
          return
        else
          if(Config.displayplate == false) then
            ShowInfo("A person in a ~y~" .. primary .. " ~w~vehicle is not wearing their seatbelt.") 
          else 
            ShowInfo("A person in the ~y~" .. primary .. " ~w~vehicle is not wearing their seatbelt. Plate: " .. plate)
          end
        end
      end
    end
  end
end)

RegisterNetEvent('NAT2K15:PLAYSOUND')
AddEventHandler('NAT2K15:PLAYSOUND', function(soundFile, soundVolume)
    SendNUIMessage({transactionType = 'playSound', transactionFile     = soundFile, transactionVolume = soundVolume})
end)


-- MIAN FNUCTION  --
function checkvehicle(veh)
	for i = 1, #Config.seatbeltException, 1 do
		if GetEntityModel(veh) == GetHashKey(Config.seatbeltException[i]) then
			return true
		end
	end
	return false
end

function ShowInfo(string)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(string)
  DrawNotification(false, true)
end

function DisplayHelpText(text)
  SetTextComponentFormat("STRING")
  AddTextComponentString(text)
  DisplayHelpTextFromStringLabel(0, 0, 0, -1)
end

function checkclass(vehicle)
  return (GetVehicleClass(vehicle) >= 0 and GetVehicleClass(vehicle) <= 7) or (GetVehicleClass(vehicle) >= 9 and  GetVehicleClass(vehicle) <= 12) or (GetVehicleClass(vehicle) >= 17 and GetVehicleClass(vehicle) <= 20)
end	

function Fwv(entity)
  local hr = GetEntityHeading(entity) + 90.0
  if hr < 0.0 then hr = 360.0 + hr end
  hr = hr * 0.0174533
  return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end