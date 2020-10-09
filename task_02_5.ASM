;Разработать программу, которая вводит одномерный массив A[N],
;формирует из элементов массива A новый массив B
;из нечетных чисел и выводит оба массива.

format PE Console

entry Start

include 'win32a.inc'

section '.data' data readable writable
        enterSizeStr      db       'enter the size of A:', 10, 13, 0
        sizeErrorStr      db       'wrong array size', 10, 13, 0
        enterElemStr      db       'enter [%d] element: ', 0
        enterElem         db       '%d', 0
        writeAStr         db       'A:', 10, 13, 0
        writeBStr         db       'B:', 10, 13, 0
        newLine           db       '', 10, 13, 0
        exitStr           db       'end of the program', 0

        sizeA             dd       ?
        sizeB             dd       ?
        A                 dd       ?
        B                 dd       ?
        i                 dd       ?
        j                 dd       ?
        heapA             dd       ?
        heapB             dd       ?
        tmp               dd       ?
        cur               dd       ?


section '.code' code readable executable
        Start:
                call ReadSizeA
                call CreateA
                call ReadA
                call WriteA
                call GetSizeB
                call CreateB
                call FormB
                call WriteB

                ;Очистка памяти

                push [A]
                push 0
                push [heapA]
                call [HeapFree]
                add esp, 12

                push [B]
                push 0
                push [heapB]
                call [HeapFree]
                add esp, 12

                ;Вывод завершающей строки и выход из программы

                push exitStr
                call [printf]
                add esp, 4

                call [getch]
                push 0
                call [ExitProcess]

ReadSizeA:
        push enterSizeStr
        call [printf]
        add esp, 4

        push sizeA
        push enterElem
        call [scanf]
        add esp, 8

        ;Проверка корректности размера А

        cmp [sizeA], 0
        jl WrongSizeA

        cmp [sizeA], 100
        jg WrongSizeA

        ret

WrongSizeA:
        push sizeErrorStr
        call [printf]
        add esp, 4

        jmp Start

        ret

GetSizeB:
        mov [sizeB], 0
        mov [i], -1
        GetSizeBLoop:
               add [i], 1

                mov ecx, [i]
                cmp ecx, [sizeA]
                je FinishLoop

                mov eax, [A]
                mov ecx, [i]
                imul ecx, 4
                add eax, ecx

                ;Выясняем, является ли элемент массива А нечетным, выполняя деление с остатком

                mov eax, dword [eax]
                mov ecx, 2
                mov edx, 0

                div ecx
                mov [tmp], edx

                ;Если да, то добавляем к размеру В единицу

                cmp [tmp], 0
                jg IsOdd

                jmp GetSizeBLoop

        ret

        IsOdd:
                add [sizeB], 1
                jmp GetSizeBLoop

        FinishLoop:
                ret

CreateA:
        push 0
        push 0
        push 0
        call [HeapCreate]
        mov [heapA], eax

        push sizeA*8
        push 0
        push dword [heapA]
        call [HeapAlloc]
        mov [A], eax

       ret

CreateB:
        push 0
        push 0
        push 0
        call [HeapCreate]
        mov dword [heapB], eax

        push sizeB*8
        push 0
        push dword [heapB]
        call [HeapAlloc]
        mov dword [B], eax

        ret

ReadA:
        mov [i], 0
        ReadALoop:
                push [i]
                push enterElemStr
                call [printf]
                add esp, 8

                mov ecx, [i]
                imul ecx, 4
                mov eax, [A]
                add eax, ecx

                push eax
                push enterElem
                call [scanf]
                add esp, 8

                add [i], 1

                mov ecx, [i]
                cmp ecx, [sizeA]
                jne ReadALoop

        ret

FormB:
        mov [i], 0
        mov [j], 0
        FormBLoop:
                mov eax, [A]
                mov ecx, [i]
                imul ecx, 4
                add eax, ecx

                mov ebx, [eax]
                mov [cur], ebx

                ;Проверяем, является ли элемент массива А нечетным

                mov eax, [cur]
                mov ecx, 2
                mov edx, 0
                div ecx

                ;Если да, то добавляем его в В

                cmp edx, 0
                jg AddElemToB

                add [i], 1

                mov ecx, [i]
                cmp ecx, [sizeA]
                je FinishLoop

                jmp FormBLoop

        AddElemToB:
                mov ebx, [B]
                mov ecx, [j]
                imul ecx, 4
                add ebx, ecx

                mov eax, [cur]
                mov [ebx], eax

                add [j], 1
                add [i], 1

                mov ecx, [j]
                cmp ecx, [sizeB]
                je FinishLoop

                jmp FormBLoop

WriteA:
        mov [i], 0
        push writeAStr
        call [printf]
        add esp, 4
        WriteALoop:
                mov ecx, [i]
                imul ecx, 4
                mov eax, [A]
                add eax, ecx

                push dword [eax]
                push enterElem
                call [printf]
                add esp, 8

                push newLine
                call [printf]
                add esp, 4

                add [i], 1

                mov ecx, [i]
                cmp ecx, [sizeA]
                jne WriteALoop
        ret

WriteB:
        push writeBStr
        call [printf]
        add esp, 4

        mov eax, [sizeB]
        cmp eax, 0
        je BIsEmpty

        mov [j], 0
        WriteBLoop:
                mov eax, [B]
                mov ecx, [j]
                imul ecx, 4
                add eax, ecx

                push dword [eax]
                push enterElem
                call [printf]
                add esp, 8

                push newLine
                call [printf]
                add esp, 4

                add [j], 1

                mov ecx, [j]
                cmp ecx, [sizeB]
                jne WriteBLoop

        BIsEmpty:
        ret

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                user32,'USER32.DLL',\
               msvcrt, 'msvcrt.dll'
               include 'api\user32.inc'
               include 'api\kernel32.inc'

        import kernel,\
               ExitProcess, 'ExitProcess',\
               HeapCreate, 'HeapCreate',\
               \HeapAlloc, 'HeapAlloc',\
               HeapFree, 'HeapFree'
               include 'api\kernel32.inc'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'

