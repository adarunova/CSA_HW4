extern PerimeterShape

extern CIRCLE
extern RECTANGLE
extern TRIANGLE

%include "macros.mac"

global DeleteContainerElements
DeleteContainerElements:
section .data
    .ten   dq  10.0
section .bss
    .pcontainer         resq    1   ; адрес контейнера
    .length             resq    1   ; адрес для сохранения числа введенных элементов
    .averagePerimeter   resq    1   ; 
    .perimeter          resq    1   ; вычисленный периметр
    .newContainer       resq    1   ; вычисленный периметр
    .newLength          resq    1   ; вычисленный периметр
section .text
push rbp
mov rbp, rsp

    mov     [.pcontainer], rdi          ; сохраняется указатель на контейнер
    mov     [.length], esi              ; сохраняется число элементов
    movsd   [.averagePerimeter], xmm0   ; сохраняется указатель на среднее арифметическое периметров

    ; В rdi адрес начала контейнера
    mov     ebx, esi        ; число фигур
    xor     ecx, ecx        ; счетчик фигур

    xor     rsi, rsi
    mov     [.newContainer], rdx
    mov     [.newLength], rsi

.loop:
    cmp     ecx, ebx        ; проверка на окончание цикла
    jge     .return         ; перебрали все фигуры

    push rbx
    push rcx

    mov     r10, rdi                    ; сохранение начала фигуры
    mov     rdi, [.pcontainer]
    call    PerimeterShape              ; получение периметра фигуры
    movsd   [.perimeter], xmm0          ; сохранение периметра
    subsd   xmm0, [.averagePerimeter]   ; находим разницу периметра фигуры и среднего периметра всех фигур
    mulsd   xmm0, [.ten]                ; умножаем на 10, чтобы точно была ненулевая целая часть
    cvtsd2si eax, xmm0                  ; берём целую часть от разницы периметров

    cmp     eax, 0                      ; если целая чать больше 0, то добавляем фигуру                       
    jl     .delete
    jmp    .countNewLength

.nextShape:
    pop rcx
    pop rbx
    inc ecx

    mov rdi, [.pcontainer]
    add rdi, 32             ; адрес следующей фигуры
    mov [.pcontainer], rdi
    jmp .loop

.delete:
    mov edi, [.pcontainer]
    lea eax, [edi-4]
    mov [edi], eax          ; удаление
    add edi, 4
    jmp .nextShape

.countNewLength:
    mov rsi, [.newLength]
    inc rsi
    mov [.newLength], rsi
    jmp .nextShape

.return:
    mov rsi, [.newLength]
    
leave
ret