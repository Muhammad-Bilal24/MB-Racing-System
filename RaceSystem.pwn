
//==============================includes ======================================//
#include <a_samp>
#include <foreach>
#include <zcmd>
//================================Define ======================================//
#define SCM 	 SendClientMessage
#define SCMToAll SendClientMessageToAll
//================================Color ======================================//
#define 	COLOR_YELLOW	0xFFFF00AA
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
new Float:Rx[15] , Float:Ry[15] , Float:Rz[15];
new COUNT_DOWN , RACE_TIMER;
new RACE_EVENT_ACTIVE;
new FREEZE_PLAYER[MAX_PLAYERS];
new RACE_CREATED;

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" 	RACE SYSTEM LOADED				   ");
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
	SCM(playerid,-1,"=============| /createrace   |=============");
	SCM(playerid,-1,"=============| /enableraceevent |=============");
	SCM(playerid,-1,"=============| /startrace	  |=============");
	SCM(playerid,-1,"=============| /endrace	  |=============");
	SCM(playerid,-1,"=============| /joinrace 	  |=============");
	SCM(playerid,-1,"=============| /leaverace 	  |=============");
	SCM(playerid,COLOR_YELLOW,"==============| RACE SYSTEM |==============");
	return 1;
}

CMD:createrace(playerid)
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,-1,"You need to be rcon admin to use that cmd.");
	if(RACE_STARTED == 1)return SCM(playerid,-1,"You can't make race right now! Please let the race finish first.");
	CREATING_CHECKPOINTS = 1;
	CP_COUNTER = 0;
	SCM(playerid,-1,"[RACE SYSTEM]: You've to press Fire Key to create checkpoints.");
	return 1;
}

CMD:enableraceevent(playerid)
{   new string[128];
	if(!IsPlayerAdmin(playerid))return SCM(playerid,-1,"You need to be rcon admin to use that cmd.");
	if(RACE_CREATED == 0)return SCM(playerid,-1,"You need to create all 14 checkpoint to start the race.");
	if(RACE_STARTED == 1)return SCM(playerid,-1,"Race is already enabled .");
	RACE_STARTED = 1;
	format(string,sizeof(string),"Admin %s started race event type /joinrace to join race.",GetName(playerid));
	SCMToAll(COLOR_YELLOW,string);
	SCM(playerid,-1,"You've successfully turn on the race event /startrace to start the race.");
	return 1;
}

CMD:endrace(playerid)
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,-1,"You need to be rcon admin to use that cmd.");
	if(RACE_STARTED == 0)return SCM(playerid,-1,"There is no race going on at moment.");
	RACE_STARTED = 0;
	RACE_EVENT_ACTIVE = 0;
	foreach(Player,i)
	{
		if(PLAYER_IN_RACE[i])
		{
            PLAYER_IN_RACE[i] = 0;
			DisablePlayerCheckpoint(i);
 			RACE_CP[i] = 0;
		}
	}
 	KillTimer(RACE_TIMER);
	SCM(playerid,-1,"You've successfully stop the race.");
	return 1;
}

CMD:startrace(playerid)
{
	if(!IsPlayerAdmin(playerid))return SCM(playerid,-1,"You need to be rcon admin to use that cmd.");
	RACE_EVENT_ACTIVE = 1;
	COUNT_DOWN = 15;
	SCM(playerid,-1,"You've successfully started the race event.");
	RACE_TIMER = SetTimer("OnPlayerRaceCountDown",1000,1);
	return 1;
}

CMD:joinrace(playerid,params[])
{
	if(RACE_EVENT_ACTIVE == 1)return SCM(playerid,-1,"You're late try next time.");
	new string[128];
	if(RACE_STARTED == 1)
	{
		PLAYER_IN_RACE[playerid] = 1;
		RACE_CP[playerid] = 0;
		ResetPlayerWeapons(playerid);
		SetPlayerPos(playerid,Rx[0],Ry[0],Rz[0]);
		SetPlayerCheckpoint(playerid, Rx[0],Ry[0],Rz[0], CP_SIZE);
		ShowPlayerDialog(playerid,DIALOG_RACE,DIALOG_STYLE_LIST, "Race Cars Menu", "Bullet\nTurismo\nSultan\nAlpha\nHotring\nSandking\nSentinel","Spawn" ,"Close");
		SCM(playerid,-1,"You've successfully join the race event.");
		SCM(playerid,-1,"Please wait some seconds let other racers join the race.");
		format(string,sizeof(string),"[RACE SYSTEM]: Total number of players in race %d.",TOTAL_PLAYER_IN_RACE());
		SCMToAll(-1,string);
	}
	return 1;
}

CMD:leaverace(playerid,params[])
{
	if(!PLAYER_IN_RACE[playerid])return SCM(playerid,-1,"You didn't join any race yet.");
	PLAYER_IN_RACE[playerid] = 0;
	RACE_CP[playerid] = 1;
	DisablePlayerCheckpoint(playerid);
	SCM(playerid,-1,"You've successfully join the race event.");
	return 1;
}

//================================ Functions && Callbacks ============================================//
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_FIRE) && CREATING_CHECKPOINTS == 1 && IsPlayerAdmin(playerid)&& CP_COUNTER <= 14)
    {
        new Float: X , Float: Y , Float: Z;
		switch(CP_COUNTER)
		{
			case 0:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[0]= X , Ry[0] = Y , Rz[0] = Z;
			}
			case 1:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[1]= X , Ry[1] = Y , Rz[2] = Z;
			}
			case 2:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[2]= X , Ry[2] = Y , Rz[2] = Z;
			}
			case 3:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[3]= X , Ry[3] = Y , Rz[3] = Z;
			}
			case 4:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[4]= X , Ry[4] = Y , Rz[4] = Z;
			}
			case 5:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[5]= X , Ry[5] = Y , Rz[5] = Z;
			}
			case 6:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[6]= X , Ry[6] = Y , Rz[6] = Z;
			}
			case 7:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[7]= X , Ry[7] = Y , Rz[7] = Z;
			}
			case 8:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[8]= X , Ry[8] = Y , Rz[8] = Z;
			}
			case 9:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[9]= X , Ry[9] = Y , Rz[9] = Z;
			}
			case 10:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[10]= X , Ry[10] = Y , Rz[10] = Z;
			}
			case 11:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[11]= X , Ry[11] = Y , Rz[11] = Z;
			}
			case 12:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[12]= X , Ry[12] = Y , Rz[12] = Z;
			}
			case 13:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[13]= X , Ry[13] = Y , Rz[13] = Z;
			}
			case 14:
			{
				GetPlayerPos(playerid,X,Y,Z);
				Rx[14]= X , Ry[14] = Y , Rz[14] = Z;
				RACE_CREATED = 1;
				SCM(playerid,-1,"Congratz You've successfully created Race checkpoints.");
			}
		}
		new string[128];
		format(string,sizeof(string),"You've successfully created checkpoint ID %d Total CP [%d / 14]",CP_COUNTER,CP_COUNTER);
		SCM(playerid,-1,string);
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
				case 0:
				{
					CreateRaceVehicle(playerid,541);
				}
				case 1:
				{
					CreateRaceVehicle(playerid,451);
				}
				case 2:
				{
					CreateRaceVehicle(playerid,560);
				}
				case 3:
				{
					CreateRaceVehicle(playerid,602);
				}
				case 4:
				{
					CreateRaceVehicle(playerid,494);
				}
				case 5:
				{
					CreateRaceVehicle(playerid,495);
				}
				case 6:
				{
					CreateRaceVehicle(playerid,405);
				}
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
	SCM(playerid,-1,"[RACE SYSTEM]: You've 10 seconds to set your vehicle position.");
	return 1;
}

public OnPlayerFreezed(playerid)
{
	SCM(playerid,-1,"[RACE SYSTEM]: You're freezed now! Please wait other member to join the race.");
	KillTimer(FREEZE_PLAYER[playerid]);
	TogglePlayerControllable(playerid, 0);
	return 1;
}
new Cash[] = {5000,10000,8000,9000,7000};
public OnPlayerEnterCheckpoint(playerid)
{
	if(PLAYER_IN_RACE[playerid] && RACE_STARTED == 1  && RACE_EVENT_ACTIVE == 1 && IsPlayerInAnyVehicle(playerid))
	{
		if(RACE_CP[playerid] == 14 )
		{
			new pCash = Cash[random(5)];
			new string[128];
			DisablePlayerCheckpoint(playerid);
		    format(string,sizeof(string),"[RACE SYSTEM]: Congratulation %s has completed the race at First Position and won %d",GetName(playerid),pCash);
			SCMToAll(COLOR_YELLOW,string);
			GivePlayerMoney(playerid,pCash);
		    RACE_STARTED = 0;
			RACE_EVENT_ACTIVE = 0;
			PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
		}
		else
		{
			PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
		    RACE_CP[playerid]++;
			new string[128];
			format(string,sizeof(string),"~y~You've successfully ~n~~r~captured %d checkpoints ~n~~b~Total CP (%d | 14) ",RACE_CP[playerid],RACE_CP[playerid]);
	    	GameTextForPlayer(playerid,string,1000,5);
	    	OnPlayerEnterCP(playerid);
		}
	}
	return 1;
}

OnPlayerEnterCP(playerid)
{
	if(PLAYER_IN_RACE[playerid] && RACE_STARTED == 1)
	{
	   	switch(RACE_CP[playerid])
		{
			case 1:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[1],Ry[1],Rz[1], CP_SIZE);
			}
			case 2:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[2],Ry[2],Rz[2], CP_SIZE);
			}
			case 3:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[3],Ry[3],Rz[3], CP_SIZE);
			}
			case 4:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[4],Ry[4],Rz[4], CP_SIZE);
			}
	 		case 5:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[5],Ry[5],Rz[5], CP_SIZE);
			}
			case 6:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[6],Ry[6],Rz[6], CP_SIZE);
			}
			case 7:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[7],Ry[7],Rz[7], CP_SIZE);
			}
			case 8:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[8],Ry[8],Rz[8], CP_SIZE);
			}
			case 9:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[9],Ry[9],Rz[9], CP_SIZE);
			}
			case 10:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[10],Ry[10],Rz[10], CP_SIZE);
			}
			case 11:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[11],Ry[11],Rz[11], CP_SIZE);
			}
			case 12:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[12],Ry[12],Rz[12], CP_SIZE);
			}
			case 13:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[13],Ry[13],Rz[13], CP_SIZE);
			}
			case 14:
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Rx[14],Ry[14],Rz[14], CP_SIZE);
			}
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

public OnPlayerRaceCountDown()
{
	new string[128];
	COUNT_DOWN -- ;
	if(COUNT_DOWN <= 1)
	{
 		format(string, sizeof(string), "~r~RACE IS~n~~b~STARTED.");
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
	    	GameTextForPlayer(i,string,2000,3);
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
	if(PLAYER_IN_RACE[playerid])
	{
		PLAYER_IN_RACE[playerid] = 0;
		RACE_CP[playerid] = 0;
		KillTimer(FREEZE_PLAYER[playerid]);
		DisablePlayerCheckpoint(playerid);
	}
	return 1;
}
