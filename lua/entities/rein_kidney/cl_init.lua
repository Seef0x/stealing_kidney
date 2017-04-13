include("shared.lua");

surface.CreateFont("ReinStealing", {
	font = "Arial",
	size = 60,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
});

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local camPos = self:GetPos();
	local camAng = self:GetAngles();

	if (LocalPlayer():GetPos():Distance(self:GetPos()) < 254) then
		cam.Start3D2D(camPos+Vector(0, 0, 12), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.075)
			draw.SimpleTextOutlined("Rein", "ReinStealing", 0, -20, Color(127, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("Revente : "..self:GetNWInt("price"), "ReinStealing", 0, 20, Color(150, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
	end;
end;