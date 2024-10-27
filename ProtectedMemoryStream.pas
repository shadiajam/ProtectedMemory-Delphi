{
  **********************************************************
  * TProtectedMemoryStream - Secure memory stream handling *
  * Free Source Code snippet (For Delphi)                  *
  **********************************************************

  Unit Information:
    * Purpose      : Provides secure memory protection for streams.
    * Notes:
       --> Implements memory protection using Windows API with
           VirtualAlloc and VirtualProtect, allowing memory used by
           the stream to be protected from read/write access and
           securely cleared when no longer needed.

    Initial Author:
      * Shadi Ajam (https://github.com/shadiajam)

    License:
      * This project is open-source and free to use. You are encouraged to
        contribute, modify, and redistribute it under the MIT license.

    Usage:
      * Example:
        var
          Stream: TProtectedMemoryStream;
          Data: AnsiString;
          Buffer: array[0..255] of Byte;
        begin
          Data := 'Sensitive Data';

          // Create the protected stream
          Stream := TProtectedMemoryStream.Create;
          try
            // Write data to the stream
            Stream.Write(PAnsiChar(Data)^, Length(Data));

            // Protect the memory of the stream
            Stream.IsProtected := True;

            // Accessing the protected memory will cause an access violation
            try
              Stream.Read(Buffer, 10);
            except
              on E: Exception do
                Writeln('Memory is protected, cannot read!');
            end;

            // Unprotect the memory to allow reading
            Stream.IsProtected := False;
            Stream.Read(Buffer, 10);
            Writeln('Read data: ', PAnsiChar(@Buffer));
          finally
            Stream.Free;
          end;
        end;
}

unit ProtectedMemoryStream;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows,System.RTLConsts,System.Math;

type
  TProtectedMemoryStream = class(TMemoryStream)
  private
    FProtected: Boolean;
    procedure SetProtected(const Value: Boolean);
  protected
    function Realloc(var NewCapacity: NativeInt): Pointer;reintroduce;override;
  public
    property IsProtected: Boolean Read FProtected write SetProtected;
    procedure AfterConstruction; override;
  end;

implementation


{ TProtectedMemoryStream }

procedure TProtectedMemoryStream.AfterConstruction;
begin
  inherited;
end;

function ReVirtualAlloc(var Ptr: Pointer; OldSize, NewSize: NativeUInt): Pointer;
var
  NewPtr: Pointer;
begin
  NewPtr := VirtualAlloc(nil, NewSize, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
  if NewPtr = nil then
    raise EOutOfMemory.Create('Memory allocation failed');

  if (Ptr <> nil) and (OldSize > 0) then
    Move(Ptr^, NewPtr^, Min(OldSize, NewSize));

  if Ptr <> nil then
    VirtualFree(Ptr, 0, MEM_RELEASE);

  Ptr := NewPtr;

  Result := NewPtr;
end;

function TProtectedMemoryStream.Realloc(var NewCapacity: NativeInt): Pointer;
const
  MemoryDelta = $2000; { Must be a power of 2 }
begin
  if (NewCapacity > 0) and (NewCapacity <> Capacity) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> Capacity then
  begin
    if NewCapacity = 0 then
    begin
      VirtualFree(Memory, 0, MEM_RELEASE); // Free the old memory
      Result := nil;
    end else
    begin

      if NewCapacity > 0 then
        Result := ReVirtualAlloc(Result,Capacity, NewCapacity);
      if Result = nil then raise EStreamError.CreateRes(@SMemoryStreamError);
    end;
  end;
end;

procedure TProtectedMemoryStream.SetProtected(const Value: Boolean);
var
  OldProtect: DWORD;
begin
  if FProtected <> Value then
  begin
    FProtected := Value;
    if FProtected then
    begin
      // Protect memory using VirtualProtect (no access)
      if not VirtualProtect(Memory, Capacity, PAGE_NOACCESS, @OldProtect) then
        raise EStreamError.Create('Failed to protect memory');
    end
    else
    begin
      // Unprotect memory using VirtualProtect (read/write access)
      if not VirtualProtect(Memory, Capacity, PAGE_READWRITE, @OldProtect) then
        raise EStreamError.Create('Failed to unprotect memory');
    end;
  end;
end;

end.

