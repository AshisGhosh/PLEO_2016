//
// Very simple sensors.p example. Add code to on_sensor for those
// sensors you would like to respond to.
//
 
// save space by packing all strings
#pragma pack 1

#include <Log.inc>
#include <Script.inc>
#include <Sensor.inc>
#include <Sound.inc>
#include "sounds.inc"
#include <Motion.inc>
#include "motions.inc"

public init()
{
    print("sensors:init() enter\n");
    
    print("sensors:init() exit\n");
}

public on_sensor(time, sensor_name: sensor, value)
{
    new name[32];
    sensor_get_name(sensor, name);
    
    printf("sensors:on_sensor(%d, %s, %d)\n", time, name, value);
    
    switch (sensor)
    {
	case SENSOR_HEAD:
		if (value==0)
		{
			sound_play(snd_growl);
			
		}
	case SENSOR_BATTERY:
		if (value <=35)
		{
			sound_play(snd_1p1_honk04);
		}
	
	case SENSOR_MOUTH:
		if (value)
		{
			sound_play(snd_beep);
			
		}

    }
    
	// reset sensor trigger
    return true;
}

public close()
{
    print("sensors:close() enter\n");

    print("sensors:close() exit\n");
}