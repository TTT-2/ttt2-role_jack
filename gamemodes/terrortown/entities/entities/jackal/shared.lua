if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/icon_jack.vmt")
    resource.AddFile("materials/vgui/ttt/sprite_jack.vmt")
end

JACKAL_EQUIPMENT = {
    "weapon_ttt_flaregun",
    "weapon_ttt_knife",
    "weapon_ttt_phammer",
    "weapon_ttt_push",
    "weapon_ttt_sipistol",
    "weapon_ttt_decoy",
    "weapon_ttt2_sidekickdeagle",
    EQUIP_ARMOR,
    EQUIP_DISGUISE
}

hook.Add("Initialize", "TTT2InitCRoleJack", function()
	-- important to add roles with this function,
	-- because it does more than just access the array ! e.g. updating other arrays
	AddCustomRole("JACKAL", { -- first param is access for ROLES array => ROLES["JACKAL"] or ROLES["JESTER"]
		color = Color(59, 215, 222, 255), -- ...
		dkcolor = Color(59, 215, 222, 255), -- ...
		bgcolor = Color(59, 215, 222, 200), -- ...
		name = "jackal", -- just a unique name for the script to determine
		abbr = "jack", -- abbreviation
		team = "jacks", -- the team name: roles with same team name are working together
		defaultEquipment = JACKAL_EQUIPMENT, -- here you can set up your own default equipment
		surviveBonus = 0, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 1, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -8, -- multiplier for teamkill
		fallbackTable = {},
		traitorCreditAward = true -- will receive credits on kill like a traitor
	}, {
		pct = 0.14, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 7, -- minimum amount of players until this role is able to get selected
		credits = 3, -- the starting credits of a specific role
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 50
	})
end)

-- init jackal fallback table
hook.Add("InitFallbackShops", "JackInitFallback", function()
	-- init fallback shop
	InitFallbackShop(ROLES.JACKAL, table.Merge(ROLES.JACKAL.fallbackTable, ROLES.TRAITOR.fallbackTable)) -- merge jackal equipment with traitor equipment
end)

-- if sync of roles has finished
if CLIENT then
	hook.Add("TTT2_FinishedSync", "JackInitT", function(ply, first)
		if first then -- just on client and first init !
			-- setup here is not necessary but if you want to access the role data, you need to start here
			-- setup basic translation !
			LANG.AddToLanguage("English", ROLES.JACKAL.name, "Jackal")
			LANG.AddToLanguage("English", "info_popup_" .. ROLES.JACKAL.name, 
				[[You are the Jackal! 
				Try to kill each other role! It's hard, so maybe you need a Sidekick...]])
			LANG.AddToLanguage("English", "body_found_" .. ROLES.JACKAL.abbr, "This was a Jackal...")
			LANG.AddToLanguage("English", "search_role_" .. ROLES.JACKAL.abbr, "This person was a Jackal!")
			LANG.AddToLanguage("English", "target_" .. ROLES.JACKAL.name, "Jackal")
			LANG.AddToLanguage("English", "ttt2_desc_" .. ROLES.JACKAL.name, [[The Jackal needs to win alone or with his sidekick!]])
			LANG.AddToLanguage("English", "hilite_win_" .. ROLES.JACKAL.name, "THE JACK WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.SERIALKILLER.team)[1].name
			LANG.AddToLanguage("English", "win_" .. ROLES.JACKAL.team, "The Jackal has won!") -- teamname
			LANG.AddToLanguage("English", "ev_win_" .. ROLES.JACKAL.abbr, "The evil Jackal won the round!")
			LANG.AddToLanguage("English", "credit_" .. ROLES.JACKAL.abbr .. "_all", "Jackals, you have been awarded {num} equipment credit(s) for your performance.")
			
			-- optional for toggling whether player can avoid the role
			LANG.AddToLanguage("English", "set_avoid_" .. ROLES.JACKAL.abbr, "Avoid being selected as Jackal!")
			LANG.AddToLanguage("English", "set_avoid_" .. ROLES.JACKAL.abbr .. "_tip", 
				[[Enable this to ask the server not to select you as Jackal if possible. Does not mean you are Traitor more often.]])
			
			---------------------------------

			-- maybe this language as well...
			LANG.AddToLanguage("Deutsch", ROLES.JACKAL.name, "Jackal")
			LANG.AddToLanguage("Deutsch", "info_popup_" .. ROLES.JACKAL.name, 
				[[Du bist ein Jackal! 
				Versuche jede andere Rolle zu töten! Es ist schwer, also brauchst du vielleicht einen Sidekick]])
			LANG.AddToLanguage("Deutsch", "body_found_" .. ROLES.JACKAL.abbr, "Er war ein Jackal...")
			LANG.AddToLanguage("Deutsch", "search_role_" .. ROLES.JACKAL.abbr, "Diese Person war ein Jackal!")
			LANG.AddToLanguage("Deutsch", "target_" .. ROLES.JACKAL.name, "Jackal")
			LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. ROLES.JACKAL.name, [[Der Jackal muss alleine oder mit seinem Sidekick gewinnen!]])
			LANG.AddToLanguage("Deutsch", "hilite_win_" .. ROLES.JACKAL.name, "THE JACK WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.SERIALKILLER.team)[1].name
			LANG.AddToLanguage("Deutsch", "win_" .. ROLES.JACKAL.team, "Der Jackal hat gewonnen!") -- teamname
			LANG.AddToLanguage("Deutsch", "ev_win_" .. ROLES.JACKAL.abbr, "Der böse Jackal hat die Runde gewonnen!")
			LANG.AddToLanguage("Deutsch", "credit_" .. ROLES.JACKAL.abbr .. "_all", "Jackale, euch wurde(n) {num} Ausrüstungs-Credit(s) für eure Leistung gegeben.")
			
			LANG.AddToLanguage("Deutsch", "set_avoid_" .. ROLES.JACKAL.abbr, "Vermeide als Jackal ausgewählt zu werden!")
			LANG.AddToLanguage("Deutsch", "set_avoid_" .. ROLES.JACKAL.abbr .. "_tip", 
				[[Aktivieren, um beim Server anzufragen, nicht als Jackal ausgewählt zu werden. Das bedeuted nicht, dass du öfter Traitor wirst!]])
		end
	end)
else
	-- modify roles table of rolesetup addon
	hook.Add("TTTAModifyRolesTable", "ModifyRoleJackToInno", function(rolesTable)
		local jackals = rolesTable[ROLES.JACKAL.index]
		
		if not jackals then return end
		
		rolesTable[ROLES.INNOCENT.index] = rolesTable[ROLES.INNOCENT.index] + jackals
	end)
end
