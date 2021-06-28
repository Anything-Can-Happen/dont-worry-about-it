
RegisterNetEvent("NAT2K15:SENDNOT")
AddEventHandler("NAT2K15:SENDNOT", function(primary, displaytext, class, plate)
    TriggerClientEvent("NAT2K15:NOTIFY", -1, source, primary, displaytext, class, plate)
end)


RegisterServerEvent('NAT2K15:SERVERPLAY')
AddEventHandler('NAT2K15:SERVERPLAY', function(soundFile, soundVolume)
    TriggerClientEvent('NAT2K15:PLAYSOUND', source, soundFile, soundVolume)
end)
