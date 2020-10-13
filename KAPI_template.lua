if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

KAPI.setProgName("Template")
--KAPI.setStartingCard(0)
--KAPI.setMoveTimeout(10)
--KAPI.setStorageBlockID("minecraft:chest")

--[Constansts]--

--[Globals]--

--[Functions]--

--[Main]--

KAPI.init()
origin = KAPI.getOrigin()
print("origin: ", origin:tostring())
KAPI.goTo()
pos = KAPI.updateLastPos()
print("current: ", pos:tostring())
KAPI.goTo(origin)