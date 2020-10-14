--[Constants]--

--[Globals]--
startingCard = 0                        -- (South = 0, East = 1, North = 2, West =3)
toolHand = "left"                       -- side of the turtle with the tool
storageBlockID = "minecraft:chest"      -- id of chest to unload inventory in
facingCard = nil                        -- set by startingCard and updated by functions
progName = "KAPI"                       -- name of program using KAPI
origin = vector.new(0,0,0)              -- starting position in vector form
moveTimeout = 10                        -- how many attempts to move, before giving up
emergencyState = false                  -- are we trying to return to origin after a failure

--[Functions]--
function setProgName(str)
    progName = str
end

function getProgName()
    return progName 
end

function setStartingCard(val)
    startingCard = sanitizeCard(val)
end

function getStartingCard()
    return startingCard 
end

function getFacingCard()
    return facingCard 
end

function setMoveTimeout(val)
    moveTimeout = val
end

function getMoveTimeout()
    return moveTimeout 
end

function setToolHand(str)
    toolHand = str
end

function getToolHand()
    return toolHand
end

function setStorageBlockID(str)
    storageBlockID = str
end

function getStorageBlockID()
    return storageBlockID 
end

function getOrigin()
    return origin
end

function init()
    local loggerPath = "log/log_" .. progName   -- clear log
    local file = fs.open(loggerPath, "w")
    if (file == nil) then
        error("Could not open log for:" .. progName)
    end
    file.writeLine("")
    file.close()

    logger("initializing KAPI")
    facingCard = startingCard
    logger("Starting cardinal is: " .. facingCard)
    logger("Program using KAPI: " .. progName)
    logger("Tool hand is: " .. toolHand)
    logger("Move attempt timeout is: " .. moveTimeout)
    logger("Storage ID is: " .. storageBlockID .. "\n" .. "---------------------------------------")

    origin = vector.new(gps.locate(10))

    if (origin.x == 0) then
        logger("\"!!!ERROR: GPS Unavailable!!!\"")
        error("GPS Unavailable")
    else
        logger("Found origin at: " .. origin:tostring())
        logger("Updating  res/coords_origin...")
        local file = fs.open("res/coords_origin", "w") 
        if (file == nil) then
            logger("\"!!!EXC: Could not update  res/coords_origin!!!\"")
        else
            file.writeLine(origin.x)
            file.writeLine(origin.y)
            file.writeLine(origin.z)
            file.writeLine(startingCard)
            logger("Successfuly updated")
        end
        file.close()
    end
end

function logger(msg)   -- adds msg as timestamped line in log file
    local loggerPath = "log/log_" .. progName
    local file = fs.open(loggerPath, "a")
    if (file == nil) then
        error("Could not open log for:" .. progName)
    end
    file.writeLine("[D:" .. os.day() .. " T:" .. textutils.formatTime( os.time(), true ) .. "]: " .. msg .. "\n")
    file.close()
end

function moveHard(dir) -- (0-Forwards, 1-Down, 2-Up, 3-Back) moves in direction, removing obsticles, will timeout. returns false on timeout
    -- dig(dir)
    local succStatus = moveSoft(dir)

    if not (succStatus) then
        for i = 1,moveTimeout,1 do
            if not dig(dir) then
                attack(dir)
            end
            succStatus = moveSoft(dir)
            if (succStatus) then
                break
            end
        end
    end
    if not(succStatus) then
        local pos = updateLastPos()
        if (pos.x ~= nil) then
            logger("\"" .. "!!!EXC: Failed to hard move to block in direction: " .. dir .. " at position: " .. pos:tostring() .. "!!!\"")
        else
            logger("\"" .. "!!!EXC: Failed to hard move to block in direction: " .. dir .. " at position: UNKOWN" .. "!!!\"")
        end
    end
    return succStatus
end

function moveHardALot (dir, amount)
    for i = 1, amount, 1 do
        local succStatus = moveHard(dir)
        if not (succStatus) then
            return false
        end
    end
    return true
end

function moveSoft (dir) -- (0-Forwards, 1-Down, 2-Up, 3-Back) attemts to move in direction. returns false if it fails
    if(dir == 0) then
        return turtle.forward()
    end
    if(dir == 1) then
        return turtle.down()
    end
    if(dir == 2) then
        return turtle.up()
    end
    if(dir == 3) then
        return turtle.back()
    end
end

function moveSoftALot (dir, amount)
    for i = 1, amount, 1 do
        local succStatus = moveSoft(dir)
        if not (succStatus) then
            return false
        end
    end
    return true
end

function attack(dir)    -- (0-Front, 1-Down, 2-Up, 3-Back) returns true if successful
    if(dir == 0) then
        return turtle.attack(toolHand)
    end
    if(dir == 1) then
        return turtle.attackDown(toolHand)
    end
    if(dir == 2) then
        return turtle.attackUp(toolHand)
    end
    if(dir == 3) then
        faceCard(facingCard + 2)
        local succStatus = turtle.attack(toolHand)
        faceCard(facingCard - 2)
        return succStatus
    end
    
end

function dig(dir)   -- (0-Front, 1-Down, 2-Up, 3-Back) returns true if successful
    if (dir == 0) then
        if (turtle.detect) then
            return (turtle.dig(toolHand))
        end
    end
    if (dir == 1) then
        if (turtle.detectDown) then
            return (turtle.digDown(toolHand))
        end
    end    
    if (dir == 2) then
        if (turtle.detectUp) then
            return (turtle.digUp(toolHand))
        end
    end
    if (dir == 3) then
        faceCard(facingCard + 2)
        if (turtle.detect) then
            local succStatus = (turtle.dig(toolHand))
            faceCard(facingCard - 2)
            return succStatus
        end
    end
end

function updateLastPos() -- return vector of current position and updates file
    logger("Retrieving GPS position")
    local pos = vector.new(gps.locate(10))

    if (pos.x == 0) then
        logger("\"!!!EXC: GPS Unavailable!!!\"")
    else
        logger("Current Position is: " .. pos:tostring())
        logger("Updating  res/coords_last_known...")
        local file = fs.open("res/coords_last_known", "w") 
        if (file == nil) then
            logger("\"!!!EXC: Could not update  res/coords_last_known!!!\"")
        else
            file.writeLine(pos.x)
            file.writeLine(pos.y)
            file.writeLine(pos.z)
            file.writeLine(facingCard)
            logger("Successfuly updated")
        end
        file.close()
    end

    return pos
end

function getLastPos() -- return last saved position from file
    logger("Retrieving last saved position...")
    local x = 0
    local y = 0
    local z = 0
    local card = 0
    local file = fs.open("res/coords_last_known", "r")
    if (file == nil) then
        logger("\"!!!EXC: Could not read  res/coords_last_known!!!\"")
    else
        x = file.readLine()
        y = file.readLine()
        z = file.readLine()
        card = file.readLine()
        logger("Read from file: position: " .. x .. y .. z .. " cardinal: " .. card)
    end
    file.close()
    return {x, y, z, card}
end

function getOrigin() -- return last saved position from file
    logger("Retrieving origin...")
    if (origin.x ~= 0) then
        logger("Found at run-time variable...")
        return {origin.x, origin.y, origin.z, startingCard}
    end
    local x = 0
    local y = 0
    local z = 0
    local card = 0
    local file = fs.open("res/coords_origin", "r")
    if (file == nil) then
        logger("\"!!!EXC: Could not read  res/coords_origin!!!\"")
    else
        x = file.readLine()
        y = file.readLine()
        z = file.readLine()
        card = file.readLine()
        logger("Read from file: origin: " .. x .. y .. z .. " cardinal: " .. card)
    end
    file.close()
    return {x, y, z, card}
end

function faceCard(card)   -- turn to cardinal direction (0=South, 1=East, 2=North, 3=West)
    card = sanitizeCard(card)
    if(sanitizeCard(facingCard - 1) == card) then
        turtle.turnRight()
        facingCard = sanitizeCard(facingCard - 1)
    else
        while (facingCard ~= card) do
            turtle.turnLeft()
            facingCard = sanitizeCard(facingCard + 1)
        end
    end
end

function sanitizeCard(val) -- wraps a given value to it's correct cardinal direction going clockwise
    while not (val <= 3 and val >= 0) do
        if (val > 3) then
            val = val - 4
        elseif(val < 0) then
            val = val + 4
        end
    end
    return val
end

function goTo(dest) -- navigates to given coords, disregarding blocks in the way. matches y, x and then z coordinate
    logger("Going to position: " .. dest:tostring())
    local curr = updateLastPos()
    local noGPS = false
    if (curr.x == 0) then
        local backup = getLastPos()
        curr.x = backup[1]
        curr.y = backup[2]
        curr.z = backup[3]
        if (curr.x == nil) then
            logger("\"!!!ERROR: No valid last known position\"!!!")   -- TODO - attempt to send error back
            error("No valid last known position")
        end
        noGPS = true
    end
    local diff = dest - curr
    logger("Diffrence between positions: " .. diff:tostring())
    local succDigStatus = true
    if (diff.y >= 0) then
        if succDigStatus then
            succDigStatus = moveHardALot(2, diff.y)
        end
    else
        if succDigStatus then
            succDigStatus = moveHardALot(1, -diff.y)
        end
    end
    if (diff.x >= 0) then
        if succDigStatus then
            faceCard(1)
            succDigStatus = moveHardALot(0, diff.x)
        end
    else
        if succDigStatus then
            faceCard(3)
            succDigStatus = moveHardALot(0, -diff.x)
        end
    end

    if (diff.z >= 0) then
        if succDigStatus then
            faceCard(0)
            succDigStatus = moveHardALot(0, diff.z)
        end
    else
        if succDigStatus then
            faceCard(2)
            succDigStatus = moveHardALot(0, -diff.z)
        end
    end
    if (not succDigStatus) or noGPS then
        if not emergencyState then
            if(noGPS) then
                logger("GPS lost, retreating to origin")
            else
                logger("Failed to go to destination, retreating to origin")
            end
            emergencyState = true
            local originBkUp = getOrigin()
            goTo(vector.new(originBkUp[1], originBkUp[2], originBkUp[3]))
        else
            local curr = updateLastPos()
            logger("\"" .. "!!!ERROR: Failed to return to origin. Current pos: " .. curr:tostring() .. "!!!\"")
            error("Failed to return to origin" .. "\n" .. "Current pos: " .. curr:tostring())
        end
    else
        emergencyState = false
    end
    faceCard(startingCard)
    logger("Arrived at destination")
end

function checkIfFull()
    if(turtle.getItemCount(16) > 0) then
        return true
    else
        return false
    end
end

function unload(dir) -- Attemps to unload inventory in storage in direction (0-Front, 1-Down, 2-Up, 3-Back)
    logger("Attempting to unload in direction: " .. dir)
    local blockBool, blockData = turtle.inspectUp()
    if(dir == 0) then
        blockBool, blockData = turtle.inspect()
    end
    if(dir == 1) then
        blockBool, blockData = turtle.inspectDown()
    end
    if(dir == 2) then
        blockBool, blockData = turtle.inspectUp()
    end
    if(dir == 3) then
        faceCard(facingCard + 2)
        blockBool, blockData = turtle.inspect()
        faceCard(facingCard - 2)
    end
    if (blockData.name == storageBlockID) then
        currCard = facingCard
        if(dir == 3) then
            faceCard(facingCard + 2)
        end
        for i = 1, 16, 1 do
            if(turtle.getItemCount(i) > 0) then
                turtle.select(i)
                local succStatus = false
                if(dir == 0 or dir == 3) then
                    succStatus = turtle.drop()
                end
                if(dir == 1) then
                    succStatus = turtle.dropDown()
                end
                if(dir == 2) then
                    succStatus = turtle.dropUp()
                end
                if not succStatus then
                    logger("\"" .. "!!!ERROR: Failed to unload slot #: " .. i .."!!!\"")
                    error("Failed to unload inventory slot #: " .. i)
                end
            end
        end
        faceCard(currCard)
        turtle.select(1)
        logger("Unload Successful")
    else
        logger("\"!!!ERROR: Could not find chest that matches given ID:".. storageBlockID .. "!!!\"")
        error("Could not find chest that matches given ID:".. storageBlockID)
    end
end

function changeTo(id)   --changes to next slot with id item, returns false is fails
    local data = turtle.getItemDetail(turtle.getSelectedSlot())
    if (turtle.getItemCount() == 0 or data.name ~= id) then
        logger("Trying to find  " .. id .. "  in inventory...")
        newSlot = KAPI.findItem(id)
        if (newSlot == 0) then
            logger("Failed to find more  " .. id)
            return false
        else
            logger("Found more  " .. id .. "  in slot: " .. newSlot)
            turtle.select(newSlot)
            return true
        end
    end
end

function getItemID(slot)
    local data = turtle.getItemDetail(slot)
    if data then
        return data.name
    else
        return "failed"
    end
end

function findItem(id)
    local slot = 0
    for i = 1, 16, 1 do
        if (getItemID(i) == id) then
            slot = i
            break
        end
    end
    return slot
end

function place(dir)     -- TODO - skips if mob falls on top of it
    local slot = turtle.getSelectedSlot()
    if(dir == 0) then
        if not turtle.compare(slot) then
            dig(dir)
            return turtle.place()
        end
    end
    if(dir == 1) then
        if not turtle.compareDown(slot) then
            dig(dir)
            return turtle.placeDown()
        end
    end
    if(dir == 2) then
        if not turtle.compareUp(slot) then
            dig(dir)
            return turtle.placeUp()
        end
    end
    if(dir == 3) then
        local succStatus = false    --TODO - will return false if compare true
        faceCard(facingCard + 2)
        if not turtle.compare(slot) then
            dig(0)
            succStatus = turtle.place()
        end
        faceCard(facingCard - 2)
        return succStatus
    end
end

function ceilGPS()
    local gps = vector.new(gps.locate(10))
    local vec = vector.new(math.ceil(gps.x),math.ceil(gps.y),math.ceil(gps.z))
    return vec
end

-- loadup method