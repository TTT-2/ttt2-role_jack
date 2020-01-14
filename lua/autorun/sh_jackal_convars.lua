-- replicated convars have to be created on both client and server
CreateConVar("ttt_jackal_armor_value", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("ttt_jackal_spawn_siki_deeagle", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_jackal_convars", function(tbl)
	tbl[ROLE_JACKAL] = tbl[ROLE_JACKAL] or {}

	table.insert(tbl[ROLE_JACKAL], {cvar = "ttt_jackal_armor_value", slider = true, min = 0, max = 100, decimal = 0, desc = "ttt_jackal_armor_value (def. 30)"})
	table.insert(tbl[ROLE_JACKAL], {cvar = "ttt_jackal_spawn_siki_deagle", checkbox = true, desc = "ttt_jackal_spawn_siki_deagle (def. true)"})
end)
