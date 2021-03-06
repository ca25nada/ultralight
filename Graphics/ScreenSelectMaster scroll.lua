local gc = Var("GameCommand");

return Def.ActorFrame {
	-- cursor base
	Def.Quad{
		InitCommand=cmd(zoomto,192,26;diffuse,HSVA(192,0.8,1,0.45);blend,Blend.Add;fadeleft,0.5;faderight,0.35;skewx,-0.1;);
		OnCommand=cmd(glowshift;effectcolor1,color("1,1,1,0");effectcolor2,color("1,1,1,0.125"););
		GainFocusCommand=cmd(stoptweening;cropright,0;cropleft,1;linear,0.05;cropleft,0;);
		LoseFocusCommand=cmd(stoptweening;cropright,0;linear,0.05;cropright,1;);
	};
	-- top add
	Def.Quad{
		InitCommand=cmd(zoomto,192,3;blend,Blend.Add;diffusealpha,0.125;vertalign,top;x,9.6;y,-13;fadebottom,0.9;skewx,-0.025);
		GainFocusCommand=cmd(visible,true);
		LoseFocusCommand=cmd(visible,false);
	};
	Font("mentone","24px") .. {
		Text=gc:GetName();
		OnCommand=cmd(y,-1;strokecolor,HSVA(0,0,0,0);shadowlength,1);
		GainFocusCommand=cmd(stoptweening;bouncebegin,0.25;zoom,1;diffuse,HSVA(192,0.8,1,1););
		LoseFocusCommand=cmd(stoptweening;bounceend,0.25;zoom,0.75;diffuse,HSVA(192,0.0,0.8,0.85););
	};
};