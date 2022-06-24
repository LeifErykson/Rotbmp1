        section .text
        global  rotbmp1

rotbmp1:
        ; prologue
        push    ebp
        mov     ebp, esp
        sub     esp, 8
        push    ebx
        push    edx

        ; Bytes_per_row
        mov     edi, [ebp+12]
        add     edi, 31
        shr     edi, 5
        shl     edi, 2
        mov     [ebp-4], edi

        ; how many bytes contain full pixels
        mov     edi, [ebp+12]
        add     edi, 7
        shr     edi, 3
        dec     edi
        mov     [ebp-8], edi

        ; left up (rotated file)
        mov     edx, [ebp+12]
        dec     edx
        imul    edx, [ebp-4]
        add     edx, [ebp+16]

        ; left down (not rotated file)
        mov     ebx, [ebp+8]

        ; row counter
        mov     esi, [ebp+12]

        ; column counter
        mov     edi, [ebp+12]

        ; load bitmask
        mov     ah, 0x80

        ; prepare ecx
        xor     ecx, ecx

main_loop:
        mov     al, [ebx]
        and     al, ah
        jz      next_bit           ; if 0 move on

add_1:
        mov     al, 0x80
        shr     al, cl
        add     ch, al

; higher level
next_bit:
        add     ebx, [ebp-4]
        dec     edi
        jz      next_column
        inc     cl              ; handled exception
        test    cl, 0x08        ; if byte created (cl=8) /cmp
        jz      main_loop

update_byte:
        xchg    ch, [edx]
        xor     ecx, ecx        ; cl=0, ch=0
        inc     edx             ; move pointer to next byte
        jmp     main_loop

next_column:
        xchg    ch, [edx]
        xor     ecx, ecx        ; cl=0, ch=0
        dec     esi
        jz      end
        mov     edi, [ebp+12]
        imul    edi, [ebp-4]
        sub     ebx, edi
        sub     edx, [ebp-8]
        sub     edx, [ebp-4]    ; pointer 1 level lower at the beginning
        mov     edi, [ebp+12]
        shr     ah, 1 
        jnz     main_loop

update_bitmask_and_byte:
        mov     ah, 0x80        ; mask ended, load new mask
        inc     ebx             ; move pointer to next byte of row
        jmp     main_loop

end:
        ; epilogue
        pop     edx
        pop     ebx
        mov     esp, ebp
        pop     ebp
        ret