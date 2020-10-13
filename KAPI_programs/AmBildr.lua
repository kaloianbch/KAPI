if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

KAPI.setProgName("AmBuildr")
--KAPI.setStartingCard(0)
--KAPI.setMoveTimeout(10)
--KAPI.setStorageBlockID("minecraft:chest")

--[Constansts]--

--[Globals]--
length = 0
width = 0
firstTurnCardArg = 3
turnCard = nil
chestDir = 2
floorBlockID = nil
floorCurrSlot = 0

--[Functions]--
function buildFloor()
    turnCard = KAPI.sanitizeCard(turnCard + 2)
    moveHardALotWrap(1,2)
    for i = 1,width,1 do
        for j = 2,length,1 do
            KAPI.changeTo(floorBlockID)
            moveHardWrap(0)
            placeWrap(2)
        end
        if (i ~= width) then
            local currCard = KAPI.getFacingCard()
            KAPI.faceCard(turnCard)
            moveHardWrap(0)
            KAPI.faceCard(currCard + 2)
            placeWrap(2)
        else
            local originData = KAPI.getOrigin() -- add state here maybe
            KAPI.goTo(vector.new(originData[1], originData[2], originData[3]))
        end
    end

    local pos = KAPI.updateLastPos()
    if (pos.x == 0) then
        noGPSHandler()
    end
end

function moveHardWrap(dir)
    if not KAPI.moveHard(dir) then
        endBuildingHandler()
    end
end

function moveHardALotWrap(dir, amount)
    if not KAPI.moveHardALot(dir, amount) then
        endBuildingHandler()
    end
end

function placeWrap(dir)
    return KAPI.place(dir)
end

function checkInv(id)
    if (turtle.getItemCount() == 0) then
        newSlot = KAPI.findItem(id)
        if (newSlot == 0) then
            endBuildingHandler()
        else
            turtle.select(newSlot)
        end
    end
end

function endBuildingHandler()
    KAPI.logger("AmBildr: Failed to move or ran out of items, retreating to origin")
    local originData = KAPI.getOrigin()
    KAPI.goTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.unload(unloadDir)
    KAPI.logger("AmBildr: Ending program")
    os.shutdown()
end

function noGPSHandler()
    local originData = KAPI.getOrigin()
    KAPI.goTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.unload(unloadDir)
    KAPI.logger("ERROR: Lost GPS signal")
    error("Lost GPS signal")
end

--[Main]--
print("Running AmBildr Alpha...")
print("The turtle has to be facing South by default.")
print("The turtle should have a regular chest on top of it.")

print("Enter length of area:")
length = tonumber(read())
print("Enter width of area:")
width = tonumber(read())
print("Slot of floor block:")
floorCurrSlot = tonumber(read())

print("Other settings?(y/n):")
if (read() == "y") then
    
    print("Starting cardinal(0=South, 1=East, 2=North, 3=West):")
    local sCard = tonumber(read())
    KAPI.setStartingCard(sCard)
    print("Side of tool(left/right):")
    KAPI.setToolHand(read())
    print("Direction of width(3 for left, 1 for right):")
    firstTurnCardArg = tonumber(read())
    print("Unload direction(0-front, 1-down, 2-top, 3-back):")
    chestDir = tonumber(read())
    print("Storage ID(blank for wooden chest):")
    local sid = read()
    if (sid ~="") then
        KAPI.setStorageBlockID(sid)
    end

end
math.randomseed(os.time())
os.setComputerLabel("Yellow Snow Co. Bildr " .. math.random(1, 1000))
KAPI.init()
KAPI.logger("Starting AmMinr with these settings:")
KAPI.logger("length: " .. length .. " width:" .. width)
KAPI.logger("Unload direction is: " .. chestDir)
turnCard = KAPI.sanitizeCard(KAPI.getStartingCard() + firstTurnCardArg)
KAPI.logger("First turn will be in cardinal:" .. turnCard)
floorBlockID = KAPI.getItemID(w)
KAPI.logger("Floor Block ID:" .. floorBlockID .. "\n" .. "---------------------------------------")

print("I came to build, build, build, build")

buildFloor() --add block, restock