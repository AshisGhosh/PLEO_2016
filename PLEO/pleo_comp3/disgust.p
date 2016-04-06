//
// hunger.p
// PDK drive system example
//
// This script defines the callbacks that the LifeOS drive system
// uses to manage Pleo's hunger drive.
// 
// The hunger drive defines one behavior: eat.  Whenever the hunger drive
// is active, the eat behavior is the active behavior. 
//
// This drive's evaluator monitors the value of the blood_sugar property, which is
// dependant on leakage (set in main.p) and sensor input (managed by sensors.p).
// When blood_sugar dips below a certain level, it returns a high value in 
// an attempt to become the active drive:
//
//     if (property_get(property_blood_sugar) <= 30)
//    {
//        return 100;
//    }
//
// Once the drive is active, the behavior evaluator selects 
// the eat behavior (see eat.p), which, in the case of the hunger
// drive, is the only defined behavior:
//
//    switch (behavior_id)
//    {
//        // When Pleo's hunger drive is active, 
//        // he should always run the eat script.
//        case scr_eat:
//        {
//            return 100;
//        }
//    }
//

#include <Sound.inc>
#include "sounds.inc"
#include <Motion.inc>
#include "motions.inc"
#include <Util.inc>


#include <Drive.inc>
#include <Log.inc>

#include "scripts.inc"

// These forward declarations of the functions
// called by the firmware are prototypes.
forward public disgust_init();
forward public disgust_eval();
forward public disgust_behavior_eval(behavior_id);
forward public disgust_exit();
forward public disgust_activate();
forward public disgust_deactivate();


//
// hunger_init
// This function is run by LifeOS
// when the behavior is activated.
//
public disgust_init()
{

    // behavior_add(scr_eat, "hunger", 0, 100, 100, 100, 1000);
    //behavior_add(scr_growl, "anger", 0, 100, 100, 100, 1000);
    //behavior_add(scr_rage, "anger", 0, 100, 100, 100, 1000);
	//behavior_add(scr_annoyed, "anger", 0, 100, 100, 100, 1000);
	behavior_add(scr_nasty1, "disgust", 0, 100, 100, 100, 1000);
	behavior_add(scr_nasty2, "disgust", 0, 100, 100, 100, 1000);

}

//
// hunger_eval
// This function returns the current weight
// of the hunger drive, which is based on Pleo's
// blood sugar level.
//
public disgust_eval()
{

    // printf("Life Statistics: blood_sugar is %d, happiness is %d\n", get(property_blood_sugar), get(property_happiness));

    // If the blood sugar is below 25, this drive should dominate,
    // so it returns a high value.
    if (property_get(property_disgustpoints) > 0)
    {
        return 100;
    }
    
    // By default, this drive isn't active, 
    // so it returns a losing value.
    return 0;

}


//
// hunger_behavior_eval(behavior_id);
// This function goes through each of the behaviors
// that are a part of this drive and selects one
// based on Pleo's blood sugar level.
//
public disgust_behavior_eval(behavior_id)
{

    switch (behavior_id)
    {
    
        // When Pleo's hunger drive is active, 
        // he should always run the eat script.

        case scr_nasty1:
        {
            if (property_get(property_disgustpoints) > 0 && property_get(property_disgustpoints) < 40){
                sound_play(snd_sniffnasty);
                return 50;
            }
			
        }

        case scr_nasty2:
        {
            if (property_get(property_disgustpoints) >= 40){
                sound_play(snd_vomit);
                return 100;
            }
        }


    
    }

    return 0;

}