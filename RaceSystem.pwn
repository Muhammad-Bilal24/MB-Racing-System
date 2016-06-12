//==============================includes ======================================//
#include <a_samp>
#include <foreach>
#include <zcmd>
#include <sscanf2>
//================================Define ======================================//
#define SCM 	 SendClientMessage
#define SCMToAll SendClientMessageToAll
//================================Color ======================================//
#define 	COLOR_YELLOW	0xFFFF00AA
#define     COLOR_GREEN     0x33AA33AA
//==============================Dialog ID =====================================//
#define DIALOG_RACE 1002
//==============================forwards ======================================//
forward OnPlayerFreezed(playerid);
forward OnPlayerRaceCountDown();
//=============================Varaibles ======================================//
new Float:CP_SIZE = 10.0;
new RACE_STARTED;
new RACE_CP[MAX_PLAYERS];
new PLAYER_IN_RACE[MAX_PLAYERS];
new CREATING_CHECKPOINTS;
new CP_COUNTER;
new Float:Rx[100] , Float:Ry[100] , Float:Rz[100];
new COUNT_DOWN , RACE_TIMER;
new RACE_EVENT_ACTIVE;
new FREEZE_PLAYER[MAX_PLAYERS];
new RACE_CREATED;
new TOTAL_RACE_CP;
new Cash[] = {5000,10000,8000,9000,7000};

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" 	RACE SYSTEM LOADED				   ");
	print(" CREATED BY MUHAMMAD BILAL				");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	KillTimer(RACE_TIMER);
	return 1;
}

#else

main()
{
	print("\n----------------------------------");
	print(" RACE SYSTEM LOADED					");
	print(" CREATED BY MUHAMMAD BILAL			");
	print("----------------------------------\n");
}

#endif

//================================ CommanDs ============================================//

CMD:rcmds(playerid)
{
	SCM(playerid,COLOR_YELLOW,"==============| RACE SYSTEM |==============");
	SCM(playerid,COLOR_GREEN,"=============| /createrace   |=============");
	SCM(playerid,COLOR_GREEN,"=============| /enableraceevent |=============");
	SCM(playerid,COLOR_GREEN,"=============| /startrace	  |=============");
	SCM(playerid,COLOR_GREEN,"=============| /endrace	  |=============");
	SCM(playerid,COLOR_GREEN,"=============| /deleterace	  |=============");
	SCM(playerid,COLOR_GREEN,"=============| /joinrace 	  |=============");
	SCM(playerid,COLOR_GREEN,"=============| /leaverace 	  |=============");
	SCM(playerid,COLOR_GREEN,"=============| /topracer 	  |=============");
	SCM(playerid,COLOR_YELLOW,"==============| RACE SYSTEM |==============");
	return 1;
}

CMD:deleterace(playerid)
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You need to be rcon admin to use that cmd.");
	if(CREATING_CHECKPOINTS == 1)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You can't make race right now! Some budy is already make race at a moment.");
	if(RACE_STARTED == 1)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You can't make race right now! Please let the race finish first.");
	CREATING_CHECKPOINTS = 0;
	CP_COUNTER = 0;
	RACE_STARTED = 0;
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've successfully delete the race.");
	return 1;
}

CMD:createrace(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,COLOR_GREEN,"You need to be rcon admin to use that cmd.");
	if(CREATING_CHECKPOINTS == 1)return SCM(playerid,COLOR_GREEN,"You can't make race right now! Some budy is already make race at a moment.");
	if(RACE_STARTED == 1)return SCM(playerid,COLOR_GREEN,"You can't make race right now! Please let the race finish first.");
	if(sscanf(params,"i",TOTAL_RACE_CP))return SCM(playerid,COLOR_GREEN,"/createrace [Checkpoints 1-99]");
	if(0  > TOTAL_RACE_CP > 100)return SCM(playerid,COLOR_GREEN,"Checkpoint Must be greater than 0 and less than 100");
	CREATING_CHECKPOINTS = 1;
	CP_COUNTER = 0;
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've to press Fire Key to create checkpoints.");
	return 1;
}

CMD:enableraceevent(playerid)
{   new string[128];
	if(!IsPlayerAdmin(playerid))return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You need to be rcon admin to use that cmd.");
	if(RACE_CREATED == 0)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You need to create checkpoint to start the race.");
	if(RACE_STARTED == 1)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: Race is already enabled .");
	RACE_STARTED = 1;
	format(string,sizeof(string),"[MB-RACE SYSTEM]: Admin %s started race event type /joinrace to join race.",GetName(playerid));
	SCMToAll(COLOR_YELLOW,string);
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've successfully turn on the race event /startrace to start the race.");
	return 1;
}

CMD:endrace(playerid)
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You need to be rcon admin to use that cmd.");
	if(RACE_STARTED == 0)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: There is no race going on at moment.");
	RACE_STARTED = 0;
	RACE_EVENT_ACTIVE = 0;
	foreach(Player,i)
	{
		if(PLAYER_IN_RACE[i])
		{
            PLAYER_IN_RACE[i] = 0;
			DisablePlayerRaceCheckpoint(i);
 			RACE_CP[i] = 0;
		}
	}
 	KillTimer(RACE_TIMER);
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've successfully stop the race.");
	return 1;
}

CMD:startrace(playerid)
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You need to be rcon admin to use that cmd.");
	if(RACE_STARTED == 0)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: There is no race going on at moment.");
	if(RACE_EVENT_ACTIVE == 1)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: Race event is already going on at moment.");
	RACE_EVENT_ACTIVE = 1;
	COUNT_DOWN = 15;
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've successfully started the race event.");
	RACE_TIMER = SetTimer("OnPlayerRaceCountDown",1000,1);
	return 1;
}

CMD:joinrace(playerid,params[])
{
	if(RACE_EVENT_ACTIVE == 1)return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You're late try next time.");
	new string[128];
	if(RACE_STARTED == 1)
	{
		PLAYER_IN_RACE[playerid] = 1;
		RACE_CP[playerid] = 0;
		ResetPlayerWeapons(playerid);
		SetPlayerPos(playerid,Rx[0],Ry[0],Rz[0]);
 		SetPlayerRaceCheckpoint(playerid,1,Rx[0],Ry[0],Rz[0],0.0,0.0,0.0,CP_SIZE);
		ShowPlayerDialog(playerid,DIALOG_RACE,DIALOG_STYLE_LIST, "Race Cars Menu", "Bullet\nTurismo\nSultan\nAlpha\nHotring\nSandking\nSentinel","Spawn" ,"Close");
		SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've successfully join the race event.");
		SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: Please wait some seconds let other racers join the race.");
		format(string,sizeof(string),"[MB-RACE SYSTEM]: Total number of players in race %d.",TOTAL_PLAYER_IN_RACE());
		SCMToAll(-1,string);
	}
	return 1;
}

CMD:leaverace(playerid,params[])
{
	if(!PLAYER_IN_RACE[playerid])return SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You didn't join any race yet.");
	PLAYER_IN_RACE[playerid] = 0;
	RACE_CP[playerid] = 0;
	DisablePlayerRaceCheckpoint(playerid);
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've successfully join the race event.");
	return 1;
}

CMD:topracer(playerid)
{
	GetTopRacer();
	return 1;
}
//================================ Functions && Callbacks ============================================//
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_FIRE) && CREATING_CHECKPOINTS == 1 && IsPlayerAdmin(playerid)&& CP_COUNTER <= TOTAL_RACE_CP)
    {
	    new Float: X , Float: Y , Float: Z;
		for(new i = CP_COUNTER; i <= TOTAL_RACE_CP ; i++)
		{
				if(CP_COUNTER == TOTAL_RACE_CP)
				{
					GetPlayerPos(playerid,X,Y,Z);
					Rx[i]= X , Ry[i] = Y , Rz[i] = Z;
					RACE_CREATED = 1;
                    CP_COUNTER = 0;
					CREATING_CHECKPOINTS = 0;
					SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: Congratz You've successfully created Race checkpoints.");
					break;
				}
				else
				{
					GetPlayerPos(playerid,X,Y,Z);
					Rx[i]= X , Ry[i] = Y , Rz[i] = Z;
					break;
				}
		}
		new string[128];
	    format(string, sizeof(string), "~r~RACE CHECKPOINT~n~~n~~y~ID %d~n~successfully created~n~~r~Total CP ~y~~n~(%d / %d).",CP_COUNTER,CP_COUNTER,TOTAL_RACE_CP);
		GameTextForPlayer(playerid,string,1500,3);
		CP_COUNTER++;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_RACE)
	{
		switch(listitem)
		{
				case 0:CreateRaceVehicle(playerid,541);
				case 1:CreateRaceVehicle(playerid,451);
				case 2:CreateRaceVehicle(playerid,560);
				case 3:CreateRaceVehicle(playerid,602);
				case 4:CreateRaceVehicle(playerid,494);
				case 5:CreateRaceVehicle(playerid,495);
				case 6:CreateRaceVehicle(playerid,405);
		}
	}
	return 0;
}

CreateRaceVehicle(playerid,vehicleid)
{
	new Float:pX,Float:pY,Float:pZ,Float:pw;
	GetPlayerPos(playerid, pX,pY,pZ);
	GetPlayerFacingAngle(playerid, pw);
	new VID = CreateVehicle(vehicleid, pX, pY, pZ, pw, 0, 0, 0);
	PutPlayerInVehicle(playerid, VID, 0);
	FREEZE_PLAYER[playerid] = SetTimerEx("OnPlayerFreezed",10000,0,"i",playerid);
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You've 10 seconds to set your vehicle position.");
	return 1;
}

public OnPlayerFreezed(playerid)
{
	SCM(playerid,COLOR_GREEN,"[MB-RACE SYSTEM]: You're freezed now! Please wait other member to join the race.");
	KillTimer(FREEZE_PLAYER[playerid]);
	TogglePlayerControllable(playerid, 0);
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(PLAYER_IN_RACE[playerid] && RACE_STARTED == 1 && RACE_EVENT_ACTIVE == 1 && IsPlayerInAnyVehicle(playerid))
	{
	    	OnPlayerEnterCP(playerid);
	}
	return 1;
}

OnPlayerEnterCP(playerid)
{
	for(new i = RACE_CP[playerid]; i <= TOTAL_RACE_CP ; i++)
	{
		if(RACE_CP[playerid] == TOTAL_RACE_CP )
		{
			new pCash = Cash[random(5)];
			new string[128];
		    format(string,sizeof(string),"[MB-RACE SYSTEM]: Congratulation %s has completed the race at First Position and won %d",GetName(playerid),pCash);
			SCMToAll(COLOR_YELLOW,string);
			GivePlayerMoney(playerid,pCash);
		    RACE_STARTED = 0;
			RACE_EVENT_ACTIVE = 0;
			foreach(Player,a)
			{
				if(PLAYER_IN_RACE[a])
				{
				RACE_CP[a] = 0;
				DisablePlayerRaceCheckpoint(a);
				}
			}
			PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
			break;
		}
		else
		{
			new string[128];
			format(string,sizeof(string),"~y~You've successfully ~n~~r~captured %d checkpoints ~n~~b~Total CP (%d | 14) ",RACE_CP[playerid],RACE_CP[playerid]);
  			GameTextForPlayer(playerid,string,1000,5);
			DisablePlayerRaceCheckpoint(playerid);
 			SetPlayerRaceCheckpoint(playerid,1,Rx[i],Ry[i],Rz[i],0.0,0.0,0.0,CP_SIZE);
			PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
   			RACE_CP[playerid]++;
   			GetTopRacer();
			break;
		}
	}
	return 1;
}

GetName(playerid)
{
	new JName[MAX_PLAYER_NAME];
	GetPlayerName(playerid,JName,MAX_PLAYER_NAME);
	return JName;
}

GetTopRacer()
{
	new string[128],TOP_RACER;
	foreach(Player,i)
	{
		if(PLAYER_IN_RACE[i])
		{
		    if(RACE_CP[i] > TOP_RACER)
		    {
		        TOP_RACER = RACE_CP[i];
				format(string,sizeof(string),"[MB-RACING]: %s is now leading the race by capturing %d checkpoints",GetName(i),RACE_CP[i]);
				SendMessageToAllRacers(COLOR_GREEN,string);
			}
		}
	}
}

SendMessageToAllRacers(Color,string[])
{
	foreach(Player,i)
	{
		if(PLAYER_IN_RACE[i])
		{
   			SCM(i,Color,string);
		}
	}
}

public OnPlayerRaceCountDown()
{
	new string[128];
	COUNT_DOWN -- ;
	if(COUNT_DOWN <= 1)
	{
 		format(string, sizeof(string), "~r~RACE IS~n~~b~STARTED~n~~r~Lets~y~Go");
	    KillTimer(RACE_TIMER);
		foreach(Player,i)
		{
			if(PLAYER_IN_RACE[i])
			{
	  			TogglePlayerControllable(i, 1);
		    	GameTextForPlayer(i,string,2000,3);
				PlayerPlaySound(i, 4203, 0.0, 0.0, 0.0);
			}
		}
	}
    format(string, sizeof(string), "~r~RACE IS GOING~n~~n~~y~TO~n~Start In~n~~r~%d ~y~~n~seconds.",COUNT_DOWN);
	foreach(Player,i)
	{
		if(PLAYER_IN_RACE[i])
		{
	    	GameTextForPlayer(i,string,1000,3);
			PlayerPlaySound(i, 4203, 0.0, 0.0, 0.0);
		}
	}
	return 1;
}

TOTAL_PLAYER_IN_RACE()
{
	new count;
	foreach(Player,i)
	{
		if(PLAYER_IN_RACE[i])
		{
			count++;
		}
	}
	return count;
}

public OnPlayerConnect(playerid)
{
	PLAYER_IN_RACE[playerid] = 0;
	RACE_CP[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerAdmin(playerid) && CREATING_CHECKPOINTS == 1 && 	RACE_CREATED == 0)
	{
		CREATING_CHECKPOINTS = 0;
	}
	if(PLAYER_IN_RACE[playerid])
	{
		PLAYER_IN_RACE[playerid] = 0;
		RACE_CP[playerid] = 0;
		KillTimer(FREEZE_PLAYER[playerid]);
		DisablePlayerRaceCheckpoint(playerid);
	}
	return 1;
}
