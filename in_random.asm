; file.asm - использование файлов в NASM
extern printf
extern rand

extern CIRCLE
extern RECTANGLE
extern TRIANGLE


global Random
Random:
section .data
    .maxCoordinate  dq  20
section .text
push rbp
mov rbp, rsp

    xor     rax, rax    ;
    call    rand        ; запуск генератора случайных чисел
    xor     rdx, rdx    ; обнуление перед делением
    idiv    qword[.maxCoordinate]       ; (/%) -> остаток в rdx
    mov     rax, rdx
    inc     rax         ; должно сформироваться случайное число

leave
ret


global RandomColor
RandomColor:
section .data
    .colorsCount    dq  7
section .text
push rbp
mov rbp, rsp

    xor     rax, rax    ;
    call    rand        ; запуск генератора случайных чисел
    xor     rdx, rdx    ; обнуление перед делением
    idiv    qword[.colorsCount]       ; (/%) -> остаток в rdx
    mov     rax, rdx

leave
ret


global InRandomCircle
InRandomCircle:
section .bss
    .pcircle    resq    1   ; адрес прямоугольника
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес прямоугольника
    mov     [.pcircle], rdi
    ; Генерация координат прямоугольника
    call    Random
    mov     rbx, [.pcircle]
    mov     [rbx], eax      ; x

    call    Random
    mov     rbx, [.pcircle]
    mov     [rbx+4], eax    ; y

.generateRedius:
    call    Random
    mov     rbx, [.pcircle]
    mov     [rbx+8], eax    ; x2
    mov     ebx, eax
    cmp     ebx, 0 
    jle     .generateRedius ; c <= 0

    call    RandomColor
    mov     rbx, [.pcircle]
    mov     [rbx+12], eax   ; цвет
leave
ret


global InRandomRectangle
InRandomRectangle:
section .bss
    .prectangle  resq 1   ; адрес прямоугольника
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес прямоугольника
    mov     [.prectangle], rdi
    ; Генерация координат прямоугольника
    call    Random
    mov     rbx, [.prectangle]
    mov     [rbx], eax      ; x1

    call    Random
    mov     rbx, [.prectangle]
    mov     [rbx+4], eax    ; y1

    call    Random
    mov     rbx, [.prectangle]
    mov     [rbx+8], eax    ; x2
    mov     ecx, [rbx]      ; x1
    mov     ebx, eax
    cmp     ebx, ecx 
    jle     .generateX2     ; x2 <= x1
    jmp     .next

.generateX2:
    mov     rbx, [.prectangle]
    mov     [rbx+8], eax    ; x2
    mov     ecx, [rbx]      ; x1
    add     eax, ecx        ; x2 + x1
    mov     [rbx+8], eax    ; x2 = x2 + x1
    jmp     .next

.next:
    call    Random
    mov     rbx, [.prectangle]
    mov     [rbx+12], eax   ; y2
    mov     ecx, [rbx+4]    ; y1
    mov     ebx, eax
    cmp     ebx, ecx
    jge     .generateY2     ; y2 >= y1 

.generateY2: 
    mov     rbx, [.prectangle]
    mov     [rbx+12], eax   ; y2
    mov     ecx, [rbx+4]    ; y1
    sub     ecx, eax        ;y1 - y2
    mov     [rbx+12], ecx   ; y2 = y1 - y2
    jmp     .color

.color:
    call    RandomColor
    mov     rbx, [.prectangle]
    mov     [rbx+16], eax   ; цвет
leave
ret


global InRandomTriangle
InRandomTriangle:
section .bss
    .ptriangle  resq 1   ; адрес треугольника
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес треугольника
    mov     [.ptriangle], rdi
    ; Генерация сторон треугольника
    call    Random
    mov     rbx, [.ptriangle]
    mov     [rbx], eax          ; x1
    call    Random
    mov     rbx, [.ptriangle]
    mov     [rbx+4], eax        ; y1
    call    Random
    mov     rbx, [.ptriangle]
    mov     [rbx+8], eax        ; x2
    call    Random
    mov     rbx, [.ptriangle]
    mov     [rbx+16], eax       ; x3

.generateY2:
    call    Random
    mov     rbx, [.ptriangle]
    mov     [rbx+8], eax    ; y2
    mov     ecx, [rbx+4]    ; y1
    mov     ebx, eax
    cmp     ebx, ecx
    je      .checkCoordinates12ForEquality  ; y2 == y1 
    jmp     .generateY3

.checkCoordinates12ForEquality:
    mov     rbx, [.ptriangle]
    mov     ecx, [rbx]      ; x1
    mov     ebx, [rbx+8]    ; x2
    cmp     ebx, ecx
    je      .generateY2     ; (x1, y1) == (x2, y2)
    jmp     .generateY3

.generateY3:
    call    Random
    mov     rbx, [.ptriangle]
    mov     [rbx+20], eax   ; y3
    mov     ecx, [rbx+4]    ; y1
    mov     ebx, eax
    cmp     ebx, ecx
    je      .checkCoordinates13ForEquality  ; y3 == y1 

    mov     rbx, [.ptriangle]
    mov     ecx, [rbx+20]   ; y3
    mov     ebx, [rbx+12]   ; y2
    cmp     ebx, ecx
    je      .checkCoordinates23ForEquality  ; y3 == y2

    jmp     .color

.checkCoordinates13ForEquality:
    mov     rbx, [.ptriangle]
    mov     ecx, [rbx]      ; x1
    mov     ebx, [rbx+16]   ; x3
    cmp     ebx, ecx
    je      .generateY3     ; (x1, y1) == (x3, y3)
    jmp     .color
.checkCoordinates23ForEquality:
    mov     rbx, [.ptriangle]
    mov     ecx, [rbx+8]    ; x2
    mov     ebx, [rbx+16]   ; x3
    cmp     ebx, ecx
    je      .generateY3     ; (x2, y2) == (x3, y3)
    jmp     .color
.color:
    call    RandomColor
    mov     rbx, [.ptriangle]
    mov     [rbx+24], eax   ; цвет
leave
ret


global InRandomShape
InRandomShape:
section .data
    .keys   dq 3
section .bss
    .pshape     resq    1   ; адрес фигуры
    .key        resd    1   ; ключ
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес фигуры
    mov [.pshape], rdi

    ; Формирование признака фигуры
    xor     eax, eax
    call    rand            ; запуск генератора случайных чисел

    xor     edx, edx        ; обнуление перед делением
    idiv    qword[.keys]    ; (/%) -> остаток в edx
    mov     eax, edx
    inc     eax         ; должно сформироваться случайное число

    mov rdi, [.pshape]
    mov [rdi], eax      ; запись ключа в фигуру
    cmp eax, [CIRCLE]
    je .circleInRandom
    cmp eax, [RECTANGLE]
    je .rectangleInRandom
    cmp eax, [TRIANGLE]
    je .triangleInRandom
    xor eax, eax        ; код возврата = 0
    jmp     .return
.circleInRandom:
    ; Генерация круга
    add     rdi, 4
    call    InRandomCircle
    mov     eax, 1      ;код возврата = 1
    jmp     .return
.rectangleInRandom:
    ; Генерация прямоугольника
    add     rdi, 4
    call    InRandomRectangle
    mov     eax, 1      ;код возврата = 1
    jmp     .return
.triangleInRandom:
    ; Генерация треугольника
    add     rdi, 4
    call    InRandomTriangle
    mov     eax, 1      ;код возврата = 1
.return:
leave
ret


global InRandomContainer
InRandomContainer:
section .bss
    .pcont      resq    1   ; адрес контейнера
    .plength    resq    1   ; адрес для сохранения числа введенных элементов
    .psize      resd    1   ; число порождаемых элементов
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi       ; сохраняется указатель на контейнер
    mov [.plength], rsi     ; сохраняется указатель на длину
    mov [.psize], edx       ; сохраняется число порождаемых элементов
    
    ; В rdi адрес начала контейнера
    xor ebx, ebx            ; число фигур = 0
.loop:
    cmp ebx, edx
    jge     .return
    ; сохранение рабочих регистров
    push rdi
    push rbx
    push rdx

    call    InRandomShape   ; ввод фигуры
    cmp rax, 0              ; проверка успешности ввода
    jle  .return            ; выход, если признак меньше или равен 0

    pop rdx
    pop rbx
    inc rbx

    pop rdi
    add rdi, 32             ; адрес следующей фигуры

    jmp .loop
.return:
    mov rax, [.plength]     ; перенос указателя на длину
    mov [rax], ebx          ; занесение длины
leave
ret
