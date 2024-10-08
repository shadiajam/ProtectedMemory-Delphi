
# Protected Memory Unit for Delphi

This unit provides a secure memory protection unit for Delphi, allowing developers to protect memory regions, preventing access and ensuring that sensitive data is cleared when no longer needed.

## Why you need it!?

It's crucial to protect sensitive information, such as encryption keys, passwords, and other confidential data, from unauthorized access. Without proper memory protection, even temporarily stored sensitive data in memory can be vulnerable to attacks like memory dumps or process injection. This unit helps to lock and protect memory, ensuring that sensitive data is shielded and securely erased when no longer needed.

## Usage

1. **Clone or simply download the unit**: Clone the repository or download the `ProtectedMemory` unit to your Delphi project.
2. **Start using it**: Use the `ProtectMemory`, `UnProtectMemory`, and `ReleaseProtectedMemory` procedures to secure your memory.
3. **Release the Memory**: Ensure that memory is released and cleared after use by calling `ReleaseAllProtectedMemory`.

### Example: protect constant data

```delphi
uses
  ProtectedMemory;

var
  Data: array[0..255] of Byte;
  DataPtr: Pointer;
begin
  Data[0] := 99;
  Data[1] := 11;
  Data[2] := 22;
  Data[3] := 33;
  Data[4] := 44;
  Data[5] := 55;
  DataPtr := @Data[0];
  
  // Protect the memory (prevents access to the memory region)
  ProtectMemory(DataPtr, SizeOf(Data));

  // Accessing the protected memory here will return zeros.
  // Unprotect the memory before accessing it
  UnProtectMemory(DataPtr);

  // Optionally release the memory and clear its content
  ReleaseProtectedMemory(DataPtr);
end;
```

### Example: protect delphi managed string

```delphi
uses
  ProtectedMemory;

var
  SensitiveStr: string;
  NonSensitiveStr: string;
  DataPtr: Pointer;
begin
  SensitiveStr := 'Sensitive Data';
  NonSensitiveStr := 'Not Sensitive Data';

  // Get a pointer to SensitiveStr's memory
  DataPtr := Pointer(SensitiveStr);

  // Protect the memory region containing SensitiveStr
  Writeln('Protecting memory...');
  ProtectMemory(DataPtr, Length(SensitiveStr) * SizeOf(Char));

  // Accessing SensitiveStr here will return zeros or show undefined behavior
  Writeln('SensitiveStr after protection: ', SensitiveStr);

  // You can still access NonSensitiveStr, which is unaffected
  NonSensitiveStr := 'Updated Non-Sensitive Data';
  Writeln('NonSensitiveStr: ', NonSensitiveStr);

  // UnProtect Memory it's reutrn it's orginal data
  Writeln('Releasing memory...');
  UnProtectMemory(DataPtr);

  // SensitiveStr is now restored
  Writeln('Restored SensitiveStr: ', SensitiveStr);
end;
```

### Procedures

- **`ProtectMemory(var DataPtr: Pointer; Size: NativeUInt)`**: Protects the specified memory region by setting it to `PAGE_NOACCESS` and locking it to prevent paging. The data is copied to a new protected memory block, and the original pointer is updated to point to this protected block.
  
- **`UnProtectMemory(DataPtr: Pointer)`**: Restores the memory protection to `PAGE_READWRITE` and removes the region from the list of protected memory blocks.

- **`ReleaseProtectedMemory(DataPtr: Pointer)`**: Restores memory access, clears the content by securely zeroing the memory, and removes it from the protected list.

- **`ReleaseAllProtectedMemory()`**: Releases and clears all protected memory regions.

## Author

- **Shadi Ajam**  

  [![GitHub](https://img.shields.io/badge/GitHub-333?logo=github)](https://github.com/shadiajam)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?logo=linkedin)](https://www.linkedin.com/in/shadiajam/)

## Useful Unit, Right?

YES! We’d love your support! Please give it a 🌟 and share it with others.

**Share on social media**:

<a href="https://www.linkedin.com/sharing/share-offsite/?url=https://github.com/shadiajam/ProtectedMemory-Delphi" target="_blank">
  <img src="https://img.shields.io/badge/Share%20on%20LinkedIn-0077B5?logo=linkedin&logoColor=white" alt="Share on LinkedIn" />
</a>
<a href="https://dev.to/new?url=https://github.com/shadiajam/ProtectedMemory-Delphi" target="_blank">
  <img src="https://img.shields.io/badge/Share%20on%20DEV.to-0A0A0A?logo=dev.to&logoColor=white" alt="Share on Dev.to" />
</a>
<a href="https://twitter.com/intent/tweet?text=Check%20out%20this%20awesome%20repository%20on%20GitHub%21&url=https://github.com/shadiajam/ProtectedMemory-Delphi" target="_blank">
  <img src="https://img.shields.io/badge/Share%20on%20X-1DA1F2?logo=X&logoColor=white" alt="Share on X" />
</a>
<a href="https://reddit.com/submit?url=https://github.com/shadiajam/ProtectedMemory-Delphi&title=Check%20out%20this%20awesome%20repository%20on%20GitHub%21" target="_blank">
  <img src="https://img.shields.io/badge/Share%20on%20Reddit-FF4500?logo=reddit&logoColor=white" alt="Share on Reddit" />
</a>
<a href="https://www.facebook.com/sharer/sharer.php?u=https://github.com/shadiajam/ProtectedMemory-Delphi" target="_blank">
  <img src="https://img.shields.io/badge/Share%20on%20Facebook-1877F2?logo=facebook&logoColor=white" alt="Share on Facebook" />
</a>
