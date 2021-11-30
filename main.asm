;------------------------------------------------------------------------------
; main.asm - содержит главную функцию,
; обеспечивающую простое тестирование
;------------------------------------------------------------------------------
; main.asm

global  CIRCLE
global  RECTANGLE
global  TRIANGLE

extern InRandomContainer
extern DeleteContainerElements

%include "macros.mac"

section .data
    CIRCLE      dd  1
    RECTANGLE   dd  2
    TRIANGLE    dd  3
    oneDouble   dq  1.0
    randomGeneration    db  "-n",0
    fileGeneration      db  "-f",0
    errorMessage1   db  "Incorrect command line!", 10,"  Waited:",10
                    db  "     command -f input_file output_file1 output_file2",10,"  Or:",10
                    db  "     command -n number output_file1 output_file2",10,0
    errorMessage2   db  "Incorrect qualifier value!", 10,"  Waited:",10
                    db  "     command -f input_file output_file1 output_file2",10,"  Or:",10
                    db  "     command -n number output_file1 output_file2",10,0
    length          dd  0       ; Количество элементов в массиве
section .bss
    argc        resd    1
    num         resd    1
    averagePerimeter    resq    1   ; среднее арифметическое всех периметров
    start       resq    1       ; начало отсчета времени
    delta       resq    1       ; интервал отсчета времени
    startTime   resq    2       ; начало отсчета времени
    endTime     resq    2       ; конец отсчета времени
    deltaTime   resq    2       ; интервал отсчета времени
    input_file  resq    1       ; указатель на файл, открываемый файл для чтения фигур
    output_file1    resq    1       ; указатель на файл, открываемый файл для записи контейнера
    output_file2    resq    1       ; указатель на файл, открываемый файл для записи периметра
    container   resb    320032  ; массив используемый для хранения данных
section .text
    global main
main:
push rbp
mov rbp,rsp

    mov dword [argc], edi       ; rdi contains number of arguments
    mov r12, rdi                ; rdi contains number of arguments
    mov r13, rsi                ; rsi contains the address to the array of arguments

.printArguments:
    PrintStrLn "The command and arguments:", [stdout]
    mov rbx, 0
.printLoop:
    PrintStrBuf qword [r13+rbx*8], [stdout]
    PrintStr    10, [stdout]
    inc rbx
    cmp rbx, r12
    jl .printLoop

    PrintStrLn  "", [stdout]

    cmp r12, 5                  ; проверка количества аргументов
    je .start
    PrintStrBuf errorMessage1, [stdout]
    jmp .return

.start:
    ; Вычисление времени старта
    mov rax, 228                ; 228 is system call for sys_clock_gettime
    xor edi, edi                ; 0 for system clock (preferred over "mov rdi, 0")
    lea rsi, [startTime]
    syscall                     ; [time] contains number of seconds
                                ; [time + 8] contains number of nanoseconds

    PrintStrLn "Start", [stdout]
    ; Проверка второго аргумента
    mov     rdi, randomGeneration
    mov     rsi, [r13+8]            ; второй аргумент командной строки
    call    strcmp
    cmp     rax, 0                  ; строки равны "-n"
    je      .fillContainerRandomly
    mov     rdi, fileGeneration
    mov     rsi, [r13+8]            ; второй аргумент командной строки
    call    strcmp
    cmp     rax, 0                  ; строки равны "-f"
    je      .fillContainerFromFile
    PrintStrBuf errorMessage2, [stdout]
    jmp     .return

.fillContainerRandomly:
    ; Генерация случайных фигур
    mov     rdi, [r13+16]
    call    atoi
    mov     [num], eax
    mov     eax, [num]
    cmp     eax, 1
    jl      .printError
    cmp     eax, 10000
    jg      .printError
    ; Начальная установка генератора случайных чисел
    xor     rdi, rdi
    xor     rax, rax
    call    time
    mov     rdi, rax
    xor     rax, rax
    call    srand
    ; Заполнение контейнера случайными фигурами
    mov     rdi, container      ; передача адреса контейнера
    mov     rsi, length         ; передача адреса для длины
    mov     edx, [num]          ; передача количества порождаемых фигур
    call    InRandomContainer
    jmp     .checkLength

.fillContainerFromFile:
    ; Получение фигур из файла
    FileOpen [r13+16], "r", input_file
    ; Заполнение контейнера фигурами из файла
    mov     rdi, container      ; адрес контейнера
    mov     rsi, length         ; адрес для установки числа элементов
    mov     rdx, [input_file]   ; указатель на файл
    xor     rax, rax
    call    InContainer         ; ввод данных в контейнер
    FileClose [input_file]
    jmp     .checkLength


.checkLength:
    mov     eax, [length]
    cmp     eax, 1
    jl      .printError
    cmp     eax, 10000
    jg      .printError
    jmp     .printContainer

.printContainer:
    ; Вывод содержимого контейнера
    PrintStrLn  "Filled container:", [stdout]
    PrintContainer container, [length], [stdout]

    FileOpen    [r13+24], "w", output_file1
    PrintStrLn  "Filled container:", [output_file1]
    PrintContainer container, [length], [output_file1]
    FileClose   [output_file1]

.deleteElementsFromContainer:

    AveragePerimeter container, [length], [averagePerimeter]

    DeleteContainerFigures container, [length], [averagePerimeter]
    mov [length], rsi

    ; Вычисление времени завершения
    mov rax, 228   ; 228 is system call for sys_clock_gettime
    xor edi, edi   ; 0 for system clock (preferred over "mov rdi, 0")
    lea rsi, [endTime]
    syscall        ; [time] contains number of seconds
                   ; [time + 8] contains number of nanoseconds

    ; Получение времени работы
    mov rax, [endTime]
    sub rax, [startTime]
    mov rbx, [endTime+8]
    mov rcx, [startTime+8]
    cmp rbx, rcx
    jge .subNanoOnly
    ; иначе занимаем секунду
    dec rax
    add rbx, 1000000000
.subNanoOnly:
    sub rbx, [startTime+8]
    mov [deltaTime], rax
    mov [deltaTime+8], rbx

    ; Вывод периметра нескольких фигур
    PrintStrLn  "", [stdout]
    PrintStrLn  "Container after deleting shapes:", [stdout]
    PrintContainer container, [length], [stdout]
    PrintStrLn  "", [stdout]
    PrintStr    "Average perimeter = ", [stdout]
    PrintDouble [averagePerimeter], [stdout]
    PrintStr    ". Calculaton time = ", [stdout]

    PrintLLUns  [deltaTime], [stdout]
    PrintStr    " sec, ", [stdout]
    PrintLLUns  [deltaTime+8], [stdout]
    PrintStr    " nsec", [stdout]
    PrintStr    10, [stdout]

    FileOpen    [r13+32], "w", output_file2
    PrintStrLn  "Container after deleting shapes:", [output_file2]
    PrintContainer container, [length], [output_file2]
    PrintStr    "Average perimeter = ", [output_file2]
    PrintDouble [averagePerimeter], [output_file2]
    PrintStr    ". Calculaton time = ", [output_file2]
    PrintLLUns  [deltaTime], [output_file2]
    PrintStr    " sec, ", [output_file2]
    PrintLLUns  [deltaTime+8], [output_file2]
    PrintStr    " nsec", [output_file2]
    PrintStr    10, [output_file2]
    FileClose   [output_file2]

    PrintStrLn "Stop", [stdout]
    jmp .return

.printError:
    PrintStrLn "Incorrect numer of figures. Set 0 < number <= 10000", [stdout]
    jmp .return
.return:
leave
ret
