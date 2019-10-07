if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_jack.vmt")
end

-- creates global var "TEAM_JACKAL" and other required things
-- TEAM_[name], data: e.g. icon, color, ...
roles.InitCustomTeam(ROLE.name, { -- this creates the var "TEAM_JACKAL"
	icon = "vgui/ttt/dynamic/roles/icon_jack",
	color = Color(100, 190, 205, 255)
})

function ROLE:PreInitialize()
	self.color = Color(100, 190, 205, 255) -- ...
	self.dkcolor = Color(36, 134, 152, 255) -- ...
	self.bgcolor = Color(255, 188, 121, 255) -- ...
	self.abbr = "jack" -- abbreviation
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.fallbackTable = {}
	self.traitorCreditAward = true -- will receive credits on kill like a traitor
	
	self.defaultTeam = TEAM_JACKAL -- the team name: roles with same team name are working together
	self.defaultEquipment = JACKAL_EQUIPMENT -- here you can set up your own default equipment
	
	self.conVarData = {
		pct = 0.14, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 7, -- minimum amount of players until this role is able to get selected
		credits = 3, -- the starting credits of a specific role
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 50
	}
end

-- init jackal fallback table
hook.Add("InitFallbackShops", "JackInitFallback", function()
	-- init fallback shop
	InitFallbackShop(JACKAL, table.Merge(JACKAL.fallbackTable, TRAITOR.fallbackTable)) -- merge jackal equipment with traitor equipment
end)

function ROLE:Initialize()
	if SERVER and JESTER then
		-- add a easy role filtering to receive all jesters
		-- but just do it, when the role was created, then update it with recommended function
		-- theoretically this function is not necessary to call, but maybe there are some modifications
		-- of other addons. So it's better to use this function
		-- because it calls hooks and is doing some networking
		self.networkRoles = {JESTER}
	end

	if CLIENT then
		-- Role specific language elements
		LANG.AddToLanguage("English", self.name, "Jackal")
		LANG.AddToLanguage("English", self.defaultTeam, "TEAM Jackal")
		LANG.AddToLanguage("English", "info_popup_" .. self.name, [[You are the Jackal! Try to kill everyone but you! Make use of your sidekick deagle to shoot yourself a partner in crime.]])
		LANG.AddToLanguage("English", "body_found_" .. self.abbr, "They were a Jackal!")
		LANG.AddToLanguage("English", "search_role_" .. self.abbr, "This person was a Jackal!")
		LANG.AddToLanguage("English", "target_" .. self.name, "Jackal")
		LANG.AddToLanguage("English", "ttt2_desc_" .. self.name, [[The Jackal needs to win alone or with his sidekick!]])
		LANG.AddToLanguage("English", "hilite_win_" .. self.defaultTeam, "THE JACK WON")
		LANG.AddToLanguage("English", "win_" .. self.defaultTeam, "The Jackal has won!")
		LANG.AddToLanguage("English", "ev_win_" .. self.defaultTeam, "The evil Jackal won the round!")
		LANG.AddToLanguage("English", "credit_" .. self.abbr .. "_all", "Jackals, you have been awarded {num} equipment credit(s) for your performance.")

		LANG.AddToLanguage("Deutsch", self.name, "Schackal")
		LANG.AddToLanguage("Deutsch", self.defaultTeam, "TEAM Schackal")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. self.name, [[Du bist ein Schackal! Versuche jeden anderen Spieler zu töten! Nutze deine Sidekickdeagle, um dir einen Komplizen zu schießen.]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. self.abbr, "Er war ein Schackal!")
		LANG.AddToLanguage("Deutsch", "search_role_" .. self.abbr, "Diese Person war ein Schackal!")
		LANG.AddToLanguage("Deutsch", "target_" .. self.name, "Schackal")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. self.name, [[Der Schackal muss alleine oder mit seinem Sidekick gewinnen!]])
		LANG.AddToLanguage("Deutsch", "hilite_win_" .. self.defaultTeam, "THE JACK WON")
		LANG.AddToLanguage("Deutsch", "win_" .. self.defaultTeam, "Der Schackal hat gewonnen!")
		LANG.AddToLanguage("Deutsch", "ev_win_" .. self.defaultTeam, "Der böse Schackal hat die Runde gewonnen!")
		LANG.AddToLanguage("Deutsch", "credit_" .. self.abbr .. "_all", "Schackale, euch wurden {num} Ausrüstungs-Credit(s) für eure Leistung gegeben.")
	end
end

if SERVER then	
	-- modify roles table of rolesetup addon
	hook.Add("TTTAModifyRolesTable", "ModifyRoleJackToInno", function(rolesTable)
		local jackals = rolesTable[ROLE_JACKAL]

		if not jackals then return end

		rolesTable[ROLE_INNOCENT] = rolesTable[ROLE_INNOCENT] + jackals
		rolesTable[ROLE_JACKAL] = 0
	end)

	-- Give Loadout on respawn and rolechange	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if isRoleChange then -- TODO: maybe give SiKi deagle on respawn if not used before
			ply:GiveEquipmentWeapon("weapon_ttt2_sidekickdeagle")
		end
		ply:GiveEquipmentItem("item_ttt_armor")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:StripWeapon("weapon_ttt2_sidekickdeagle")
		ply:RemoveEquipmentItem("item_ttt_armor")
	end
end
