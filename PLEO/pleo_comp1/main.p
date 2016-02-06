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
public walkforward_scan();
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
public turnleftshort_scan();
public turnleftshort_hd();
public turnright();
public turnrightshort();
public turnrightshort_scan();
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
public walk_fs_across();
//public soc_stand();



new objlatch=0;
new obj_angle=0;



//TODO:
// * Calibrate forward movement. Convert one motion to cm
// * Change walk forward while head down right to allow it to detect edges to the front right, not just right
// * Develop motion files for tight turning radius
// * Develop motion files for straight walk with head fixed towards the right and left
// * Make faster head sweep motion file for intial edge detection
// * Develop recognition of starting orientation
// * Develop confirmation of objects knocked down


new testflag =0;
new state_mach = 1;
new scan_count = 0;
new scan_fail = 0;

public main()
{
	
    print("main::main() enter\n");
	
	if (testflag)
		goto testcode;
    
//MAIN COMPETITION CODE	
	
	
	//STATE1: Start left
	if (state_mach==1){
		sound_play(snd_state_one);
		while(sound_is_playing(snd_state_one)){}
		//scan to confirm which side - currently hardcoded for start in right box
		hdr();
		sweep_hdr();
		
		//start turning towards first object
		turnleftscan();
		
		
		//walkforward();
		//sound_play(snd_beep);
		
		//call function to home in on object using neck scanning and identifying position
		//object knocked over as soon as not picked up in a single scan
		
		
		
		zero_in();
		if(!objlatch){
			sound_play(snd_bite);
			while(sound_is_playing(snd_bite)){}
		}
		
		
		//confirmation animation of knocking over
		wag();
		
		//begn to walk across the table to the far end
		
		joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		sound_play(snd_beep);
		joint_move_to(JOINT_NECK_VERTICAL, -45, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
		sound_play(snd_going_across);
		while(sound_is_playing(snd_going_across)){}
		
		walk_fs_hdr_across();
		
		
		//TODO: condition to exit moving towards far end and enter STATE 2. Options:
		//	--> time
		//	--> detect far edge of the table
		
		//promote to STATE 2
		state_mach++;
	}
	
	if (state_mach==2){
		
		scan_count=0;
		scan_fail=0;
		
		sound_play(snd_state_two);
		while(sound_is_playing(snd_state_two)){}
		
		sound_play(snd_beep);
		sound_play(snd_beep);
		sound_play(snd_beep);
		sound_play(snd_beep);
		backleft();
		backright();
		turnleftshort();
		
		//sound_play(snd_fuck);
		
		//scan for object, if not there then backup towards the right (object presumed to be on the left)
		/*while(!(scan())){	
			backright();
			joint_move_to(JOINT_NECK_VERTICAL, 20, 200, angle_degrees ); //reset head position for proper scanning
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			
		}*/
		
		//Once object is detected, start using the zero_in() function
		//If the object is lost (i.e. not picked up when zero_in() calls scan()) then backup and zero_in() agan
		//Needs exit condition to consider having hit all three objects
		new direction =1;
		while(1){
			zero_in();
			if(direction){
				backright();
				direction=0;
			}
			else{
				turnleftshort();
				if(scan_count<=3)
					direction=1;
			}
			joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			
			if(scan_count >= 7){
				sound_play(snd_scan_count_hit);
				while(sound_is_playing(snd_scan_count_hit)){}
			}
			
			if (scan_fail >= 2){
				sound_play(snd_scan_fail_hit);
				while(sound_is_playing(snd_scan_fail_hit)){}
			}
			
			if((scan_count>=7 && scan_fail >=2) || scan_fail >=5)
				break;
			
		}
		state_mach++;
	}
		
	if (state_mach==3){
		sound_play(snd_state_three);
		while(sound_is_playing(snd_state_three)){}
	}
	
		
//TESTING CODE:	
	if (testflag){
		
	
	testcode:
		new count=0;
		while(1){
			if(sensor_get_value(SENSOR_SOUND_LOUD)>40)
				count++;
			if (count==3)
				break;
		}
		
		wag();
		
		/*while(1){
			motion_play(mot_test_walk);
			while(motion_is_playing(mot_test_walk)){}
			
			if(sensor_get_value(SENSOR_OBJECT)>=75){
				sound_play(snd_fuck);
				break;
			}
				
		}*/
		/*joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, -45, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}	

		while(sensor_get_value(SENSOR_OBJECT>25)){
			sound_play(snd_beep);
			motion_play(mot_walk_straight_hd);
			while(motion_is_playing(mot_walk_straight_hd)){
				if(sensor_get_value(SENSOR_OBJECT)<=25){
						motion_stop(mot_walk_straight_hd);
				}
			}
		}*/
	
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
  
			
    sound_play(snd_end_of_program);
	while(sound_is_playing(snd_end_of_program)){}

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
		//obj_angle=joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
	
		if(obj_angle>=2){
			sound_play(snd_right);
			while(sound_is_playing(snd_right)){}
			turnrightshort();
		}
		else if(obj_angle<=-2){
			sound_play(snd_left);
			while(sound_is_playing(snd_right)){}
			turnleftshort();
		}
		
		else{
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			if(sensor_get_value(SENSOR_OBJECT)>=68){
				sound_play(snd_ahead);
				while(sound_is_playing(snd_ahead)){}
				walkforward();
			}
		}
		
		joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
	}
		
	
}
public walkforward()
{
				//objlatch=1;
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){}
					
}

public walkforward_scan()
{
	//objlatch=1;
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){
					
		if(sensor_get_value(SENSOR_OBJECT)<50){
			sound_play(snd_1p1_honk04);
		}
		else
			motion_stop(mot_walk_straight);
	}
					
}

public walk_fs_across()
{
				//objlatch=1;
            	motion_play(mot_walk_straight_hd);
				while (motion_is_playing(mot_walk_straight_hd)){
					
					if(sensor_get_value(SENSOR_OBJECT)<=25){
						sound_play(snd_1p1_honk04);
						motion_stop(mot_walk_straight_hd);
						return 1;
						
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
	motion_play(mot_com_walk_fs_hdr);
	while(motion_is_playing(mot_com_walk_fs_hdr)){}
}

public walk_fs_hdr_across()
{
	while(sensor_get_value(SENSOR_OBJECT)>=25){
			
        motion_play(mot_com_walk_fs_hdr);
		while (motion_is_playing(mot_com_walk_fs_hdr))
        {
           	if(sensor_get_value(SENSOR_OBJECT)<=25){
				motion_stop(mot_com_walk_fs_hdr);
				joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				if(sensor_get_value(SENSOR_OBJECT>25)){	
					turnleftshort_hd();
					hdr();
				}
						
			}
		}
		joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, -40, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
					
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
				motion_stop(mot_com_walk_fl_2a);
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

public turnleftshort_scan()
{
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_com_walk_fl_short);
	}
}

public turnleftshort_hd()
{
	motion_play(mot_com_walk_fl_hd)
	while(motion_is_playing(mot_com_walk_fl_hd)){
		if(sensor_get_value(SENSOR_OBJECT)<25)
			motion_stop(mot_com_walk_fl_hd);
	}
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

public turnrightshort_scan()
{
	motion_play(mot_com_walk_fr_short)
	while(motion_is_playing(mot_com_walk_fr_short)){
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_com_walk_fr_short);
	}
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
	if(sensor_get_value(SENSOR_OBJECT)>=92)
	{
		//sound_play(snd_1p1_honk04);
		return 1;
	}
}
public lean_back()
{
	motion_play(mot_lean_back);
	while(motion_is_playing(mot_lean_back)){}
}

public knockover(){
		walkforward();
		if(!(object_check())){
			
			//scan();
			
		}
}


public scan(){
	//while(sensor_get_value(SENSOR_OBJECT)<75){
		
		scan_fail++;
		objlatch=0;
		if(state_mach==1)
			motion_play(mot_scan_lf);
		if(state_mach==2)
			motion_play(mot_scan_rf);
		while(motion_is_playing(mot_scan_lf)||motion_is_playing(mot_scan_rf)){	
			joint_move_to(JOINT_NECK_VERTICAL, 15, 200, angle_degrees );
			if(((sensor_get_value(SENSOR_OBJECT)>=68)&&state_mach==1) || ((sensor_get_value(SENSOR_OBJECT)>=70)&&state_mach==2))
			{
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				motion_stop(mot_scan_lf);
				motion_stop(mot_scan_rf);
				//sound_play(snd_1p1_honk04);	
				objlatch=1;
				scan_fail=0;
				scan_count++;
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








