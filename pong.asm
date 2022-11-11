; vers�o de 10/05/2007
; corrigido erro de arredondamento na rotina line.
; circle e full_circle disponibilizados por Jefferson Moro em 10/2009
;
segment code
..start:
	mov 		ax,data
	mov 		ds,ax
	mov 		ax,stack
	mov 		ss,ax
	mov 		sp,stacktop

	; configuracao de interrupcao
restart:
	cli
	xor     ax, ax
	mov     es, ax
	mov     ax, [es:int9*4];carregou ax com offset anterior
	mov     [offset_dos], ax        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
	mov     ax, [es:int9*4+2]     ; cs_dos guarda o end. anterior de cs
	mov     [cs_dos], ax		 
	mov     [es:int9*4+2], cs
	mov     WORD [es:int9*4],keyint
	sti

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
	mov  		ah,0Fh
	int  		10h
	mov  		[modo_anterior],al   

; alterar modo de video para gr�fico 640x480 16 cores
  	mov     	al,12h
	mov     	ah,0
	int     	10h
	
;-----------------------------------------------MENU-----------------------------------------
menu:
	call escreveMenu
	call escreveDificil
	call escreveMedio
	call escreveFacil


;----------------------------------------------ESCOLHA DA DIFICULDADE------------------------
dificuldade:
	cmp byte[tecla_u], 23h ;h
	je	setaDificil
	cmp byte[tecla_u], 21h ;f
	je	setaFacil
	cmp byte[tecla_u], 32h ;m
	je	setaMedio

	liberaComEnter:
		cmp 	byte[tecla_u], 0x1C ; enter
		jne		menu
		mov     al,12h
		mov     ah,0
		int     10h
		jmp 	header


	setaFacil:
		mov word[vel_relogio], 8000 
		mov     al,12h
		mov     ah,0
		int     10h
		jmp 	dificuldade
	setaMedio:
		mov 	word[vel_relogio], 4000 
		mov     al,12h
		mov     ah,0
		int     10h
		jmp 	dificuldade
	setaDificil:
		mov word[vel_relogio], 40
		mov     al,12h
		mov     ah,0
		int     10h
		jmp dificuldade
		
;----------------------------------------------INICIO DO JOGO-----------------------------
header:
  	call desenhaLinhas
	call textoEmbarcados
	call escreveNome
inicio:
	call trocaCor
	call desenhaRaquete
	call escreveVelocidadeAtual
	call sobrepoe_bola
	call colisao_y

;----------------------------------------------TROCA O DIREÇÃO DO X-----------------------
;se está indo para a direita então vai trocar para ir para a esquerda
checa_x:
  mov 		ax, [px_bola]
  add		ax, [velx]
  cmp		ax, 629 ;limite da parede direita
  jge		troca_x
  cmp		ax, 9 ;esquerda
  jge		move_bola
troca_x:
  mov		bx, -1
  mov		ax, [velx]
  imul		bx
  mov		[velx], ax
  
;----------------------------------------------MOVE A BOLA---------------------------------
move_bola:
		call 	desenha_bola_vermelha
		mov    	ah,0Bh
		int     21h
		xor 	al, al

		mov 	cx, 0
		mov 	dx, word[vel_relogio]
		mov 	ah, 86h
		int 	15h
		xor 	ax, ax

		jz inicio

		; fim loop
		call fim_programa

;----------------------------------------------DESENHA AS LINHAS DA PAREDE-------------------
desenhaLinhas:
;desenhar retas
  mov		byte[cor],branco_intenso	
  mov		ax, 0
  push		ax
  mov		ax, 0
  push		ax
  mov		ax, 639
  push		ax
  mov		ax, 0
  push		ax
  call		line

  mov		ax, 639
  push		ax
  mov		ax, 0
  push		ax
  mov		ax, 639
  push		ax
  mov		ax, 479
  push		ax
  call		line

  mov		ax, 639
  push		ax
  mov		ax, 479
  push		ax
  mov		ax, 0
  push		ax
  mov		ax, 479
  push		ax
  call		line

  mov		ax, 0
  push		ax
  mov		ax, 479
  push		ax
  mov		ax, 0
  push		ax
  mov		ax, 0
  push		ax
  call		line

  mov		ax, 0
  push		ax
  mov		ax, 409
  push		ax
  mov		ax, 639
  push		ax
  mov		ax, 409
  push		ax
  call		line
  ret

;----------------------------------------------ESCREVE O CABEÇALHO-------------------------
textoEmbarcados:
  mov byte[cor],branco_intenso
  mov cx, 44
  mov bx, 0
  mov dh, 1
  mov dl, 4

  lEmbarcados:
    call cursor
    mov al, [bx+embarcados]
    call caracter
    inc bx
    inc dl
    loop lEmbarcados
ret

;----------------------------------------------ESCREVE NOME DOS ALUNOS----------------------
escreveNome:
	mov byte[cor],branco_intenso
	mov cx, 26
	mov bx, 0
	mov dh, 3 ; deslocamento vertical
	mov dl, 4 ; deslocamento horizontal

	lNome:
		call cursor
		mov al, [bx+nome]
		call caracter
		inc bx
		inc dl
		loop lNome
ret

;----------------------------------------------ESCREVE MENU-----------------------------------
escreveMenu:
	mov byte[cor],branco_intenso
	mov cx, 23
	mov bx, 0
	mov dh, 10
	mov dl, 5
	
	lMenu:
		call cursor
		mov al, [bx+texto_menu]
		call caracter
		inc bx
		inc dl
		loop lMenu
		
ret

escreveDificil:
	mov byte[cor],branco_intenso
	mov cx, 29
	mov bx, 0
	mov dh, 12
	mov dl, 5
	lDificil:
		call cursor
		mov al, [bx+dificil]
		call caracter
		inc bx
		inc dl
		loop lDificil
	
ret
escreveMedio:
	mov byte[cor],branco_intenso
	mov cx, 27
	mov bx, 0
	mov dh, 14
	mov dl, 5
	lMedio:
		call cursor
		mov al, [bx+medio]
		call caracter
		inc bx
		inc dl
		loop lMedio
ret

escreveFacil:
	mov byte[cor],branco_intenso
	mov cx, 27
	mov bx, 0
	mov dh, 16
	mov dl, 5
	lFacil:
		call cursor
		mov al, [bx+facil]
		call caracter
		inc bx
		inc dl
		loop lFacil
ret

escreveVelocidadeAtual:
	mov byte[cor],branco_intenso
	mov cx, 18
	mov bx, 0
	mov dh, 3
	mov dl, 55
	lVelocidadeAtual:
		call cursor
		mov al, [bx+velocidade_atual_txt]
		call caracter
		inc bx
		inc dl
		loop lVelocidadeAtual
		mov cx, 1
		mov bx, 0
		mov dh, 3
		mov dl, 73

		call cursor
		mov al, [bx+velocidade_jogo]
		add al, '0'
		call caracter
		ret

trocaCor:
	mov		byte[cor],branco_intenso

;----------------------------------------------DESENHA RAQEUTE----------------------------
desenhaRaquete:
	;x1
	mov         bx, [px_raquete]
    mov		    ax, bx
	sub         bx, 50
    push		ax
	;y1
	mov 		ax, 15
	push		ax
	;x2
	mov			ax, bx
	push		ax
	;y2
	mov			ax, 15
	push		ax
	call		line
	ret

;----------------------------------------------SOBREPOE A BOLA------------------------------
sobrepoe_bola:
  mov		byte[cor],preto	
  push	word[px_bola]
  push	word[py_bola]
  push	word 5
  call	full_circle
	ret
;----------------------------------------------DESENHA A BOLA-------------------------------
desenha_bola_vermelha:
	mov		byte[cor],vermelho	;circulo vermelho
	mov 	ax, [px_bola]
	add		ax, [velx]
	mov		[px_bola], ax
	push 	ax
	mov 	ax, [py_bola]
	add		ax, [vely]
	mov		[py_bola], ax
	push 	ax
	push	word 5
	call	full_circle
	ret

;----------------------------------------------FIM DO JOGO----------------------------------
fim:
	mov     	al,12h
	mov     	ah,0
	int     	10h
	escreveGameOver:
		mov cx, 43
		mov bx, 0
		mov dh, 16
		mov dl, 5
		mov		byte[cor],branco_intenso
	lGameOver:
		call cursor
		mov al, [bx+gameOver]
		call caracter
		inc bx
		inc dl
		loop lGameOver

		lerResposta:
			mov     ax,[p_i]
			CMP     ax,[p_t]
			JE     	escreveGameOver

;----------------------------------------------TROCA A DIREÇÃO Y-----------------------------
;se a bolinha estIver indo pAra cima então troca para ir para baixo
colisao_y:
  mov 		ax, [py_bola]
  add		ax, [vely]
  cmp		ax, 399  ;verifica se o y do centro da bolinha colidiu com o fundo
  jge		troca_y
  cmp		ax, 10 
  jge		nao_colidiu_parede
  cmp 		ax, 9
  je 		fim
	troca_y:
		cmp   	word[vely], 0
		jle		colidiu_parede
		
	colidiu_parede:;verifica se colide com a  parede
		mov		bx, -1
		mov		ax, [vely]
		imul	bx
		mov		[vely], ax
	nao_colidiu_parede:
		mov 	ax, word[py_bola]      	; ax com y da bolinha
		cmp  	word[vely], 0			
		jge 	nao_colidiu_raquete
		cmp 	ax, 21					; compara centro da bolinha com 21 se não for igual é porque colidiu com a parede
		jne   	nao_colidiu_raquete		
		mov 	ax,	word[px_bola]
		cmp		ax, word[px_raquete]
		jg		nao_colidiu_raquete
		add 	ax, 50
		cmp		ax, word[px_raquete]
		jl    	nao_colidiu_raquete

		mov		bx, -1
		mov		ax, [vely]
		imul	bx
		mov		[vely], ax

	nao_colidiu_raquete:
		ret


keyint:
	PUSH    AX
	push    bx
	push    ds
	mov     ax,data
	mov     ds,ax
	IN      AL, kb_data
	inc     WORD [p_i]
	and     WORD [p_i],7
	mov     bx,[p_i]
	mov     [bx+tecla],al
	IN      AL, kb_ctl
	OR      AL, 80h
	OUT     kb_ctl, AL
	AND     AL, 7Fh
	OUT     kb_ctl, AL
	MOV     AL, eoi
	OUT     pictrl, AL

	leTeclado:
		mov     ax,[p_i]
		CMP     ax,[p_t]
		jne     leTeclado_leTecla
		jmp			fim_controle
		leTeclado_leTecla:
			inc     word[p_t]
			and     word[p_t],7
			mov     bx,[p_t]
			XOR     AX, AX
			MOV     AL, [bx+tecla]
			mov     [tecla_u],al
;----------------------------------------------TERMINA O JOGO-----------------------------
	termina_jogo:
		CMP     BYTE [tecla_u], 10h	;compara com a letra q
		JE      fim_programa
		call    controle_jogo
		jmp		fim_controle
;----------------------------------------------RECOMEÇA O JOGO----------------------------
	recomeca:
		CMP     BYTE [tecla_u], 13h	;compara com a letra r
		JE      recomeca_jogo
		call controle_jogo
		jmp 	fim_controle
		
;----------------------------------------------FIM DO PROGRAMA----------------------------
	fim_programa:
		CLI
		xor			ax, ax
		MOV     ES, AX
		MOV     AX, [cs_dos]
		MOV     [ES:int9*4+2], AX
		MOV     AX, [offset_dos]
		MOV     [ES:int9*4], AX 
		XOR     AX, AX
		mov 		al, byte[modo_anterior]
		int			10h
		XOR     AX, AX
		MOV     AH, 4Ch
		int     21h
;----------------------------------------------CONTROLE DO JOGO----------------------------
	controle_jogo:
		cmp byte[tecla_u], 19h ;p
		je	inc_vel
		cmp byte[tecla_u], 18h ;o
		je	dec_vel
		cmp byte[tecla_u], 20h ;a
		je direita_raquete
		cmp byte[tecla_u], 0x1E ;d
		je esquerda_raquete
		cmp byte[tecla_u], 0x1F ;s
		je  pausa_jogo
		cmp byte[tecla_u], 13h  ;r
		je 	recomeca_jogo
		ret
	recomeca_jogo:
		mov 		word[px_bola], 320
		mov 		word[py_bola], 240
		mov			word[velx], 1
		mov			word[vely], 1
		mov 		word[px_raquete], 330
		jmp 		restart
		ret
;----------------------------------------------AUMENTA/DIMINUI A VELOCIDADE--------
	inc_vel:
		cmp byte[velocidade_jogo], 5
		je  retorna_controle
		inc byte[velocidade_jogo]
		sub word[vel_relogio], 1800
		ret

	dec_vel:
		cmp byte[velocidade_jogo], 1
		je retorna_controle
		dec byte[velocidade_jogo]
		add word[vel_relogio], 1800
		ret
;----------------------------------------------MOVE A RAQUETE-----------------------
	direita_raquete:
		mov byte[cor], preto
		call desenhaRaquete
		cmp word[px_raquete], 635
		jge retorna_controle
		add word[px_raquete], 8
		ret

	esquerda_raquete:
		mov byte[cor], preto
		call desenhaRaquete
		cmp word[px_raquete], 50
		jle retorna_controle
		sub word[px_raquete], 8
		ret
;----------------------------------------------PAUSA O JOGO-------------------------
	pausa_jogo:
		jmp restart
		ret

	retorna_controle:
		ret

	fim_controle:
		mov al, 20h
		out 20h, al
		pop     ds
		pop     bx
		POP     AX
		IRET
	
		
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,2
		mov     	bh,0
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,9
		mov     	bh,0
		mov     	cx,1
   		mov     	bl,[cor]
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

plot_xy:
		push		bp
		mov			bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub			dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
;_____________________________________________________________________________
;    fun��o circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov 	dx,bx	
	add		dx,cx       ;ponto extremo superior
	push    ax			
	push	dx
	call plot_xy
	
	mov		dx,bx
	sub		dx,cx       ;ponto extremo inferior
	push    ax			
	push	dx
	call plot_xy
	
	mov 	dx,ax	
	add		dx,cx       ;ponto extremo direita
	push    dx			
	push	bx
	call plot_xy
	
	mov		dx,ax
	sub		dx,cx       ;ponto extremo esquerda
	push    dx			
	push	bx
	call plot_xy
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
	mov		si,di
	cmp		si,0
	jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar:	
	mov		si,dx
	add		si,ax
	push    si			;coloca a abcisa x+xc na pilha
	mov		si,cx
	add		si,bx
	push    si			;coloca a ordenada y+yc na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,dx
	push    si			;coloca a abcisa xc+x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do s�timo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc+x na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do oitavo octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	add		si,cx
	push    si			;coloca a ordenada yc+y na pilha
	call plot_xy		;toma conta do terceiro octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do sexto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quinto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quarto octante
	
	cmp		cx,dx
	jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov		si,bx
	sub		si,cx
	push    ax			;coloca xc na pilha			
	push	si			;coloca yc-r na pilha
	mov		si,bx
	add		si,cx
	push	ax		;coloca xc na pilha
	push	si		;coloca yc+r na pilha
	call line
	
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar_full
inf_full:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar_full:	
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call 	line
	
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call	line
	
	cmp		cx,dx
	jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_full_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
;*******************************************************************
segment data

cor		db		branco_intenso

preto		equ		0
azul		equ		1
verde		equ		2
cyan		equ		3
vermelho	equ		4
magenta		equ		5
marrom		equ		6
branco		equ		7
cinza		equ		8
azul_claro	equ		9
verde_claro	equ		10
cyan_claro	equ		11
rosa		equ		12
magenta_claro	equ		13
amarelo		equ		14
branco_intenso	equ		15
int9    equ 	9h
kb_data equ 	60h  ;PORTA DE LEITURA DE TECLADO
kb_ctl  equ 	61h  ;PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
pictrl  equ 	20h
eoi     equ 	20h
cs_dos  dw  	1
offset_dos  dw 	1
p_i     dw  	0   ;ponteiro p/ interrupcao (qnd pressiona tecla)  
p_t     dw  	0   ;ponterio p/ interrupcao ( qnd solta tecla) 
teclasc DB  	0,0,13,10,'$'
tecla_u db 		0
tecla_anterior db 0
modo_anterior	db		0
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0
velx        dw      1
vely        dw      1
vel_relogio	dw			8000
px_bola          dw      320
py_bola          dw      240
px_raquete			dw	330
tecla   resb  	8 
velocidade  dw      10
embarcados  db          'Trabalho 1 de Sistemas Embarcados I - 2022/2'
nome        db          'Elias Junior e Maria Julia' 
velocidade_atual_txt db '     Velocidade:   '
velocidade_jogo		db 1
gameOver 	db 	'Game over - Pressione r para continuar ou q para sair'
mens_pausa db 			'Jogo pausado - Pressione s para voltar a jogar'
texto_menu db			'Escolha o modo de jogo:' 
dificil db 				'Dificil - Pressione a tecla h' 
medio db				'Medio - Pressione a tecla m' 
facil db 				'Facil - Pressione a tecla f' 
;*************************************************************************
segment stack stack
    		resb 		512
stacktop:

