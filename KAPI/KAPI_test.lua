if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--

--[Functions]--
---------------Epic Unit Test Framework---------------
function failHandler(testName, expected, actual)
    KAPI.kill()
    if actual ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected .. " recieved: " .. actual)
    else if expected ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected)
    end
        error("Failed Test: " .. testName)
    end
end

function passHandler(testName)
    print("Passed Test:" .. testName)
end

function assertEquals(testName, expected, actual)
    if expected == actual then
        passHandler(testName)
    else
        failHandler(testName, expected, actual)
    end
end

function assertNotNull(testName, actual)
    if nil ~= actual then
        passHandler(testName)
    else
        failHandler(testName,"not nil")
    end
end

function assertNull(testName, actual)
    if nil == actual then
        passHandler(testName)
    else
        failHandler(testName,"nil")
    end
end

function assertTrue(testName, actual)
    if actual then
        passHandler(testName)
    else
        failHandler(testName,"true")
    end
end

function assertFalse(testName, actual)
    if not actual then
        passHandler(testName)
    else
        failHandler(testName,"false")
    end
end

---------------Maths functions test---------------
function testCeilGPS() -- deprecated?
    --get pos,  
 end
 
 function testSanitizeCard()
    assertEquals("testSanitizeCard", 3, -1)
    assertEquals("testSanitizeCard", 2, -2)
    assertEquals("testSanitizeCard", 1, -3)
    assertEquals("testSanitizeCard", 0, -4)

    assertEquals("testSanitizeCard", 0, 4)
    assertEquals("testSanitizeCard", 1, 5)
    assertEquals("testSanitizeCard", 2, 6)
    assertEquals("testSanitizeCard", 3, 7)
 end
-------------------------------------------------
---------------Getter/Setter Tests---------------
function testSetGetProgName()
    KAPI.setProgName("KAPITEST")
    assertEquals("testSetGetProgName", "KAPITEST", KAPI.getProgName())
    KAPI.kill()
end

function testSetGetStartingCard()
    KAPI.setStartingCard(0)
    assertEquals("testSetGetStartingCard", 0, KAPI.getStartingCard())
    KAPI.kill()
end

function testSetGetFacingCard()
    KAPI.setFacingCard(0)
    assertEquals("testSetGetFacingCard", 0, KAPI.getFacingCard())
    KAPI.kill()
end

function testSetGetMoveTimeout()
    KAPI.setMoveTimeout(66)
    assertEquals("testSetGetMoveTimeout", 66, KAPI.getMoveTimeout())
    KAPI.kill()
end

function testSetGetToolHand()
    KAPI.setToolHand("poop")
    assertEquals("testSetGetToolHand", "poop", KAPI.getToolHand())
    KAPI.kill()
end

function testSetGetStorageBlockID()
    KAPI.setStorageBlockID("poop2")
    assertEquals("testSetGetStorageBlockID", "poop2", KAPI.getStorageBlockID())
    KAPI.kill()
end

function testSetGetState()
    KAPI.setState("poop3")
    assertEquals("testSetGetState", "poop3", KAPI.getState())
    KAPI.kill()
end

function testSetGetOriginVar()
    KAPI.setOriginVar(vector.new(1,2,3))
    local origvar = KAPI.getOriginVar()
    assertEquals("testSetGetOriginVar_X", 1, origvar.x)
    assertEquals("testSetGetOriginVar_Y", 2, origvar.y)
    assertEquals("testSetGetOriginVar_Z", 3, origvar.z)
    KAPI.kill()
end

-------------------------------------------------
---------------GPS/Init globals Tests---------------
function testInit()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    local log = fs.open("log/log_KAPITEST", "r")
    assertNotNull("testInit_log", log)
    log.close()
    local origin = fs.open("res/coords_origin", "r")
    assertNotNull("testInit_origin", origin)
    origin.close()
    assertNotNull("testInit_facing", KAPI.getFacingCard())
    KAPI.kill()
end

function testInitArgs()
    KAPI.init()
    assertEquals("testInitArgs_startingCard", 0, KAPI.getStartingCard())
    assertEquals("testInitArgs_toolHand", "right", KAPI.getToolHand())
    assertEquals("testInitArgs_storageBlockID", "minecraft:chest", KAPI.getStorageBlockID())
    assertEquals("testInitArgs_facingCard", KAPI.getStartingCard(), KAPI.getFacingCard())
    assertEquals("testInitArgs_progName", "KAPI", KAPI.getProgName())
    local kapiOrigin = KAPI.getOriginVar()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitArgs\nGPS Unavailable")
    end
    assertEquals("testInitArgs_origin_x", orig.x, kapiOrigin.x)
    assertEquals("testInitArgs_origin_y", orig.y, kapiOrigin.y)
    assertEquals("testInitArgs_origin_z", orig.z, kapiOrigin.z)
    assertEquals("testInitArgs_moveTimeout", 10, KAPI.getMoveTimeout())
    assertEquals("testInitArgs_State", false, KAPI.getState())
    KAPI.kill()
end

function testInitOrigWrite()
    KAPI.init()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitOrigWrite\nGPS Unavailable")
    end
    local file = fs.open("res/coords_origin", "r")
    assertEquals("testInitOrigWrite_x", orig.x, math.floor(file.readLine()))
    assertEquals("testInitOrigWrite_y", orig.y, math.floor(file.readLine()))
    assertEquals("testInitOrigWrite_z", orig.z, math.floor(file.readLine()))
    assertEquals("testInitOrigWrite_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.kill()
end

function loggerTest()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.logger("test message")
    local file = fs.open("log/log_KAPITEST", "r")
    assertEquals("loggerTest_line_1", "", file.readLine())
    assertTrue("loggerTest_line_2", string.find(file.readLine(), "initializing KAPI"))
    file.close()
    KAPI.kill()
end

function testGetOrigin()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.setOriginVar(vector.new(1,2,3))
    KAPI.setStartingCard(3)
    local kapiOrig = KAPI.getOrigin()
    assertEquals("testGetOrigin_X", 1, kapiOrig[1])
    assertEquals("testGetOrigin_Y", 2, kapiOrig[2])
    assertEquals("testGetOrigin_Z", 3, kapiOrig[3])
    assertEquals("testGetOrigin_Z", 3, kapiOrig[4])
    KAPI.kill()
end

function testGetOriginfromFile()
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
    local kapiOrig = KAPI.getOrigin()
    assertEquals("testGetOriginfromFile_X", 0, math.floor(kapiOrig[1]))
    assertEquals("testGetOriginfromFile_Y", 1, math.floor(kapiOrig[2]))
    assertEquals("testGetOriginfromFile_Z", 2, math.floor(kapiOrig[3]))
    assertEquals("testGetOriginfromFile_Card", 3, math.floor(kapiOrig[4]))
    KAPI.kill()
end

function testUpdateLastPos()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.setFacingCard(0)
    local pos = vector.new(gps.locate(10))
    if pos.x == nil then
        error("Failed Test: testUpdateLastPos\nGPS Unavailable")
    end
    local kapiPos = KAPI.updateLastPos()
    assertEquals("testUpdateLastPos_X", pos.x, kapiPos.x)
    assertEquals("testUpdateLastPos_Y", pos.y, kapiPos.y)
    assertEquals("testUpdateLastPos_Z", pos.z, kapiPos.z)
    local file = fs.open("res/coords_last_known", "r")
    assertEquals("testUpdateLastPos_x_read", pos.x, math.floor(file.readLine()))
    assertEquals("testUpdateLastPos_y_read", pos.y, math.floor(file.readLine()))
    assertEquals("testUpdateLastPos_z_read", pos.z, math.floor(file.readLine()))
    assertEquals("testUpdateLastPos_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.kill()
end

-------------------------------------------------
---------------Inventory Tests---------------

function testGetItemID()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place dirt in slot 16(bottom right)")
    read()
    assertEquals("testGetItemID_pass", "minecraft:dirt", KAPI.getItemID(16))
    assertEquals("testGetItemID_fail", "failed",KAPI.getItemID(6))
    KAPI.kill()
end

function testFindItem()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    assertEquals("testFindItem_pass", 16, KAPI.findItem("minecraft:dirt"))
    assertEquals("testFindItem_fail", 0, KAPI.findItem("nothingness"))
    KAPI.kill()
end

function testChangeTo()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    assertTrue("testChangeTo_pass", KAPI.changeTo("minecraft:dirt"))
    assertFalse("testChangeTo_fail", KAPI.changeTo("nothingness"))
    KAPI.kill()
end

function testCheckIfFull()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    assertTrue("testCheckIfFull", KAPI.checkIfFull)
    KAPI.kill()
end


-------------------------------------------------
---------------Basic Interactions Tests---------------
function testFaceCard()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.faceCard(1)
    print("Am I facing East (y/n)?")
    assertEquals("testFaceCard_east", "y", read())
    KAPI.faceCard(2)
    print("Am I facing North (y/n)?")
    assertEquals("testFaceCard_north", "y", read())
    KAPI.faceCard(3)
    print("Am I facing West (y/n)?")
    assertEquals("testFaceCard_west", "y", read())
    KAPI.faceCard(4)
    print("Am I facing South (y/n)?")
    assertEquals("testFaceCard_south", "y", read())
    KAPI.kill()

end

function testAttack()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place a chicken in all interaction directions")
    read()
    assertTrue("testAttack_pass_front", KAPI.attack(0))
    assertTrue("testAttack_pass_down", KAPI.attack(1))
    assertTrue("testAttack_pass_up", KAPI.attack(2))
    assertTrue("testAttack_pass_back", KAPI.attack(3))
    print("\"Remove\" the chickens please")
    read()
    assertFalse("testAttack_fail_front", KAPI.attack(0))
    assertFalse("testAttack_fail_down", KAPI.attack(1))
    assertFalse("testAttack_fail_up", KAPI.attack(2))
    assertFalse("testAttack_fail_back", KAPI.attack(3))
    KAPI.kill()
end

function testDig()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place dirt in all interactable directions")
    read()
    assertTrue("testDig_pass_front", KAPI.dig(0))
    assertTrue("testDig_pass_down", KAPI.dig(1))
    assertTrue("testDig_pass_up", KAPI.dig(2))
    assertTrue("testDig_pass_back", KAPI.dig(3))
    assertFalse("testDig_fail_front", KAPI.dig(0))
    assertFalse("testDig_fail_down", KAPI.dig(1))
    assertFalse("testDig_fail_up", KAPI.dig(2))
    assertFalse("testDig_fail_back", KAPI.dig(3))
    KAPI.kill()
end

function testPlace()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Put a 4 blocks of dirt and vanilla wooden planks in inv")
    read()
    KAPI.changeTo("minecraft:dirt")
    assertTrue("testPlace_pass_front", KAPI.place(0))
    assertTrue("testPlace_pass_down", KAPI.place(1))
    assertTrue("testPlace_pass_up", KAPI.place(2))
    assertTrue("testPlace_pass_back", KAPI.place(3))

    assertTrue("testPlace_skip_front", KAPI.place(0))
    assertTrue("testPlace_skip_down", KAPI.place(1))
    assertTrue("testPlace_skip_up", KAPI.place(2))
    assertTrue("testPlace_skip_back", KAPI.place(3))

    KAPI.changeTo("minecraft:oak_planks")
    assertTrue("testPlace_replace_front", KAPI.place(0))
    assertTrue("testPlace_replace_down", KAPI.place(1))
    assertTrue("testPlace_replace_up", KAPI.place(2))
    assertTrue("testPlace_replace_back", KAPI.place(3))

    KAPI.dig(0)
    KAPI.dig(1)
    KAPI.dig(2)
    KAPI.dig(3)
    KAPI.kill()
end

function testUnload()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place vanilla chest in all interactable directions.\nPut something in the inventory after every unload.")
    read()
    KAPI.unload(0)
    print("Did I unload front (y/n)?")
    assertEquals("testUnload_front", "y", read())
    print("Fill'er up!")
    read()
    KAPI.unload(1)
    print("Did I unload down (y/n)?")
    assertEquals("testUnload_down", "y", read())
    print("Fill'er up!")
    read()
    KAPI.unload(2)
    print("Did I unload up (y/n)?")
    assertEquals("testUnload_up", "y", read())
    print("Fill'er up!")
    read()
    KAPI.unload(3)
    print("Did I unload back (y/n)?")
    assertEquals("testUnload_back", "y", read())
end

-------------------------------------------------
---------------Movement Tests---------------
function testMoveSoft()
    --
end

function testMoveSoftALot()
    --
end

function testMoveHard()
    --
end

function testMoveHardALot()
    --
end

function testGoTo()
    --
end

--[Main]--

--Setters/Getters--
print("Place facing South")
read()
testSetGetProgName()
testSetGetStartingCard()
testSetGetFacingCard()
testSetGetMoveTimeout()
testSetGetToolHand()
testSetGetStorageBlockID()
testSetGetOriginVar()
testSetGetState()
--Init\GPS--
testInit()
testInitArgs()
testInitOrigWrite()
loggerTest()
testGetOrigin()
testGetOriginfromFile()
testUpdateLastPos()
--Inventory--
testGetItemID()
testFindItem()
testChangeTo()
testCheckIfFull()
--basic interactions--
testFaceCard()
testAttack()
testDig()
testPlace()