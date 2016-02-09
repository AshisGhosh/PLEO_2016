// Very simple main script. Fill in logic in the main function.

// save space by packing all strings
#pragma pack 1
 
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

//all commented out functions are not used at the moment
public backleft();
public backright();
public backup();
public backupshort();
public batterycheck();
public edge_check();
public hdr();
//public hdr_check();
//public headleft();
//public headright();
public home();
//public knockover();
//public lean_back();
public object_check();
public pivot_left();
public pivot_right();
public scan();
//public soc_stand();
public sweep_hdr();
public test_sensors();
public turnleft();
//public turnleft_find();
public turnleftscan();
public turnleftshort();
public turnleftshort_hd();
public turnleftshort_scan();
public turnright();
public turnright_find();
//public turnright180();
public turnrightshort();
public turnrightshort_hd();
public turnrightshort_scan();
public turnto(); //UNDECLARED
public wag();
//public walk_fl_s();
//public walk_fr_2();
//public walk_fs_across(); 
//public walk_fs_hd();
//public walk_fs_hd1();
//public walk_fs_hdr();
public walk_fs_hdr_across();
public walkforward();    //standard walk forward function
public walkforward_scan();
public zero_in();

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


new testflag = 0;
new state_mach = 1;
new scan_count = 0;
new scan_fail = 0;

public main()
{	
	batterycheck();
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
		while(sound_is_playing(snd_beep)){}
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
		while(sound_is_playing(snd_beep)){}
		
		backleft();
		backright();
		turnleft();
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
				backup();
				direction=0;
			}
			else{
				turnleftshort();
				if(scan_count<=3)
					direction=1;
			}
			/*joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}*/
			
			if(scan_count >= 7){
				sound_play(snd_scan_count_hit);
				while(sound_is_playing(snd_scan_count_hit)){}
			}
			
			if (scan_fail >= 2){
				sound_play(snd_scan_fail_hit);
				while(sound_is_playing(snd_scan_fail_hit)){}
			}
			
			if(scan_fail >=5 || (((scan_count + scan_fail)>=9)&&(scan_fail>=2)))
				break;
			
		}
		state_mach++;
	}
		
	if (state_mach==3){
		sound_play(snd_state_three);
		while(sound_is_playing(snd_state_three)){}
		new direction = 1;
		turnright();
		while(!scan()){
			if(direction){
				turnright();
				direction = 0;
			}
			else{
				walkforward();
				direction = 1;
			}
		}
		zero_in();
		
		while(!scan())
			turnrightshort();
		zero_in();
		wag();
		wag();
	}
			
//TESTING CODE:	
	if (testflag){
		
	
	testcode:
		new count=0;
		while(1){
			zero_in();
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

public home()
{
	motion_play(mot_home);
	while(motion_is_playing(mot_home)){}
}

public zero_in()
{
	while(scan()){
		//obj_angle=joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)>=98){
			sound_play(snd_beep);
			while(sound_is_playing(snd_beep)){}
			//joint_move_to(JOINT_NECK_HORIZONTAL,-65,300,angle_degrees);
			//while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			//joint_move_to(JOINT_NECK_HORIZONTAL,65,300,angle_degrees);
			//while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		}
	
		if(obj_angle>=15){
			sound_play(snd_right);
			while(sound_is_playing(snd_right)){}
			turnrightshort_scan();
			//pivot_right();
		}
		else if(obj_angle<=-15){
			sound_play(snd_left);
			while(sound_is_playing(snd_right)){}
			turnleftshort_scan();
			//pivot_left();
		}
		
		else{
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			
			if(sensor_get_value(SENSOR_OBJECT)>=25){
				sound_play(snd_ahead);
				while(sound_is_playing(snd_ahead)){}
				walkforward_scan();
			}
		}
		
		/*joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}*/
		
		obj_angle=0;
		
		
	}
	
		
	
}


//NOT USED CURRENTLY
/*public turnto()
{
	while(scan()){
		if(obj_angle>=15){
			sound_play(snd_right);
			while(sound_is_playing(snd_right)){}
			
			pivot_right();
			while(sensor_get_value(SENSOR_OBJECT)<=25)
				pivot_right();
			while(sensor_get_value(SENSOR_OBJECT)>25)
				pivot_right();
		}
		else if(obj_angle<=-15){
			sound_play(snd_left);
			while(sound_is_playing(snd_left)){}
			
			pivot_left();
			while(sensor_get_value(SENSOR_OBJECT)<=25)
				pivot_left();
			while(sensor_get_value(SENSOR_OBJECT)>25)
				pivot_left();
		}
		
		joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
		if(sensor_get_value(SENSOR_OBJECT)>60){
			sound_play(snd_ahead);
			while(sound_is_playing(snd_ahead)){}
			walkforward();
		}
		
		joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
	}
}*/

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
					
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_walk_straight);
	}
					
}

//NOT CURRENTLY USED
/* public walk_fs_across()
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
					
} */

//NOT USED CURRENTLY
/* public walk_fs_hd()
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
} */

//NOT USED CURRENTLY
/* public walk_fs_hdr()
{
	motion_play(mot_com_walk_fs_hdr);
	while(motion_is_playing(mot_com_walk_fs_hdr)){}
}
 */

public walk_fs_hdr_across()
{
	
	new walkcount=0;
	new walkcheck = 10;
	while(sensor_get_value(SENSOR_OBJECT)>=25){
		
		joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
				
        motion_play(mot_com_walk_fs_hdr);
		while (motion_is_playing(mot_com_walk_fs_hdr))
        {
           	if(sensor_get_value(SENSOR_OBJECT)<=25){
				motion_stop(mot_com_walk_fs_hdr);
				
				joint_move_to(JOINT_NECK_HORIZONTAL, -35, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_VERTICAL)){}
					
				if((sensor_get_value(SENSOR_OBJECT)<10)&&(walkcount>=walkcheck))
					break;
				
				
				turnleftshort_hd();
				turnrightshort_hd();
				joint_move_to(JOINT_NECK_HORIZONTAL, -20, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				joint_move_to(JOINT_NECK_VERTICAL, -70, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_VERTICAL)){sleep;}
				
				walkcount++;				
					//hdr();
			}
						
			
		}
		
		
		if (walkcount>=walkcheck){
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, -70, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){sleep;}
		}
					
	}	
	return 0;
}

//NOT USED CURRENTLY
/* public walk_fs_hdl()
{
	motion_play(mot_com_walk_fs_hdl);
	while(motion_is_playing(mot_com_walk_fs_hdl)){}
} */

//NOT USED CURRENTLY.
/* public walk_fr_2()
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
} */

//NOT CURRENTLY USED
/* public walk_fl_s()
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
 */

 
public turnleft()
{
	motion_play(mot_com_walk_fl_2a);
	while(motion_is_playing(mot_com_walk_fl_2a)){}
}

public turnleftscan()
{
	while(!objlatch){
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
	joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
	joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
}

//NOT CURRENTLY USED
/* public turnleft_find(){
	sound_play(snd_growl);
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){
		if(!(object_check())){
			motion_stop(mot_com_walk_fl_short);
			//objlatch=0;
			//turnright_find();
		}
	}	
} */

public turnleftshort()
{
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){}
}

public turnleftshort_scan()
{
	joint_control(JOINT_NECK_HORIZONTAL,1);
	joint_control(JOINT_NECK_VERTICAL,1);
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){
		joint_move_to(JOINT_NECK_HORIZONTAL, obj_angle, 200, angle_degrees);
		joint_move_to(JOINT_NECK_VERTICAL, 15, 200, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_com_walk_fl_short);
	}
	joint_control(JOINT_NECK_HORIZONTAL,0);
	joint_control(JOINT_NECK_VERTICAL,0);
}

public turnleftshort_hd()
{
	motion_play(mot_com_walk_fl_hd)
	while(motion_is_playing(mot_com_walk_fl_hd)){
		joint_move_to(JOINT_NECK_VERTICAL, -40, 200, angle_degrees );
		joint_move_to(JOINT_NECK_HORIZONTAL, -35, 200, angle_degrees );
		if(sensor_get_value(SENSOR_OBJECT)<15){
			motion_stop(mot_com_walk_fl_hd);	
			return 0;
		}
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

public turnrightshort_hd()
{
	motion_play(mot_com_walk_fr_short)
	while(motion_is_playing(mot_com_walk_fr_short)){
		joint_move_to(JOINT_NECK_VERTICAL, -40, 200, angle_degrees );
		joint_move_to(JOINT_NECK_HORIZONTAL, 50, 200, angle_degrees );
		if(sensor_get_value(SENSOR_OBJECT)<15){
			motion_stop(mot_com_walk_fr_short);
			return 0;
		}
	}
}

public turnrightshort_scan()
{
	joint_control(JOINT_NECK_HORIZONTAL,1);
	joint_control(JOINT_NECK_VERTICAL,1);
	
	motion_play(mot_com_walk_fr_short)
	while(motion_is_playing(mot_com_walk_fr_short)){
		joint_move_to(JOINT_NECK_HORIZONTAL, obj_angle, 200, angle_degrees);
		joint_move_to(JOINT_NECK_VERTICAL, 15, 200, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)<50){
			motion_stop(mot_com_walk_fr_short);
		}
	}
	
	joint_control(JOINT_NECK_HORIZONTAL,0);
	joint_control(JOINT_NECK_VERTICAL,0);
}

//NOT CURRENTLY USED
/* public turnright180()
{
	for(new count=0; count<4; count++)
		turnright();
}
 */

 public backleft()
{
	motion_play(mot_com_walk_bl_2a);
	while(motion_is_playing(mot_com_walk_bl_2a)){}
}

public backright()
{
	motion_play(mot_com_walk_br_2a);
	while(motion_is_playing(mot_com_walk_br_2a)){
		joint_move_to(JOINT_NECK_VERTICAL,15,200,angle_degrees);
	}
}

public backup()
{
	motion_play(mot_com_walk_bs);
	while(motion_is_playing(mot_com_walk_bs)){}
}

public backupshort()
{
	motion_play(mot_com_walk_bs);
	while(motion_is_playing(mot_com_walk_bs)){
		for(new count; count<5000; count++){}
		motion_stop(mot_com_walk_bs);
	}
}

public pivot_right()
{
	motion_play(mot_pivot_right);
	while(motion_is_playing(mot_pivot_right)){
		joint_move_to(JOINT_NECK_HORIZONTAL, 30, 200, angle_degrees );
	}
}

public pivot_left()
{
	motion_play(mot_pivot_left);
	while(motion_is_playing(mot_pivot_left)){
		joint_move_to(JOINT_NECK_HORIZONTAL, -30, 200, angle_degrees );
	}

}


public wag()
{
	for (new i=0; i<1 ;i++)
	{
		motion_play(mot_wag_front_back);
		while(motion_is_playing(mot_wag_front_back)){}
	}
}

//CURRENTLY NOT USED
/* public headright()
{
	motion_play(mot_headright);
	while(motion_is_playing(mot_headright)){}
} */

//CURRENTLY NOT USED
/* public headleft()
{
	motion_play(mot_headleft);
	while(motion_is_playing(mot_headleft)){}
} */

public hdr()
{
	motion_play(mot_headdownright);
	while(motion_is_playing(mot_headdownright)){
		/*if(edge_check())
			motion_stop(mot_headdownright);*/
	}
}

//CURRENTLY NOT USED
/* public hdr_check()
{
	motion_play(mot_headdownright);
	while(motion_is_playing(mot_headdownright)){
		if(sensor_get_value(SENSOR_OBJECT)<=25){
							//motion_stop(mot_com_walk_fl_short);
							sound_play(snd_growl);
						}
	
	}
} */

//currently not used
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
		while(sound_is_playing(snd_growl)){}
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

//not used
/* public lean_back()
{
	motion_play(mot_lean_back);
	while(motion_is_playing(mot_lean_back)){}
} */

//not used
/* public knockover(){
		walkforward();
		if(!(object_check())){
			
			//scan();
			
		}
}
 */

/*public scan(){
	//while(sensor_get_value(SENSOR_OBJECT)<75){
		
		scan_fail++;
		
		if(state_mach==1)
			motion_play(mot_scan_lf);
		if(state_mach==2)
			motion_play(mot_scan_rf);
		while(motion_is_playing(mot_scan_lf)||motion_is_playing(mot_scan_rf)){
			joint_control(JOINT_NECK_VERTICAL,1);
			joint_move_to(JOINT_NECK_VERTICAL, 15, 200, angle_degrees );

			if(((sensor_get_value(SENSOR_OBJECT)>=10)&&state_mach==1) || ((sensor_get_value(SENSOR_OBJECT)>=10)&&state_mach==2))
			{
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				motion_stop(mot_scan_lf);
				motion_stop(mot_scan_rf);
				while(joint_is_moving(JOINT_NECK_VERTICAL)){}
				joint_control(JOINT_NECK_VERTICAL,0);

				//sound_play(snd_1p1_honk04);	
				objlatch=1;
				scan_fail=0;
				scan_count++;
				return 1;
			}
			
			if(objlatch)
				backupshort();

			objlatch=0;
			
		}
	//}
}*/


public scan()
{
	
	joint_control(JOINT_NECK_HORIZONTAL,1);
	home();
	joint_control(JOINT_NECK_HORIZONTAL,0);
	
	scan_fail++;
	
	if(sensor_get_value(SENSOR_OBJECT)>25){
		obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
		scan_count++;
		scan_fail = 0;
		objlatch = 1;
		return 1;
	}
	
	joint_move_to(JOINT_NECK_VERTICAL,13,200,angle_degrees);
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
	joint_move_to(JOINT_NECK_HORIZONTAL, 0, 100, angle_degrees );
	while(joint_is_moving(JOINT_NECK_HORIZONTAL)){sleep;}
	
	if(sensor_get_value(SENSOR_OBJECT)>25){
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				scan_count++;
				scan_fail = 0;
				objlatch = 1;
				return 1;
			}
	
	if (state_mach==1){
		new k =-65;
		while(k<=65){
			joint_move_to(JOINT_NECK_HORIZONTAL, k, 100, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				k++;
			if(sensor_get_value(SENSOR_OBJECT)>25){
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				scan_count++;
				scan_fail = 0;
				objlatch = 1;
				return 1;
			}
		}
	}
		
	if (state_mach==2 || state_mach==3){
		new k = 65;

		while(k>=-65){
			joint_move_to(JOINT_NECK_HORIZONTAL, k, 100, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				k--;
			if(sensor_get_value(SENSOR_OBJECT)>25){
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				scan_count++;
				scan_fail = 0;
				objlatch = 1;
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

public batterycheck()
{
	
	if(sensor_get_value(SENSOR_BATTERY)>=70){
		sound_play(snd_battery_high);
		while(sound_is_playing(snd_battery_high)){}
	}
	
	else if(sensor_get_value(SENSOR_BATTERY)>=35){
		sound_play(snd_battery_med);
		while(sound_is_playing(snd_battery_med)){}
	}
	
	else{
		sound_play(snd_battery_low);
		while(sound_is_playing(snd_battery_low)){}
	}

}
