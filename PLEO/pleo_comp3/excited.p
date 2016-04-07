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
forward public excited_init();
forward public excited_eval();
forward public excited_behavior_eval(behavior_id);
forward public excited_exit();
forward public excited_activate();
forward public excited_deactivate();


//
// hunger_init
// This function is run by LifeOS
// when the behavior is activated.
//
public excited_init()
{

    // behavior_add(scr_eat, "hunger", 0, 100, 100, 100, 1000);
    behavior_add(scr_heard, "excited", 0, 100, 100, 100, 1000);
    behavior_add(scr_excited, "excited", 0, 100, 100, 100, 1000);

}

//
// hunger_eval
// This function returns the current weight
// of the hunger drive, which is based on Pleo's
// blood sugar level.
//
public excited_eval()
{

    // If the value for how pumped pleo is is above 90, then this drive will dominate
    // so it returns a high value.
    if (property_get(property_pumped) >= 60)
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
public excited_behavior_eval(behavior_id)
{
 new count=0;
    switch (behavior_id)
    {
    
        // When Pleo's hunger drive is active, 
        // he should always run the eat script.
        case scr_heard:
        {
            if ((property_get(property_pumped) > 50) && (property_get(property_pumped)<75 )){
                sound_play(snd_panting);
				//while(sound_is_playing(snd_panting)){}
				// motion_play(mot_heardyou);
				// while(motion_is_playing(mot_heardyou)){}
                return 100;
            }

        }


        case scr_excited:
        {
            if (property_get(property_pumped) >= 75){
                
                sound_play(snd_excited);			
                return 100;
            }
        }
    
    }

    return 0;

}