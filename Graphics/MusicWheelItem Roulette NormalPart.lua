return Def.ActorFrame {
	-- bottom line
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,16;zoomto,330,2;diffuse,color("#ffcccc");fadeleft,0.25;faderight,0.25);
	};
	---------------------------
	Def.Quad{
		InitCommand=cmd(halign,1;x,240;y,0;zoomto,330,30;diffuse,color("#ffe5e5"));
	};
	-- roulette special stuff here

	-- lights
	Def.Quad{
		InitCommand=cmd(x,-80;zoomto,8,24;diffuse,HSVA(0,0,0.8,1);diffusebottomedge,HSVA(0,0,0.35,1));
	};
	Def.Quad{
		InitCommand=cmd(x,-80;zoomto,8,24;blend,Blend.Add;diffusealpha,0.25;);
		OnCommand=cmd(rainbow);
	};
	
};