if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

KAPI.setProgName("AmMnr")
--KAPI.setStartingCard(0)
--KAPI.setMoveTimeout(10)
--KAPI.setToolHand("left")
--KAPI.setStorageBlockID("minecraft:chest")

--[Constansts]--

--[Globals]--
depthDir = 1
length = 0
width = 0
depth = 0
doWork = true
offsetDepth = 0
offsetX = 0
offsetZ = 0
firstTurnCardArg = 3    --defalut dig to the left of start
turnCard = nil
unloadDir = 2

--[Functions]--
function miner() -- Main function
    turnCard = KAPI.sanitizeCard(turnCard + 2)
    for i = 1,width,1 do
        for j = 2,length,1 do
            checkInv()
            moveHardWrap(0)
        end
        if (i ~= width) then
            local currCard = KAPI.getFacingCard()
            KAPI.faceCard(turnCard)
            checkInv()
            moveHardWrap(0)
            KAPI.faceCard(currCard + 2)
        else
            KAPI.faceCard(KAPI.getFacingCard() + 2)
        end
    end
    local pos = KAPI.updateLastPos()
    if (pos.x == 0) then
        noGPSHandler()
    end
    
end

function checkInv() -- checks capacity and unloads if full. will return after it unloads
    if (KAPI.checkIfFull()) then
        local pos = KAPI.updateLastPos()
        local currCard = KAPI.getFacingCard()
        if (pos.x == 0) then
            noGPSHandler()
        end
        local originData = KAPI.getOrigin()
        KAPI.goTo(vector.new(originData[1], originData[2], originData[3]))
        KAPI.unload(unloadDir)
        moveHardWrap(0)
        KAPI.goTo(pos)
        KAPI.faceCard(currCard)
    end
end

function moveHardWrap(dir)
    if not KAPI.moveHard(dir) then
        endMiningHandler()
    end
end

function moveHardALotWrap(dir, amount)
    if not KAPI.moveHardALot(dir, amount) then
        endMiningHandler()
    end
end

function endMiningHandler()
    KAPI.logger("AmMinr: Failed to move, retreating to origin")
    local originData = KAPI.getOrigin()
    KAPI.goTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.unload(unloadDir)
    KAPI.logger("AmMinr: Ending program")
    print("I've been a miner o7")
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
print("Running AmMnr V2.0...")
print("The turtle has to be facing South by default.")
print("The turtle should have a regular chest on top of it.")

print("Enter length of area:")
length = tonumber(read())
print("Enter width of area:")
width = tonumber(read())
print("Limit depth(0 for unlimited):")
depth = tonumber(read())
print("Offset depth:")
offsetDepth = tonumber(read())
print("Offset X:")
offsetX = tonumber(read())
print("Offset Z:")
offsetZ = tonumber(read())
print("Invert depth(y/n):")
if (read() == "y") then
    depthDir = 2
end

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
    unloadDir = tonumber(read())
    print("Storage ID(blank for wooden chest):")
    local sid = read()
    if (sid ~="") then
        KAPI.setStorageBlockID(sid)
    end

end
math.randomseed(os.time())
os.setComputerLabel("Yellow Snow Co. Minr " .. math.random(1, 1000))
KAPI.init()
KAPI.logger("Starting AmMinr with these settings:")
KAPI.logger("length: " .. length .. " width:" .. width)
KAPI.logger("depth: " .. depth .. " offset_depth: " .. offsetDepth)
if (depthDir == 2) then
    KAPI.logger("Depth is inverted")
else
    KAPI.logger("Depth is NOT inverted")
end
KAPI.logger("Unload direction is: " .. unloadDir)
turnCard = KAPI.sanitizeCard(KAPI.getStartingCard() + firstTurnCardArg)
KAPI.logger("First turn will be in cardinal:" .. turnCard .. "\n" .. "---------------------------------------")

print("HERE COMES THE MINER!")

moveHardWrap(0)
if (offsetDepth > 0) then
    moveHardALotWrap(depthDir, offsetDepth)
end
if (offsetX > 0) then
    KAPI.faceCard(KAPI.getStartingCard())
    moveHardALotWrap(0, offsetX)
end
if (offsetZ > 0) then
    KAPI.faceCard(firstTurnCardArg)
    moveHardALotWrap(0, offsetZ)
    KAPI.faceCard(KAPI.getStartingCard())
end
if (depth > 0) then
    for i = 1,depth,1 do
        moveHardWrap(depthDir)
        miner()
    end
    endMiningHandler()
else
    while doWork do
        moveHardWrap(depthDir)
        miner()
    end
    endMiningHandler()
end
