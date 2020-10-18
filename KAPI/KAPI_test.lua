if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--

--[Functions]--
---------------Epic Unit Test Framework---------------
function FailHandler(testName, expected, actual)
    KAPI.Kill()
    if actual ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected .. " recieved: " .. actual)
    else if expected ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected)
    end
        error("Failed Test: " .. testName)
    end
end

function PassHandler(testName)
    print("Passed Test:" .. testName)
end

function AssertEquals(testName, expected, actual)
    if expected == actual then
        PassHandler(testName)
    else
        FailHandler(testName, expected, actual)
    end
end

function AssertNotNull(testName, actual)
    if nil ~= actual then
        PassHandler(testName)
    else
        FailHandler(testName,"not nil")
    end
end

function AssertNull(testName, actual)
    if nil == actual then
        PassHandler(testName)
    else
        FailHandler(testName,"nil")
    end
end

function AssertTrue(testName, actual)
    if actual then
        PassHandler(testName)
    else
        FailHandler(testName,"true")
    end
end

function AssertFalse(testName, actual)
    if not actual then
        PassHandler(testName)
    else
        FailHandler(testName,"false")
    end
end

---------------Maths functions test---------------
function TestCeilGPS() -- deprecated?
    --get pos,  
 end
 
 function TestSanitizeCard()
    AssertEquals("testSanitizeCard_neg1", 3, KAPI.SanitizeCard(-1))
    AssertEquals("testSanitizeCard_neg2", 2, KAPI.SanitizeCard(-2))
    AssertEquals("testSanitizeCard_neg3", 1, KAPI.SanitizeCard(-3))
    AssertEquals("testSanitizeCard_neg4", 0, KAPI.SanitizeCard(-4))

    AssertEquals("testSanitizeCard_pos4", 0, KAPI.SanitizeCard(4))
    AssertEquals("testSanitizeCard_pos5", 1, KAPI.SanitizeCard(5))
    AssertEquals("testSanitizeCard_pos6", 2, KAPI.SanitizeCard(6))
    AssertEquals("testSanitizeCard_pos7", 3, KAPI.SanitizeCard(7))
 end
 
 function TestFlipDirection()
    AssertEquals("TestFlipDirection_front", 3, KAPI.FlipDirection(0))
    AssertEquals("TestFlipDirection_down", 2, KAPI.FlipDirection(1))
    AssertEquals("TestFlipDirection_up", 1, KAPI.FlipDirection(2))
    AssertEquals("TestFlipDirection_back", 0, KAPI.FlipDirection(3))
 end
-------------------------------------------------
---------------Getter/Setter Tests---------------
function TestSetGetProgName()
    KAPI.SetProgName("KAPITEST")
    AssertEquals("testSetGetProgName", "KAPITEST", KAPI.GetProgName())
    KAPI.Kill()
end

function TestSetGetStartingCard()
    KAPI.SetStartingCard(0)
    AssertEquals("testSetGetStartingCard", 0, KAPI.GetStartingCard())
    KAPI.Kill()
end

function TestSetGetFacingCard()
    KAPI.SetFacingCard(0)
    AssertEquals("testSetGetFacingCard", 0, KAPI.GetFacingCard())
    KAPI.Kill()
end

function TestSetGetMoveTimeout()
    KAPI.SetMoveTimeout(66)
    AssertEquals("testSetGetMoveTimeout", 66, KAPI.GetMoveTimeout())
    KAPI.Kill()
end

function TestSetGetToolHand()
    KAPI.SetToolHand("poop")
    AssertEquals("testSetGetToolHand", "poop", KAPI.GetToolHand())
    KAPI.Kill()
end

function TestSetGetStorageBlockID()
    KAPI.SetStorageBlockID("poop2")
    AssertEquals("testSetGetStorageBlockID", "poop2", KAPI.GetStorageBlockID())
    KAPI.Kill()
end

function TestSetGetState()
    KAPI.SetState("poop3")
    AssertEquals("testSetGetState", "poop3", KAPI.GetState())
    KAPI.Kill()
end

function TestSetGetOriginVar()
    KAPI.SetOriginVar(vector.new(1,2,3))
    local origvar = KAPI.GetOriginVar()
    AssertEquals("testSetGetOriginVar_X", 1, origvar.x)
    AssertEquals("testSetGetOriginVar_Y", 2, origvar.y)
    AssertEquals("testSetGetOriginVar_Z", 3, origvar.z)
    KAPI.Kill()
end

-------------------------------------------------
---------------GPS/Init globals Tests---------------
function TestInit()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    local log = fs.open("log/log_KAPITEST", "r")
    AssertNotNull("testInit_log", log)
    log.close()
    local origin = fs.open("res/coords_origin", "r")
    AssertNotNull("testInit_origin", origin)
    origin.close()
    AssertNotNull("testInit_facing", KAPI.GetFacingCard())
    KAPI.Kill()
end

function TestInitArgs()
    KAPI.Init()
    AssertEquals("testInitArgs_startingCard", 0, KAPI.GetStartingCard())
    AssertEquals("testInitArgs_toolHand", "right", KAPI.GetToolHand())
    AssertEquals("testInitArgs_storageBlockID", "minecraft:chest", KAPI.GetStorageBlockID())
    AssertEquals("testInitArgs_facingCard", KAPI.GetStartingCard(), KAPI.GetFacingCard())
    AssertEquals("testInitArgs_progName", "KAPI", KAPI.GetProgName())
    local kapiOrigin = KAPI.GetOriginVar()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitArgs\nGPS Unavailable")
    end
    AssertEquals("testInitArgs_origin_x", orig.x, kapiOrigin.x)
    AssertEquals("testInitArgs_origin_y", orig.y, kapiOrigin.y)
    AssertEquals("testInitArgs_origin_z", orig.z, kapiOrigin.z)
    AssertEquals("testInitArgs_moveTimeout", 10, KAPI.GetMoveTimeout())
    AssertEquals("testInitArgs_State", false, KAPI.GetState())
    KAPI.Kill()
end

function TestInitOrigWrite()
    KAPI.Init()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitOrigWrite\nGPS Unavailable")
    end
    local file = fs.open("res/coords_origin", "r")
    AssertEquals("testInitOrigWrite_x", orig.x, math.floor(file.readLine()))
    AssertEquals("testInitOrigWrite_y", orig.y, math.floor(file.readLine()))
    AssertEquals("testInitOrigWrite_z", orig.z, math.floor(file.readLine()))
    AssertEquals("testInitOrigWrite_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.Kill()
end

function TestLogger()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    KAPI.Logger("test message")
    local file = fs.open("log/log_KAPITEST", "r")
    AssertEquals("LoggerTest_line_1", "", file.readLine())
    file.readLine()
    file.readLine()
    AssertTrue("LoggerTest_line_2", string.find(file.readLine(), "Initializing KAPI"))
    file.close()
    KAPI.Kill()
end

function TestGetOrigin()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    KAPI.SetOriginVar(vector.new(1,2,3))
    KAPI.SetStartingCard(3)
    local kapiOrig = KAPI.GetOrigin()
    AssertEquals("testGetOrigin_X", 1, kapiOrig[1])
    AssertEquals("testGetOrigin_Y", 2, kapiOrig[2])
    AssertEquals("testGetOrigin_Z", 3, kapiOrig[3])
    AssertEquals("testGetOrigin_Z", 3, kapiOrig[4])
    KAPI.Kill()
end

function TestGetOriginfromFile()
    local file = fs.open("res/coords_origin", "w") 
    if (file == nil) then
        error("Failed Test: testGetOriginfromFile\nCould not write to res/coords_origin")
    else
        file.writeLine(0)
        file.writeLine(1)
        file.writeLine(2)
        file.writeLine(3)
    end
    file.close()
    local kapiOrig = KAPI.GetOrigin()
    AssertEquals("testGetOriginfromFile_X", 0, math.floor(kapiOrig[1]))
    AssertEquals("testGetOriginfromFile_Y", 1, math.floor(kapiOrig[2]))
    AssertEquals("testGetOriginfromFile_Z", 2, math.floor(kapiOrig[3]))
    AssertEquals("testGetOriginfromFile_Card", 3, math.floor(kapiOrig[4]))
    KAPI.Kill()
end

function TestUpdateLastPos()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    KAPI.SetFacingCard(0)
    local pos = vector.new(gps.locate(10))
    if pos.x == nil then
        error("Failed Test: testUpdateLastPos\nGPS Unavailable")
    end
    local kapiPos = KAPI.UpdateLastPos()
    AssertEquals("testUpdateLastPos_X", pos.x, kapiPos.x)
    AssertEquals("testUpdateLastPos_Y", pos.y, kapiPos.y)
    AssertEquals("testUpdateLastPos_Z", pos.z, kapiPos.z)
    local file = fs.open("res/coords_last_known", "r")
    AssertEquals("testUpdateLastPos_x_read", pos.x, math.floor(file.readLine()))
    AssertEquals("testUpdateLastPos_y_read", pos.y, math.floor(file.readLine()))
    AssertEquals("testUpdateLastPos_z_read", pos.z, math.floor(file.readLine()))
    AssertEquals("testUpdateLastPos_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.Kill()
end

-------------------------------------------------
---------------Inventory Tests---------------

function TestGetItemID()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place dirt in slot 16(bottom right)")
    read()
    AssertEquals("testGetItemID_pass", "minecraft:dirt", KAPI.GetItemID(16))
    AssertEquals("testGetItemID_fail", "failed",KAPI.GetItemID(6))
    KAPI.Kill()
end

function TestFindItem()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    AssertEquals("testFindItem_pass", 16, KAPI.FindItem("minecraft:dirt"))
    AssertEquals("testFindItem_fail", 0, KAPI.FindItem("nothingness"))
    KAPI.Kill()
end

function TestChangeTo()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    AssertTrue("testChangeTo_pass", KAPI.ChangeTo("minecraft:dirt"))
    AssertTrue("testChangeTo_repeat", KAPI.ChangeTo("minecraft:dirt"))
    AssertFalse("testChangeTo_fail", KAPI.ChangeTo("nothingness"))
    KAPI.Kill()
end

function TestCheckIfFull()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    AssertTrue("testCheckIfFull", KAPI.CheckIfFull)
    KAPI.Kill()
end


-------------------------------------------------
---------------Basic Interactions Tests---------------
function TestFaceCard()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    KAPI.FaceCard(1)
    print("Am I facing East (y/n)?")
    AssertEquals("testFaceCard_east", "y", read())
    KAPI.FaceCard(2)
    print("Am I facing North (y/n)?")
    AssertEquals("testFaceCard_north", "y", read())
    KAPI.FaceCard(3)
    print("Am I facing West (y/n)?")
    AssertEquals("testFaceCard_west", "y", read())
    KAPI.FaceCard(4)
    print("Am I facing South (y/n)?")
    AssertEquals("testFaceCard_south", "y", read())
    KAPI.Kill()

end

function TestAttack()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place a chicken in all interaction directions")
    read()
    AssertTrue("testAttack_pass_front", KAPI.Attack(0))
    AssertTrue("testAttack_pass_down", KAPI.Attack(1))
    AssertTrue("testAttack_pass_up", KAPI.Attack(2))
    AssertTrue("testAttack_pass_back", KAPI.Attack(3))
    print("\"Remove\" the chickens please")
    read()
    AssertFalse("testAttack_fail_front", KAPI.Attack(0))
    AssertFalse("testAttack_fail_down", KAPI.Attack(1))
    AssertFalse("testAttack_fail_up", KAPI.Attack(2))
    AssertFalse("testAttack_fail_back", KAPI.Attack(3))
    KAPI.Kill()
end

function TestDig()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place dirt in all interactable directions")
    read()
    AssertTrue("testDig_pass_front", KAPI.Dig(0))
    AssertTrue("testDig_pass_down", KAPI.Dig(1))
    AssertTrue("testDig_pass_up", KAPI.Dig(2))
    AssertTrue("testDig_pass_back", KAPI.Dig(3))
    AssertFalse("testDig_fail_front", KAPI.Dig(0))
    AssertFalse("testDig_fail_down", KAPI.Dig(1))
    AssertFalse("testDig_fail_up", KAPI.Dig(2))
    AssertFalse("testDig_fail_back", KAPI.Dig(3))
    KAPI.Kill()
end

function TestPlace()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Put a 4 blocks of dirt and vanilla wooden planks in inv")
    read()
    KAPI.ChangeTo("minecraft:dirt")
    AssertTrue("testPlace_pass_front", KAPI.Place(0))
    AssertTrue("testPlace_pass_down", KAPI.Place(1))
    AssertTrue("testPlace_pass_up", KAPI.Place(2))
    AssertTrue("testPlace_pass_back", KAPI.Place(3))

    AssertTrue("testPlace_skip_front", KAPI.Place(0))
    AssertTrue("testPlace_skip_down", KAPI.Place(1))
    AssertTrue("testPlace_skip_up", KAPI.Place(2))
    AssertTrue("testPlace_skip_back", KAPI.Place(3))

    KAPI.ChangeTo("minecraft:oak_planks")
    AssertTrue("testPlace_rePlace_front", KAPI.Place(0))
    AssertTrue("testPlace_rePlace_down", KAPI.Place(1))
    AssertTrue("testPlace_rePlace_up", KAPI.Place(2))
    AssertTrue("testPlace_rePlace_back", KAPI.Place(3))

    KAPI.Dig(0)
    KAPI.Dig(1)
    KAPI.Dig(2)
    KAPI.Dig(3)
    KAPI.Kill()
end

function TestUnload()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place vanilla chest in all interactable directions.\nPut something in the inventory after every Unload.")
    read()
    KAPI.Unload(0)
    print("Did I Unload front (y/n)?")
    AssertEquals("testUnload_front", "y", read())
    print("Fill'er up!")
    read()
    KAPI.Unload(1)
    print("Did I Unload down (y/n)?")
    AssertEquals("testUnload_down", "y", read())
    print("Fill'er up!")
    read()
    KAPI.Unload(2)
    print("Did I Unload up (y/n)?")
    AssertEquals("testUnload_up", "y", read())
    print("Fill'er up!")
    read()
    KAPI.Unload(3)
    print("Did I Unload back (y/n)?")
    AssertEquals("testUnload_back", "y", read())

    KAPI.Kill()
end

function TestTake()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place vanilla chest in all interactable directions.\nPut at least a stack in each chests.")
    KAPI.Take(0)
    print("Did I Take from front (y/n)?")
    AssertEquals("TestTake_front", "y", read())
    KAPI.Take(1)
    print("Did I Take from down (y/n)?")
    AssertEquals("TestTake_down", "y", read())
    KAPI.Take(2)
    print("Did I Take from up (y/n)?")
    AssertEquals("TestTake_up", "y", read())
    KAPI.Take(3)
    print("Did I Take from back (y/n)?")
    AssertEquals("TestTake_back", "y", read())

    KAPI.Dig(0)
    KAPI.Dig(1)
    KAPI.Dig(2)
    KAPI.Dig(3)
    KAPI.Kill()
end

-------------------------------------------------
---------------Movement Tests---------------
function TestMoveSoft()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Remove blocks above and in front of turtle")
    read()
    AssertTrue("testMoveSoft_forwards_pass", KAPI.MoveSoft(0))
    AssertTrue("testMoveSoft_backwards_pass", KAPI.MoveSoft(3))
    AssertTrue("testMoveSoft_up_pass", KAPI.MoveSoft(2))
    AssertTrue("testMoveSoft_down_pass", KAPI.MoveSoft(1))
    print("Place blocks in all movable directions")
    read()
    AssertFalse("testMoveSoft_forwards_fail", KAPI.MoveSoft(0))
    AssertFalse("testMoveSoft_backwards_fail", KAPI.MoveSoft(3))
    AssertFalse("testMoveSoft_up_fail", KAPI.MoveSoft(2))
    AssertFalse("testMoveSoft_down_fail", KAPI.MoveSoft(1))
end

function TestMoveSoftALot()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Remove blocks above and in front of turtle")
    read()
    AssertTrue("testMoveSoftALot_forwards_pass", KAPI.MoveSoftALot(0,2))
    AssertTrue("testMoveSoftALot_backwards_pass", KAPI.MoveSoftALot(3,2))
    AssertTrue("testMoveSoftALot_up_pass", KAPI.MoveSoftALot(2,2))
    AssertTrue("testMoveSoftALot_down_pass", KAPI.MoveSoftALot(1,2))
    print("Place blocks in all movable directions with a gap of 1 in front and above")
    read()
    AssertFalse("testMoveSoftALot_forwards_fail", KAPI.MoveSoftALot(0,2))
    AssertFalse("testMoveSoftALot_backwards_fail", KAPI.MoveSoftALot(3,2))
    AssertFalse("testMoveSoftALot_up_fail", KAPI.MoveSoftALot(2,2))
    AssertFalse("testMoveSoftALot_down_fail", KAPI.MoveSoftALot(1,2))
end

function TestMoveHard()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place blocks above and in front of turtle")
    read()
    AssertTrue("testMoveHard_forwards_pass", KAPI.MoveHard(0))
    AssertTrue("testMoveHard_backwards_pass", KAPI.MoveHard(3))
    AssertTrue("testMoveHard_up_pass", KAPI.MoveHard(2))
    AssertTrue("testMoveHard_down_pass", KAPI.MoveHard(1))
    print("Place bedrock in all movable directions")
    read()
    AssertFalse("testMoveHard_forwards_fail", KAPI.MoveHard(0))
    AssertFalse("testMoveHard_backwards_fail", KAPI.MoveHard(3))
    AssertFalse("testMoveHard_up_fail", KAPI.MoveHard(2))
    AssertFalse("testMoveHard_down_fail", KAPI.MoveHard(1))
    KAPI.Kill()
end

function TestMoveHardALot()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    print("Place blocks above and in front of turtle + 1")
    read()
    AssertTrue("testMoveHardALot_forwards_pass", KAPI.MoveHardALot(0,2))
    AssertTrue("testMoveHardALot_backwards_pass", KAPI.MoveHardALot(3,2))
    AssertTrue("testMoveHardALot_up_pass", KAPI.MoveHardALot(2,2))
    AssertTrue("testMoveHardALot_down_pass", KAPI.MoveHardALot(1,2))
    print("Place Bedrock in all movable directions with a gap of 1 in front and above")
    read()
    AssertFalse("testMoveHardALot_forwards_fail", KAPI.MoveHardALot(0,2))
    AssertFalse("testMoveHardALot_backwards_fail", KAPI.MoveHardALot(3,2))
    AssertFalse("testMoveHardALot_up_fail", KAPI.MoveHardALot(2,2))
    AssertFalse("testMoveHardALot_down_fail", KAPI.MoveHardALot(1,2))
end

function TestGoTo()
    KAPI.SetProgName("KAPITEST")
    KAPI.Init()
    local goPos = KAPI.UpdateLastPos()
    goPos= vector.new(goPos.x + 2, goPos.y + 2, goPos.z + 2)
    print("Turtle will go +2 in all directions\nGoing to: ".. goPos.x .. ', ' .. goPos.y .. ', ' .. goPos.z)
    read()
    KAPI.GoTo(goPos)
    print("Did I go +2 and am I facing the same direction? (y/n)")
    AssertEquals("testGoTo_positive", "y", read())

    goPos = vector.new(goPos.x - 2, goPos.y - 2, goPos.z - 2)
    print("Turtle will go -2 in all directions\nGoing to: ".. goPos.x .. ', ' .. goPos.y .. ', ' .. goPos.z)
    read()
    KAPI.GoTo(goPos)
    print("Did I go -2(starting position) and am I facing the same direction? (y/n)")
    AssertEquals("testGoTo_negative", "y", read())
    KAPI.Kill()
end

--TODO - GoTo recovery test

--[Main]--
--!!Do not skip the first 3 sections when writing new tests!!--
print("Place facing South")
read()
--Maths--
TestSanitizeCard()
TestFlipDirection()
--Setters/Getters--
TestSetGetProgName()
TestSetGetStartingCard()
TestSetGetFacingCard()
TestSetGetMoveTimeout()
TestSetGetToolHand()
TestSetGetStorageBlockID()
TestSetGetOriginVar()
TestSetGetState()
--Init\GPS--
TestInit()
TestInitArgs()
TestInitOrigWrite()
TestLogger()
TestGetOrigin()
TestGetOriginfromFile()
TestUpdateLastPos()
--Inventory--
TestGetItemID()
TestFindItem()
TestChangeTo()
TestCheckIfFull()
--Basic Interactions--
TestFaceCard()
TestAttack()
TestDig()
TestPlace()
TestUnload()
TestTake()
--Movements--
TestMoveSoft()
TestMoveSoftALot()
TestMoveHard()
TestMoveHardALot()
TestGoTo()