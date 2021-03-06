--[Constants]--

--[Globals]--
StartingCard = 0                        -- (South = 0, East = 1, North = 2, West =3)
ToolHand = "right"                       -- side of the turtle with the tool
StorageBlockID = "minecraft:chest"      -- id of chest to Unload inventory in
FacingCard = nil                        -- set by startingCard and updated by functions
ProgName = "KAPI"                       -- name of program using KAPI
Origin = vector.new(0,0,0)              -- starting position in vector form
MoveTimeout = 10                        -- how many attempts to move, before giving up
EmergencyState = false                  -- are we trying to return to origin after a failure

--[Functions]--
function SetProgName(str)
    ProgName = str
end

function GetProgName()
    return ProgName
end

function SetStartingCard(val)
    StartingCard = SanitizeCard(val)
end

function GetStartingCard()
    return StartingCard
end

function SetFacingCard(val)
    FacingCard = SanitizeCard(val)
end

function GetFacingCard()
    return FacingCard
end

function SetMoveTimeout(val)
    MoveTimeout = val
end

function GetMoveTimeout()
    return MoveTimeout
end

function SetToolHand(str)
    ToolHand = str
end

function GetToolHand()
    return ToolHand
end

function SetStorageBlockID(str)
    StorageBlockID = str
end

function GetStorageBlockID()
    return StorageBlockID
end

function SetOriginVar(val)
    Origin = val
end

function GetOriginVar()
    return Origin
end

function SetState(str)
    EmergencyState = str
end

function GetState()
    return EmergencyState
end

function Init()
    local LoggerPath = "log/log_" .. ProgName   -- clear log
    local file = fs.open(LoggerPath, "w")
    if (file == nil) then
        error("Could not open log for:" .. ProgName)
    end
    file.writeLine("")
    file.close()

    Logger("\n---------------------------------------\nInitializing KAPI:")
    Logger("Start cardinal: " .. StartingCard)
    Logger("Program       : " .. ProgName)
    Logger("Tool hand     : " .. ToolHand)
    Logger("Move timeout  : " .. MoveTimeout)
    Logger("Storage ID    : " .. StorageBlockID)
    Logger("GPS Origin attempt...")

    FacingCard = StartingCard
    Origin = vector.new(gps.locate(10))

    if (Origin.x == 0) then
        Logger("\"ERROR: GPS Unavailable\"")
        error("GPS Unavailable")
    else
        Logger("Origin    : " .. Origin:tostring() .. "\n---------------------------------------")
        fs.delete("res/coords_origin")
        local file = fs.open("res/coords_origin", "w")
        if (file == nil) then
            Logger("\"EXC: Could not update  res/coords_origin\"")
        else
            file.writeLine(Origin.x)
            file.writeLine(Origin.y)
            file.writeLine(Origin.z)
            file.writeLine(StartingCard)
        end
        file.close()
    end
end

function Logger(msg)   -- adds msg as timestamped line in log file
    local LoggerPath = "log/log_" .. ProgName
    local file = fs.open(LoggerPath, "a")
    if (file == nil) then
        error("Could not open log for:" .. ProgName)
    end
    -- file.writeLine("[D:" .. os.day() .. " T:" .. textutils.formatTime( os.time(), true ) .. "]: " .. msg .. "\n") -- cute, but really long
    file.writeLine("[D:" .. os.day() .. "]: " .. msg .. "\n")
    file.close()
end

function Kill()     -- resets globals back to Initial values
    turtle.select(1)
    StartingCard = 0
    ToolHand = "right"
    StorageBlockID = "minecraft:chest"
    FacingCard = nil
    ProgName = "KAPI"
    Origin = vector.new(0,0,0)
    MoveTimeout = 10
    EmergencyState = false
    Logger("\n---------------------------------------\nResetting KAPI\n---------------------------------------")
end

function MoveHard(dir) -- (0-Forwards, 1-Down, 2-Up, 3-Back) moves in direction, removing obsticles, will timeout. returns false on timeout
    -- Dig(dir)
    local succStatus = MoveSoft(dir)
    local tempCard = nil

    if not (succStatus) then
        if(dir == 3) then   -- if moving backwards and failing, just turn once till the timeout
            tempCard = GetFacingCard()
            dir = 0
            FaceCard(tempCard + 2)
        end
        for i = 1,MoveTimeout,1 do
            if not Dig(dir) then
                Attack(dir)
            end
            succStatus = MoveSoft(dir)
            if (succStatus) then
                if tempCard ~= nil then -- reset orientation in case we were moving backwards
                    FaceCard(tempCard)
                end
                break
            end
        end
        if tempCard ~= nil then -- reset orientation in case we were moving backwards
            FaceCard(tempCard)
        end
    end
    if not(succStatus) then
        Logger("\"EXC: Failed to hard move in direction: " .. dir .. "\"")
        local pos = UpdateLastPos()
    end
    return succStatus
end

function MoveHardALot (dir, amount)
    for i = 1, amount, 1 do
        local succStatus = MoveHard(dir)
        if not (succStatus) then
            return false
        end
    end
    return true
end

function MoveSoft (dir) -- (0-Forwards, 1-Down, 2-Up, 3-Back) attemts to move in direction. returns false if it fails
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

function MoveSoftALot (dir, amount)
    for i = 1, amount, 1 do
        local succStatus = MoveSoft(dir)
        if not (succStatus) then
            return false
        end
    end
    return true
end

function Attack(dir)    -- (0-Front, 1-Down, 2-Up, 3-Back) returns true if successful
    if(dir == 0) then
        return turtle.attack(ToolHand)
    end
    if(dir == 1) then
        return turtle.attackDown(ToolHand)
    end
    if(dir == 2) then
        return turtle.attackUp(ToolHand)
    end
    if(dir == 3) then
        FaceCard(FacingCard + 2)
        local succStatus = turtle.attack(ToolHand)
        FaceCard(FacingCard - 2)
        return succStatus
    end

end

function Dig(dir)   -- (0-Front, 1-Down, 2-Up, 3-Back) returns true if successful
    if (dir == 0) then
        if (turtle.detect) then
            return (turtle.dig(ToolHand))
        end
    end
    if (dir == 1) then
        if (turtle.detectDown) then
            return (turtle.digDown(ToolHand))
        end
    end
    if (dir == 2) then
        if (turtle.detectUp) then
            return (turtle.digUp(ToolHand))
        end
    end
    if (dir == 3) then
        FaceCard(FacingCard + 2)
        if (turtle.detect) then
            local succStatus = (turtle.dig(ToolHand))
            FaceCard(FacingCard - 2)
            return succStatus
        end
    end
end

function UpdateLastPos() -- return vector of current position and updates file
    local pos = vector.new(gps.locate(10))

    if (pos.x == 0) then
        Logger("\"EXC: GPS Unavailable\"")
    else
        Logger("Updated position: " .. pos:tostring())
        fs.delete("res/coords_last_known")
        local file = fs.open("res/coords_last_known", "w")
        if (file == nil) then
            Logger("\"EXC: Could not update  res/coords_last_known\"")
        else
            file.writeLine(pos.x)
            file.writeLine(pos.y)
            file.writeLine(pos.z)
            file.writeLine(FacingCard)
        end
        file.close()
    end

    return pos
end

function GetLastPos() -- return last saved position from file
    local x = 0
    local y = 0
    local z = 0
    local card = 0
    local file = fs.open("res/coords_last_known", "r")
    if (file == nil) then
        Logger("\"EXC: Could not read  res/coords_last_known\"")
    else
        x = file.readLine()
        y = file.readLine()
        z = file.readLine()
        card = file.readLine()
        Logger("\"Last location read from file:\"\n  \"coords: " .. x .. y .. z .. " cardinal: " .. card .."\"")
    end
    file.close()
    return {x, y, z, card}
end

function GetOrigin() -- return last saved position from file
    if (Origin.x ~= 0) then
        return {Origin.x, Origin.y, Origin.z, StartingCard}
    end
    local x = 0
    local y = 0
    local z = 0
    local card = 0
    local file = fs.open("res/coords_origin", "r")
    if (file == nil) then
        Logger("\"EXC: Could not read  res/coords_origin\"")
    else
        x = file.readLine()
        y = file.readLine()
        z = file.readLine()
        card = file.readLine()
        Logger("\"Origin read from file:\"\n  \"coords: " .. x .. y .. z .. " cardinal: " .. card .."\"")
    end
    file.close()
    return {x, y, z, card}
end

function FaceCard(card)   -- turn to cardinal direction (0=South, 1=East, 2=North, 3=West)
    card = SanitizeCard(card)
    if(SanitizeCard(FacingCard - 1) == card) then
        turtle.turnRight()
        FacingCard = SanitizeCard(FacingCard - 1)
    else
        while (FacingCard ~= card) do
            turtle.turnLeft()
            FacingCard = SanitizeCard(FacingCard + 1)
        end
    end
end

function SanitizeCard(val) -- wraps a given value to it's correct cardinal direction going clockwise
    while not (val <= 3 and val >= 0) do
        if (val > 3) then
            val = val - 4
        elseif(val < 0) then
            val = val + 4
        end
    end
    return val
end

function FlipDirection(val) -- flips movement/interaction directions
    if val == 0 then
        return 3
    end
    if val == 1 then
        return 2
    end
    if val == 2 then
        return 1
    end
    if val == 3 then
        return 0
    end
    Logger("\"EXC: Cannot flip direction: " .. val)
    return nil
end

function GoTo(dest) -- navigates to given coords, disregarding blocks in the way. matches y, x and then z coordinate
    Logger("Going to position: " .. dest:tostring())
    local curr = UpdateLastPos()
    if (curr.x == 0) then
        error("GPS Unavailable")    --TODO - pretty sure this should be the point where we try to return to origin
    end
    local diff = dest - curr
    Logger("Diffrence between positions: " .. diff:tostring())
    local succDigStatus = true
    if (diff.y >= 0) then
        if succDigStatus then
            succDigStatus = MoveHardALot(2, diff.y)
        end
    else
        if succDigStatus then
            succDigStatus = MoveHardALot(1, -diff.y)
        end
    end
    if (diff.x >= 0) then
        if succDigStatus then
            FaceCard(1)
            succDigStatus = MoveHardALot(0, diff.x)
        end
    else
        if succDigStatus then
            FaceCard(3)
            succDigStatus = MoveHardALot(0, -diff.x)
        end
    end

    if (diff.z >= 0) then
        if succDigStatus then
            FaceCard(0)
            succDigStatus = MoveHardALot(0, diff.z)
        end
    else
        if succDigStatus then
            FaceCard(2)
            succDigStatus = MoveHardALot(0, -diff.z)
        end
    end
    FaceCard(StartingCard)
    UpdateLastPos()
end

function CheckIfFull()
    if(turtle.getItemCount(16) > 0) then
        return true
    else
        return false
    end
end

function Unload(dir) -- Attemps to Unload inventory in storage in direction (0-Front, 1-Down, 2-Up, 3-Back)
    local blockBool, blockData = turtle.inspectUp()
    local currCard = FacingCard
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
        FaceCard(FacingCard + 2)
        blockBool, blockData = turtle.inspect()
    end
    if (blockData.name == StorageBlockID) then
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
                    Logger("\"ERROR: Failed to Unload slot #: " .. i .."\"")
                    error("Failed to Unload inventory slot #: " .. i)
                end
            end
        end
        FaceCard(currCard)
        turtle.select(1)
    else
        Logger("\"ERROR: Could not find Unload chest that matches given ID:".. StorageBlockID .. "\"")
        error("Could not find Unload chest that matches given ID:".. StorageBlockID)
    end
end

function Take(dir) -- Attemps to Take a stack from storage in direction until it's full (0-Front, 1-Down, 2-Up, 3-Back)
    local currCard = FacingCard
    local blockBool, blockData = turtle.inspectUp()
    local suckStatus = false
    local suckTimes = 0

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
        FaceCard(FacingCard + 2)
        blockBool, blockData = turtle.inspect()
    end
    if (blockData.name == StorageBlockID) then
        repeat
            if(dir == 0 or dir == 3) then
                suckStatus = turtle.suck()
            end
            if(dir == 1) then
                suckStatus = turtle.suckDown()
             end
            if(dir == 2) then
                suckStatus = turtle.suckUp()
            end
            if suckStatus then
                suckTimes = suckTimes + 1
            end
        until  not suckStatus
        FaceCard(currCard)
        turtle.select(1)
        Logger("Grabbed " .. suckTimes .. " of slots from storage")
    else
        Logger("\"ERROR: Could not find resource chest that matches given ID:".. StorageBlockID .. "\"")
        error("Could not find resource chest that matches given ID:".. StorageBlockID)
    end
end

function ChangeTo(id)   --changes to next slot with id item, returns false is fails, returns true on change or if already on that block
    local data = turtle.getItemDetail(turtle.getSelectedSlot())
    if (turtle.getItemCount() == 0 or data.name ~= id) then
        newSlot = KAPI.FindItem(id)
        if (newSlot == 0) then
            Logger("Failed to find " .. id)
            return false
        else
            Logger("Found " .. id .. " in slot: " .. newSlot)
            turtle.select(newSlot)
            return true
        end
    else
        return true
    end
end

function GetItemID(slot)
    local data = turtle.getItemDetail(slot)
    if data then
        return data.name
    else
        return "failed"
    end
end

function FindItem(id)
    local slot = 0
    for i = 1, 16, 1 do
        if (GetItemID(i) == id) then
            slot = i
            break
        end
    end
    return slot
end

function Place(dir)     -- TODO - skips if mob falls on top of it
    local slot = turtle.getSelectedSlot()  
    if(dir == 0) then
        if not turtle.compare(slot) then    -- TODO - what if we just ran out of blocks and try to do this compare?
            Dig(dir)                        -- TODO - PlaceHARD
            return turtle.place()
        else
            return true
        end
    end
    if(dir == 1) then
        if not turtle.compareDown(slot) then
            Dig(dir)
            return turtle.placeDown()
        else
            return true
        end
    end
    if(dir == 2) then
        if not turtle.compareUp(slot) then
            Dig(dir)
            return turtle.placeUp()
        else
            return true
        end
    end
    if(dir == 3) then
        local succStatus = false
        FaceCard(FacingCard + 2)
        if not turtle.compare(slot) then
            Dig(0)
            succStatus = turtle.place()
        else
            FaceCard(FacingCard - 2)
            return true
        end
        FaceCard(FacingCard - 2)
        return succStatus
    end
end

function CeilGPS()
    local gps = vector.new(gps.locate(10))
    local vec = vector.new(math.ceil(gps.x),math.ceil(gps.y),math.ceil(gps.z))
    return vec
end

-- loadup method