return Def.ActorFrame{
	Def.Quad{
		Name="Horizontal";
		InitCommand=cmd(draworder,-350;x,48;y,14;zoomto,SCREEN_CENTER_X,32;diffuse,color("1,0.6,0.6,0.05");blend,Blend.Add;vertalign,bottom;fadeleft,0.5;faderight,0.5);
		OffCommand=cmd(visible,false);
	};
	--[[
	Def.Quad{
		Name="Vertical";
		InitCommand=cmd(draworder,-350;x,48;y,14;zoomto,SCREEN_CENTER_X,32;diffuse,color("1,1,1,0");blend,Blend.Add;vertalign,bottom;fadetop,0.25);
	};
	--]]

	Def.Quad{
		InitCommand=cmd(halign,0;draworder,100;x,0-(SCREEN_WIDTH-240)+SCREEN_CENTER_X*0.225;y,15;zoomto,(SCREEN_WIDTH-330)-(SCREEN_CENTER_X*0.225),2;diffuse,color("1,1,1,1");blend,Blend.Add;halign,left;vertalign,bottom);
		OffCommand=cmd(visible,false);
	};
	--]]
	--[[
	Def.Quad{
		InitCommand=cmd(x,-208;y,15;zoomto,SCREEN_CENTER_X-80,2;diffuse,color("1,1,1,1");blend,Blend.Add;halign,left;vertalign,bottom);
	};
	--]]
	-- bottom line
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,-2;x,240;y,-1;zoomto,330,28;diffuse,color("1,0.8,0.8,0.1");fadetop,1);
	};
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,-1;x,240;y,-1;zoomto,330,28;blend,Blend.Add;diffusealpha,0.25);
		OnCommand=cmd(diffuseshift;effectcolor1,color("1,1,1,0.3");effectcolor2,color("1,1,1,0"););
	};

};