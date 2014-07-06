return Def.ActorFrame {
	--Def.Quad{
	--	InitCommand=cmd(draworder,99;x,-80;zoomto,8,24;diffuse,color("#666666"););
	--};
	--Def.Quad{
	--	InitCommand=cmd(draworder,99;x,-80;zoomto,8,24;blend,Blend.Add;diffusealpha,0.25);
	--	OnCommand=cmd(effectclock,"beat";diffuseshift;effectcolor1,color("1,1,1,0.8");effectcolor2,color("1,1,1,0.5"););
	--};

	-- bottom line
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,-15;zoomto,330,2;diffuse,color("#ffcccc"));
		--InitCommand=cmd(draworder,105;x,76;y,-15;zoomto,SCREEN_CENTER_X+10,2;diffuse,color("#ffcccc"));
	};

	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,16;zoomto,330,2;diffuse,color("#ffcccc"));
		--InitCommand=cmd(draworder,105;x,76;y,16;zoomto,SCREEN_CENTER_X+10,2;diffuse,color("#ffcccc"));
	};
	----------
	Def.Quad{
		InitCommand=cmd(halign,1;x,240;y,0;zoomto,330,32;diffuse,color("1,1,1,1"));
		--InitCommand=cmd(x,76;y,0;zoomto,SCREEN_CENTER_X+10,32;diffuse,color("1,1,1,1"));
	};
};