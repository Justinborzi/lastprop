---
--- init.lua - Server Init Component
-----------------------------------------------------
--- init file for server
---

AddCSLuaFile('sh_init.lua')
AddCSLuaFile('cl_init.lua')

--
-- Include shared server init
--
include('sh_init.lua')

--
-- Include server base
--
include('base/sv/sv_init.lua')
