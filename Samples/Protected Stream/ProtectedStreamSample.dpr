program ProtectedStreamSample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  ProtectedMemoryStream, SysUtils;

var
  ProtectedStream: TProtectedMemoryStream;
  Data: AnsiString;
  Buffer: array[0..255] of Byte;
begin
  Data := 'Sensitive Data';

  ProtectedStream := TProtectedMemoryStream.Create();
  try
    // Write data to the protected stream
    ProtectedStream.Write(PAnsiChar(Data)^, Length(Data));
    Data := ''; // Set Data to zero after write to stream

    // Protect the stream memory
    ProtectedStream.IsProtected := True;

    // Attempting to read from the stream will raise an exception due to memory protection
    try
      ProtectedStream.Position:=0;
      ProtectedStream.Read(Buffer, 10);
    except
      on E: Exception do
        Writeln('Access violation due to memory protection');
    end;

    // Unprotect the memory to allow reading
    ProtectedStream.IsProtected := False;
    ProtectedStream.Position:=0;
    ProtectedStream.Read(Buffer, 10);

    // Display the first 10 bytes
    Writeln('Read from protected stream: ', PAnsiChar(@Buffer));
    Readln;
  finally
    ProtectedStream.Free;
  end;

  Readln;
end.
