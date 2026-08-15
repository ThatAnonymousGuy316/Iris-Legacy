local color = '000000'
local alpha = 0.5
local scalee = 0.3

function makeBG(tag, group)
    local x1 = getPropertyFromGroup(group, 0, 'x')
    local x2 = getPropertyFromGroup(group, 1, 'x')
    local x3 = getPropertyFromGroup(group, 2, 'x')
    local x4 = getPropertyFromGroup(group, 3, 'x')

    local minX = math.min(x1, x2, x3, x4)
    local maxX = math.max(x1, x2, x3, x4)

    local padding = scalee * 15

    makeLuaSprite(tag, '', minX - padding, -50)
    makeGraphic(tag, (maxX + 112) - minX + (padding * 2), 820, color)

    setProperty(tag .. '.alpha', alpha)
    setObjectCamera(tag, 'hud')

    addLuaSprite(tag, false)
end

function updateBG(tag, group)
    local x1 = getPropertyFromGroup(group, 0, 'x')
    local x2 = getPropertyFromGroup(group, 1, 'x')
    local x3 = getPropertyFromGroup(group, 2, 'x')
    local x4 = getPropertyFromGroup(group, 3, 'x')

    local minX = math.min(x1, x2, x3, x4)
    local maxX = math.max(x1, x2, x3, x4)

    local padding = scalee * 15

    setProperty(tag .. '.x', minX - padding)
    setProperty(tag .. '._frame.frame.width',
        (maxX + 112) - minX + (padding * 2)
    )
end

function onCreatePost()
    -- player side always
    makeBG('playerBG', 'playerStrums')

    -- opponent side only if middlescroll is disabled
    if not middlescroll then
        makeBG('opponentBG', 'opponentStrums')
    end
end

function onUpdatePost()
    -- player side always
    updateBG('playerBG', 'playerStrums')

    -- opponent side only if middlescroll is disabled
    if not middlescroll then
        updateBG('opponentBG', 'opponentStrums')
    end
end