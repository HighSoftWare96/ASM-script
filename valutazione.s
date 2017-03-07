.section .data

	INIT_t:
		.long 0

	RESET_t:
		.long 0

	RPM_t:
		.long 0

	MOD_PREC_t:
		.long 0

	COUNTER_t:
		.long 0

.section .text
	.global scelta

	# Valori contenuti:INIT eax
	# 				   RESET ebx
	#				   RPM_S ecx
	#				   MOD_PREC_M edx

	########################################
	# Valori di ritorno: MODE eax
	#					 NUMB ebx
	#					 ALM ecx


.type scelta, @function
#funzione di valutazione dello stato della macchina


scelta:

	movl %eax, INIT_t
	movl %ebx, RESET_t
	movl %ecx, RPM_t
	movl %edx, MOD_PREC_t


	#controllo INIT
	movl INIT_t, %eax
	cmpl $0, %eax					# INIT = 0 ?
	je machine_off


	#CONTROLLO RESET
	cmpl $1, %ebx					# RESET = 1 ?
	je reset_1

controllo_rpm:

	#controllo RPM
	movl RPM_t, %ecx

	#controllo RPM < 2000
	cmp $2000, %ecx
	jl sotto_giri

	#controllo RPM <= 4000
	cmp $4000, %ecx
	jle opt_giri

	#allora è > 4000
	jmp fuori_giri

#MACCHINA SPENTA:

machine_off:

	movl $0, %eax		# Mode = 0
	movl $0, %ebx		# NUMB = 0
	movl $0, %ecx		# ALM = 0
	ret

#IN CASO DI RESET == 1
reset_1: #etichetta per azzerare NUMB
	movl $-1, %ebx #azzero l'uscita NUMB
	movl $-1, COUNTER_t #counter = 0
jmp controllo_rpm


#MACCHINA ACCESA:

#SOTTO GIRI
sotto_giri:

	#MODE == 01 (1)
	movl $1, %eax

	#NUMB
	cmpl MOD_PREC_t, %eax
	#resetto numb se cambiamo stato
	jne reset_numb

	#incremento numb attuale
	addl $1, COUNTER_t
	movl COUNTER_t, %ebx #restituisco

	#ALM
	movl $0, %ecx #restituisco

	ret

#REGIME OTTIMALE
opt_giri:
	#MODE == 10 (10)
	movl $10, %eax

	#NUMB
	cmpl MOD_PREC_t, %eax
	#resetto numb se cambiamo stato
	jne reset_numb

	#incremento numb attuale
	addl $1, COUNTER_t
	movl COUNTER_t, %ebx #restituisco

	#ALM
	movl $0, %ecx #restituisco

	ret

#SIAMO FUORI GIRI
fuori_giri:

	#MODE == 11 (11)
	movl $11, %eax

	#NUMB
	cmpl MOD_PREC_t, %eax
	#resetto numb se cambiamo stato
	jne reset_numb

	movl COUNTER_t, %edx
	cmpl $14, %edx #se NUMB è maggiore di 15
	jge alm

	#altrimenti solita procedura
	#incremento numb attuale
	addl $1, COUNTER_t
	movl COUNTER_t, %ebx #restituisco

	#ALM
	movl $0, %ecx #restituisco

	ret

#RESETTO IL NUMB
reset_numb:
	#incremento numb attuale
	movl $0, COUNTER_t
	movl $0, %ebx #restituisco

	#ALM
	movl $0, %ecx #restituisco
	movl $0, %edx
	ret

#FUORI GIRI OLTRE TEMPO STABILITO!
alm:

	addl $1, COUNTER_t
	movl COUNTER_t, %ebx #restituisco

	#ALM!!
	movl $1, %ecx #restituisco

	ret
