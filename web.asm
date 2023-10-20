format ELF64 executable 3                 ;; ELF64 Format for GNU+Linux
segment readable executable               ;; Executable code section

sys_close   equ 3
sys_write   equ 1
sys_socket  equ 41
sys_bind    equ 49
sys_listen  equ 50
sys_accept  equ 43
sys_send    equ 44
sys_exit    equ 60
AF_INET     equ 2
SOCK_STREAM equ 1

stdout      equ 1


_start:

;;;;;;;;;;;;    socket  ;;;;;;;;;;;;;;;;;;

    ; socket(AF_INET, SOCK_STREAM, 0)
    mov rax, sys_socket
    mov edi, AF_INET
    mov esi, SOCK_STREAM
    xor edx, edx
    syscall
    mov R12, rax  ; сохраняем дескриптор сокета

    ; выход на ошибку
    cmp rax, 0
    jl exit_error

    ; вывод в консоль "socket_ok"                                    
    mov rax, sys_write                    
    mov rdi, stdout                       
    mov rsi, socket_ok                  
    mov rdx, socket_ok_length           
    syscall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;    bind  ;;;;;;;;;;;;;;;;;;
    ; bind(sockfd, &addr, sizeof(addr))
    mov rsi, my_addr
    mov rdx, my_addr_length
    mov rdi, R12
    mov rax, sys_bind
    syscall

    ; выход на ошибку
    cmp rax, 0
    jl exit_error

    ; вывод в консоль "bind_ok"                                    
    mov rax, sys_write                    
    mov rdi, stdout                       
    mov rsi, bind_ok                  
    mov rdx, bind_ok_length           
    syscall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;    listen  ;;;;;;;;;;;;;;;;;;
    ; listen(sockfd, 5)
    mov rax, sys_listen
    mov rsi, 20       ; backlog
    mov rdi, R12
    syscall

    ; выход на ошибку
    cmp rax, 0
    jl exit_error
    ; вывод в консоль "listen_ok"                                    
    mov rax, sys_write                    
    mov rdi, stdout                       
    mov rsi, listen_ok                  
    mov rdx, listen_ok_length           
    syscall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


accept_loop:
;;;;;;;;;;;;    accept  ;;;;;;;;;;;;;;;;;;
    ; accept(sockfd, NULL, NULL)
    mov rax, sys_accept
    mov rdi, R12
    xor rsi, rsi
    xor rdx, rdx
    syscall

    mov rdi, rax  ; сохраняем дескриптор клиента
    mov r10, rdi 

    ; выход на ошибку
    cmp rax, 0
    jl exit_error

    ; вывод в консоль "listen_ok"                                    
    mov rax, sys_write                    
    mov rdi, stdout                       
    mov rsi, accept_ok                  
    mov rdx, accept_ok_length           
    syscall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; send(client_fd, "Привет, мир!", 13, 0)
    ;mov rax, sys_send
    ;mov rdi, r9
    ;mov rsi, hello                  
    ;mov rdx, hello_length
    ;or r10d, r10d
    ;syscall

    ;cmp rax, 0
    ;jl exit

;; отправка основного HTML
    mov R8, html_response
    mov R9, response_length
    mov rsi, html_response
write_loop:

    ; write(client_fd, html_response, length)
    mov rax, sys_write
    ;mov rsi, R8
    mov rdi, r10
    mov rdx, R9
    syscall

    sub R9, rax                 ; subtract the number of bytes written
    add rsi, rax                    ; move the pointer forward

    cmp R9, 0             ; check if there are more bytes left to write
    jg write_loop            ; if yes, loop back

    ; close(client_fd)
    mov rax, sys_close
    mov rdi, r10   ; восстанавливаем дескриптор клиента из r10
    syscall
    jmp accept_loop

exit:
    ;; выход из программы 
    mov eax, 60                     
    mov edi, 0               
    syscall 

exit_error:
    ; вывод в консоль '!! error_msg !!'                             
    mov rax, sys_write                    
    mov rdi, stdout                       
    mov rsi, error_msg                  
    mov rdx, error_msg_length           
    syscall
    ;; выход из программы ошибка
    mov eax, 60                     
    mov edi, 1                 
    syscall 


segment readable writable
    hello db 'дыыыыы, йцу', 0
    hello_length = $ - hello  

    socket_ok db '-= socket_ok =-',10, 0
    socket_ok_length = $ - socket_ok

    bind_ok db '-= bind_ok =-',10, 0
    bind_ok_length = $ - bind_ok

    listen_ok db '-= listen_ok =-',10, 0
    listen_ok_length = $ - listen_ok

    accept_ok db '-= accept_ok =-',10, 0
    accept_ok_length = $ - accept_ok



    error_msg db '!! error_msg !!',10, 0
    error_msg_length = $ - error_msg



    html_response   db 'HTTP/1.1 200 OK', 0x0D, 0x0A
        db 'Content-Type: text/html', 0x0D, 0x0A
        db 'Content-Length: 1500', 0x0D, 0x0A
        db 0x0D, 0x0A
        ;db '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>ASM+HTMX</title></head><body>asdqZXCwe123</body></html>'
        db '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>BLAZER фаст asm+htmx</title><script src="https://unpkg.com/htmx.org"></script></head><body><center><center></center><table cols="5" border="0"><tbody><tr align="center"><td><a href=""><img src="https://raw.githubusercontent.com/AndreyyTs/BLAZER_FAST_WEB/main/img/5PERCLGT.gif"height="97" border="0" width="72"></a></td><td><a href=""><img src="https://github.com/AndreyyTs/BLAZER_FAST_WEB/blob/main/img/GitHub.png?raw=true"height="118" border="0" width="120"></a></td><td><a href=""><img src="https://github.com/AndreyyTs/BLAZER_FAST_WEB/blob/main/img/habr.jpg?raw=true"height="118" border="0" width="120"></a></td><td><a href=""><img src="https://github.com/AndreyyTs/BLAZER_FAST_WEB/blob/main/img/coolsite.gif?raw=true"height="118" border="0" width="120"></a></td><td><a href=""><img src="https://github.com/AndreyyTs/BLAZER_FAST_WEB/blob/main/img/rss.png?raw=true"height="118" border="0" width="120"></a></td></tr></tbody></table></center><center><h1>꧁༺ <font size=45> Персональный сайт </font> ༻꧂</h1></center><p><p/><center><p></p><button hx-post="/резюме" hx-swap="outerText" hx-target="#qwe">резюме</button><button hx-post="/смешные_картинки" hx-swap="outerText" hx-target="#qwe">смешные картинки</button><button hx-post="/о_сайте" hx-swap="outerText" hx-target="#qwe">о сайте</button></center><div id="qwe"></div></body></html>'
   
    response_length = $ - html_response

   my_addr:
        sin_family      dw AF_INET                ; Address family: AF_INET
        sin_port        dw 0x5C12                 ; порт 4444 в big-endian формате
        sin_addr        dd 0                      ; INADDR_ANY
        sin_zero        db 0, 0, 0, 0, 0, 0, 0, 0 ; Дополнительные байты для выравнивания структуры

    my_addr_length = $ - my_addr



