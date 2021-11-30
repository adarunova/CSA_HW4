; file.asm - использование файлов в NASM
extern printf
extern fprintf
extern fscanf

extern CIRCLE
extern RECTANGLE
extern TRIANGLE

extern Random
extern RandomColor
extern InRandomRectangle


global InCircle
InCircle:
section .data
    .errorCircle    db "Incorrect CIRCLE. Radius cannot be zero or less. The radius will be randomly generated.",10,0
    .errorColor     db "Incorrect color! The COLOR will be randomly generated.",10,0
    .inputFormat    db "%d%d%d%d",0
section .bss
    .FILE       resq    1   ; временное хранение указателя на файл
    .pcircle    resq    1   ; адрес прямоугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pcircle], rdi       ; сохраняется адрес круга
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Ввод прямоугольника из файла
    mov     rdi, [.FILE]
    mov     rsi, .inputFormat   ; Формат - 1-й аргумент
    mov     rdx, [.pcircle]     ; x
    mov     rcx, [.pcircle]
    add     rcx, 4              ; y
    mov     r8,  [.pcircle]
    add     r8,  8              ; radius
    mov     r9,  [.pcircle]
    add     r9,  12             ; цвет
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

    mov     rdx,  [.pcircle]
    mov     eax, [rdx+8]
    cmp     eax,  0
    jle     .generateRadius

.checkColor:
    mov     rdx,  [.pcircle]
    mov     eax, [rdx+12]
    cmp     eax,  0
    jl      .generateColor
    cmp     eax,  6
    jg      .generateColor
    jmp     .return

.generateRadius:
    mov     rdi, .errorCircle
    call    printf
    mov     rbx, [.pcircle]
    call    Random
    mov     [rbx+8], eax        ; radius
    jmp     .checkColor
.generateColor:
    mov     rdi, .errorColor
    call    printf
    mov     rbx, [.pcircle]
    call    RandomColor
    mov     [rbx+12], eax        
    jmp     .return
.return:
leave
ret


global InRectangle
InRectangle:
section .data
    .errorRectangle db  "Incorrect RECTANGLE. Wrong corner coordinates! The RECTANGLE will be randomly generated.",10,0
    .errorColor     db  "Incorrect color! The COLOR will be randomly generated.",10,0
    .inputFormat1   db  "%d%d%d%d",0
    .inputFormat2   db  "%d",0
section .bss
    .FILE       resq    1   ; временное хранение указателя на файл
    .prectangle resq    1   ; адрес прямоугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.prectangle], rdi  ; сохраняется адрес прямоугольника
    mov     [.FILE], rsi        ; сохраняется указатель на файл

    ; Ввод прямоугольника из файла
    mov     rdi, [.FILE]
    mov     rsi, .inputFormat1  ; Формат - 1-й аргумент
    mov     rdx, [.prectangle]  ; x1
    mov     rcx, [.prectangle]
    add     rcx, 4              ; y1
    mov     r8,  [.prectangle]
    add     r8,  8              ; x2
    mov     r9,  [.prectangle]
    add     r9,  12             ; y2
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

    mov     rdi, [.FILE]
    mov     rsi, .inputFormat2  ; Формат - 1-й аргумент
    mov     rdx, [.prectangle]
    add     rdx, 16             ; цвет
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

    mov     rdx,  [.prectangle]
    mov     eax, [rdx+8]
    mov     ebx, [rdx]
    cmp     eax,  ebx
    jle     .generateNewRectangle
    mov     rdx,  [.prectangle]
    mov     ecx, [rdx+12]
    mov     edx, [rdx+4]
    cmp     ecx,  edx
    jge     .generateNewRectangle

.checkColor:
    mov     rdx,  [.prectangle]
    mov     eax, [rdx+16]
    cmp     eax,  0
    jl      .generateColor
    cmp     eax,  6
    jg      .generateColor
    jmp     .return
.generateNewRectangle:
    mov     rdi, .errorRectangle
    call    printf
    mov     rdi, [.prectangle]
    call    InRandomRectangle
    jmp     .checkColor

.generateColor:
    mov     rdi, .errorColor
    call    printf
    mov     rbx, [.prectangle]
    call    RandomColor
    mov     [rbx+16], eax
    jmp     .return
.return:
leave
ret


global InTriangle
InTriangle:
section .data
    .errorColor   db    "Incorrect color! The COLOR will be randomly generated.",10,0
    .inputFormat1 db    "%d%d%d%d",0
    .inputFormat2 db    "%d%d%d",0
section .bss
    .FILE       resq    1   ; временное хранение указателя на файл
    .ptriangle  resq    1   ; адрес треугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.ptriangle], rdi   ; сохраняется адрес треугольника
    mov     [.FILE], rsi        ; сохраняется указатель на файл

    ; Ввод треугольника из файла
    mov     rdi, [.FILE]
    mov     rsi, .inputFormat1  ; Формат - 1-й аргумент
    mov     rdx, [.ptriangle]   ; x1
    mov     rcx, [.ptriangle]
    add     rcx, 4              ; y1
    mov     r8,  [.ptriangle]
    add     r8,  8              ; x2
    mov     r9,  [.ptriangle]
    add     r9,  12             ; y2
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

    mov     rdi, [.FILE]
    mov     rsi, .inputFormat2  ; Формат - 1-й аргумент
    mov     rdx, [.ptriangle]
    add     rdx, 16             ; x3
    mov     rcx, [.ptriangle]
    add     rcx, 20             ; y3
    mov     r8, [.ptriangle]
    add     r8, 24              ; цвет
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

    mov     rdx,  [.ptriangle]
    mov     eax, [rdx+24]
    cmp     eax,  0
    jl      .generateColor
    cmp     eax,  6
    jg      .generateColor
    jmp     .return

.generateColor:
    mov     rdi, .errorColor
    call    printf
    mov     rbx, [.ptriangle]
    call    RandomColor
    mov     [rbx+24], eax
    jmp     .return
.return:
leave
ret


global InShape
InShape:
section .data
    .tagFormat   db     "%d",0
section .bss
    .FILE       resq    1   ; временное хранение указателя на файл
    .pshape     resq    1   ; адрес фигуры
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pshape], rdi  ; сохраняется адрес фигуры
    mov     [.FILE], rsi    ; сохраняется указатель на файл

    ; чтение признака фигуры и его обработка
    mov     rdi, [.FILE]
    mov     rsi, .tagFormat
    mov     rdx, [.pshape]  ; адрес начала фигуры (ее признак)
    xor     rax, rax        ; нет чисел с плавающей точкой
    call    fscanf

    mov rcx, [.pshape]      ; загрузка адреса начала фигуры
    mov eax, [rcx]          ; и получение прочитанного признака
    cmp eax, [CIRCLE]
    je .circleIn
    cmp eax, [RECTANGLE]
    je .rectangleIn
    cmp eax, [TRIANGLE]
    je .triangleIn
    cmp eax, 0
    je .EOF
    xor eax, eax
    jmp .return
.circleIn:
    ; Ввод круга
    mov     rdi, [.pshape]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InCircle
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.rectangleIn:
    ; Ввод прямоугольника
    mov     rdi, [.pshape]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InRectangle
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.triangleIn:
    ; Ввод треугольника
    mov     rdi, [.pshape]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InTriangle
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.EOF:
    mov rax, 4
    jmp .return
.return:
leave
ret


global InContainer
InContainer:
section .data
    .errorShape db  "Incorrect figure key!!! Input process will be interrupted.",10,0
section .bss
    .pcontainer resq    1   ; адрес контейнера
    .plength    resq    1   ; адрес для сохранения числа введенных элементов
    .FILE       resq    1   ; указатель на файл
section .text
push rbp
mov rbp, rsp

    mov [.pcontainer], rdi  ; сохраняется указатель на контейнер
    mov [.plength],  rsi    ; сохраняется указатель на длину
    mov [.FILE],  rdx       ; сохраняется указатель на файл
    ; В rdi адрес начала контейнера
    xor rbx, rbx            ; число фигур = 0
    mov rsi, rdx            ; перенос указателя на файл
.loop:

    cmp rbx, 10001
    jge .return

    ; сохранение рабочих регистров
    push rdi
    push rbx

    mov  rsi, [.FILE]
    mov  rax, 0         ; нет чисел с плавающей точкой
    call InShape        ; ввод фигуры
    cmp  eax, 0         ; проверка успешности ввода
    jle  .printError    ; выход, если признак меньше или равен 0
    cmp  eax, 4         ; проверка успешности ввода
    je  .return         ; выход, если признак меньше или равен 0

    pop rbx
    pop rdi

    inc rbx
    add rdi, 32         ; адрес следующей фигуры

    jmp .loop
    jmp .return

.printError:
    mov     rdi, .errorShape
    call    printf
    jmp     .return
.return:
    mov rax, [.plength] ; перенос указателя на длину
    mov [rax], ebx      ; занесение длины
leave
ret

