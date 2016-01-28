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
#include <Joint.inc>
#include <Util.inc>
#include <Time.inc>




public init()
{
    print("main::init() enter\n");

    print("main::init() exit\n");
}

public walkforward();    //standard walk forward function
public walk_fs_hd();
public walk_fs_hdr();
public wag();
public walk_fr_2();
public walk_fl_s();
public test_sensors();
public headright();
public headleft();
public turnleft();
public turnleftscan();
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
public zero_in();
//public soc_stand();



new objlatch=0;
new obj_angle=0;



//TODO:
// * Calibrate forward movement. Convert one motion to cm
// * Change walk forward while head down right to allow it to detect edges to the front right, not just right
// * Adapt object detection threshold for the change above in head angle
// * Calibrate sensor IR distance. Map points 100, 95, 90, 80, 60, 40, 20 to distances
// * Develop motion files for tight turning radius
// * Develop motion files for straight walk with head fixed towards the right and left
// * Make faster head sweep motion file for intial edge detection
// * Develop recognition of starting orientation
// * Develop confirmation of objects knocked down
// * Develop transition from scanning to moving towards and knocking down object
//		--> read head position
//		--> go from head position to robot orientation

new testflag =0;
new state_mach = 1;

public main()
{
	
    print("main::main() enter\n");
	
	if (testflag)
		goto testcode;
    
//MAIN COMPETITION CODE	
	
	
	//STATE1: Start left
	if (state_mach==1){
		//scan to confirm which side - currently hardcoded for start in right box
		hdr();
		sweep_hdr();
		
		//start turning towards first object
		turnleftscan();
		sound_play(snd_twitch);
		walkforward();
		
		
		//call function to home in on object using neck scanning and identifying position
		//object knocked over as soon as not picked up in a single scan
		
		
		
		zero_in();
		
		//confirmation animation of knocking over
		wag();
		
		//begn to walk across the table to the far end
		joint_move_to(JOINT_NECK_VERTICAL, -60, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		while(object_check()){
			walkforward();
			joint_move_to(JOINT_NECK_VERTICAL, -60, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		}
		
		
		//TODO: condition to exit moving towards far end and enter STATE 2. Options:
		//	--> time
		//	--> detect far edge of the table
		
		//promote to STATE 2
		state_mach++;
	}
	
	if (state_mach==2){
		
		//sound_play(snd_fuck);
		
		//scan for object, if not there then backup towards the right (object presumed to be on the left)
		while(!(scan())){	
			backright();
			joint_move_to(JOINT_NECK_VERTICAL, 20, 200, angle_degrees ); //reset head position for proper scanning
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			
		}
		
		//Once object is detected, start using the zero_in() function
		//If the object is lost (i.e. not picked up when zero_in() calls scan()) then backup and zero_in() agan
		//Needs exit condition to consider having hit all three objects
		
		while(1){
			zero_in();
			backright();
			joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		}
	}
		

	
		
//TESTING CODE:	
	if (testflag){
		
	
	testcode:
		/*while(1){
			motion_play(mot_test_walk);
			while(motion_is_playing(mot_test_walk)){}
			
			if(sensor_get_value(SENSOR_OBJECT)>=75){
				sound_play(snd_fuck);
				break;
			}
				
		}*/
		
		while(1){
			sound_play(snd_twitch);
			motion_play(mot_pivot_test);
			while(motion_is_playing(mot_pivot_test)){}
		}
	
		/*while(1){
			//motion_play(mot_walk_straight);
			//while(motion_is_playing(mot_walk_straight)){
				printf("POSITION - LH: %d | LK: %d | RH: %d | RK: %d\n",
				joint_get_position(JOINT_LEFT_HIP, angle_degrees), 
				joint_get_position(JOINT_LEFT_KNEE, angle_degrees), 
				joint_get_position(JOINT_RIGHT_HIP, angle_degrees), 
				joint_get_position(JOINT_RIGHT_KNEE, angle_degrees));
				
				printf("MIN - LH: %d | LK: %d | RH: %d | RK: %d\n",
				joint_get_min(JOINT_LEFT_HIP, angle_degrees), 
				joint_get_min(JOINT_LEFT_KNEE, angle_degrees), 
				joint_get_min(JOINT_RIGHT_HIP, angle_degrees), 
				joint_get_min(JOINT_RIGHT_KNEE, angle_degrees));
				
				printf("MAX - LH: %d | LK: %d | RH: %d | RK: %d\n",
				joint_get_max(JOINT_LEFT_HIP, angle_degrees), 
				joint_get_max(JOINT_LEFT_KNEE, angle_degrees), 
				joint_get_max(JOINT_RIGHT_HIP, angle_degrees), 
				joint_get_max(JOINT_RIGHT_KNEE, angle_degrees));
				
				printf("NEUTRAL - LH: %d | LK: %d | RH: %d | RK: %d\n",
				joint_get_neutral(JOINT_LEFT_HIP, angle_degrees), 
				joint_get_neutral(JOINT_LEFT_KNEE, angle_degrees), 
				joint_get_neutral(JOINT_RIGHT_HIP, angle_degrees), 
				joint_get_neutral(JOINT_RIGHT_KNEE, angle_degrees));
				
				printf("OFFSET - LH: %d | LK: %d | RH: %d | RK: %d\n",
				joint_get_offset(JOINT_LEFT_HIP), 
				joint_get_offset(JOINT_LEFT_KNEE), 
				joint_get_offset(JOINT_RIGHT_HIP), 
				joint_get_offset(JOINT_RIGHT_KNEE));
				
					
				
				
				
			//}
		}*/
	
	}
	

//FUNCTION TO ACIVATE ALL SENSORS FOR TESTING	 
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

//MAIN FUNCTIONS
public zero_in()
{
	while(scan()){
	obj_angle=joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
	sound_play(snd_twitch);
		if(obj_angle>=20){
			sound_play(snd_growl);
			turnrightshort();
		}
		else if(obj_angle<=-20)
			turnleftshort();
		
		else
			knockover();
		}
		joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
}
public walkforward()
{
				//objlatch=1;
            	motion_play(mot_test_walk);
				while (motion_is_playing(mot_test_walk)){
					
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
							return 1;
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
							return 1;
							}
					}
					
		 }	
	return 0;
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
	motion_play(mot_com_walk_fl_2a);
	while(motion_is_playing(mot_com_walk_fl_2a)){}
}

public turnleftscan()
{
	while(!(objlatch)){
		motion_play(mot_com_walk_fl_2a);
		while(motion_is_playing(mot_com_walk_fl_2a)){
			if(object_check()){
				objlatch = 1;
				
			}
			/*if (!(object_check())&&(objlatch)){
				motion_stop(mot_com_walk_fl_2a);
				sound_play(snd_growl);
				return 1;
				
			}*/
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
			//scan();
			
		}
	}
}

public scan(){
	//while(sensor_get_value(SENSOR_OBJECT)<75){
		motion_play(mot_scan_lf);
		while(motion_is_playing(mot_scan_lf)){
			if(sensor_get_value(SENSOR_OBJECT)>=68)
			{
				motion_stop(mot_scan_lf);
				sound_play(snd_1p1_honk04);	
				objlatch=1;
				return 1;
			}
		}
	//}
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








