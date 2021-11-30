;------------------------------------------------------------------------------
; perimeter.asm - единица компиляции, вбирающая функции вычисления периметра
;------------------------------------------------------------------------------

extern CIRCLE
extern RECTANGLE
extern TRIANGLE

extern printf


global PerimeterCircle
PerimeterCircle:
section .data
    PI dq 3.141592653589793238462   ; число пи
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес круга
    mov eax, [rdi+8]    ; радиус
    shl eax, 1          ; умножаем радиус на 2
    cvtsi2sd xmm0, eax
    mulsd xmm0, [PI]    ; вещественный радиус, умноженный на 2, умножаем на PI

leave
ret


global PerimeterRectangle
PerimeterRectangle:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес прямоугольника
    mov eax, [rdi+8]    ; x2 - x-координата нижнего правого угла
    sub eax, [rdi]      ; x1 - x-координата верхнего левого угла
    shl eax, 1          ; умножаем найденную горизонтальную сторону на 2
    mov ebx, [rdi+4]    ; y1 - y-координата верхнего левого угла
    sub ebx, [rdi+12]   ; y2 - y-координата нижнего правого угла
    shl ebx, 1          ; умножаем найденную вертикальную сторону на 2
    add eax, ebx        ; суммирем все стороны
    cvtsi2sd xmm0, eax

leave
ret


global PerimeterTriangle
PerimeterTriangle:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес треугольника
    mov eax,    [rdi]       ; x1
    sub eax,    [rdi+8]     ; вычитаем из x1 число x2
    imul eax,   eax         ; возводим в квадрат
    mov ebx,    [rdi+4]     ; y1
    sub ebx,    [rdi+12]    ; вычитаем из y1 число y2
    imul ebx,   ebx         ; возводим в квадрат
    add eax,    ebx         ; суммируем длину по x и по y
    cvtsi2sd    xmm0, eax
    sqrtsd      xmm0, xmm0  ; находим длину первой сторны треугольника

    mov eax,    [rdi]       ; x1
    sub eax,    [rdi+16]    ; вычитаем из x1 число x3
    imul eax,   eax         ; возводим в квадрат
    mov ebx,    [rdi+4]     ; y1
    sub ebx,    [rdi+20]    ; вычитаем из y1 число y3
    imul ebx,   ebx         ; возводим в квадрат
    add eax,    ebx         ; суммируем длину по x и по y
    cvtsi2sd    xmm1, eax
    sqrtsd      xmm1, xmm1  ; находим длину первой сторны треугольника
    addsd       xmm0, xmm1  ; прибавляем длину второй стороны к длине первой

    mov         eax, [rdi+8]    ; x2
    sub         eax, [rdi+16]   ; вычитаем из x2 число x3
    imul        eax, eax        ; возводим в квадрат
    mov         ebx, [rdi+12]   ; y2
    sub         ebx, [rdi+20]   ; вычитаем из y2 число y3
    imul        ebx, ebx        ; возводим в квадрат
    add         eax, ebx        ; суммируем длину по x и по y
    cvtsi2sd    xmm1, eax  
    sqrtsd      xmm1, xmm1      ; находим длину первой сторны треугольника
    addsd       xmm0, xmm1      ; находим периметр
leave
ret


global PerimeterShape
PerimeterShape:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес фигуры
    mov eax, [rdi]
    cmp eax, [CIRCLE]
    je  circlePerimeter
    cmp eax, [RECTANGLE]
    je  rectanglePerimeter
    cmp eax, [TRIANGLE]
    je  trianglePerimeter
    xor eax, eax
    cvtsi2sd xmm0, eax
    jmp return
circlePerimeter:
    ; Вычисление периметра круга
    add     rdi, 4
    call    PerimeterCircle
    jmp     return
rectanglePerimeter:
    ; Вычисление периметра прямоугольника
    add     rdi, 4
    call    PerimeterRectangle
    jmp     return
trianglePerimeter:
    ; Вычисление периметра треугольника
    add     rdi, 4
    call    PerimeterTriangle
    jmp     return
return:
leave
ret


global AveragePerimeterContainer
AveragePerimeterContainer:
section .data
    .sum    dq  0.0   
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес начала контейнера
    mov     ebx, esi        ; число фигур
    xor     ecx, ecx        ; счетчик фигур
    movsd   xmm2, [.sum]    ; перенос накопителя суммы в регистр 2

.loop:
    cmp     ecx, ebx        ; проверка на окончание цикла
    jge     .return         ; перебрали все фигуры

    push rbx
    push rcx

    mov     r10, rdi        ; сохранение начала фигуры
    call    PerimeterShape  ; получение периметра фигуры
    addsd   xmm2, xmm0      ; накопление суммы периметров

    pop rcx
    pop rbx
    inc ecx

    add     r10, 32         ; адрес следующей фигуры
    mov     rdi, r10        ; восстановление для передачи параметра
    jmp     .loop
.return:
    cvtsi2sd    xmm1, ebx
    divsd   xmm2, xmm1
    movsd   xmm0, xmm2
leave
ret
