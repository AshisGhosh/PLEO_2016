//
// sensors.p
// PDK drive system example
//
// This script runs in the Sensors VM.  Its primary job,
// in this example, is to watch for sensor input and modify
// properties based on the nature of that sensor input. 
// The drive system and other scripts are monitoring these same 
// properties, and they'll take some action based on the values
// of these properties.
//
// For example, in on_sensor, when one of Pleo's touch sensors is 
// activated, we increase Pleo's happiness by increasing the value of
// the happiness property:
//
//    if ((sensor > SENSOR_TOUCH_FIRST) && (sensor < SENSOR_TOUCH_LAST))
//    {
//        property_set(property_happiness, get(property_happiness) + 10);
//    }
//
//
// When Pleo's mouth sensor is activated, that means that something 
// is in Pleo's mouth, so we increase the value of his blood_sugar
// property:
//
//        case SENSOR_MOUTH:
//        {
//            property_set(property_blood_sugar, get(property_blood_sugar) + 25);
//        }
//
 
// Save space by packing all strings.
#pragma pack 1

#include <Log.inc>
#include <Script.inc>
#include <Sensor.inc>
#include <Property.inc>
#include <Util.inc>
#include <Time.inc>

#include <Sound.inc>
#include "sounds.inc"

#include "user_properties.inc"


public init()
{
    print("sensors:init() enter\n");
    
    print("sensors:init() exit\n");
}

public delay(ms)
{
    new start = time();
    while (time()-start<ms)
    {
       
    }
}
//
// on_sensor
// 
// If Pleo is touched, up the happiness property.
// If Pleo is fed, up the blood_sugar property.
//
public on_sensor(time, sensor_name: sensor, value)
{
    new name[32];
    sensor_get_name(sensor, name);
    
    printf("sensors:on_sensor(%d, %s, %d)\n", time, name, value);
    
    // If Pleo is touched, increase his happiness.
    if ((sensor > SENSOR_TOUCH_FIRST) && (sensor < SENSOR_TOUCH_LAST))
    {
        property_set(property_happiness, get(property_happiness) + 10);
    }
    
    switch (sensor)
    {
    
        // If Pleo eats something, 
        // increase his blood sugar..

		case SENSOR_CHIN:
        {
            if(property_get(property_ragepoints) <45){
                property_set(property_ragepoints, 55);
				property_set(property_pumped,0);
                //sound_play(snd_beep);
                //while(sound_is_playing(snd_beep)){}
            }
			
			else if(property_get(property_ragepoints) >= 50){
                property_set(property_ragepoints, 65);
                //sound_play(snd_beep);
                //while(sound_is_playing(snd_beep)){}
            }

            else if(property_get(property_ragepoints) >= 50){
                property_set(property_ragepoints, 75);
                //sound_play(snd_beep);
                //while(sound_is_playing(snd_beep)){}
            }
        }
		
        case SENSOR_CHEEKL:
        {
            if(property_get(property_pumped) <60){
                property_set(property_pumped, get(property_pumped) + 20);
                sound_play(snd_beep);
                while(sound_is_playing(snd_beep)){}
            }
        }

       case SENSOR_HEAD:
        {
            if(property_get(property_pumped) <60){
                property_set(property_pumped, get(property_pumped) + 10);
                sound_play(snd_beep);
                while(sound_is_playing(snd_beep)){}
			}
			else if(property_get(property_pumped)>=60) {
			property_set(property_pumped,100);}
			
			if(property_get(property_ragepoints)>40){
                property_set(property_ragepoints,100);
				property_set(property_pumped,0);
            }
        }
		
		case SENSOR_SOUND_LOUD_CHANGE:
		{
			if (property_get(property_pumped)>=60){
				property_set(property_pumped,100);
			}
		}
		
        /*case SENSOR_BACK:
        {
            if(property_get(property_ragepoints)>40){
                property_set(property_ragepoints,100);
            }
        }*/
		
		case SENSOR_LEFT_ARM:
        {
			if(property_get(property_lovepoints) <80){
				property_set(property_lovepoints, get(property_lovepoints) + 20);
				sound_play(snd_beep);
				while(sound_is_playing(snd_beep)){}
				delay(1000)
			}	
        }
		
		case SENSOR_RIGHT_ARM:
        {
            if(property_get(property_lovepoints)>0){
                property_set(property_lovepoints,0);
				sound_stop(snd_lovesong);
            }
        }
		
		case SENSOR_RFID:
        {
			if (value == 19)
			{
				if(property_get(property_disgustpoints) <10)
				{
					property_set(property_ragepoints, 0);
					property_set(property_disgustpoints, get(property_disgustpoints) + 20);
					//sound_play(snd_beep);
					//while(sound_is_playing(snd_beep)){}
				}
			}
			
			if (value == 12)
			{
				if(property_get(property_disgustpoints) >= 40)
				{
					property_set(property_disgustpoints, 0);
					sound_stop(snd_vomit);
					sound_play(snd_better);
					while(sound_is_playing(snd_better)){}
				}
			}

        }
		
		case SENSOR_MOUTH:
        {
            if(property_get(property_disgustpoints)<40){
                property_set(property_disgustpoints,100);
            }
        }
		
		case SENSOR_SHAKE:
        {
            if(property_get(property_pumped)>60){
                property_set(property_pumped,100);
            }
        }    
		
    
    }
    
    // Reset sensor trigger.
    return true;
}

public close()
{
    print("sensors:close() enter\n");

    print("sensors:close() exit\n");
}