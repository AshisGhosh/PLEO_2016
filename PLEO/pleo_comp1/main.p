//
// Very simple main script. Fill in logic in the main function.
//
 
// save space by packing all strings
#pragma pack 1

// 
#include <Log.inc>
#include <Script.inc>
#include <Sensor.inc>
#include <Sound.inc>
#include "sounds.inc"
#include <Motion.inc>
#include "motions.inc"



public init()
{
    print("main::init() enter\n");

    print("main::init() exit\n");
}

public walkforward();
public walk_fs_hd();
public walk_fs_hdr();
public wag();
public walk_fr_2();
public walk_fl_s();
public test_sensors();
public headright();
public headleft();
public turnleft();
public turnleftshort();
public turnright();
public turnright180();
public lean_back();
public backright();
public backleft();
public backup();
public hdr_check();
public edge_check();
public object_check();
public hdr();
public knockover();
public sweep_hdr();
public turnleft_find();
public turnright_find();
//public soc_stand();

new objlatch=0;
public main()
{
    print("main::main() enter\n");
    
    //headright();
	//headleft();
	//soc_stand();
	//lean_back();
	//walkforward();
	//backleft();
	//backright();
	//walk_fs_hdl();
	
	
	//hdr();
	//sweep_hdr();
	
	//walk_fs_hdr();
	//walk_fs_hdr();
	//backup();
	//walk_fs_hd();
	//walk_fr_2();
	//turnright180();
	
	/*while(1)
		walkforward();*/
	
	
	/*turnleft();
	knockover();
	wag();*/
	
    scan();
	 
    //test_sensors();
  
			
     

    for (;;)
    {
        // give some time back to the firmware
        sleep;
    }

    // left in, this generates an 'unreachable code' Pawn warning
    //print("main::main() exit\n");
}

public close()
{
    print("main:close() enter\n");

    print("main:close() exit\n");
}

public walkforward()
{
				//objlatch=1;
            	motion_play(mot_walk_straight);
				while (motion_is_playing(mot_walk_straight)){
					if((object_check())){
						sound_play(snd_1p1_honk04);
					}
				}
					
}

public walk_fs_hd()
{
	    while(sensor_get_value(SENSOR_EDGE_IN_FRONT)==0){

            	motion_play(mot_com_walk_fs_hd);
				while (motion_is_playing(mot_com_walk_fs_hd))
         			{
              			if(sensor_get_value(SENSOR_EDGE_IN_FRONT)==1){
							motion_stop(mot_com_walk_fs_hd);
							sound_play(snd_growl);
							}
					}
					
		 }	
}

public walk_fs_hdr()
{
	while(sensor_get_value(SENSOR_OBJECT)>=25){

            	motion_play(mot_com_walk_fs_hdr);
				while (motion_is_playing(mot_com_walk_fs_hdr))
         			{
              			if(sensor_get_value(SENSOR_OBJECT)<=25){
							motion_stop(mot_com_walk_fs_hdr);
							turnleftshort();
							hdr();
							sound_play(snd_growl);
							}
					}
					
		 }	
}

public walk_fs_hdl()
{
	motion_play(mot_com_walk_fs_hdl);
	while(motion_is_playing(mot_com_walk_fs_hdl)){}
}


public walk_fr_2()
{
	    while(sensor_get_value(SENSOR_OBJECT)<=75){

            	motion_play(mot_com_walk_fr_2a);
				while (motion_is_playing(mot_com_walk_fr_2a))
         			{
              			if(sensor_get_value(SENSOR_OBJECT)>=75){
							motion_stop(mot_com_walk_fr_2a);
							sound_play(snd_growl);
							}
					}
					
		 }
}

public walk_fl_s()
{
	    while(sensor_get_value(SENSOR_OBJECT)<=95){

            	motion_play(mot_com_walk_fl_short);
				while (motion_is_playing(mot_com_walk_fl_short))
         			{
              			if(sensor_get_value(SENSOR_OBJECT)>=95){
							motion_stop(mot_com_walk_fl_short);
							sound_play(snd_growl);
							}
					}
					
		 }
}

public turnleft()
{
	while(1){
		motion_play(mot_com_walk_fl_2a);
		while(motion_is_playing(mot_com_walk_fl_2a)){
			if(object_check()){
				objlatch = 1;
			}
			if (!(object_check())&&(objlatch)){
				motion_stop(mot_com_walk_fl_2a);
				sound_play(snd_growl);
				return 1;
			}
		}
	}
}

public turnleft_find(){
	sound_play(snd_growl);
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){
		if(!(object_check())){
			motion_stop(mot_com_walk_fl_short);
			//objlatch=0;
			//turnright_find();
		}
	}	
}
public turnleftshort()
{
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){}
}

public turnright_find(){
	sound_play(snd_growl);
	motion_play(mot_com_walk_fr_short)
	while(motion_is_playing(mot_com_walk_fr_short)){
		/*if(!(object_check())){
			motion_stop(mot_com_walk_fr_short);
		}*/
	}	
}

public turnright()
{
	motion_play(mot_com_walk_fr_2a);
	while(motion_is_playing(mot_com_walk_fr_2a)){}
}

public turnrightshort()
{
	motion_play(mot_com_walk_fr_short);
	while(motion_is_playing(mot_com_walk_fr_short)){}
}

public turnright180()
{
	for(new count=0; count<4; count++)
		turnright();
}

public backleft()
{
	motion_play(mot_com_walk_bl_2a);
	while(motion_is_playing(mot_com_walk_bl_2a)){}
}

public backright()
{
	motion_play(mot_com_walk_br_2a);
	while(motion_is_playing(mot_com_walk_br_2a)){}
}

public backup()
{
	motion_play(mot_com_walk_bs);
	while(motion_is_playing(mot_com_walk_bs)){}
}

public wag()
{
	for (new i=0; i<1 ;i++)
	{
		motion_play(mot_wag_front_back);
		while(motion_is_playing(mot_wag_front_back)){}
	}
}

public headright()
{
	motion_play(mot_headright);
	while(motion_is_playing(mot_headright)){}
}
public headleft()
{
	motion_play(mot_headleft);
	while(motion_is_playing(mot_headleft)){}
}

public hdr()
{
	motion_play(mot_headdownright);
	while(motion_is_playing(mot_headdownright)){
		/*if(edge_check())
			motion_stop(mot_headdownright);*/
	}
}

public hdr_check()
{
	motion_play(mot_headdownright);
	while(motion_is_playing(mot_headdownright)){
		if(sensor_get_value(SENSOR_OBJECT)<=25){
							//motion_stop(mot_com_walk_fl_short);
							sound_play(snd_growl);
						}
	
	}
}

/*public edge_check()
{
	while(sensor_get_value(SENSOR_OBJECT)>=25){
							sound_play(snd_growl);
						}
}*/

public edge_check()
{
	if(sensor_get_value(SENSOR_OBJECT)<=25)
	{
		sound_play(snd_growl);
		return 1;
	}
}

public object_check()
{       
	if(sensor_get_value(SENSOR_OBJECT)>=90)
	{
		sound_play(snd_1p1_honk04);
		return 1;
	}
}
public lean_back()
{
	motion_play(mot_lean_back);
	while(motion_is_playing(mot_lean_back)){}
}

public knockover(){
	while(objlatch){
		walkforward();
		if(!(object_check())){
			objlatch=0;
			scan();
			
		}
	}
}

public scan(){
	while(!(object_check())){
		motion_play(mot_scan);
		while(motion_is_playing(mot_scan)){
			if(object_check())
			{
				sound_play(snd_1p1_honk04);	
				objlatch=1;
				motion_stop(mot_scan);
				return 1;
			}
		}
	}
}

public sweep_hdr(){
	motion_play(mot_sweep_right);
	while(motion_is_playing(mot_sweep_right)){
		if(edge_check())
			motion_stop(mot_sweep_right);
	}
}


/*public soc_stand()
{
	motion_play(mot_soc_stand_c);
	while(motion_is_playing(mot_soc_stand_c)){}
}*/

public test_sensors()
{
//SENSOR TESTING
	while(1){
		if(sensor_get_value(SENSOR_OBJECT_IN_FRONT)==1)
			sound_play(snd_growl);
		if(sensor_get_value(SENSOR_OBJECT_ON_RIGHT)==1)
			sound_play(snd_growl);
		if(sensor_get_value(SENSOR_OBJECT_ON_LEFT)==1)
			sound_play(snd_growl);
		if(sensor_get_value(SENSOR_PICKED_UP)==1)
			sound_play(snd_growl);
		if(sensor_get_value(SENSOR_SOUND_LOUD_CHANGE)==1)
			sound_play(snd_growl);
		if(sensor_get_value(SENSOR_OBJECT)>=50)
			sound_play(snd_growl);
		if(sensor_get_value(SENSOR_EDGE_IN_FRONT)==1)
			sound_play(snd_growl);
	}
		
}






