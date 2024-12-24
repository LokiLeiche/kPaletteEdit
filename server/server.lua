local g_dumpster = {}

local function GetDefaultColor()
    local red = GetConvarInt('palette_default_red', 3)
    local green = GetConvarInt('palette_default_green', 252)
    local blue = GetConvarInt('palette_default_blue', 194)
    
    red = math.max(0, math.min(255, red))
    green = math.max(0, math.min(255, green))
    blue = math.max(0, math.min(255, blue))
    
    return (red << 16) | (green << 8) | blue
end

local function InitializeDumpster(maxPlayers)
    local defaultColor = GetDefaultColor()
    for playerId = 0, maxPlayers do
        g_dumpster[playerId] = {}
        for i = 0, 4 - 1 do
            g_dumpster[playerId][i] = defaultColor
        end
    end
end

local function SetPaletteColorInternal(playerId, paletteIndex, red, green, blue)
    if type(paletteIndex) ~= "number" or paletteIndex < 0 or paletteIndex >= 4 then
        error("'paletteIndex' must be a number between 0 and 3")
    elseif type(red) ~= "number" or red < 0 or red > 255 then
        error("'red' must be a number between 0 and 255")
    elseif type(green) ~= "number" or green < 0 or green > 255 then
        error("'green' must be a number between 0 and 255")
    elseif type(blue) ~= "number" or blue < 0 or blue > 255 then
        error("'blue' must be a number between 0 and 255")
    end

    if not g_dumpster[playerId] then
        g_dumpster[playerId] = {}
    end
    
    g_dumpster[playerId][paletteIndex] = (red << 16) | (green << 8) | blue
end

local function SerializePaletteColors(playerId)
    local paletteBits = 0
    local colors = {}
    local playerColors = g_dumpster[playerId]
    local defaultColor = GetDefaultColor()
    
    for paletteIndex = 0, 4 - 1 do
        local color = playerColors[paletteIndex]
        if color and color ~= defaultColor then
            paletteBits = paletteBits | (1 << paletteIndex)
        
            local red = (color >> 16) & 0xFF
            local green = (color >> 8) & 0xFF
            local blue = color & 0xFF
            
            table.insert(colors, {red = red, green = green, blue = blue})
        end
    end
    
    local result = string.char(paletteBits)
    for _, color in ipairs(colors) do
        result = result .. string.char(color.red, color.green, color.blue)
    end

    return result
end

function SetHeadBlendPaletteColor(source, paletteIndex, red, green, blue)
    local playerId = source
    SetPaletteColorInternal(playerId, paletteIndex, red, green, blue)
    local serializedData = SerializePaletteColors(playerId)
    Entity(GetPlayerPed(playerId)).state._paletteBytes = serializedData
end

function SetHeadBlendPaletteColors(source, colors)
    if type(colors) ~= "table" then
        error("'colors' must be a table")
    end

    local playerId = source
    for _, color in ipairs(colors) do
        if #color >= 4 then
            SetPaletteColorInternal(playerId, color[1], color[2], color[3], color[4])
        end
    end

    local serializedData = SerializePaletteColors(playerId)
    Entity(GetPlayerPed(playerId)).state._paletteBytes = serializedData
end

RegisterNetEvent('headBlend:requestInitialState')
AddEventHandler('headBlend:requestInitialState', function()
    local playerId = source
    local playerPed = GetPlayerPed(playerId)
    if not playerPed then return end
    
    if not g_dumpster[playerId] then
        g_dumpster[playerId] = {}
        local defaultColor = GetDefaultColor()
        for i = 0, 4 - 1 do
            g_dumpster[playerId][i] = defaultColor
        end
    end

    local serializedData = SerializePaletteColors(playerId)
    Entity(playerPed).state._paletteBytes = serializedData
end)

AddEventHandler('playerJoining', function(source)
    local playerId = source
    g_dumpster[playerId] = {}
    local defaultColor = GetDefaultColor()
    for i = 0, 4 - 1 do
        g_dumpster[playerId][i] = defaultColor
    end
end)

AddEventHandler('playerDropped', function(source)
    local playerId = source
    g_dumpster[playerId] = nil
end)

RegisterNetEvent('headBlend:setPaletteColor')
AddEventHandler('headBlend:setPaletteColor', function(paletteIndex, red, green, blue)
    SetHeadBlendPaletteColor(source, paletteIndex, red, green, blue)
end)

RegisterNetEvent('headBlend:setPaletteColors')
AddEventHandler('headBlend:setPaletteColors', function(colors)
    SetHeadBlendPaletteColors(source, colors)
end)

CreateThread(function()
    InitializeDumpster(GetConvarInt('sv_maxclients', 32))
end)

exports('SetHeadBlendPaletteColor', SetHeadBlendPaletteColor)
exports('SetHeadBlendPaletteColors', SetHeadBlendPaletteColors)

