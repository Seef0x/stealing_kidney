include('shared.lua')
	for _, ent in pairs (ents.FindByClass("rein_buyer")) do --<-- remplacer nomdu npc par le nom de votre dossier dans 'addons'
		if ent:GetPos():Distance(LocalPlayer():GetPos()) < 1000 then
			local Ang = ent:GetAngles()

			Ang:RotateAroundAxis( Ang:Forward(), 90)
			Ang:RotateAroundAxis( Ang:Right(), -90)
		
			cam.Start3D2D(ent:GetPos()+ent:GetUp()*79, Ang, 0.20)
				draw.SimpleTextOutlined( 'Acheteur dOrganes', "HUDNumber5", 0, 0, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))			
			cam.End3D2D()
		end
	end