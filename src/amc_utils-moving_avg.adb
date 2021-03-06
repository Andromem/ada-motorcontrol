package body AMC_Utils.Moving_Avg is


   procedure Update (Ma    : in out Moving_Average;
                     Value : in     Datatype)
   is
      Tmp : Datatype := Reset_Value;
   begin
      Ma.History (Ma.Index) := Value;

      if Ma.Index = History_Index'Last then
         Ma.Index := History_Index'First;
      else
         Ma.Index := History_Index'Succ (Ma.Index);
      end if;

      for X of Ma.History loop
         Tmp := Tmp + X;
      end loop;

      Ma.Output := Tmp / Datatype (Ma.History'Length);
   end Update;

   procedure Set (Ma    : in out Moving_Average;
                  Value : in     Datatype)
   is
   begin
      for I in Ma.History'Range loop
         Ma.History (I) := Value;
      end loop;

      Ma.Output := Value;
   end Set;

   function Get (Ma : in Moving_Average) return Datatype is
      (Ma.Output);

end AMC_Utils.Moving_Avg;
