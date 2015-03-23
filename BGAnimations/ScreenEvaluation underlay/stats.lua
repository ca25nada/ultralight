
local t = Def.ActorFrame{};

function standardDeviation( t )
	local m
	local vm
	local sum = 0
	local count = 0
	local result

	local msum = 0
	for k,v in pairs(t) do
		msum = msum+v
	end

  	m = msum/#t

	for k,v in pairs(t) do
		vm = v - m
		sum = sum + (vm * vm)
		count = count + 1
	end
	result = math.sqrt(sum / (count-1))
	return result
end

function maxmin( t )
  local max = -math.huge
  local min = math.huge

  for k,v in pairs( t ) do
    if type(v) == 'number' then
      max = math.max( max, v )
      min = math.min( min, v )
    end
  end

  return max, min
end

local highlightColor = { -- Colors of Judgment highlights
	TapNoteScore_W1 = color('0.2,0.773,0.953,0.5'),
	TapNoteScore_W2	= color("1,0.8,0,0.4"),
	TapNoteScore_W3	 = color("0.4,0.8,0.4,0.4"),
	TapNoteScore_W4	= color("0.35,0.46,0.73,0.5"),
	TapNoteScore_W5	= color("0.78,0.48,1,0.5"),
	TapNoteScore_Miss = color("0.85,0.33,0.33,0.5"),			
	HoldNoteScore_Held = color("1,0.8,0,0.4"),	
	HoldNoteScore_LetGo = color("0.85,0.33,0.33,0.5")
}

local table = getOffsetTable(PLAYER_1)
local max,min = maxmin(table)
local bucket = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local interval = (max-min)/#bucket
local graphHeight = SCREEN_HEIGHT/3*2
local graphWidth = 400
local graphX = 350
local graphY = SCREEN_HEIGHT/3


function graph(bucket)
	t = Def.ActorFrame{}
	local bmax,bmin = maxmin(bucket)
	local size = #bucket
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,graphX,graphY;zoom,1;horizalign,left;vertalign,top);
		BeginCommand=function(self)
			self:settext("working"); 
		end;
	}

	for k,v in ipairs(bucket) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,graphX+((k-1)*graphWidth/size),graphY+graphHeight;zoomto,graphWidth/#bucket,graphHeight*(v/bmax);horizalign,left;vertalign,bottom;diffusealpha,0.4;);
		}
	end

	return t
end

local i = 1
for k,v in pairs(table) do
	i = 1
	while (i <= #bucket) do
		if (v >= min+((i-1)*interval)) and (v < min+(i*interval)) then
			bucket[i] = bucket[i]+1
		end
		i = i+1
	end
end

local bmax,bmin = maxmin(bucket)

t[#t+1] = graph(bucket)

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,600,50;zoom,1;horizalign,left;vertalign,top);
	BeginCommand=function(self)
		self:settext(bmax); 
	end;
}


t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,500,100;zoom,1;horizalign,left;vertalign,top);
	BeginCommand=function(self)
		self:settext(max*1000); 
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,500,150;zoom,1;horizalign,left;vertalign,top);
	BeginCommand=function(self)
		self:settext(min*1000); 
	end;
}



t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,500,200;zoom,1;horizalign,left;vertalign,top);
	BeginCommand=function(self)
		self:settext("uwaaa")
		local table = getOffsetTable(PLAYER_1)
		local sum = 0
		for k,v in pairs(table) do
			sum = sum+v
		end
		local result = sum/#table*1000 or 0
		self:settextf("%.2f ms mean",(result)); 

	end;
}
t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,500,250;zoom,1;horizalign,left;vertalign,top);
	BeginCommand=function(self)
		local table = getOffsetTable(PLAYER_1)
		local stddev = standardDeviation(table)*1000 or 0
		self:settextf("%.2f ms stddev",stddev); 
	end;
}

return t