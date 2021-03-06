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

public home();
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
public pivot_right();
public pivot_left();
public batterycheck();
//public soc_stand();



new objlatch=0;
new obj_angle=0;
new objcount=0;



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
		objlatch=0;
		
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
				backup();
				direction=0;
			}
			else{
				turnleftshort();
				if(scan_count<=3)
					direction=1;
			}
			
			if(objlatch){
				objcount++;
				objlatch=0;
			}
			/*joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}*/
			
			if(scan_count >= 18){
				sound_play(snd_scan_count_hit);
				while(sound_is_playing(snd_scan_count_hit)){}
			}
			
			if (scan_fail >= 2){
				sound_play(snd_scan_fail_hit);
				while(sound_is_playing(snd_scan_fail_hit)){}
			}
			
			//if(scan_fail >=5 || (((scan_count + scan_fail)>=20)&&(scan_fail>=2)))
			if(scan_fail>=5||(objcount>4 && scan_fail>=2))
				break;
			
		}
		state_mach++;
	}
		
	if (state_mach==3){
		sound_play(snd_state_three);
		while(sound_is_playing(snd_state_three)){}
		//new direction = 1;
		turnright();
		turnright();
		//hdr();
		//while(!walk_fs_hdr()){}
		//backup();
		hdr();
		walk_fs_hdr_edge();
		
		zero_in();
		
		turnleftscan();
		
		zero_in();
		
		//walk_fs_hdr_across();
		
		wag();
		wag();
		
	}
	
		
//TESTING CODE:	
	if (testflag){
		
	
	testcode:
		hdr();
		walk_fs_hdr_across();
		
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

		if(sensor_get_value(SENSOR_OBJECT)>=98){
			sound_play(snd_beep);
			while(sound_is_playing(snd_beep)){}
		}
	
		if(obj_angle>=15){
			sound_play(snd_right);
			while(sound_is_playing(snd_right)){}
			turnrightshort_scan();
		}
		else if(obj_angle<=-15){
			sound_play(snd_left);
			while(sound_is_playing(snd_right)){}
			turnleftshort_scan();
		}
		
		else{
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, 15, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			
			if(sensor_get_value(SENSOR_OBJECT)>=25){
				sound_play(snd_ahead);
				while(sound_is_playing(snd_ahead)){}
				walkforward_scan();
			}
		}
		obj_angle=0;	
	}
}

public walkforward()
{
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){}
					
}

public walkforward_scan()
{
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){
					
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_walk_straight);
	}
					
}

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

//Modded walk_fs_hdr_across version for second line of movement
public walk_fs_hdr_across2()
{
<<<<<<< HEAD
	new walkcount=0;

	while(1){
=======
	
	new walkcount=0;
	new walkcheck = 6;
	while(sensor_get_value(SENSOR_OBJECT)>=25){
>>>>>>> origin/master
		
		joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
				
        motion_play(mot_com_walk_fs_hdr);
		while (motion_is_playing(mot_com_walk_fs_hdr))
        {
           	
			
			if(sensor_get_value(SENSOR_OBJECT)<25){
				motion_stop(mot_com_walk_fs_hdr);
				
<<<<<<< HEAD
				
				joint_move_to(JOINT_NECK_HORIZONTAL, -30, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_VERTICAL)){}
				
				if(sensor_get_value(SENSOR_OBJECT)<25)
					backright();
=======
				joint_move_to(JOINT_NECK_HORIZONTAL, -35, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_VERTICAL)){}
					
				if((sensor_get_value(SENSOR_OBJECT)<10)&&(walkcount>=walkcheck))
					break;
>>>>>>> origin/master
				
				
				turnleftshort_hd();
				turnrightshort_hd();
<<<<<<< HEAD
				
					//hdr();
=======
				joint_move_to(JOINT_NECK_HORIZONTAL, -20, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				joint_move_to(JOINT_NECK_VERTICAL, -70, 200, angle_degrees );
				while(joint_is_moving(JOINT_NECK_VERTICAL)){sleep;}

>>>>>>> origin/master
			}
						
			
		}
		walkcount++;
		
<<<<<<< HEAD
		joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		joint_move_to(JOINT_NECK_VERTICAL, 15, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}	
		
		sleep(1);
		sound_play(snd_beep);
		while(sound_is_playing(snd_beep)){}
		
		if(walkcount++>10) 
			if(scan()){
				//sound_play(snd_fuck);
				//while(sound_is_playing(snd_fuck)){}
				break;
			}
		
		
							
=======
		if (walkcount>=walkcheck){
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, -70, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){sleep;}
			if(scan())
				break;
		}
					
>>>>>>> origin/master
	}	
	return 0;
}


 
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
		}
	}
	joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
	joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
}


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
		joint_move_to(JOINT_NECK_VERTICAL, 17, 200, angle_degrees);
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
		joint_move_to(JOINT_NECK_VERTICAL, 17, 200, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)<50){
			motion_stop(mot_com_walk_fr_short);
		}
	}
	
	joint_control(JOINT_NECK_HORIZONTAL,0);
	joint_control(JOINT_NECK_VERTICAL,0);
}


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

public hdr()
{
	motion_play(mot_headdownright);
	while(motion_is_playing(mot_headdownright)){

	}
}


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
		return 1;
	}
}

public scan()
{
	
	joint_control(JOINT_NECK_HORIZONTAL,1);
	//home();
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
