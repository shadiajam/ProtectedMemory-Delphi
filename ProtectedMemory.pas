{
  *****************************************************
  * Access protection for memory regions              *
  * Free Source Code snippet (For Delphi)             *
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
   System.SysUtils,Winapi.Windows;

// Exposed Procedures

// Allocates protected memory, moves original data to the protected area, and returns the new pointer.
procedure ProtectMemory(var DataPtr: Pointer; Size: NativeUInt);

// Unprotects the specified memory region by restoring its original access.
procedure UnProtectMemory(DataPtr: Pointer);

// Releases the specified memory region by restoring access, clearing its memory, and freeing it.
procedure ReleaseProtectedMemory(DataPtr: Pointer);

// Releases and clears all protected memory regions.
procedure ReleaseAllProtectedMemory;

implementation

uses
  Generics.Collections;

type
  TProtectedMemory = record
    DataPtr: Pointer;
    OriginalDataPtr: Pointer;
    Size: NativeUInt;
    OldProtect: DWORD;
  end;
  PProtectedMemory = ^TProtectedMemory;

type
  TProtectedMemoryList = class(TList<PProtectedMemory>)
  public
    procedure ProtectMemory(var DataPtr: Pointer; Size: NativeUInt);
    procedure ReleaseMemory(DataPtr: Pointer; ClearTheMemory: Boolean);
    procedure ClearList;
    destructor Destroy; override;
  end;

var
  ProtectedMemoryList: TProtectedMemoryList;

function SetMemoryProtection(const DataPtr: Pointer; const Size: NativeUInt; Protect: DWORD): DWORD;
var
  OldProtect: DWORD;
begin
  if not VirtualProtect(DataPtr, Size, Protect, @OldProtect) then
    RaiseLastOSError;
  Result := OldProtect;
end;

procedure RemoveMemoryProtection(const DataPtr,OriginalDataPtr: Pointer; const Size: NativeUInt; const OldProtect: DWORD; const ClearTheMemory: Boolean);
begin
  if ClearTheMemory then
  begin
    SetMemoryProtection(DataPtr, Size, PAGE_READWRITE);
    ZeroMemory(DataPtr, Size);
    VirtualFree(DataPtr, 0, MEM_RELEASE); // Free the old memory
  end else
  if (not ClearTheMemory) or (OldProtect <> PAGE_READWRITE) then
  begin
    SetMemoryProtection(DataPtr, Size, OldProtect);
    System.Move(DataPtr^, OriginalDataPtr^, Size);
    ZeroMemory(DataPtr, Size);
    VirtualFree(DataPtr, 0, MEM_RELEASE); // Free the old memory
  end;
end;

function FindProtectedMemory(DataPtr: Pointer): PProtectedMemory;
var
  i: Integer;
  Mem: PProtectedMemory;
begin
  Result := nil;
  for i := 0 to ProtectedMemoryList.Count - 1 do
  begin
    Mem := ProtectedMemoryList[i];
    if Mem^.DataPtr = DataPtr then
    begin
      Result := Mem;
      Exit;
    end;
  end;
end;

procedure TProtectedMemoryList.ProtectMemory(var DataPtr: Pointer; Size: NativeUInt);
var
  OldProtect: DWORD;
  NewMem: PProtectedMemory;
  ProtectedMemory: Pointer;
begin
  ProtectedMemory := VirtualAlloc(nil, Size, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
  if ProtectedMemory = nil then
    RaiseLastOSError;

  System.Move(DataPtr^, ProtectedMemory^, Size);

  OldProtect := SetMemoryProtection(ProtectedMemory, Size, PAGE_NOACCESS);

  try
    New(NewMem);
    NewMem^.DataPtr := ProtectedMemory;
    NewMem^.OriginalDataPtr := DataPtr;

    NewMem^.Size := Size;
    NewMem.OldProtect := OldProtect;
    try
      Self.Add(NewMem);
    except
      Dispose(NewMem);
      raise;
    end;
  except
    RemoveMemoryProtection(ProtectedMemory,DataPtr, Size, OldProtect, False);
    raise;
  end;

  ZeroMemory(DataPtr,Size);

  DataPtr := ProtectedMemory;
end;

procedure TProtectedMemoryList.ReleaseMemory(DataPtr: Pointer; ClearTheMemory: Boolean);
var
  i: Integer;
  Mem: PProtectedMemory;
begin
  for i := Self.Count - 1 downto 0 do
  begin
    if Self[i]^.DataPtr = DataPtr then
    begin
      Mem := Self[i];
      RemoveMemoryProtection(Mem^.DataPtr,Mem^.OriginalDataPtr, Mem^.Size, Mem^.OldProtect, ClearTheMemory);
      Self.Delete(i);
      Dispose(Mem);
      Exit;
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
    RemoveMemoryProtection(Mem^.DataPtr, Mem^.OriginalDataPtr, Mem^.Size, Mem^.OldProtect, True);
    Dispose(Mem);
  end;
  Self.Clear;
end;

destructor TProtectedMemoryList.Destroy;
begin
  ClearList;
  inherited Destroy;
end;

procedure ProtectMemory(var DataPtr: Pointer; Size: NativeUInt);
begin
  ProtectedMemoryList.ProtectMemory(DataPtr, Size);
end;

procedure UnProtectMemory(DataPtr: Pointer);
begin
  ProtectedMemoryList.ReleaseMemory(DataPtr, False);
end;

procedure ReleaseProtectedMemory(DataPtr: Pointer);
begin
  ProtectedMemoryList.ReleaseMemory(DataPtr, True);
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

