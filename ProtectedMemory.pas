{
  *****************************************************
  * Access protection for memory regions              *
  * Free Source Code snippt (For Delphi)              *
  *****************************************************

  Unit Information:
    * Purpose      : Provides secure memory protection functionality.
    * Notes:
       --> Implements memory protection using Windows API, allowing
           memory regions to be protected from read/write access and
           securely cleared when no longer needed.

    Initial Author:
      * Shadi Ajam (https://github.com/shadiajam)

    License:
      * This project is open-source and free to use. You are encouraged to
        contribute, modify, and redistribute it under the MIT license.

    Usage:
      * Example:
        var
          Data: array[0..255] of Byte;
          DataPtr: Pointer;
        begin
          DataPtr := @Data[0];
          // Protect memory
          ProtectMemory(DataPtr, SizeOf(Data));

          // Accessing the protected memory here will cause an exception
          // Unprotect the memory before accessing it
          UnProtectMemory(DataPtr);

          // Optionally release the memory and clear its content
          ReleaseProtectedMemory(DataPtr);
        end;
}

unit ProtectedMemory;

interface

uses
  Windows, SysUtils;

// Exposed Procedures

// Protects the specified memory region by setting it to PAGE_NOACCESS and locking it.
procedure ProtectMemory(DataPtr: Pointer; Size: NativeUInt);

// Unprotects the specified memory region by restoring PAGE_READWRITE access.
procedure UnProtectMemory(DataPtr: Pointer);

// Releases the specified memory region by restoring access, clearing the memory, and removing it from the protected list.
procedure ReleaseProtectedMemory(DataPtr: Pointer);

// Releases and clears all protected memory regions.
procedure ReleaseAllProtectedMemory;

implementation

uses
  Generics.Collections;

type
  TProtectedMemory = record
    DataPtr: Pointer;
    Size: NativeUInt;
  end;
  PProtectedMemory = ^TProtectedMemory;

type
  TProtectedMemoryList = class(TList<PProtectedMemory>)
  public
    procedure AddToList(DataPtr: Pointer; Size: NativeUInt);
    procedure RemoveFromList(DataPtr: Pointer);
    procedure ClearList;
    destructor Destroy; override;
  end;

var
  ProtectedMemoryList: TProtectedMemoryList;

procedure SetMemoryProtection(const DataPtr: Pointer; const Size: NativeUInt; Protect: DWORD);
var
  OldProtect: DWORD;
begin
  if not VirtualProtect(DataPtr, Size, Protect, @OldProtect) then
    RaiseLastOSError;
end;

function GetProtectedMemorySize(DataPtr: Pointer): NativeUInt;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to ProtectedMemoryList.Count - 1 do
  begin
    if ProtectedMemoryList[i]^.DataPtr = DataPtr then
    begin
      Result := ProtectedMemoryList[i]^.Size;
      Exit;
    end;
  end;
end;

procedure TProtectedMemoryList.AddToList(DataPtr: Pointer; Size: NativeUInt);
var
  NewMem: PProtectedMemory;
begin
  New(NewMem);
  NewMem^.DataPtr := DataPtr;
  NewMem^.Size := Size;
  Self.Add(NewMem);
end;

procedure TProtectedMemoryList.RemoveFromList(DataPtr: Pointer);
var
  i: Integer;
  Mem: PProtectedMemory;
begin
  for i := Self.Count - 1 downto 0 do
  begin
    if Self[i]^.DataPtr = DataPtr then
    begin
      Mem := Self[i];
      Self.Delete(i);
      Dispose(Mem);
      Break;
    end;
  end;
end;

procedure TProtectedMemoryList.ClearList;
var
  i: Integer;
  Mem: PProtectedMemory;
begin
  for i := 0 to Self.Count - 1 do
  begin
    Mem := Self[i];
    SetMemoryProtection(Mem^.DataPtr, Mem^.Size, PAGE_READWRITE);
    ZeroMemory(Mem^.DataPtr, Mem^.Size);
    Dispose(Mem);
  end;
  Self.Clear;
end;

destructor TProtectedMemoryList.Destroy;
begin
  ClearList;
  inherited Destroy;
end;

procedure ProtectMemory(DataPtr: Pointer; Size: NativeUInt);
begin
  if not VirtualLock(DataPtr, Size) then
    RaiseLastOSError;

  SetMemoryProtection(DataPtr, Size, PAGE_NOACCESS);

  ProtectedMemoryList.AddToList(DataPtr, Size);
end;

procedure UnProtectMemory(DataPtr: Pointer);
var
  Size: NativeUInt;
begin
  Size := GetProtectedMemorySize(DataPtr);
  if Size = 0 then exit;
  SetMemoryProtection(DataPtr, Size, PAGE_READWRITE);
  ProtectedMemoryList.RemoveFromList(DataPtr);
end;

procedure ReleaseProtectedMemory(DataPtr: Pointer);
var
  Size: NativeUInt;
begin
  Size := GetProtectedMemorySize(DataPtr);
  if Size = 0 then exit;
  SetMemoryProtection(DataPtr, Size, PAGE_READWRITE);

  ZeroMemory(DataPtr, Size);

  ProtectedMemoryList.RemoveFromList(DataPtr);
end;

procedure ReleaseAllProtectedMemory;
begin
  ProtectedMemoryList.ClearList;
end;

initialization
  ProtectedMemoryList := TProtectedMemoryList.Create;

finalization
  ProtectedMemoryList.Free;

end.

