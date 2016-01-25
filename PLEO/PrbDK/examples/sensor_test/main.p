#include <Log.inc>
#include <Script.inc>
new sensorV;
public init()
{
}
public main()
{
	sensorV=sensor_get_value(SENSOR_HEAD);
	while(1){
		printf("Sensor Value is: %d/n",sensorV);
		killtime(500);
	}
}
killtime(ms)
{
	new start = time();
	while (time() - start < ms)
	{
	}
}