program ProtectString;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  ProtectedMemory;

var
  SensitiveStr: string;
  NonSensitiveStr: string;
  DataPtr: Pointer;
  StringLength: NativeUInt;

begin
  try
    // Initialize the strings
    SensitiveStr := 'Sensitive Data';
    NonSensitiveStr := 'Not Sensitive Data';

    // Print the initial value of SensitiveStr
    Writeln('Initial SensitiveStr: ', SensitiveStr);

    // Get pointer to the string memory (for SensitiveStr only)
    DataPtr := Pointer(SensitiveStr);

    // Protect the memory of SensitiveStr (length of SensitiveStr * size of each character)
    StringLength := Length(SensitiveStr) * SizeOf(Char);
    Writeln('Protecting memory for SensitiveStr...');
    ProtectMemory(DataPtr, StringLength);

    // At this point, SensitiveStr's memory is protected, accessing it will likely show as cleared
    Writeln('SensitiveStr after protection (zeroed or undefined behavior): ', SensitiveStr);

    // Assign a new value to NonSensitiveStr (it is separate from SensitiveStr, no conflict here)
    NonSensitiveStr := 'Hi There, how are you?';
    Writeln('NonSensitiveStr: ', NonSensitiveStr);

    // Now release the protected memory for SensitiveStr
    Writeln('UnProtect memory for SensitiveStr...');
    UnProtectMemory(DataPtr);

    // Once UnProtectMemory, SensitiveStr is now safe to use again and should be restored to its original content
    Writeln('Restored SensitiveStr: ', SensitiveStr);

    Readln;
  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;
end.
