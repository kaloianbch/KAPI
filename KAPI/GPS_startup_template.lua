-- change label name and position(remember y is -1 when standing on top of PC)
-- the name of this file has to be "startup"
-- guide for building the structure:
-- (http://www.computercraft.info/forums2/index.php?/topic/3088-how-to-guide-gps-global-position-system/)
shell.run("label","set","CHANGE")
shell.run("gps", "host", "X","Y","Z")