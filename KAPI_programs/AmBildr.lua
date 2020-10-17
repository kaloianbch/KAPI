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
FloorLevels = {1}
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
        else                    --TODO recovery bad when in middle of wall
            OutOfBlockHandler("floor", dir, isPlaceLight)
        end
    elseif dir == 2 then
        if KAPI.changeTo(CeilingBlock) then
            KAPI.place(dir)
        else
            OutOfBlockHandler("ceiling", dir, isPlaceLight)
        end
    elseif isPlaceLight then
        if KAPI.changeTo(LightBlock) then
            KAPI.place(dir)
        else
            OutOfBlockHandler("light", dir, isPlaceLight)
        end
    else
        if KAPI.changeTo(WallBlock) then
            KAPI.place(dir)
        else
            OutOfBlockHandler("wall", dir, isPlaceLight)
        end
    end
end

function OutOfBlockHandler(blockType, dir, isPlaceLight)       --TODO unload maybe?
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

    MoveHardALotWrap(0,2)
    KAPI.goTo(pos)
    KAPI.faceCard(currCard)
    PlaceWrap(dir, isPlaceLight)
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

function EndProgramHandler()
    local origin = KAPI.getOrigin()
    KAPI.goTo(vector.new(origin[1], origin[2], origin[3]))
    KAPI.unload(StorageDirection)
    KAPI.logger("*Building Completed, enjoy.")
    print("Building Completed, enjoy.")
    -- break in call loop
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

function Setup()    --TODO inverting Y
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
    KAPI.logger("Light Block  : " .. LightBlock)
    local floorStr = ""
    for key, val in pairs(FloorLevels) do
        if key == 1 then
            floorStr = floorStr .. val
        else
            floorStr = floorStr .. ", " .. val
        end
    end
    KAPI.logger("Floor Levels : " .. floorStr .. "\n---------------------------------------")
end

function DoSurface(dir, y) -- builds surface. 1 for floor, 2 for ceiling
    KAPI.logger("Starting work on surface at y: " .. y .. " in direction: " .. dir)
    local turnCard = XDirection
    for x = 1, XLength, 1 do
        PlaceWrap(dir)
        for z = 1, ZLength - 1, 1 do
            MoveHardWrap(0)
            PlaceWrap(dir)
        end
        if x ~= XLength then
            KAPI.faceCard(KAPI.getFacingCard() - turnCard)
            MoveHardWrap(0)
            KAPI.faceCard(KAPI.getFacingCard() - turnCard)
            turnCard = KAPI.sanitizeCard(turnCard - 2)
        end
    end
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
print("The turtle will start building 2 blocks ahead to allow for storage access.")
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

MoveHardALotWrap(0,2) -- Move to starting position
MoveHardWrap(KAPI.flipDirection(YDirection)) -- Move to starting position

for y = 1, YLength + 2, 1 do    --TODO item check
    local startCard = KAPI.getFacingCard()
    WalkAndPlace(ZLength-2)
    DoCorner()
    WalkAndPlace(XLength-2)
    DoCorner()
    WalkAndPlace(ZLength-2)
    DoCorner()
    WalkAndPlace(XLength-2)
    DoCorner()

    KAPI.faceCard(startCard)
    if(y == YLength + 2) then -- last surface(ceiling for now)
        MoveHardWrap(KAPI.flipDirection(YDirection))
        DoSurface(2, YLength)
        EndProgramHandler()
        break
    end

    MoveHardWrap(YDirection)
    for key, val in pairs(FloorLevels) do -- first and other surfaces
        if y == val then
            DoSurface(1, y)
            if XLength % 2 == 0 then
                KAPI.faceCard(KAPI.getStartingCard() + XDirection)
            else
                KAPI.faceCard(KAPI.getStartingCard() + 2)
            end
        end 
    end
end

KAPI.kill()