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
	self.color = Color(100, 190, 205, 255)

	self.abbr = "jack" -- abbreviation
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.fallbackTable = {}

	if not GetConVar("ttt_jackal_spawn_siki_deagle"):GetBool() then
		table.insert(self.fallbackTable, {id = "weapon_ttt2_sidekickdeagle"})
	end

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
		if isRoleChange and WEPS.IsInstalled("weapon_ttt2_sidekickdeagle")
			and GetConVar("ttt_jackal_spawn_siki_deagle"):GetBool() then -- TODO: maybe give SiKi deagle on respawn if not used before
			ply:GiveEquipmentWeapon("weapon_ttt2_sidekickdeagle")
		end

		ply:GiveArmor(GetConVar("ttt_jackal_armor_value"):GetInt())
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		if WEPS.IsInstalled("weapon_ttt2_sidekickdeagle") then
			ply:StripWeapon("weapon_ttt2_sidekickdeagle")
		end

		ply:RemoveArmor(GetConVar("ttt_jackal_armor_value"):GetInt())
	end
end
