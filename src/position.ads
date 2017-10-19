with AMC_Types; use AMC_Types;
with AMC_Math;
with AMC_Hall;
with Config;
with Generic_PO;

package Position is
   --  @summary
   --  Rotor State Calculation
   --
   --  @description
   --  Measures and calculates the state of the rotor, e.g. angle and speed.
   --  It provides an interface to the used position sensor. Supported sensors:
   --
   --  - Quadrature encoder
   --  - Hall sensor
   --  - Todo: Sensorless, i.e. No sensor at all
   --

   --  Defines directions measured by hall sensor.
   --  Ccw is defined as an increasing angle.
   type Hall_Direction is (Standstill, Cw, Ccw);

   task Hall_State_Handler with
      Priority => Config.Hall_State_Handler_Prio,
      Storage_Size => (2 * 1024);

   function Get_Hall_Sector_Center_Angle (Sector : in Hall_Sector)
                                          return Angle_Erad;
   --  Get the angle (referenced to the stator's a-axis) to the center of the
   --  specified hall sensor sector.
   --  @param Sector The hall sensor sector.
   --  @return The angle in electrical radians in [0, 2pi).

   function To_Erad (Angle : in Angle_Rad)
                     return Angle_Erad;
   --  Convert a mechanical angle to the corresponding electrical angle.
   --  @param Angle Mechanical angle in radians
   --  @return Angle Electrical angle, i.e. corrected for number of motor pole-pairs.

   function Get_Angle return Angle_Erad;
   --  Get the current rotor electrical angle using the configured sensor.
   --  @return Angle in radians.

   function Wrap_To_180 (Angle : in Angle_Deg)
                         return Angle_Deg;
   --  Wraps Angle into [-180, 180] degrees.
   --  @param Angle Input angle in degrees.
   --  @return Output angle in degrees.

   function Wrap_To_360 (Angle : in Angle_Deg)
                         return Angle_Deg;
   --  Wraps Angle into [0, 360] degrees such that positive multiples of 360
   --  degrees map to 360 and negative multiples map to zero.
   --  Zero wraps to zero and 360 wraps to 360.
   --  @param Angle Input angle in degrees.
   --  @return Output angle in degrees.

   function Wrap_To_Pi (Angle : in Angle_Rad)
                        return Angle_Rad;
   --  Wraps Angle into [-Pi, Pi] radians.
   --  @param Angle Input angle in radians.
   --  @return Output angle in radians.

   function Wrap_To_2Pi (Angle : in Angle_Rad)
                         return Angle_Rad;
   --  Wraps Angle into [0, 2Pi] radians such that positive multiples of 2Pi
   --  radians map to 2Pi and negative multiples map to zero.
   --  Zero wraps to zero and 2Pi wraps to 2Pi.
   --  @param Angle Input angle in radians.
   --  @return Output angle in radians.

private

   Pi     : constant Angle_Rad := Angle_Rad (AMC_Math.Pi);
   Two_Pi : constant Angle_Rad := Angle_Rad (2.0 * AMC_Math.Pi);

   Hall_Sector_Angle : constant Angle_Erad := Angle_Erad (Two_Pi / 6.0);

   Hall_Offset : constant Angle_Erad := Config.Position_Sensor_Offset;

   Sector_Center_Angle : constant array (Hall_Sector'Range) of Angle_Erad :=
      (0.0,
       1.0 * Pi / 3.0,
       2.0 * Pi / 3.0,
       3.0 * Pi / 3.0,
       4.0 * Pi / 3.0,
       5.0 * Pi / 3.0);

   type Position_Hall_Data is record
      Hall_State : AMC_Hall.Hall_State;
      Angle      : Angle_Erad;
      Speed_Raw  : Speed_Eradps;
   end record;

   package Position_Hall_PO_Pack is new Generic_PO (Position_Hall_Data);

   Hall_Data : Position_Hall_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   package Hall_Map_PO_Pack is new Generic_PO (Pattern_To_Sector_Map);

   Hall_Sector_Map : Hall_Map_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

end Position;
