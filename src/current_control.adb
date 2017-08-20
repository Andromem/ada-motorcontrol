with Ada.Real_Time; use Ada.Real_Time;

with AMC_ADC;
with AMC_PWM;
with AMC_Board;
with AMC;
with Position;
with FOC;
with ZSM;

package body Current_Control is

   function Voltage_To_Duty (V    : in Abc;
                             Vbus : in Voltage_V)
                             return Abc;

   task body Current_Control is
      V_Samples     : Abc;
      I_Samples     : Abc;
      Vbus          : Voltage_V;
      Vmax          : Voltage_V;
      Iabc_Raw      : Abc;
      Current_Angle : Angle_Erad;
      V_Ctrl_Abc    : Abc;
      Duty          : Abc;
      Mode          : AMC_Types.Mode;
   begin

      delay until Clock + Milliseconds (10);

      loop
         AMC_ADC.Handler.Await_New_Samples
            (Phase_Voltage_Samples => V_Samples,
             Phase_Current_Samples => I_Samples);

         AMC_Board.Turn_On (AMC_Board.Led_Green);

         Mode := AMC.Inverter_System_Outputs.Mode.Get;

         if Mode /= Off then

            if Mode = Alignment then
               Current_Angle := AMC.Inverter_System_Outputs.Alignment_Angle.Get;
            else
               Current_Angle := Position.Get_Angle;
            end if;

            Iabc_Raw := AMC_Board.To_Phase_Currents (I_Samples);

            Vbus := AMC.Inverter_System_Outputs.Vbus.Get;
            Vmax := 0.5 * Vbus * ZSM.Modulation_Index_Max (Config.Modulation_Method);

            V_Ctrl_Abc := FOC.Calculate_Voltage
               (Iabc          => Iabc_Raw,
                I_Set_Point   => AMC.Inverter_System_Outputs.Idq_CC_Request.Get,
                Current_Angle => Current_Angle,
                Vmax          => Vmax,
                Period        => Nominal_Period);

            Duty := Voltage_To_Duty (V_Ctrl_Abc, Vbus);

         else

            Duty := Abc'(50.0, 50.0, 50.0);

         end if;

         AMC_PWM.Set_Duty_Cycle (Duty);

         AMC_Board.Turn_Off (AMC_Board.Led_Green);

      end loop;
   end Current_Control;

   function Voltage_To_Duty (V    : in Abc;
                             Vbus : in Voltage_V)
                             return Abc
   is
      Duty : constant Abc := (100.0 / Vbus) * V + (50.0, 50.0, 50.0);
   begin
      return ZSM.Modulate (X      => Duty,
                           Method => Config.Modulation_Method);
   end Voltage_To_Duty;

   procedure Initialize
   is
   begin

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is
      (Initialized);


end Current_Control;
