; file.asm - использование файлов в NASM
extern printf
extern fprintf

extern PerimeterCircle
extern PerimeterRectangle
extern PerimeterTriangle

extern CIRCLE
extern RECTANGLE
extern TRIANGLE


global OutCircle
OutCircle:
section .data
    .outfmt db "It is CIRCLE. Center coordinates: (%d, %d), radius: %d. Perimeter = %g. Color: ",0
section .bss
    .pcircle    resq  1
    .FILE       resq  1   ; временное хранение указателя на файл
    .p          resq  1   ; вычисленный периметр круга
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pcircle], rdi ; сохраняется адрес круга
    mov     [.FILE],    rsi ; сохраняется указатель на файл

    ; Вычисление периметра круга (адрес уже в rdi)
    call    PerimeterCircle
    movsd   [.p], xmm0      ; сохранение периметра

    ; Вывод информации о круге в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt    ; Формат - 2-й аргумент
    mov     rax, [.pcircle] ; адрес круга
    mov     edx, [rax]      ; x
    mov     ecx, [rax+4]    ; y
    mov     r8,  [rax+8]    ; радиус
    movsd   xmm0, [.p]
    mov     rax, 1          ; есть числа с плавающей точкой
    call    fprintf

    mov     rdi, [.FILE]
    mov     rax, [.pcircle]
    mov     edx,  [rax+12]   ; цвет
    call    OutColor

leave
ret


global OutRectangle
OutRectangle:
section .data
    .outfmt  db "It is RECTANGLE. Coordinates of angles: (%d, %d), (%d, %d). Perimeter = %g. Color: ",0
section .bss
    .prectangle     resq  1
    .FILE           resq  1 ; временное хранение указателя на файл
    .p              resq  1 ; вычисленный периметр прямоугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.prectangle], rdi   ; сохраняется адрес прямоугольника
    mov     [.FILE], rsi    ; сохраняется указатель на файл

    ; Вычисление периметра прямоугольника (адрес уже в rdi)
    call    PerimeterRectangle
    movsd   [.p], xmm0      ; сохранение периметра

    ; Вывод информации о прямоугольнике в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt    ; Формат
    mov     rax, [.prectangle]   ; адрес прямоугольника
    mov     edx, [rax]      ; x1
    mov     ecx, [rax+4]    ; y1
    mov     r8,  [rax+8]    ; x2
    mov     r9,  [rax+12]   ; y2
    movsd   xmm0, [.p]
    mov     rax, 1          ; есть числа с плавающей точкой
    call    fprintf

    mov     rdi, [.FILE]
    mov     rax, [.prectangle]
    mov     edx, [rax+16]
    call    OutColor

leave
ret


global OutTriangle
OutTriangle:
section .data
    .outfmt1 db "It is TRIANGLE. Coordinates of vertices: (%d, %d), (%d, %d)",0
    .outfmt2 db ", (%d, %d). Perimeter =  %g. Color: ",0
section .bss
    .ptriangle  resq  1
    .FILE       resq  1 ; временное хранение указателя на файл
    .p          resq  1 ; вычисленный периметр треугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранени принятых аргументов
    mov     [.ptriangle], rdi   ; сохраняется адрес треугольника
    mov     [.FILE], rsi        ; сохраняется указатель на файл

    ; Вычисление периметра треугольника (адрес уже в rdi)
    call    PerimeterTriangle
    movsd   [.p], xmm0  ; сохранение периметра

    ; Вывод информации о треугольнике в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt1       ; Формат
    mov     rax, [.ptriangle]   ; адрес треугольника
    mov     edx, [rax]          ; x1
    mov     ecx, [rax+4]        ; y1
    mov     r8,  [rax+8]        ; x2
    mov     r9,  [rax+12]       ; y2
    call    fprintf

    mov     rdi, [.FILE]
    mov     rsi, .outfmt2       ; Формат
    mov     rax, [.ptriangle]
    mov     edx, [rax+16]       ; x3
    mov     ecx, [rax+20]       ; y3
    mov     rax, 0              ; нет чисел с плавающей точкой

    movsd   xmm0, [.p]
    mov     rax, 1      ; есть числа с плавающей точкой
    call    fprintf

    mov     rdi, [.FILE]
    mov     rax, [.ptriangle]
    mov     edx,  [rax+24]
    call    OutColor

leave
ret


global OutShape
OutShape:
section .data
    .outfmt db "%d: ",0
section .bss
    .shapeNumber    resq    1
    .pshape     resq    1
    .FILE       resq    1 ; временное хранение указателя на файл
section .text
push rbp
mov rbp, rsp
    
    mov [.shapeNumber], rdx
    mov [.pshape],  rdi
    mov [.FILE],    rsi

    ; В rdi адрес фигуры
    mov eax, [rdi]
    cmp eax, [CIRCLE]
    je .circleOut
    cmp eax, [RECTANGLE]
    je .rectangleOut
    cmp eax, [TRIANGLE]
    je .triangleOut
    mov rax, 0
    mov edx, -1
    jmp     .return
.circleOut:

    mov rdi, [.FILE]
    mov rsi, .outfmt            ; формат для вывода фигуры
    mov rdx, [.shapeNumber]     ; индекс текущей фигуры
    xor rax, rax                ; только целочисленные регистры
    call fprintf


    mov rsi, [.FILE]
    mov rdi, [.pshape]

    ; Вывод круга
    add     rdi, 4
    inc     edx
    ;mov     rdx, [edx]
    mov     [.shapeNumber], rdx

    call    OutCircle

    jmp     .return
.rectangleOut:
    mov rdi, [.FILE]
    mov rsi, .outfmt            ; формат для вывода фигуры
    mov edx, [.shapeNumber]     ; индекс текущей фигуры
    xor rax, rax                ; только целочисленные регистры
    call fprintf

    mov rsi, [.FILE]
    mov rdi, [.pshape]

    ; Вывод прямоугольника
    add     rdi, 4
    inc     edx
    mov     [.shapeNumber], edx

    call    OutRectangle
    jmp     .return
.triangleOut:
    mov rdi, [.FILE]
    mov rsi, .outfmt            ; формат для вывода фигуры
    mov edx, [.shapeNumber]     ; индекс текущей фигуры
    xor rax, rax                ; только целочисленные регистры
    call fprintf

    mov rsi, [.FILE]
    mov rdi, [.pshape]

    ; Вывод треугольника
    add     rdi, 4
    inc     edx
    mov     [.shapeNumber], edx
    call    OutTriangle
.return:
leave
ret

global OutColor
OutColor:
section .data
    RED     db "RED",10, 0
    ORANGE  db "ORANGE",10, 0
    YELLOW  db "YELLOW",10, 0
    GREEN   db "GREEN",10, 0
    CYAN    db "CYAN",10, 0
    BLUE    db "BLUE",10, 0
    PURPLE  db "PURPLE",10, 0
section .bss
    .pcolor     resq  1
    .FILE       resq  1 ; временное хранение указателя на файл
section .text
push rbp
mov rbp, rsp
    cmp edx, 0 
    je  .red
    cmp edx, 1
    je  .orange
    cmp edx, 2
    je  .yellow
    cmp edx, 3 
    je  .green
    cmp edx, 4
    je  .cyan
    cmp edx, 5
    je  .blue
    cmp edx, 6
    je  .purple
    jmp     .return
.red:
    mov esi, RED
    call    fprintf
    jmp     .return
.orange:
    mov esi, ORANGE
    call    fprintf
    jmp     .return
.yellow:
    mov esi, YELLOW
    call    fprintf
    jmp     .return
.green:
    mov esi, GREEN
    call    fprintf
    jmp     .return
.cyan:
    mov esi, CYAN
    call    fprintf
    jmp     .return
.blue:
    mov esi, BLUE
    call    fprintf
    jmp     .return
.purple:
    mov esi, PURPLE
    call    fprintf
    jmp     .return
.return:
leave
ret

global OutContainer
OutContainer:
section .data
    .numFmt  db  "%d: ",0
section .bss
    .pcontainer resq    1   ; адрес контейнера
    .length     resd    1   ; адрес для сохранения числа введенных элементов
    .FILE       resq    1   ; указатель на файл
section .text
push rbp
mov rbp, rsp

    mov [.pcontainer], rdi   ; сохраняется указатель на контейнер
    mov [.length], esi  ; сохраняется число элементов
    mov [.FILE],  rdx   ; сохраняется указатель на файл

    ; В rdi адрес начала контейнера
    mov rbx, rsi            ; число фигур
    xor ecx, ecx            ; счетчик фигур = 0
    xor edx, edx            ; счётчик выводимых фигур = 0
    mov rsi, rdx            ; перенос указателя на файл
.loop:
    cmp ecx, ebx            ; проверка на окончание цикла
    jge .return             ; перебрали все фигуры

    push rbx
    push rcx


    ; Вывод текущей фигуры
    mov edx, ecx
    mov rdi, [.pcontainer]
    mov rsi, [.FILE]
    call OutShape           ; получение периметра первой фигуры


    pop rcx
    pop rbx

    cmp edx, -1
    je .nextShape
    jmp .incrementIndex

.incrementIndex:
    inc ecx                 ; индекс следующей фигуры
    jmp .nextShape

.nextShape:
    mov rax, [.pcontainer]
    add rax, 32             ; адрес следующей фигуры
    mov [.pcontainer], rax
    jmp .loop
.return:
leave
ret

