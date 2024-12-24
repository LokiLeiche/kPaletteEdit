
local function IsBitSet(num, position)
    return (num & (1 << position)) ~= 0
end

local function ApplyPaletteColors(ped, paletteIndex, red, green, blue)
    Citizen.InvokeNative(0x891b421a88aeb58d, ped, red, green, blue, paletteIndex)
end

local function ApplyPaletteColorsFromBuffer(entity, paletteBytes)
    if not paletteBytes then return end

    local paletteBits = string.byte(paletteBytes, 1)
    local readOffset = 2
    local ped = NetworkGetEntityFromNetworkId(entity)
    if not DoesEntityExist(ped) then return end

    local defaultRed = GetConvarInt('palette_default_red', 3)
    local defaultGreen = GetConvarInt('palette_default_green', 252)
    local defaultBlue = GetConvarInt('palette_default_blue', 194)
    
    for paletteIndex = 0, 4 - 1 do
        if not IsBitSet(paletteBits, paletteIndex) then
            ApplyPaletteColors(ped, paletteIndex, defaultRed, defaultGreen, defaultBlue)
        else
            local r = string.byte(paletteBytes, readOffset)
            local g = string.byte(paletteBytes, readOffset + 1)
            local b = string.byte(paletteBytes, readOffset + 2)
            ApplyPaletteColors(ped, paletteIndex, r, g, b)
            readOffset = readOffset + 3
        end
    end
end

function SetHeadBlendPaletteColor(paletteIndex, red, green, blue)
    TriggerServerEvent('headBlend:setPaletteColor', paletteIndex, red, green, blue)
end

function SetHeadBlendPaletteColors(colors)
    TriggerServerEvent('headBlend:setPaletteColors', colors)
end

local function CheckAndApplyColors()
    local playerPed = PlayerPedId()
    if DoesEntityExist(playerPed) then
        local stateBag = Entity(playerPed).state._paletteBytes
        if stateBag then
            ApplyPaletteColorsFromBuffer(NetworkGetNetworkIdFromEntity(playerPed), stateBag)
        end
    end
end

local function InitializePaletteColors() -- if someone would like to pr a diff way to do this, please do.
    local playerPed = PlayerPedId()
    if not DoesEntityExist(playerPed) then return end
    TriggerServerEvent('headBlend:requestInitialState')
    Wait(1000)
    CheckAndApplyColors()
end

CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            Wait(1000) 
            InitializePaletteColors()
            break
        end
        Wait(100)
    end
end)

AddStateBagChangeHandler('_paletteBytes', nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if DoesEntityExist(entity) and IsPedAPlayer(entity) then
        ApplyPaletteColorsFromBuffer(NetworkGetNetworkIdFromEntity(entity), value)
    end
end)

exports('SetHeadBlendPaletteColor', SetHeadBlendPaletteColor)
exports('SetHeadBlendPaletteColors', SetHeadBlendPaletteColors)
exports('CheckAndApplyColors', CheckAndApplyColors)
exports('InitializePaletteColors', InitializePaletteColors)


