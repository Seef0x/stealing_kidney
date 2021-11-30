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

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IronsightsPredicted")
    self:NetworkVar("Float", 0, "IronsightsTime")
    self:NetworkVar("Bool", 1, "Reloading")
    self:NetworkVar("Float", 1, "LastPrimaryAttack")
    self:NetworkVar("Float", 2, "ReloadEndTime")
    self:NetworkVar("Float", 3, "BurstTime")
    self:NetworkVar("Int", 0, "BurstBulletNum")
    self:NetworkVar("Int", 1, "TotalUsedMagCount")
    self:NetworkVar("String", 0, "FireMode")
    self:NetworkVar("Entity", 0, "LastOwner")
    
	self:NetworkVar( "Entity", 1, "Target" )
    self:NetworkVar( "Int", 2, "StartPick" )
    self:NetworkVar( "Int", 3, "EndPick" )
end

//Initialize\\
function SWEP:Initialize()
	self:SetWeaponHoldType( "normal" )
end

//Primary Attack\\
function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
	
	if IsValid( self:GetTarget() ) then return end

	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	
	if not IsValid( e ) or not e:IsPlayer() or trace.HitPos:Distance( self.Owner:GetShootPos() ) > PPConfig_Distance then
		
		if CLIENT then
			self.Owner:PrintMessage( HUD_PRINTTALK, "Il n'y a personne en face de vous ! (Idiot)" )
		end
		
		return
		
	end

	if SERVER then

        local curtime = CurTime()

        self:SetTarget(e)
        self:SetStartPick(curtime)
        self:SetEndPick(curtime + PPConfig_Duration)
		
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

    self:SetTarget()
	
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
	
	self:SetWeaponHoldType( "normal" )

	self.Weapon:SetNextPrimaryFire( CurTime() + PPConfig_Wait )
	
	if CLIENT then
		timer.Destroy( "PickpocketDots" )
	end
    
	if SERVER then

        local target = self:GetTarget()
		
        if IsValid( target ) and target:Alive() and target:GetNWInt( "player_rein_amout" ) < 1 then
            target:Kill();
            target:SetNWInt("player_rein_amout", 1);
            
            local rein = ents.Create( "rein_kidney" );
            rein:SetPos( self.Owner:GetEyeTrace().HitPos );
            rein:Spawn()
            rein:GetPhysicsObject():SetVelocity( ( rein:GetForward() * -16 ) + ( rein:GetUp() * 8 ) );
        else 
            self.Owner:PrintMessage( HUD_PRINTTALK, "Il n'a plus de rein (Dommage)" )
        end;
        
	end
	
    self:SetTarget()
end

//Pickpocket Fail\\
function SWEP:Fail()
	
    self:SetTarget()
	
	self:SetWeaponHoldType( "normal" )
	
	if CLIENT then
		timer.Destroy( "PickpocketDots" )
        self.Owner:PrintMessage( HUD_PRINTTALK, "Charcutage interrompu ... (Dommage)" )
	end
	
end

//Think\\
function SWEP:Think()
	
	local ended = false
    local target = self:GetTarget()
    local endPick = self:GetEndPick()

    if target ~= Entity( -1 ) and endPick then
        if (not IsValid( target )
            or self.Owner:GetEyeTrace().Entity ~= target
            or target:GetPos():Distance( self.Owner:GetShootPos() ) > PPConfig_Distance
            or (PPConfig_Hold and not self.Owner:KeyDown( IN_ATTACK )))
        and not ended then
            ended = true
			self:Fail()
            return
        end

        if endPick <= CurTime() and not ended then
			ended = true
			self:Succeed()
		end
    end
	
end

//Draw HUD\\
function SWEP:DrawHUD()

    local startPick, endPick = self:GetStartPick(), self:GetEndPick()
	
	if IsValid( self:GetTarget() ) and endPick then
		
		self.Dots = self.Dots or ""
		
		local w = ScrW()
		local h = ScrH()
		local x, y, width, height = w / 2 - w / 10, h / 2 - 60, w / 5, h / 15
		
		draw.RoundedBox( 8, x, y, width, height, Color( 10, 10, 10, 120 ) )

		local time = endPick - startPick
		local curtime = CurTime() - startPick
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