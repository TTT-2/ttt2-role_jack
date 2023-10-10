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

	self.defaultTeam = TEAM_JACKAL
	self.defaultEquipment = JACKAL_EQUIPMENT

	self.conVarData = {
		pct = 0.14,
		maximum = 1,
		minPlayers = 7,
		togglable = true,
		random = 50,
		credits = 3,
		creditsAwardDeadEnable = 1,
		creditsAwardKillEnable = 1
	}
end

-- init jackal fallback table
hook.Add("InitFallbackShops", "JackInitFallback", function()
	-- init fallback shop
	InitFallbackShop(JACKAL, table.Merge(JACKAL.fallbackTable, TRAITOR.fallbackTable)) -- merge jackal equipment with traitor equipment
end)

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

if CLIENT then
	function ROLE:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

		form:MakeSlider({
			serverConvar = "ttt_jackal_armor_value",
			label = "label_jackal_armor_value",
			min = 0,
			max = 100,
			decimal = 0
		})

		form:MakeCheckBox({
			serverConvar = "ttt_jackal_spawn_siki_deagle",
			label = "label_jackal_spawn_siki_deagle"
		})
	end
end
