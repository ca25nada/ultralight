local t = Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,HSV(0,0,0););
		--InitCommand=cmd(FullScreen;diffuse,HSV(0,0.2,0);diffuserightedge,HSV(0,0.2,0));
	};
};

return t;