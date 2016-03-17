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

new card=0;
new acrosswalk=0;


//TODO:
// * Calibrate forward movement. Convert one motion to cm
// * Change walk forward while head down right to allow it to detect edges to the front right, not just right
// * Develop motion files for tight turning radius
// * Develop motion files for straight walk with head fixed towards the right and left
// * Make faster head sweep motion file for intial edge detection
// * Develop recognition of starting orientation
// * Develop confirmation of objects knocked down


new testflag = 0;
new state_mach = 2;
new scan_count = 0;
new scan_fail = 0;
new flag_right=0, flag_left=0;
new boardhalf=0;

public main()
{	
	batterycheck();
	
    print("main::main() enter\n");
	
	if (testflag)
		goto testcode;
	
//************************************************************    
//MAIN COMPETITION CODE	
	
	
	//STATE1: Start left
	if (state_mach==1){
		sound_play(snd_state_one);
		while(sound_is_playing(snd_state_one)){}
		
		home();
		
		while(1){
			if(sensor_get_value(SENSOR_SOUND_DIR) > 30)
				break;
		}
		
		walkforward();
		for(new i=0; i<6; i++)
			turnrightshort();
			
		
		joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
		while(sensor_get_value(SENSOR_OBJECT)>20){
			joint_control(JOINT_NECK_VERTICAL,1)
			walkforward_hd_scan();
		}
		
		joint_control(JOINT_NECK_VERTICAL,0)
		state_mach++;
	}
	
	if(state_mach==2){
		sound_play(snd_state_two);
		while(sound_is_playing(snd_state_two)){}
		joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
		home();
		
		boardhalf=1;
		
		while(!flag_right && !flag_left){
			if(sensor_get_value(SENSOR_RIGHT_ARM)){
				flag_right=1;
				sound_play(snd_right);
				while(sound_is_playing(snd_right)){}
			}
				
			if(sensor_get_value(SENSOR_LEFT_ARM)){
				sound_play(snd_left);
				while(sound_is_playing(snd_left)){}
				flag_left=1;
			}
		}
		
		sound_play(snd_beep);
		while(sound_is_playing(snd_beep)){}
		
		backup();
		backup();
		backup();
		backup();
		backup();
		backup();
		
		if(flag_right){
			for(new i=0; i<6; i++)
				turnrightshort();
		}
		
		if(flag_left){
			for(new i=0; i<9; i++)
				turnleftshort();
		}
		
		joint_move_to(JOINT_NECK_VERTICAL, -45, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
		while(sensor_get_value(SENSOR_OBJECT)>20){
			joint_control(JOINT_NECK_VERTICAL,1)
			walkforward_scan();
		}

		while(sensor_get_value(SENSOR_OBJECT)>20){
			joint_control(JOINT_NECK_VERTICAL,1)
			walkforward_scan();
		}
		
		joint_control(JOINT_NECK_VERTICAL,0)
		state_mach++;
	}

state_mach3:	
	if(state_mach==3){
		sound_play(snd_state_three);
		while(sound_is_playing(snd_state_three)){}
		/* 
		backleft();
		turnrightshort();
		turnrightshort(); */
		
		backup();
		
		if(flag_right){
			turnrightshort();
			do{
				walk_fs_hdl_across();
				if(boardhalf==1)
					if(sensor_get_value(SENSOR_OBJECT)>75)
						go_middle();
			}while(boardhalf==1)			
		}
		
		if(flag_left){
			turnleftshort();
			backup();
			do{
				walk_fs_hdr_across();
				if(boardhalf==1)
					if(sensor_get_value(SENSOR_OBJECT)>75)
						go_middle();
			}while(boardhalf==1)
		}
		
		
		
		if(state_mach==3)
			state_mach=4;
	}	
		
// ------------------------------------------------------- STATE 4 *************  __________  ******************  __________  *****************	
state_mach4:
	if (state_mach==4){
		for(new beepcount=0; beepcount<4;beepcount++){
			sound_play(snd_beep);
			while(sound_is_playing(snd_beep)){}
		}

	joint_control(JOINT_HEAD,1);
		joint_move_to(JOINT_HEAD,-90,200,angle_degrees);
		while(joint_is_moving(JOINT_HEAD)){}
		
		while(1){
			zero_in();
			if (card)
				break;
			//walkforward_eat();
		}

		state_mach=6;
	}
	
	if(state_mach==5){
		for(new beepcount=0; beepcount<5;beepcount++){
			sound_play(snd_beep);
			while(sound_is_playing(snd_beep)){}
		}
		
		for(new bkpcount=0; bkpcount<5; bkpcount++)
				backup();
			
		if(flag_right){
			backright();
			for(new turn=0; turn<5; turn++)
				turnleftshort();
		}

		if(flag_left){
			backleft();
			for(new turn=0; turn<3; turn++)
				turnrightshort();
		}
		
		joint_move_to(JOINT_NECK_VERTICAL, -45, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		
		while(sensor_get_value(SENSOR_OBJECT)>20){
			joint_control(JOINT_NECK_VERTICAL,1)
			walkforward_scan();
		}
		
		state_mach=3;
		goto state_mach3;
		
	}

	if(state_mach==6){
		for(new beepcount=0; beepcount<6;beepcount++){
			sound_play(snd_beep);
			while(sound_is_playing(snd_beep)){}
		}
		home();
		grab();
	}
	
	
	joint_move_to(JOINT_HEAD, 90, 200, angle_degrees);
	while(joint_is_moving(JOINT_HEAD)){}
	
	backup();
	wag();
	wag();
	
	sound_play(snd_end_of_program);
	while(sound_is_playing(snd_end_of_program)){}
		
//****************************************************************************************************************************	
//TESTING CODE:	
	if (testflag){
		
	
	testcode:
		while(1)
			zero_in();
		
		while(1){
			if(sensor_get_value(SENSOR_CHEEKR)==1){
				sound_play(snd_right);
				while(sound_is_playing(snd_right)){}
			}
			
			if(sensor_get_value(SENSOR_CHEEKL)==1){
				sound_play(snd_left);
				while(sound_is_playing(snd_left)){}
			}
			
			if(sensor_get_value(SENSOR_RFID)==1){
				sound_play(snd_beep);
				while(sound_is_playing(snd_beep)){}
			}
			
			
			if(sensor_get_value(SENSOR_RFID)==19){
				sound_play(snd_fuck);
				while(sound_is_playing(snd_fuck)){}
			}
			
			
		}
		
		
		
		
	}
	


			
    //sound_play(snd_end_of_program);
	//while(sound_is_playing(snd_end_of_program)){}

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

		if(sensor_get_value(SENSOR_MOUTH)){
			card=1;
			break;
		}

		if(sensor_get_value(SENSOR_OBJECT)>=98){
			sound_play(snd_beep);
			while(sound_is_playing(snd_beep)){}
		}
	
		if(obj_angle>=15){
			sound_play(snd_right);
			while(sound_is_playing(snd_right)){}
			turnrightshort_eat();
		}
		else if(obj_angle<=-15){
			sound_play(snd_left);
			while(sound_is_playing(snd_right)){}
			turnleftshort_eat();
		}
		
		else{
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			joint_move_to(JOINT_NECK_VERTICAL, -5, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			
			if(sensor_get_value(SENSOR_OBJECT)>=25){
				card=1;
				sound_play(snd_ahead);
				while(sound_is_playing(snd_ahead)){}
				walkforward_eat();
				break;
			}
		}
		obj_angle=0;	
	}
}

public go_middle()
{
	joint_control(JOINT_NECK_HORIZONTAL,0);
	joint_control(JOINT_NECK_VERTICAL,0);
	backup();
	if(flag_right){
		for(new turn=0; turn<4; turn++)
			turnrightshort();
		
		walkforward();
		walkforward();
		
		for(new turn=0; turn<5; turn++)
			turnleftshort();
	}

	if(flag_left){
		for(new turn=0; turn<5; turn++)
			turnleftshort();
		
		walkforward();
		walkforward();
		
		for(new turn=0; turn<4; turn++)
			turnrightshort();
	}
	
	joint_move_to(JOINT_NECK_VERTICAL, -45, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
	
	sound_play(snd_beep);
	while(sound_is_playing(snd_beep)){}
	
	while(sensor_get_value(SENSOR_OBJECT)>20){
		joint_control(JOINT_NECK_VERTICAL,1);
		walkforward_scan();
		}
		
		
	state_mach=5;
	boardhalf=2;
}

public walkforward()
{
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){}
					
}

public walkforward_eat()
{
	joint_control(JOINT_HEAD,1);
	joint_move_to(JOINT_HEAD,-90,200,angle_degrees);
	while(joint_is_moving(JOINT_HEAD)){}
	joint_control(JOINT_NECK_VERTICAL,1)
	joint_move_to(JOINT_NECK_VERTICAL,10,200,angle_degrees);
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
	
    motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){
		if(sensor_get_value(SENSOR_MOUTH)){
			card=1;
			return 1;
		}
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_walk_straight);
	}

	return 0;					
}

public walkforward_card()
{
    motion_play(mot_walk_straight);
    while (motion_is_playing(mot_walk_straight))
    {
       
        if (sensor_get_value(SENSOR_MOUTH))
        {
            delay(750);
            motion_stop(mot_walk_straight);
        }  
    }          
}

public walkforward_scan()
{
   
	motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){

		if(sensor_get_value(SENSOR_OBJECT)<50)			
			if(sensor_get_value(SENSOR_OBJECT)<50)
				motion_stop(mot_walk_straight);
	}
					
}


public walkforward_hd_scan()
{

    joint_move_to(JOINT_NECK_VERTICAL, -50, 200, angle_degrees );
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
	motion_play(mot_walk_straight);
	while (motion_is_playing(mot_walk_straight)){
					
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_walk_straight);
	}
					
}

//Walks accross the left side of table, same as above but different side.
public walk_fs_hdl_across()
{
    new edge=0, count_hdl=0;
	
	//assert dominance
	joint_control(JOINT_NECK_VERTICAL,1);
	joint_control(JOINT_NECK_HORIZONTAL,1);	
	
	

	while(1){
		if (!(++acrosswalk%2)&&acrosswalk<10){
			joint_control(JOINT_NECK_VERTICAL,1);
			joint_control(JOINT_NECK_HORIZONTAL,1);
			joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			if(scan())
				if(sensor_get_value(SENSOR_OBJECT)>85)
					break;
		}
		
		if (acrosswalk>=10&&!(acrosswalk%2)){
			boardhalf=2;
			joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			if(scan())
				if(sensor_get_value(SENSOR_OBJECT)>85)
					break;
		}
		
		joint_move_to(JOINT_NECK_VERTICAL, -35, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		joint_move_to(JOINT_NECK_HORIZONTAL, -63, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				
		motion_play(mot_tend_left);
		while(motion_is_playing(mot_tend_left)){
			if(sensor_get_value(SENSOR_OBJECT)<25){
				motion_stop(mot_tend_left);
				turnrightshort_hdlscan();	
				turnrightshort_hdlscan();
				turnrightshort_hdlscan();
			}
		}
	}
}

public walk_fs_hdr_across()
{
    //assert dominance
    joint_control(JOINT_NECK_VERTICAL,1);
    joint_control(JOINT_NECK_HORIZONTAL,1);

    while(1){
   
    	if (!(++acrosswalk%2)&&acrosswalk<10){
			joint_control(JOINT_NECK_VERTICAL,1);
			joint_control(JOINT_NECK_HORIZONTAL,1);
			joint_move_to(JOINT_NECK_VERTICAL, 10, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			if(scan())
				if(sensor_get_value(SENSOR_OBJECT)>50)
					break;
		}
		
		if (acrosswalk>=10&&!(acrosswalk%2)){
			boardhalf=2;
			joint_move_to(JOINT_NECK_VERTICAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_VERTICAL)){}
			joint_move_to(JOINT_NECK_HORIZONTAL, 0, 200, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			if(scan())
				if(sensor_get_value(SENSOR_OBJECT)>50)
					break;
		}
	
		joint_move_to(JOINT_NECK_VERTICAL, -35, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_VERTICAL)){}
		joint_move_to(JOINT_NECK_HORIZONTAL, 63, 200, angle_degrees );
		while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
			
        motion_play(mot_tend_right);
        while(motion_is_playing(mot_tend_right)){
            if(sensor_get_value(SENSOR_OBJECT)<25){
                motion_stop(mot_tend_right);
                turnleftshort_hdrscan();   
                turnleftshort_hdrscan();
				turnleftshort_hdrscan();
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

public turnleftshort_hdrscan()
{
    joint_control(JOINT_NECK_HORIZONTAL,1);
    joint_control(JOINT_NECK_VERTICAL,1);
   
    while(sensor_get_value(SENSOR_OBJECT)<25){
        motion_play(mot_com_walk_fl_short);
        while(motion_is_playing(mot_com_walk_fl_short)){
            if(sensor_get_value(SENSOR_OBJECT)>=25)
                motion_stop(mot_com_walk_fl_short);
        }
    }
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

public turnleftshort_eat()
{
	joint_control(JOINT_NECK_HORIZONTAL,1);
	joint_control(JOINT_NECK_VERTICAL,1);
	motion_play(mot_com_walk_fl_short)
	while(motion_is_playing(mot_com_walk_fl_short)){
		joint_move_to(JOINT_NECK_HORIZONTAL, obj_angle, 200, angle_degrees);
		joint_move_to(JOINT_NECK_VERTICAL, 17, 200, angle_degrees);
		if(sensor_get_value(SENSOR_OBJECT)<50)
			motion_stop(mot_com_walk_fl_short);
		if(sensor_get_value(SENSOR_MOUTH)){
			motion_stop(mot_com_walk_fl_short);
			card=1;
		}
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

public turnright180()
{
	for(new i=0; i<4; i++){
		motion_play(mot_com_walk_fr_2a);
		while(motion_is_playing(mot_com_walk_fr_2a)){}
	}
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

public turnrightshort_hdlscan()
{
	joint_control(JOINT_NECK_HORIZONTAL,1);
	joint_control(JOINT_NECK_VERTICAL,1);
	
	while(sensor_get_value(SENSOR_OBJECT)<25){
		motion_play(mot_com_walk_fr_short);
		while(motion_is_playing(mot_com_walk_fr_short)){
			if(sensor_get_value(SENSOR_OBJECT)>=25)
				motion_stop(mot_com_walk_fr_short);
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

public turnrightshort_eat()
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
		if(sensor_get_value(SENSOR_MOUTH)){
			motion_stop(mot_com_walk_fr_short);
			card=1;
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
	motion_play(mot_back_straight);
	while(motion_is_playing(mot_back_straight)){}
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
	joint_control(JOINT_NECK_VERTICAL,1);
	home();
	
	
	scan_fail++;
	
	if(sensor_get_value(SENSOR_OBJECT)>85){
		obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
		scan_count++;
		scan_fail = 0;
		objlatch = 1;
		return 1;
	}
	
	joint_move_to(JOINT_NECK_VERTICAL,0,200,angle_degrees);
	while(joint_is_moving(JOINT_NECK_VERTICAL)){}
	joint_move_to(JOINT_NECK_HORIZONTAL, 0, 100, angle_degrees );
	while(joint_is_moving(JOINT_NECK_HORIZONTAL)){sleep;}
	
	if(sensor_get_value(SENSOR_OBJECT)>85){
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
				k+=2;
			if(sensor_get_value(SENSOR_OBJECT)>85){
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				scan_count++;
				scan_fail = 0;
				objlatch = 1;
				return 1;
			}
		}
	}
		
	else{
		new k = 65;

		while(k>=-65){
			joint_move_to(JOINT_NECK_HORIZONTAL, k, 100, angle_degrees );
			while(joint_is_moving(JOINT_NECK_HORIZONTAL)){}
				k-=2;
			if(sensor_get_value(SENSOR_OBJECT)>85){
				obj_angle = joint_get_position(JOINT_NECK_HORIZONTAL, angle_degrees);
				scan_count++;
				scan_fail = 0;
				objlatch = 1;
				return 1;
			}
		}
	}
	
	
}

public scan_vert()
{
    new k = 30;
    new obj_angle;
 
    //assert dominance
    joint_control(JOINT_NECK_VERTICAL,1);
    joint_control(JOINT_NECK_HORIZONTAL,1);
    joint_control(JOINT_HEAD,1);
   
    //Reset horizontal position
    home();
   
    while(k>=-20)
    {
        joint_move_to(JOINT_NECK_VERTICAL, k, 5, angle_degrees );
        while(joint_is_moving(JOINT_NECK_VERTICAL)){}
        k--;
        if(sensor_get_value(SENSOR_OBJECT)>25)
        {
                obj_angle = joint_get_position(JOINT_NECK_VERTICAL, angle_degrees);
                //motion_stop();
                break; 
        }
    }
    //de-assert dominance
    joint_control(JOINT_NECK_VERTICAL,0);
    joint_control(JOINT_NECK_HORIZONTAL,0);
    joint_control(JOINT_HEAD,0);
   
    //Return vertical level
    return obj_angle;
}

public grab()
{
    new obj_vert = scan_vert() - 2;
   
    //assert dominance
    joint_control(JOINT_NECK_VERTICAL,1);
    joint_control(JOINT_NECK_HORIZONTAL,1);
    joint_control(JOINT_HEAD,1);
   
    //Open Mouth
    joint_move_to(JOINT_HEAD, -90, 100, angle_degrees );
    while(joint_is_moving(JOINT_HEAD)){}
   
    joint_move_to(JOINT_NECK_VERTICAL, obj_vert, 100, angle_degrees );
    while(joint_is_moving(JOINT_NECK_VERTICAL)){}
   
    while(!sensor_get_value(SENSOR_MOUTH))
    {
        walkforward_card();
    }
   
    //Close mouth
    joint_move_to(JOINT_HEAD, 90, 100, angle_degrees );
    while(joint_is_moving(JOINT_HEAD)){}
   
    backup();
 
    //de-assert dominance
    joint_control(JOINT_NECK_VERTICAL,0);
    joint_control(JOINT_NECK_HORIZONTAL,0);
    joint_control(JOINT_HEAD,0);
   
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

public delay(ms)
{
    new start = time();
    while (time()-start<ms)
    {
       
    }
}