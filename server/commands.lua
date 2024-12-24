RegisterCommand('setcolor', function(source, args)
    if #args < 4 then
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Usage: /setcolor [index] [red] [green] [blue]'}
            })
        end
        return
    end

    local index = tonumber(args[1])
    local r = tonumber(args[2])
    local g = tonumber(args[3])
    local b = tonumber(args[4])

    if not (index and r and g and b) then
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Error: All arguments must be numbers'}
            })
        end
        return
    end

    if index < 0 or index > 3 then
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Error: Index must be between 0 and 3'}
            })
        end
        return
    end

    if r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 then
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Error: RGB values must be between 0 and 255'}
            })
        end
        return
    end

    exports['kPedBlend']:SetHeadBlendPaletteColor(source, index, r, g, b)
end, false)


RegisterCommand('randomcolors', function(source)
    local colors = {}
    
    for i = 0, 3 do
        table.insert(colors, { -- rando
            i,                          
            math.random(0, 255),        
            math.random(0, 255),        
            math.random(0, 255)        
        })
    end

    exports['kPedBlend']:SetHeadBlendPaletteColors(source, colors)
end, false)

