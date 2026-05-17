PROGRAM main
  VAR
    Start  AT %IX0.0 : BOOL;
    Stop   AT %IX0.1 : BOOL := TRUE;   (* normally closed *)
    Guard1 AT %IX0.2 : BOOL := TRUE;
    Guard2 AT %IX0.3 : BOOL := TRUE;
    Motor  AT %QX0.0 : BOOL;
    Lamp   AT %QX0.1 : BOOL;
  END_VAR

  (* Seal-in latch with guards and stop. *)
  Motor := (Start OR Motor) AND Stop AND Guard1 AND Guard2;
  Lamp  := Motor;
END_PROGRAM

CONFIGURATION Config0
  RESOURCE Res0 ON PLC
    TASK Main(INTERVAL := T#20ms, PRIORITY := 0);
    PROGRAM Inst0 WITH Main : main;
  END_RESOURCE
END_CONFIGURATION
