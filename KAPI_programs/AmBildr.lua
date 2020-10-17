if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--
XLength = 0             -- size of area indicators
YLength = 0
ZLength = 0
YOffset = 0             -- offset from start
XOffset = 0
ZOffset = 0
YDirection = 2          -- 1 for down, 2 for up
XDirection = 3          -- 3 to work left of start, 1 to work right of start
StorageDirection = 3     -- (0-Front, 1-Down, 2-Up, 3-Back)
WallBlock = ""
FloorBlock = ""
CeilingBlock = ""
LightBlock = ""
--[Functions]--
function MoveHardWrap(dir)
    if not KAPI.moveHard(dir) then
        UnbreakableHandler()
    end
end

function MoveHardALotWrap(dir, amount)
    if not KAPI.moveHardALot(dir, amount) then
        UnbreakableHandler()
    end
end

function PlaceWrap(dir, isPlaceLight)   -- by default places wall on sides, floor below and ceiling above. If light toggle is true, will place light instead of wall
    if dir == 1 then
        if KAPI.changeTo(FloorBlock) then
            KAPI.place(dir)     --TODO replace with placeHARD
        else
            OutOfBlockHandler("floor")
        end
    elseif dir == 2 then
        if KAPI.changeTo(CeilingBlock) then
            KAPI.place(dir)
        else
            OutOfBlockHandler("ceiling")
        end
    elseif isPlaceLight then
        if KAPI.changeTo(LightBlock) then
            KAPI.place(dir)
        else
            OutOfBlockHandler("light")
        end
    else
        if KAPI.changeTo(WallBlock) then
            KAPI.place(dir)
        else
            OutOfBlockHandler("wall")
        end
    end
end

function OutOfBlockHandler(blockType)       --TODO unload maybe?
    KAPI.logger("\"Ran out of " .. blockType .. " blocks\"")
    local pos = KAPI.updateLastPos()

    if (pos.x == 0) then
        noGPSHandler()
    end
    local currCard = KAPI.getFacingCard()
    local originData = KAPI.getOrigin()

    if (originData[1] == 0) then
        noGPSHandler()
    end

    KAPI.goTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.take(StorageDirection)

    if not KAPI.changeTo(WallBlock) then
        KAPI.logger("\"ERROR: No wall blocks found after restock\"")
        KAPI.kill()
        error("\"ERROR: No wall blocks found after restock\"")
    end

    if not KAPI.changeTo(FloorBlock) then
        KAPI.logger("\"ERROR: No floor blocks found after restock\"")
        KAPI.kill()
        error("\"ERROR: No floor blocks found after restock\"")
    end

    if not KAPI.changeTo(CeilingBlock) then
        KAPI.logger("\"ERROR: No ceiling blocks found after restock\"")
        KAPI.kill()
        error("\"ERROR: No ceiling blocks found after restock\"")
    end

    if not KAPI.changeTo(LightBlock) then
        KAPI.logger("\"EXC: No light blocks found after restock\"")
        LightBlock = ""
    end

    MoveHardWrap(0)
    KAPI.goTo(pos)
    KAPI.faceCard(currCard)
end

function UnbreakableHandler()
    KAPI.logger("ERROR: Failed to break a block")
    KAPI.kill()
    error("Ran into an unbreakable block")

end

function NoGPSHandler()
    KAPI.logger("ERROR: Lost GPS signal")
    KAPI.kill()
    error("Lost GPS signal")
end

function RegisterBlocks()       -- sets building blocks from slots, if no ceiling block exists will use wall block and if no light block exists, no lights will be placed
    local wall = KAPI.getItemID(1)
    local floor = KAPI.getItemID(2)
    local ceiling = KAPI.getItemID(3)
    local light = KAPI.getItemID(4)

    if wall == "failed" then
        KAPI.logger("\n ERROR: No wall block found")
        error("No wall block found")
    end
    if floor == "failed" then
        KAPI.logger("\n ERROR: No floor block found")
        error("No floor block found")
    end

    if ceiling == "failed" then
        KAPI.logger("\n ERROR: No ceiling block found")
        error("No ceiling block found")
    end
    if light ~= "failed" then
        -- TODO add lighting functionality
        -- LightBlock = light
    end

    WallBlock = wall
    FloorBlock = floor
    CeilingBlock = ceiling
end

function Setup()
    print("Enter length of area:")
    XLength = tonumber(read())
    print("Enter width of area:")
    ZLength = tonumber(read())
    print("Enter height of area")
    YLength = tonumber(read())
    --[[print("Offset Y:")
    YOffset = tonumber(read())
    print("Offset X:")
    XOffset = tonumber(read())
    print("Offset Z:")
    ZOffset = tonumber(read())
    ]]
    print("Invert height (y/n):")
    if (read() == "y") then
        YDirection = 1
    end
    print("Direction of width(3 for left, 1 for right):")
    XDirection = tonumber(read())

    print("Please place the wall block in slot 1, floor block in slot 2, ceiling block in slot 3 and light block in slot 3(optional)")
    read()
    RegisterBlocks()
    print("Other settings?(y/n):")

    if (read() == "y") then
        print("Starting cardinal(0=South, 1=East, 2=North, 3=West):")
        local sCard = tonumber(read())
        KAPI.setStartingCard(sCard)
        print("Side of tool(left/right):")
        KAPI.setToolHand(read())
        print("Unload direction(0-front, 1-down, 2-top, 3-back):")
        StorageDirection = tonumber(read())
        print("Storage ID(blank for wooden chest):")
        local sid = read()
        if (sid ~="") then
            KAPI.setStorageBlockID(sid)
        end
    end

    KAPI.init()
    KAPI.logger("\n---------------------------------------\nAmBildr Settings:")
    KAPI.logger("Size of area        : " .. XLength .. ", " .. YLength .. ", " .. ZLength)
    KAPI.logger("Offset from start   : " .. XOffset .. ", " .. YOffset .. ", " .. ZOffset)
    KAPI.logger("Direction of X and Y: " .. XDirection .. " and " .. YDirection)
    KAPI.logger("Wall Block   : " .. WallBlock)
    KAPI.logger("Floor Block  : " .. FloorBlock)
    KAPI.logger("Ceiling Block: " .. CeilingBlock)
    KAPI.logger("Light Block  : " .. LightBlock .. "\n---------------------------------------")
end

function FloorCeilingCheck()
    return nil -- TODO
end

function CornerCheck()
    --TODO
end

function WallToSideCheck()
    --TODO
end

function DoCorner()
    MoveHardWrap(0)
    KAPI.faceCard(KAPI.getFacingCard() + XDirection)
    MoveHardWrap(0)
    KAPI.faceCard(KAPI.getFacingCard() - XDirection)
    PlaceWrap(0)
    KAPI.faceCard(KAPI.getFacingCard() + XDirection)
    MoveHardWrap(3)
    PlaceWrap(0)
    KAPI.faceCard(KAPI.getFacingCard() - XDirection)
    PlaceWrap(0)
    KAPI.faceCard(KAPI.getFacingCard() - XDirection)
end

function WalkAndPlace(length)
    for i = 1, length, 1 do
        MoveHardWrap(0)
        KAPI.faceCard(KAPI.getFacingCard() + XDirection)
        PlaceWrap(0)
        KAPI.faceCard(KAPI.getFacingCard() - XDirection)
    end
end

--[Main]--
print("Running AmBildr V2.0(Bulldozer)...")
print("The turtle should to be facing South by default.")
print("The turtle should have a vanilla wooden chest behind it.")
print("The pickaxe should be on the right side of the turtle.")

KAPI.setProgName("AmBildr")
math.randomseed(os.time())
os.setComputerLabel("Yellow Snow Co. Bildr " .. math.random(1, 1000))
Setup()
print("I came to build, build, build, build")

if (YOffset > 0) then   -- Move to the offset start position
    MoveHardALotWrap(YDirection, YOffset)
end
if (XOffset > 0) then
    KAPI.faceCard(KAPI.getStartingCard())
    MoveHardALotWrap(0, offsetX)
end
if (ZOffset > 0) then
    KAPI.faceCard(XDirection)
    MoveHardALotWrap(0, offsetZ)
    KAPI.faceCard(KAPI.getStartingCard())
end

MoveHardWrap(0) -- Move to starting position

for y = 1, YLength, 1 do    --TODO item check
    local fcCheck = FloorCeilingCheck()
    if fcCheck ~= nil then  --if y is at the start or at the end
        for x = 1, XLength, 1 do
            CornerCheck()
            for z = 3, ZLength, 1 do
                WallToSideCheck()
            end
            CornerCheck()
        end
    else    -- if y is inbetween its start and end
        local startCard = KAPI.getFacingCard()
        WalkAndPlace(ZLength-2)
        DoCorner()
        WalkAndPlace(XLength-2)
        DoCorner()
        WalkAndPlace(ZLength-2)
        DoCorner()
        WalkAndPlace(XLength-2)
        DoCorner()
        MoveHardWrap(YDirection)
        KAPI.faceCard(startCard)
    end
end

KAPI.kill()