#include maps\mp\_load;
#include maps\mp\_utility;

init()
{
	setDvar( "bots_aim_ext", "1" );
	
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");

	for(;;)
    {
		level waittill("connected", player);
		player thread _start_aim_ext();
	}
}

_start_aim_ext()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }

	for(;;){
		self waittill("spawned_player");
		if(!isDefined(self.pers["bots"]["skill"]["old_aim_time"]))
			self.pers["bots"]["skill"]["old_aim_time"] = self.pers["bots"]["skill"]["aim_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_aim_offset_time"]))
			self.pers["bots"]["skill"]["old_aim_offset_time"] = self.pers["bots"]["skill"]["aim_offset_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_semi_time"]))
			self.pers["bots"]["skill"]["old_semi_time"] = self.pers["bots"]["skill"]["semi_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_shoot_after_time"]))
			self.pers["bots"]["skill"]["old_shoot_after_time"] = self.pers["bots"]["skill"]["shoot_after_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_bone_update_interval"]))
			self.pers["bots"]["skill"]["old_bone_update_interval"] = self.pers["bots"]["skill"]["bone_update_interval"];

    	self thread _upd_aim();
    	self thread _upd_wpts();
    	self thread _bot_aimspots();
		wait 1;
	}
}

_aimspeed_mod(k)
{	
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getDvar("bots_aim_ext")=="1") {
			
		if (!self.isbot){return;}
		if (!isDefined(self.pers["bots"]["skill"]["aim_time"] )) {return;}
		if (isDefined(self) && isAlive(self)){ self.sw=1; self.aim_start=2; }
			
		self.pers["bots"]["skill"]["aim_time"] = self.aim_start;
		self.pers["bots"]["skill"]["aim_offset_time"] = 100;
		self.pers["bots"]["skill"]["bone_update_interval"] = 100;
		
		if (getDvar("_newmode_")!="on"){
			self.pers["bots"]["skill"]["aim_time"] = self.pers["bots"]["skill"]["old_aim_time"];
			self.pers["bots"]["skill"]["aim_offset_time"] = self.pers["bots"]["skill"]["old_aim_offset_time"];	
			self.pers["bots"]["skill"]["semi_time"] = self.pers["bots"]["skill"]["old_semi_time"];
			self.pers["bots"]["skill"]["shoot_after_time"] = self.pers["bots"]["skill"]["old_shoot_after_time"];
			self.pers["bots"]["skill"]["bone_update_interval"] = self.pers["bots"]["skill"]["old_bone_update_interval"];
			return;
		}
	
		while (self.sw == 1)  { 
			if(self.pers["bots"]["skill"]["aim_time"] < self.pers["bots"]["skill"]["old_aim_time"]) { self.sw = 0; }
			if(self.pers["bots"]["skill"]["aim_time"] < 0.2) { self.pers["bots"]["skill"]["aim_time"]=0.7; }
			self.pers["bots"]["skill"]["aim_time"] *= k;
			wait 0.05;
		} 
		while (self.sw == 0) {
			if(self.pers["bots"]["skill"]["aim_time"] > 2) { self.sw = 1; }
			self.pers["bots"]["skill"]["aim_time"] *= 1+(1-k); 
			wait 0.05;
		}
		self.pers["bots"]["skill"]["aim_time"] = self.pers["bots"]["skill"]["old_aim_time"];
	}
}

_upd_aim(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!isDefined(self)){return;}
	if (!isAlive(self)){return;}
	if (!self.isbot){return;}
	if (!isDefined(self.pers["bots"]["skill"]["aim_time"])) {return;}
	if (!isDefined(self.pers["bots"]["skill"]["semi_time"])) {return;}
	if (!isDefined(self.pers["bots"]["skill"]["aim_offset_time"])) {return;}
	if (!isDefined(self.pers["bots"]["skill"]["aim_offset_amount"])) {return;}
	
	self.swc = 1;
	self.pers["bots"]["skill"]["aim_time"] = 2;
	roundwins=0; kills=0; k=0;
	aimspeed=1; aim_offset_amount=1;
	
	for(;;){
		if (getDvar("bots_aim_ext")=="1") {
	 		if(isAlive(self)){
	 			kills=self.pers["kills"];
	 			if(self.pers["team"] == "axis") { roundwins=[[level._getTeamScore]]("allies"); }
	 			else if(self.pers["team"] == "allies") { roundwins=[[level._getTeamScore]]("axis"); }
				if(!isDefined(roundwins)) { roundwins=0; }
				k=(kills+roundwins*5)*0.001;
				
				while (self.swc == 1)  { 
					if(self.pers["bots"]["skill"]["aim_time"] < 0.2) {self.swc = 0; }
					if(self.pers["bots"]["skill"]["aim_time"] < 0.2) { self.pers["bots"]["skill"]["aim_time"]=0.7; }
					if(self.pers["bots"]["skill"]["aim_offset_amount"] < 0.1) { self.pers["bots"]["skill"]["aim_offset_amount"]=1; }
					self.pers["bots"]["skill"]["aim_time"] -= k ;
					self.pers["bots"]["skill"]["aim_time"] *= 0.7;
					self.pers["bots"]["skill"]["aim_offset_amount"] -= k;
					self.pers["bots"]["skill"]["aim_offset_amount"] *= 0.8;
					wait 0.05;
				} 
				while (self.swc == 0) {
					self.pers["bots"]["skill"]["aim_time"] -= k; 
					self.pers["bots"]["skill"]["aim_time"] *= 1.3; 
					self.pers["bots"]["skill"]["aim_offset_amount"] -= k;
					self.pers["bots"]["skill"]["aim_offset_amount"] *= 1.5;
					if(self.pers["bots"]["skill"]["aim_time"] > 2) { self.swc = 1; }
					if(self.pers["bots"]["skill"]["aim_offset_amount"] > 3) { self.pers["bots"]["skill"]["aim_offset_amount"]=1; }
					wait 0.05;
				}
					
				if (isDefined(self.pers["bots"]["skill"]["old_semi_time"]))
					self.pers["bots"]["skill"]["semi_time"]=self.pers["bots"]["skill"]["old_semi_time"]*randomFloatRange(0.5,1.9);
				if (isDefined(self.pers["bots"]["skill"]["old_shoot_after_time"]))
					self.pers["bots"]["skill"]["shoot_after_time"]=self.pers["bots"]["skill"]["old_shoot_after_time"]*randomFloatRange(0.5,1.9);
				if (isDefined(self.pers["bots"]["skill"]["old_aim_offset_time"]))
					self.pers["bots"]["skill"]["aim_offset_time"]=self.pers["bots"]["skill"]["old_aim_offset_time"]*randomFloatRange(0.5,3.9);
				if (isDefined(self.pers["bots"]["skill"]["old_aim_offset_amount"]))
					self.pers["bots"]["skill"]["aim_offset_amount"]=self.pers["bots"]["skill"]["old_aim_offset_amount"]*randomFloatRange(0.5,3.9);
			}
		}
		wait 1;
	}
}

_upd_wpts(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!self.isbot){return;}
	
	self.bot._next_wp=0;
	roundwins=0; kills=0; k=0;
		
	for(;;){
		if (getDvar("bots_aim_ext")=="1") {
			if (isDefined(self.bot.next_wp)){ 
				if (self.bot.next_wp != self.bot._next_wp){
					kills=self.pers["kills"];
					roundwins=[[level._getTeamScore]](self.pers["team"]);
					if(!isDefined(roundwins)) { roundwins=0; }
					k=0.3-((kills+roundwins)*0.001);
					self _aimspeed_mod(k);
					self.bot.next_wp = self.bot._next_wp;
				}
			}
		}
		wait 1;
	}
}

_bot_aimspots(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!self.isbot){return;}
	c=0;
	
	for(;;){
		if (getDvar("bots_aim_ext")=="1") {

			if(c<=12) { c++; }
			else if (c>12 && isDefined(self.bot.after_target)) { 
				a=self.bot.after_target.origin;
				r=randomFloatRange(0.97,1.03);
				self.aimspots = (a[0]*r,a[1]*r,a[2]*r);
				self.pers["bots"]["skill"]["aim_time"] = 1;
				self.bot.after_target_pos=self.aimspots;
				self botLookAt(self.aimspots,0.2);
				c=0;
			}
		}
		wait 0.05;
	}
}

_hud_draw_bot_aimspots(bot){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	//if (!getdvarint("developer")>0) {return;}
	if (!self.isbot) {return;}
	
	dist = 0; size=0; threshold=100;
	
	for(;;){
		if (isDefined(self.aimspots)){
			self.hud_aimspot = newClientHudElem( self ); 
			self.hud_aimspot setShader( "compass_waypoint_target", 15, 15 );
			self.hud_aimspot.alpha = 0.5;
			self.hud_aimspot.x = self.aimspots[0]; self.hud_aimspot.y = self.aimspots[1]; self.hud_aimspot.z = self.aimspots[2];
			self.hud_aimspot SetWayPoint(true, "compass_waypoint_defend");
		}
		wait 0.05;
		if(isDefined(self.hud_aimspot)){ self.hud_aimspot Destroy(); }
	}
}

cl(txt){
	if (isDefined(txt)){ print("^2-- "+txt+" -- \n"); }
	else { print("^3!! undefined !! \n"); }
}
