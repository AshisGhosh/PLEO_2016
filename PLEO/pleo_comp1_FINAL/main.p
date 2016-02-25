// Pleo Competition One
// Jonathan Swiecki, Ashish Ghosh, Galen Yates, Diego E, Denys M
//
 
// save space by packing all strings
#pragma pack 1

// nclude various packages
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

//Initialize Functions
public home();
public walkforward();    
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
public turnrightscan();
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
public scan();
public backupshort();
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
public walk_fs_hdr_across2();
public pivot_left();
public batterycheck();

//Variables declared
new objlatch=0;
new obj_angle=0;
new testflag = 0;
new state_mach = 0;
new scan_count = 0;
new scan_fail = 0;

public main()
{	
	batterycheck();
    print("main::main() enter\n");
	
	if (testflag)
		goto testcode;
    
    //MAIN COMPETITION CODE	
	if (state_mach==0){
	    motion_play(mot_home);
		while(motion_is_playing(mot_home)){}
	    sound_play(snd_check_side);
		while(sound_is_playing(snd_check_side)){}
		hdr();
		sweep_hdr();
	}
	
	//STATE1: Start left
	if (state_mach==1){
	    //Moves to other box such that it starts in case 2. Reliable path.
	    backleft();
	    backleft();
	    backleft();
	    backupshort();
	    turnright();
	    turnright();
	    turnright();
	    state_mach=8;

	    //Backup code which uses sensors to run the full course, sensors buggy.
		/*sound_play(snd_state_one);
		while(sound_is_playing(snd_state_one)){}
		
		//start turning towards first object
		turnleftscan();
		
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
        //Promote to next stage
		state_mach++;*/
	}
	
	if (state_mach==2){
		
		scan_count=0;
		scan_fail=0;

		//Sound confirmation for the stage start.
		sound_play(snd_state_two);
		while(sound_is_playing(snd_state_two)){}
		
		sound_play(snd_beep);
		while(sound_is_playing(snd_beep)){}
		
		backleft();
		backright();
		turnleft();
		
		zero_in();
		zero_in();
		
		state_mach++;
		//promote to STATE 3
	}
		
	if (state_mach==3){

	    //Walks forward until scan detects and edge.
		for(;;){
			if(scan())
				break;
			walkforward();
		}

		//Sound confirmation for the stage start.
		sound_play(snd_growl);
		while(sound_is_playing(snd_growl)){}
		
		
		walk_fs_hdr_across();
		state_mach++;
		//promote to STATE 4
	}

    if(state_mach==4){
		backleft();
		backright();
		joint_control(JOINT_NECK_HORIZONTAL,1);
	    for(;;){
	        //Sound confirmation for the stage start.
		    sound_play(snd_growl);
		    while(sound_is_playing(snd_growl)){}
		    pivot_left();
		    turnleft();
		    joint_move_to(JOINT_NECK_VERTICAL, -40, 200, angle_degrees );
		    while(joint_is_moving(JOINT_NECK_VERTICAL)){}		
		
		    joint_control(JOINT_NECK_HORIZONTAL,1);
		    joint_move_to(JOINT_NECK_HORIZONTAL, 35, 200, angle_degrees );
		    while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
		
		    if (sensor_get_value(SENSOR_OBJECT)>=15)
		    	turnleft();
		
		    else if ((sensor_get_value(SENSOR_OBJECT)<=15)&&(joint_get_position(JOINT_NECK_HORIZONTAL)>=20)){
			    break;
		    }

		    break;
	        state_mach++;
			//promote to STATE 5
	    }
	}
		if(state_mach==5){
		//Sound confirmation for the stage start.
		sound_play(snd_bite);
		while(sound_is_playing(snd_bite)){}
		joint_control(JOINT_NECK_HORIZONTAL,0);
		//Moves accross table
		walk_fs_hdr_across2();
		zero_in();
		state_mach++;
		//promote to STATE 6
		}

		if(state_mach==6){
		objlatch=0;
		turnleftscan();

		//Finds the target and homes in attempting to hit it.
		zero_in();
		
		state_mach++;
		//promote to STATE 7
		}
		
		if(state_mach==7){
		//Hits the last target
		walkforward_scan();
		zero_in();
		}


	//Case #2, start in the left box
	if (state_mach==8){
        //Prototype positioning
	    /*walk_fs_hd();
	    backup();
	    backup();
	    backup();*/

	    //Sound confirmation case 2
	    sound_play(snd_case2);
		while(sound_is_playing(snd_case2)){}
        turnright();
        turnright();
        //look for target
        zero_in();
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
		motion_play(mot_com_walk_fr_short);
		while(motion_is_playing(mot_com_walk_fr_short)){}
		walk_fs_hdl_across();
		
		//promote to STATE 2
		state_mach++;
		
		
	}
	
	if (state_mach==9){
	    //Sound confirmation
        sound_play(snd_stage2);
		while(sound_is_playing(snd_stage2)){}
	    turnright();
	    //Hits the two three point targets
	    zero_in();
	    backup();
	    backup();
	    turnrightshort();
	    home();
	    sound_play(snd_growl);
		while(sound_is_playing(snd_growl)){}
	    //Hits the two point target
	    zero_in();
	    state_mach++
    }

    if (state_mach==10){
        //Sound confirmation stage 3
        sound_play(snd_stage3);
		while(sound_is_playing(snd_stage3)){}
		turnright();
	    for (new timer=0; timer<=3 ;timer++){
            walkforward();
	    }
	    sound_play(snd_growl);
		while(sound_is_playing(snd_growl)){}
		//Hits the second two pointer
	    zero_in();
	    turnleft();
	    turnleft();
	    walkforward();
	    //Hits last target
	    zero_in();
	    state_mach++
    }

    if (state_mach==11){
        //Confirmation of completion
        sound_play(snd_winner);
		while(sound_is_playing(snd_winner)){}
		wag();
    }
	    
		
    //TESTING CODE:	
	if (testflag){
		
	
	testcode:
		turnrightshort();
		home();
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
}

public close()
{
    print("main:close() enter\n");

    print("main:close() exit\n");
}

//MAIN FUNCTIONS

//Zeroes all servos
public home()
{
	motion_play(mot_home);
	while(motion_is_playing(mot_home)){}
}


//Scans for a target and homes in on it. It will periodically rescan to 
//make sure it remains on track.
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

//Turns to the specific direction (right/left)
public turnto()
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
}

//Moves forward, straight head regular level.
public walkforward()
{
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){}
					
}

//Walks forward while scanning.
public walkforward_scan()
{
	//objlatch=1;
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){
					
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_walk_straight);
	}
					
}

//Walks accross the table to get to the three point targets.
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

//Walks forward, head down.
public walk_fs_hd()
{
    joint_control(JOINT_NECK_VERTICAL,1);
    joint_move_to(JOINT_NECK_VERTICAL,-50,200,angle_degrees);
	    while(sensor_get_value(SENSOR_EDGE_IN_FRONT)==0){

            	motion_play(mot_com_walk_fs_hd);
				while (motion_is_playing(mot_com_walk_fs_hd))
         			{
              			if(sensor_get_value(SENSOR_EDGE_IN_FRONT)==1){
							motion_stop(mot_com_walk_fs_hd);
							joint_control(JOINT_NECK_VERTICAL,0);
							sound_play(snd_growl);
							return 1;
							}
					}
					
		 }	
}

//Walks forward, head to the right facing down.
public walk_fs_hdr()
{
	motion_play(mot_com_walk_fs_hdr);
	while(motion_is_playing(mot_com_walk_fs_hdr)){}
}

//Walks across the table making sure it wont fall off the edge.
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

//Walks accross the left side of table, same as above but different side.
public walk_fs_hdl_across()
{
    joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
    while(joint_is_moving(JOINT_NECK_VERTICAL)){}
    joint_move_to(JOINT_NECK_HORIZONTAL, -50, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}

	for (new timer=0; timer<=8 ;timer++){
	        if(sensor_get_value(SENSOR_OBJECT)<=25){
	            motion_stop(mot_walk_straight_hdl);
                turnright();
	        }
            motion_play(mot_walk_straight_hdl);
            while(motion_is_playing(mot_walk_straight_hdl)){}
	}
	return
}

//Walks forward, head down left
public walk_fs_hdl()
{
	motion_play(mot_com_walk_fs_hdl);
	while(motion_is_playing(mot_com_walk_fs_hdl)){}
}

//Test version of walking forward to the right.
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

//Walks forward to the left, short movement.
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

//Turns pleo to the left one step.
public turnleft()
{
	motion_play(mot_com_walk_fl_2a);
	while(motion_is_playing(mot_com_walk_fl_2a)){}
}

//Turns pleo to the left while scanning for objects.
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

//Turns pleo to the right while scanning for objects.
public turnrightscan()
{
	    while(!objlatch){
		    motion_play(mot_com_walk_fr_short);
		    while(motion_is_playing(mot_com_walk_fr_short)){
		        if(object_check()){
			        objlatch = 1;
				    motion_stop(mot_com_walk_fr_short);
			    }
			
		    }
	    }
	joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
	joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
}

//Looks for object orientation while turning left.
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

//Turns to the left, short movement.
public turnleftshort()
{
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){}
}


//Short turn left while scanning.
public turnleftshort_scan()
{
	joint_control(JOINT_NECK_HORIZONTAL,1);
	joint_control(JOINT_NECK_VERTICAL,1);
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){
		joint_move_to(JOINT_NECK_HORIZONTAL, obj_angle, 200, angle_degrees);
		joint_move_to(JOINT_NECK_VERTICAL, 20, 200, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_com_walk_fl_short);
	}
	joint_control(JOINT_NECK_HORIZONTAL,0);
	joint_control(JOINT_NECK_VERTICAL,0);
}

//turns left short motion, head down.
public turnleftshort_hd(){
    if(state_mach==1){
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
    if(state_mach==5){
	        motion_play(mot_com_walk_fl_hd)
	        while(motion_is_playing(mot_com_walk_fl_hd)){
		        joint_move_to(JOINT_NECK_VERTICAL, -40, 200, angle_degrees );
		        joint_move_to(JOINT_NECK_HORIZONTAL, 35, 200, angle_degrees );
		        if(sensor_get_value(SENSOR_OBJECT)<15){
		    	    motion_stop(mot_com_walk_fl_hd);	
		    	    return 0;
		            }
	            }
            }
        }

//turns to the right, looking for objects
public turnright_find(){
	sound_play(snd_growl);
	motion_play(mot_com_walk_fr_short)
	while(motion_is_playing(mot_com_walk_fr_short)){
		/*if(!(object_check())){
			motion_stop(mot_com_walk_fr_short);
		}*/
	}	
}

//Turns pleo right.
public turnright()
{
	motion_play(mot_com_walk_fr_2a);
	while(motion_is_playing(mot_com_walk_fr_2a)){}
}

//Turns right with a short motion.
public turnrightshort()
{
	motion_play(mot_com_walk_fr_short);
	while(motion_is_playing(mot_com_walk_fr_short)){}
}

//Turns to the right short with head down.
public turnrightshort_hd(){
        if(state_mach==1){
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
   	    if(state_mach==8){
   	        motion_play(mot_com_walk_fr_short)
	        while(motion_is_playing(mot_com_walk_fr_short)){
		        joint_move_to(JOINT_NECK_VERTICAL, -40, 200, angle_degrees );
		        joint_move_to(JOINT_NECK_HORIZONTAL, -50, 200, angle_degrees );
		        if(sensor_get_value(SENSOR_OBJECT)<15){
		    	    motion_stop(mot_com_walk_fr_short);
		    	    return 0;
		                }
                    }
   	            }
}

//Turns to the right, short motion while scanning.
public turnrightshort_scan()
{
	joint_control(JOINT_NECK_HORIZONTAL,1);
	joint_control(JOINT_NECK_VERTICAL,1);
	
	motion_play(mot_com_walk_fr_short)
	while(motion_is_playing(mot_com_walk_fr_short)){
		joint_move_to(JOINT_NECK_HORIZONTAL, obj_angle, 200, angle_degrees);
		joint_move_to(JOINT_NECK_VERTICAL, 20, 200, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)<50){
			motion_stop(mot_com_walk_fr_short);
		}
	}
	
	joint_control(JOINT_NECK_HORIZONTAL,0);
	joint_control(JOINT_NECK_VERTICAL,0);
}

//Turns 180 degrees while walking right.
public turnright180()
{
	for(new count=0; count<4; count++)
		turnright();
}

//Walks backwards to the left.
public backleft()
{
	motion_play(mot_com_walk_bl_2a);
	while(motion_is_playing(mot_com_walk_bl_2a)){}
}

//Walks backwards to the right.
public backright()
{
	motion_play(mot_com_walk_br_2a);
	while(motion_is_playing(mot_com_walk_br_2a)){
		joint_move_to(JOINT_NECK_VERTICAL,15,200,angle_degrees);
	}
}

//Backs pleo up straight.
public backup()
{
	motion_play(mot_com_walk_bs);
	while(motion_is_playing(mot_com_walk_bs)){}
}

//Backs pleo up, short motion.
public backupshort()
{
	motion_play(mot_com_walk_bs);
	while(motion_is_playing(mot_com_walk_bs)){
		for(new count; count<5000; count++){}
		motion_stop(mot_com_walk_bs);
	}
}

//Pivots in place to the right.
public pivot_right()
{
	motion_play(mot_pivot_right);
	while(motion_is_playing(mot_pivot_right)){
		joint_move_to(JOINT_NECK_HORIZONTAL, 30, 200, angle_degrees );
	}
}

//Pivots in place to the right
public pivot_left()
{
	motion_play(mot_pivot_left);
	while(motion_is_playing(mot_pivot_left)){
		joint_move_to(JOINT_NECK_HORIZONTAL, -30, 200, angle_degrees );
	}

}

//Wags pleos tail one time.
public wag()
{
	for (new i=0; i<1 ;i++)
	{
		motion_play(mot_wag_front_back);
		while(motion_is_playing(mot_wag_front_back)){}
	}
}

//Turns pleos head to the right.
public headright()
{
	motion_play(mot_headright);
	while(motion_is_playing(mot_headright)){}
}

//Turns pleos head to the left.
public headleft()
{
	motion_play(mot_headleft);
	while(motion_is_playing(mot_headleft)){}
}


//Places pleos  head to the down right position.
public hdr()
{
	motion_play(mot_headdownright);
	while(motion_is_playing(mot_headdownright)){
		/*if(edge_check())
			motion_stop(mot_headdownright);*/
	}
}

//Checks the edge on the right hand side.
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
//Scans for an edge.
public edge_check()
{
	if(sensor_get_value(SENSOR_OBJECT)<=25)
	{
		sound_play(snd_growl);
		while(sound_is_playing(snd_growl)){}
		return 1;
	}
}

//Scans for an object.
public object_check()
{       
	if(sensor_get_value(SENSOR_OBJECT)>=92)
	{
		//sound_play(snd_1p1_honk04);
		return 1;
	}
}

//Leans pleo to the back.
public lean_back()
{
	motion_play(mot_lean_back);
	while(motion_is_playing(mot_lean_back)){}
}

//Knocks over the object
public knockover(){
		walkforward();
		if(!(object_check())){
			
			//scan();
			
		}
}

//Prototype scan function
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

//Scan function for Pleo.
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
	
	if (state_mach==1 || state_mach==9 || state_mach==10 || state_mach==8){
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


//Sweeps head on right side, used for case detection.
public sweep_hdr(){
	motion_play(mot_sweep_right);
	while(motion_is_playing(mot_sweep_right)){
		if(edge_check()){
			state_mach=1;
			}
	    else{               
	        state_mach=8;
	        }
	}
}

//Tests pleos sensors.
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

//Checks battery level.
public batterycheck(){
	
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

//Modded walk_fs_hdr_across version for second line of movement
public walk_fs_hdr_across2()
{
	
	new walkcount=0;
	new walkcheck = 6;
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

			}
						
			
		}
		walkcount++;
		
		if (walkcount>=walkcheck){
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, -70, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){sleep;}
			if(scan())
				break;
		}
					
	}	
	return 0;
}
