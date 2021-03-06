package body AMC_Utils is

   procedure Saturate (X       : in out Dq;
                       Maximum : in Float;
                       Is_Sat  : out Boolean)
   is
      Magnitude : constant Float := AMC_Types.Magnitude (X);
      Scaling : Float;
   begin
      Is_Sat := Magnitude > Maximum;

      if Is_Sat then
         Scaling := Maximum / Max (Magnitude, Float'Succ (0.0));
         X := Scaling * X;
      end if;

   end Saturate;

   function Saturate (X       : in Float;
                      Maximum : in Float;
                      Minimum : in Float)
                      return Float
   is
      (Max (Min (X, Maximum), Minimum));

   function Dead_Zone (X     : in Float;
                       Upper : in Float;
                       Lower : in Float)
                       return Float
   is
   begin
      if Lower <= X and then X <= Upper then
         return 0.0;
      else
         return X;
      end if;
   end Dead_Zone;

   function Sign (X : in Float)
                  return Float
   is
   begin
      if X > 0.0 then
         return 1.0;
      elsif X < 0.0 then
         return -1.0;
      else
         return 0.0;
      end if;
   end Sign;

   function Fmod (X, Y : in Float)
                   return Float
   is
   begin
      return X - Float'Floor (X / Y) * Y;
   end Fmod;

   function Wrap_To (X     : in Float;
                     Upper : in Float)
                     return Float
   is
      Y : constant Float := Fmod (X, Upper);
   begin

      if Y = 0.0 and then
         X > 0.0
      then
         return Upper;
      end if;

      return Y;

   end Wrap_To;

   function Max (X, Y : in Float)
                 return Float
   is
   begin
      if X > Y then
         return X;
      end if;

      return Y;
   end Max;

   function Min (X, Y : in Float)
                 return Float
   is
   begin
      if X < Y then
         return X;
      end if;

      return Y;
   end Min;

   function Max (X, Y : in Integer)
                 return Integer
   is
   begin
      if X > Y then
         return X;
      end if;

      return Y;
   end Max;

   function Min (X, Y : in Integer)
                 return Integer
   is
   begin
      if X < Y then
         return X;
      end if;

      return Y;
   end Min;

   function Create (Timeout : in Seconds) return Timer is
      (Timer'(Time    => 0.0,
              Timeout => Timeout));

   procedure Reset (T : in out Timer)
   is
   begin
      T.Time := 0.0;
   end Reset;

   procedure Reset (T       : in out Timer;
                    Timeout : in Seconds)
   is
   begin
      T.Time := 0.0;
      T.Timeout := Timeout;
   end Reset;

   function Tick (T         : in out Timer;
                  Time_Step : in Seconds) return Boolean
   is
   begin
      T.Time := T.Time + Time_Step;
      return T.Is_Done;
   end Tick;

   procedure Tick (T         : in out Timer;
                   Time_Step : in Seconds)
   is
   begin
      T.Time := T.Time + Time_Step;
   end Tick;

   function Is_Done (T : in out Timer) return Boolean is
      (T.Time >= T.Timeout);


end AMC_Utils;
