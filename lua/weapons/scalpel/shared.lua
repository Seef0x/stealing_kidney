-- Seconds to pass until Pickpocketing is done (default: 10)
local PPConfig_Duration = 20

-- Minimum money that can be stolen from the player (default: 400)
local PPConfig_MoneyFrom = 500

-- Maximumum money that can be stolen from the player (default: 700)
local PPConfig_MoneyTo = 5000

-- Seconds to wait until next Pickpocketing (default: 60)
local PPConfig_Wait = 5

-- Distance able to be stolen from (default: 100)
local PPConfig_Distance = 100


-- Hold down to keep Pickpocketing (true or false) (default: false)
local PPConfig_Hold = false

if SERVER then
	
	AddCSLuaFile( "shared.lua" )
	
	util.AddNetworkString( "pickpocket_time" )
	
end

if CLIENT then
	
	SWEP.PrintName = "Scalpel"
	SWEP.Slot = 0
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "Skyyrize"
SWEP.Instructions = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model( "models/weapons/v_knife_t.mdl" ) 
SWEP.WorldModel = Model( "models/weapons/w_knife_t.mdl" )

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Stealing Kidney"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

//Initialize\\
function SWEP:Initialize()
	self:SetWeaponHoldType( "normal" )
end

if CLIENT then
	
	net.Receive( "pickpocket_time", function()
		local wep = net.ReadEntity()

		wep.IsPickpocketing = true
		wep.StartPick = CurTime()
		wep.EndPick = CurTime() + PPConfig_Duration
	end )
	
end

//Primary Attack\\
function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
	
	if self.IsPickpocketing then return end

	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	
	if not IsValid( e ) or not e:IsPlayer() or trace.HitPos:Distance( self.Owner:GetShootPos() ) > PPConfig_Distance then
		
		if CLIENT then
			self.Owner:PrintMessage( HUD_PRINTTALK, "Il n'y a personne en face de vous ! (Idiot)" )
		end
		
		return
		
	end

	if SERVER then
		
		self.IsPickpocketing = true
		self.StartPick = CurTime()
		
		net.Start( "pickpocket_time" )
		net.WriteEntity( self )
		net.Send(self.Owner)
		
		self.EndPick = CurTime() + PPConfig_Duration
		
	end
	
	self:SetWeaponHoldType( "pistol" )
	
	if CLIENT then
		
		self.Dots = self.Dots or ""
		
		timer.Create( "PickpocketDots", 0.5, 0, function()
			
			if not self:IsValid() then
				timer.Destroy( "PickpocketDots" )
				return
			end
			
			local len = string.len( self.Dots )
			local dots = { [0] = ".", [1] = "..", [2] = "...", [3] = "" }
			
			self.Dots = dots[len]
			
		end )
		
	end
	
end

//Holster\\
function SWEP:Holster()

	self.IsPickpocketing = false
	
	if CLIENT then
		timer.Destroy( "PickpocketDots" )
	end
	
	return true
end

//OnRemove\\
function SWEP:OnRemove()
	self:Holster()
end

//Pickpocket Succeed\\
function SWEP:Succeed()
	
	self.IsPickpocketing = false
	
	self:SetWeaponHoldType( "normal" )

	self.Weapon:SetNextPrimaryFire( CurTime() + PPConfig_Wait )
	
	local trace = self.Owner:GetEyeTrace()
	
	if CLIENT then
		timer.Destroy( "PickpocketDots" )
	end


	if SERVER then
		
	if (trace.Entity:GetNWInt("player_rein_amout") < 1) then
		rein = ents.Create( "rein_kidney" );
		rein:SetPos(trace.HitPos);
		rein:Spawn()
		rein:GetPhysicsObject():SetVelocity((rein:GetForward()*-16)+(rein:GetUp()*8));
		trace.Entity:Kill();
		trace.Entity:SetNWInt("player_rein_amout", 1);

		print("Rein Spawn");
	else 
		self.Owner:PrintMessage( HUD_PRINTTALK, "Il n'a plus de rein (Dommage)" )
	end;

		
	end
	
end

//Pickpocket Fail\\
function SWEP:Fail()
	
	self.IsPickpocketing = false
	
	self:SetWeaponHoldType( "normal" )
	
	if CLIENT then
		timer.Destroy( "PickpocketDots" )
	end
	
	if CLIENT then
		self.Owner:PrintMessage( HUD_PRINTTALK, "Charcutage interrompu ... (Dommage)" )
	end
	
end

//Think\\
function SWEP:Think()
	
	local ended = false
	
	if self.IsPickpocketing and self.EndPick then
		
		local trace = self.Owner:GetEyeTrace()
		
		if not IsValid( trace.Entity ) and not ended then
			ended = true
			self:Fail()
		end
		
		if trace.HitPos:Distance( self.Owner:GetShootPos() ) > PPConfig_Distance and not ended then
			ended = true
			self:Fail()
		end
		
		if PPConfig_Hold and not self.Owner:KeyDown( IN_ATTACK ) and not ended then
			ended = true
			self:Fail()
		end

		if self.EndPick <= CurTime() and not ended then
			ended = true
			self:Succeed()
		end
		
		
	end
	
end

//Draw HUD\\
function SWEP:DrawHUD()
	
	if self.IsPickpocketing and self.EndPick then
		
		self.Dots = self.Dots or ""
		
		local w = ScrW()
		local h = ScrH()
		local x, y, width, height = w / 2 - w / 10, h / 2 - 60, w / 5, h / 15
		
		draw.RoundedBox( 8, x, y, width, height, Color( 10, 10, 10, 120 ) )

		local time = self.EndPick - self.StartPick
		local curtime = CurTime() - self.StartPick
		local status = math.Clamp( curtime / time, 0, 1)
		local BarWidth = status * ( width - 16 )
		local cornerRadius = math.Min( 8, BarWidth / 3 * 2 - BarWidth / 3 * 2 % 2 )
		
		draw.RoundedBox( cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color( 255 - ( status * 255 ), 0 + ( status * 255 ), 0, 255 ) )

		draw.DrawNonParsedSimpleText( "Charcutage" .. self.Dots, "Trebuchet24", w / 2, y + height / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		
	end
	
end

//Secondary Attack\\
function SWEP:SecondaryAttack()
end
