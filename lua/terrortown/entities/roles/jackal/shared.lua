if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_jack.vmt")
end

roles.InitCustomTeam(ROLE.name, {
	icon = "vgui/ttt/dynamic/roles/icon_jack",
	color = Color(100, 190, 205, 255)
})

function ROLE:PreInitialize()
	self.color = Color(100, 190, 205, 255)

	self.abbr = "jack"
	self.score.surviveBonusMultiplier = 0.5
	self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = 2
	self.score.teamKillsMultiplier = -16
	self.score.bodyFoundMuliplier = 0

	self.fallbackTable = {}

	if not GetConVar("ttt_jackal_spawn_siki_deagle"):GetBool() then
		table.insert(self.fallbackTable, {id = "weapon_ttt2_sidekickdeagle"})
	end

	-- will receive credits on kill like a traitor
	self.traitorCreditAward = true

	self.defaultTeam = TEAM_JACKAL
	self.defaultEquipment = JACKAL_EQUIPMENT

	self.conVarData = {
		pct = 0.14,
		maximum = 1,
		minPlayers = 7,
		credits = 3,
		togglable = true,
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
