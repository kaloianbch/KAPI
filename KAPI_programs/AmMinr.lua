if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

KAPI.SetProgName("AmMnr")
--KAPI.SetStartingCard(0)
--KAPI.SetMoveTimeout(10)
--KAPI.SetToolHand("left")
--KAPI.SetStorageBlockID("minecraft:chest")

--[Constansts]--

--[Globals]--
DepthDir = 1
Length = 0
Width = 0
Depth = 0
DoWork = true
OffsetDepth = 0
OffsetX = 0
OffsetZ = 0
FirstTurnCardArg = 3    --defalut Dig to the left of start
TurnCard = nil
UnloadDir = 2

--[Functions]--
function Miner() -- Main function
    TurnCard = KAPI.SanitizeCard(TurnCard + 2)
    for i = 1,Width,1 do
        for j = 2,Length,1 do
            CheckInv()
            MoveHardWrap(0)
        end
        if (i ~= Width) then
            local currCard = KAPI.GetFacingCard()
            KAPI.FaceCard(TurnCard)
            CheckInv()
            MoveHardWrap(0)
            KAPI.FaceCard(currCard + 2)
        else
            KAPI.FaceCard(KAPI.GetFacingCard() + 2)
        end
    end
    local pos = KAPI.UpdateLastPos()
    if (pos.x == 0) then
        NoGPSHandler()
    end
    
end

function CheckInv() -- checks capacity and Unloads if full. will return after it Unloads
    if (KAPI.CheckIfFull()) then
        local pos = KAPI.UpdateLastPos()
        local currCard = KAPI.GetFacingCard()
        if (pos.x == 0) then
            NoGPSHandler()
        end
        local originData = KAPI.GetOrigin()
        KAPI.GoTo(vector.new(originData[1], originData[2], originData[3]))
        KAPI.Unload(UnloadDir)
        MoveHardWrap(0)
        KAPI.GoTo(pos)
        KAPI.FaceCard(currCard)
    end
end

function MoveHardWrap(dir)
    if not KAPI.MoveHard(dir) then
        EndMiningHandler()
    end
end

function MoveHardALotWrap(dir, amount)
    if not KAPI.MoveHardALot(dir, amount) then
        EndMiningHandler()
    end
end

function EndMiningHandler()
    KAPI.Logger("AmMinr: Failed to move, retreating to origin")
    local originData = KAPI.GetOrigin()
    KAPI.GoTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.Unload(UnloadDir)
    KAPI.Logger("AmMinr: Ending program")
    print("I've been a miner o7")
    os.shutdown()
end

function NoGPSHandler()
    local originData = KAPI.GetOrigin()
    KAPI.GoTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.Unload(UnloadDir)
    KAPI.Logger("ERROR: Lost GPS signal")
    error("Lost GPS signal")
end

--[Main]--
print("Running AmMnr V2.0...")
print("The turtle has to be facing South by default.")
print("The turtle should have a regular chest on top of it.")

print("Enter length of area:")
Length = tonumber(read())
print("Enter width of area:")
Width = tonumber(read())
print("Limit depth(0 for unlimited):")
Depth = tonumber(read())
print("Offset depth:")
OffsetDepth = tonumber(read())
print("Offset X:")
OffsetX = tonumber(read())
print("Offset Z:")
OffsetZ = tonumber(read())
print("Invert depth(y/n):")
if (read() == "y") then
    DepthDir = 2
end

print("Other settings?(y/n):")
if (read() == "y") then
    
    print("Starting cardinal(0=South, 1=East, 2=North, 3=West):")
    local sCard = tonumber(read())
    KAPI.SetStartingCard(sCard)
    print("Side of tool(left/right):")
    KAPI.SetToolHand(read())
    print("Direction of width(3 for left, 1 for right):")
    FirstTurnCardArg = tonumber(read())
    print("Unload direction(0-front, 1-down, 2-top, 3-back):")
    UnloadDir = tonumber(read())
    print("Storage ID(blank for wooden chest):")
    local sid = read()
    if (sid ~="") then
        KAPI.SetStorageBlockID(sid)
    end

end
math.randomseed(os.time())
os.setComputerLabel("Yellow Snow Co. Minr " .. math.random(1, 1000))
KAPI.Init()
KAPI.Logger("Starting AmMinr with these settings:")
KAPI.Logger("length: " .. Length .. " width:" .. Width)
KAPI.Logger("depth: " .. Depth .. " offset_depth: " .. OffsetDepth)
if (DepthDir == 2) then
    KAPI.Logger("Depth is inverted")
else
    KAPI.Logger("Depth is NOT inverted")
end
KAPI.Logger("Unload direction is: " .. UnloadDir)
TurnCard = KAPI.SanitizeCard(KAPI.GetStartingCard() + FirstTurnCardArg)
KAPI.Logger("First turn will be in cardinal:" .. TurnCard .. "\n" .. "---------------------------------------")

print("HERE COMES THE MINER!")

MoveHardWrap(0)
if (OffsetDepth > 0) then
    MoveHardALotWrap(DepthDir, OffsetDepth)
end
if (OffsetX > 0) then
    KAPI.FaceCard(KAPI.GetStartingCard())
    MoveHardALotWrap(0, OffsetX)
end
if (OffsetZ > 0) then
    KAPI.FaceCard(FirstTurnCardArg)
    MoveHardALotWrap(0, OffsetZ)
    KAPI.FaceCard(KAPI.GetStartingCard())
end
if (Depth > 0) then
    for i = 1,Depth,1 do
        MoveHardWrap(DepthDir)
        Miner()
    end
    EndMiningHandler()
else
    while DoWork do
        MoveHardWrap(DepthDir)
        Miner()
    end
    EndMiningHandler()
end
