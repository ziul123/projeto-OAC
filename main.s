.data

LINHA0:		.word 1,0,0,0,0,0,0,0
LINHA1:		.word 0,0,0,0,2,0,0,0
LINHA2:		.word 0,0,0,2,2,2,0,0
LINHA3:		.word 0,0,0,2,0,0,0,2
LINHA4:		.word 0,0,0,0,0,0,2,2
LINHA5:		.word 2,2,2,2,2,2,2,2
MATRIZ:		.word LINHA0,LINHA1,LINHA2,LINHA3,LINHA4,LINHA5
PLAYER_POS:	.byte 0,0		#coluna,linha
M_SIZE:		.word 6,8		#n_linhas, n_colunas

esp:		.string " "
n:			.string "\n"
morreu:		.string "morreu\n"
test:		.string "aqui"

.text

MAIN:
	la a0,MATRIZ
	la a1,M_SIZE
	jal M_SHOW
	
	la a0,n
	li a7,4
	ecall

#s9 = dash (0 nao pode, 1 pode)
#s10 = flututando (0 se nao estiver, 1 se estiver)
#s11 = timer da gravidade
LOOP:


	jal GET_KEY
	
	bltz a0,END
	bgtz a0,NO_KEY
	
	la a0,MATRIZ
	la a1,M_SIZE
	jal M_SHOW
	
	la a0,n
	li a7,4
	ecall
	
NO_KEY:	
	beqz s10,N_GRAV
	csrr t0,3073
	sub t0,t0,s11			#s11 tem o tempo da ultima gravidade
	li t1,300
	bltu t0,t1,LOOP

	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_V				#desce o player por 1 posicao
	
	csrr s11,3073			#salva o tempo da ultima gravidade
	
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se o player ainda esta flutuando
	mv s10,a0
	bnez a0,N_RES_DASH
	li s9,1
N_RES_DASH:
	addi sp,sp,-4
	sw a1,0(sp)
	

	la a0,MATRIZ
	la a1,M_SIZE
	jal M_SHOW
	
	
	la a0,n
	li a7,4
	ecall
	
	lw t0,0(sp)
	addi sp,sp,4
	bgtz t0,MORREU
	
	
N_GRAV:
	j LOOP
	

MORREU:
	la a0,morreu
	li a7,4
	ecall

END:
	li a7,10
	ecall



#return a0= flag (-1 para quit, 0 para tecla pressionada, 1 para tecla n pressionada)
GET_KEY:
	addi sp,sp,-4
	sw ra,0(sp)
	
	
	li t0,0xFF200000		#endereco do controle do teclado
	lw t1,0(t0)
	andi t1,t1,0x01
	li a0,1
	beqz t1,GET_KEY_END		#se nao foi pressionada tecla, pula
	lw t1,4(t0)				#t1 = tecla pressionada pelo usuario

	li t0,'a'
	beq t1,t0,a
	
	li t0,'d'
	beq t1,t0,d
	
	li t0,'e'
	beq t1,t0,e

	li t0,'p'
	beq t1,t0,p
	
	li t0,'q'
	beq t1,t0,q

	li t0,'s'
	beq t1,t0,s
	
	li t0,'w'
	beq t1,t0,w
	
	li t0,'A'
	beq t1,t0,A
	
	li t0,'C'
	beq t1,t0,C
	
	li t0,'D'
	beq t1,t0,D
	
	li t0,'E'
	beq t1,t0,E
	
	li t0,'Q'
	beq t1,t0,Q
	
	li t0,'W'
	beq t1,t0,W
	
	li t0,'Z'
	beq t1,t0,Z

	j GET_KEY_END

a:
	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_H				#move o jogador um espaco para esquerda

	bnez s10,JA_FLUTUANDO	#se ja esta flutuando, termina
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se esta flutuando depois de mover
	mv s10,a0

	csrr s11,3073			#comeca o timer da gravidade
	

	li a0,0
	j GET_KEY_END

d:

	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_H				#move o jogador um espaco para direita

	bnez s10,JA_FLUTUANDO	#se ja esta flutuando, termina
	
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se esta flutuando depois de mover
	mv s10,a0

	csrr s11,3073			#comeca o timer da gravidade


	li a0,0
	j GET_KEY_END


e:
	bnez s10,N_PULA			#se esta flutuando, nao pula

	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_DG_C				#move o player 1 espaco para a diagonal cima direita
	
	li s10,1				#depois de pular, esta flutuando
	csrr s11,3073
	
	li a0,0
	j GET_KEY_END

p:
	li a0,-1
	j GET_KEY_END


q:
	bnez s10,N_PULA

	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_DG_C
	
	li s10,1
	csrr s11,3073

	li a0,0
	j GET_KEY_END


s:
	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_V



	li a0,0
	j GET_KEY_END

w:
	bnez s10,N_PULA
	
	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_V


	li s10,1
	csrr s11,3073

	li a0,0
	j GET_KEY_END
	
A:
	beqz s9,N_DASH
	
	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_H				#move o jogador um espaco para esquerda
	
	li s9,0

	bnez s10,JA_FLUTUANDO	#se ja esta flutuando, termina
	
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se esta flutuando depois de mover
	mv s10,a0

	csrr s11,3073			#comeca o timer da gravidade
	
	
	li a0,0
	j GET_KEY_END

C:
	beqz s9,N_DASH
	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_DG_B				#move o player 1 espaco para a diagonal cima direita
	
	li s9,0
	
	bnez s10,JA_FLUTUANDO	#se ja esta flutuando, termina
	
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se esta flutuando depois de mover
	mv s10,a0

	csrr s11,3073			#comeca o timer da gravidade
	
	
	li a0,0
	j GET_KEY_END


D:
	beqz s9,N_DASH

	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_H				#move o jogador um espaco para direita

	li s9,0

	bnez s10,JA_FLUTUANDO	#se ja esta flutuando, termina
	
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se esta flutuando depois de mover
	mv s10,a0

	csrr s11,3073			#comeca o timer da gravidade



	li a0,0
	j GET_KEY_END

E:
	beqz s9,N_DASH

	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_DG_C				#move o player 1 espaco para a diagonal cima direita

	li s9,0
	li s10,1
	csrr s11,3073

	li a0,0
	j GET_KEY_END

Q:
	beqz s9,N_DASH

	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_DG_C


	li s9,0
	li s10,1
	csrr s11,3073

	li a0,0
	j GET_KEY_END

S:
	beqz s9,N_DASH
	
	li a0,1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_V


	li s9,0
	li s10,1
	csrr s11,3073

	li a0,0
	j GET_KEY_END

W:
	beqz s9,N_DASH
	
	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_V

	li s9,0
	li s10,1
	csrr s11,3073

	li a0,0
	j GET_KEY_END


Z:
	beqz s9,N_DASH

	li a0,-1
	li a1,1
	la a2,PLAYER_POS
	la a3,MATRIZ
	la a4,M_SIZE
	li a5,0

	jal MV_DG_B
	
	bnez s10,JA_FLUTUANDO	#se ja esta flutuando, termina
	la a0,PLAYER_POS
	la a1,MATRIZ
	la a2,M_SIZE
	jal FLUTUANDO			#checa se esta flutuando depois de mover
	mv s10,a0

	csrr s11,3073			#comeca o timer da gravidade
	
	li s9,0

	li a0,0
	j GET_KEY_END


JA_FLUTUANDO:
N_PULA:
N_DASH:
	li a0,0
	j GET_KEY_END


GET_KEY_END:
	lw ra,0(sp)
	addi sp,sp,4
	ret




.include "movimentacao.s"
.include "show.s"
