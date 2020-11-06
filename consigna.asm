.data
mensaje_input_valores: .asciz "Por favor ingrese una operacion:  \n"
mensaje_introduccion3: .asciz "Si desea salir escriba: Adios.  \n"
mensaje_introduccion2: .asciz "Soporto un determinado lenguaje: Numero1 espacio Operador espacio Numero2.  \n"
mensaje_introduccion: .asciz "Estoy programado para calcular operaciones aritmeticas de +,-,*,/.  \n"
mensaje_bienvenida: .asciz "Hola soy Goku! la CalculatorBot.  \n"
mensaje_error: .asciz "Lo siento, mis respuestas son limitadas  \n"
mensaje_despedida: .asciz "Adios!\n"
text_result: .asciz "##########\n"
num1: .int 0
operacion: .byte 0
num2: .int 0
resultado: .int 0
resto: .int 0
signo1: .asciz "$"
signo2: .asciz "$"
signo_resultado: .asciz "$"
input_usuario: .asciz ""

.text
.global main
main:				/*Main del programa*/
	mov r0, #0
	bl bienvenida			@--> salto con retorno a la etiqueta `bienvenida`
bucle_del_programa:			/*Bucle que se estara ejecutando mientras el usuario no decida salir*/
	bl input_valores		@--> salto con retorno a la etiqueta `input_valores`
	bl leer_input_usuario		@--> salto con retorno a la etiqueta `leer_input_usuario`
	cmp r2, #'A'			@--> verifica si lo ingresado por el usuario comienza con el caracter 'A'
	beq verificar_palabra		@--> salto condicional a la etiqueta `verificar_palabra`
	bl es_cuenta			@--> salto con retorno a la etiqueta `es_cuenta`
	bl obtener_valor		@--> salto con retorno a la etiqueta `obtener_valor`
	bl resolver_operacion		@--> salto con retorno a la etiqueta `resolver_operacion`
	bl convertir_a_texto		@--> salto con retorno a la etiqueta `convertir_a_texto`
	bl imprimir			@--> salto con retorno a la etiqueta `imprimir`
	bl limpiar_datos		@--> salto con retorno a la etiqueta `limpiar_datos`
	bal bucle_del_programa		@--> salto incondicional a la etiqueta `bucle_del_programa`

/*---------------------------------------------------------------*/
/*En esta seccion de codigo se mostrara por pantalla una bienvenida al usuario y breves introducciones acerca del programa*/

bienvenida:
	.fnstart
	  mov r0, #1 /* salida cadena*/
          ldr r1 , =mensaje_bienvenida
          mov r2, #35 /* Tamaño texto*/
          mov r7, #4 /*sacar por pantalla*/
          swi 0
	.fnend
introduccion:
	.fnstart
	        mov r0, #1 /* salida cadena*/
                ldr r1 , =mensaje_introduccion
                mov r2, #70 /* Tamaño texto*/
                mov r7, #4 /*sacar por pantalla*/
                swi 0
	.fnend
	introduccion2:
	.fnstart
		mov r0, #1 /* salida cadena*/
                ldr r1 , =mensaje_introduccion2
                mov r2, #77 /* Tamaño texto*/
                mov r7, #4 /*sacar por pantalla*/
                swi 0
	.fnend
	introduccion3:
	.fnstart
		mov r0, #1 /* salida cadena*/
                ldr r1 , =mensaje_introduccion3
                mov r2, #33 /* Tamaño texto*/
                mov r7, #4 /*sacar por pantalla*/
                swi 0
		bx lr
	.fnend

input_valores:					/*INPUT_VALORES: Mostrara en pantalla un mensaje pidiendole al usuario
							que ingrese los valores necesarios para calcular la operacion*/
	.fnstart
	  mov r0, #1 /* salida cadena*/
          ldr r1 , =mensaje_input_valores
          mov r2, #35 /* Tamaño texto*/
          mov r7, #4 /*sacar por pantalla*/
          swi 0
	bx lr
	.fnend

/*---------------------------------------------------------------*/
leer_input_usuario:			/*LEER_INPUT_USUARIO: Se encarga de hacer la lectura de lo que ingresa el usuario*/
		.fnstart
		mov r7, #3	@lee lo que se ingresa desde el puerto del teclado
		mov r0, #0	@ingreso string
		mov r2, #10	@tamaño texto a leer
		ldr r1, =input_usuario	@guarda el texto ingresado en r1
		swi 0
	recorrer_input:			/*RECORRER_INPUT: Levanta en un registro el primer elemento para comenzar
								a recorrerlo y regresa al bucle del programa*/
			mov r2, #0
			ldrb r2, [r1]		@carga en r2 el primer elemento de lo que apunta r1
			bx lr		@retorna al bucle del programa.

		verificar_palabra:		/*VERIFICAR_PALABRA: Chequea si lo ingresado es 'Adios' comparando caracter
						     por caracter y hara un salto a 'es_salir'. En caso de que una letra sea
								distinta hara un salto a la etiqueta 'mensaje_ERROR' */
				add r1, #1	@incrementa 1 a r1 (r1 contiene una posicion de memoria)
				ldrb r2, [r1]	@carga a r2 lo que apunta r1 (actualmente)
				cmp r2, #'d'		@compara r2 con tal caracter
				bne mensaje_ERROR	@salto condicional a 'mensaje_ERROR'
				add r1, #1
				ldrb r2, [r1]
				cmp r2, #'i'
				bne mensaje_ERROR
				add r1, #1
				ldrb r2, [r1]
				cmp r2, #'o'
				bne mensaje_ERROR
				add r1, #1
				ldrb r2, [r1]
				cmp r2, #'s'
				bne mensaje_ERROR
				bal es_salir		@salto incondicional a es_salir
		.fnend
/*--------------------------------------------------------------*/
es_cuenta:				/*ES_CUENTA: Se encargara de comprobar la secuencia de caracteres
							'NUMERO1 espacio OPERADOR espacio NUMERO2'. En caso de no cumplirse
					esta secuencia se le informara al usuario con un mensaje sobre el error.*/
	.fnstart
	ldrb r2, [r1]
	verifica_N1:
		cmp r2, #'-'
		beq verificar_signo1	@si el primer caracter es un '-'
		cmp r2, #' '
		beq verifica_OP		@si es igual a un ESPACIO salta a verificar el operador
		add r1, #1
		bal rango_1
	verificar_signo1:
			add r1, #1
			bal es_cuenta
		rango_1:		/*RANGO_1: Chequea que el caracter en su valor ascii sea mayor o igual a 30h
						  que en la tabla representa al 0 */
			cmp r2, #0x30		@compara r2 con 0x30
			bge rango_2		@salto condicional a rango_2
			bal mensaje_ERROR	@salto incondicional a mensaje_ERROR
		rango_2:		/*RANGO_2: Chequea que el caracter en su valor ascii sea menor o igual a 39h
						  que en la tabla representa al 9*/
			cmp r2, #0x39		@compara r2 con 0x39
			ble es_cuenta		@salto condicional a es_cuenta
			bal mensaje_ERROR	@salto incondicional a mensaje_ERROR
	verifica_N2:
		add r1, #1
		ldrb r2, [r1]
		cmp r2, #'-'
		beq verificar_signo2
		cmp r2, #0xa
		beq retorno		@si es igual a un ENTER retorna al bucle del programa.
		bal rango_1.1
	verificar_signo2:
			bal verifica_N2
		rango_1.1:
                        cmp r2, #0x30
                        bge rango_2.2
                        bal mensaje_ERROR
                rango_2.2:
                        cmp r2, #0x39
                        ble verifica_N2
                        bal mensaje_ERROR
	verifica_OP:		/*VERIFICAR_OP: Chequea si es igual a algun operador soportado por el programa
					En caso de que ninguna se cumpla saltara al error*/
		add r1, #1
		ldrb r2, [r1]
		cmp r2, #' '
		beq verifica_N2
                cmp r2, #'+'
                beq verifica_OP
                cmp r2, #'-'
                beq verifica_OP
                cmp r2, #'*'
                beq verifica_OP
                cmp r2, #'/'
                beq verifica_OP
		bal mensaje_ERROR
	.fnend

/*--------------------------------------------------------------*/
obtener_valor:			/*OBTENER_VALOR: Su funcion es transformar los valores ascii a numeros enteros para poder
					operar con ellos */
	.fnstart
	push {lr}
	mov r1, #0
	mov r2, #0
	ldr r4, =signo1
	ldr r1, =input_usuario
	convertir_a_num:
		mov r0, #1  /* r0 contador que indica si es el primer elemento*/
		mov r10, #10
	ciclo_de_tranformacion:		/*CICLO_DE_TRANSFORMACION: Toma valores ascii y los trasnforma a lenguaje maquina*/
		ldrb r2, [r1]
		cmp r2, #'-'
		beq guardar_signo
		cmp r2, #' ' /*pregunto si es espacio*/
		beq almacenar1
		cmp r2, #0xa
		beq almacenar2
		add r1, #1
		sub r2, #0x30 /*resto 30 para obtener un valor */
		cmp r0, #1 /*pregunta si es el primer elemento*/
		bne siguiente
		mov r3, r2 /*en r3 guardo el digito*/
		add r0, #1
		bal ciclo_de_tranformacion
	siguiente:
		mul r3, r10 /*multiplica los digitos por 10*/
		add r3, r2
		bal ciclo_de_tranformacion

	almacenar1:		@-->almacena el primer valor que obtuvo hasta un espacio
		ldr r5, =num1
		str r3, [r5]
		add r1, #1
		bl obtener_operador	@-->salto con retorno a obtener_operador
		b ciclo_de_tranformacion

	almacenar2:
		ldr r5, =num2
		str r3, [r5]
		pop {lr}
		bx lr

	obtener_operador:
		ldr r4, =signo2

		ldrb r2, [r1]		@obtiene el operandor
		bal almacenar_operador

	almacenar_operador:

		ldr r6, =operacion
		str r2, [r6]		@almacena el operandor
		add r1, #2
		mov r3, #0
		bx lr
	guardar_signo:		/*GUARDAR_SIGNO: En caso de que se encuentre con un '-' lo guarda.*/
			str r2, [r4]
			add r1, #1
			bal ciclo_de_tranformacion
	.fnend
/*--------------------------------------------------------------------*/
resolver_operacion:		/*RESOLVER_OPERACION: Esta subrutina se encargara de tomar los valores almacenados en
						memoria y obtener la resolucion de la operacion reconocida.*/
	.fnstart
	ldr r4, =num1
	ldr r6, [r4]
	ldr r8, =num2
	ldr r9, [r8]
	ldr r7, =signo1
	ldrsb r7, [r7]
	ldr r10, =signo2
	ldrsb r10, [r10]
	reconocer_operacion:		/*RECONOCER_OPERACION: Reconocera cual es la operacion que debe resolver.*/
			ldr r5, =operacion
			ldrsb r5, [r5]
			cmp r5, #'+'
			beq suma_resta
			cmp r5, #'-'
			beq suma_resta
			cmp r7, r10		@compara signo1 con signo2
			bne signo_negativo	@sino es igual salta a 'signo_negativo'.
			bal multiplicar_dividir

	suma_resta:		/*SUMA_RESTA: Compara los signos de los operandos NUMERO1 y NUMERO2.*/
		cmp r7, r10
		beq operacion_normal	@si es igual salta a 'operacion_normal'.
		bne operacion_inversa	@sino salta a 'operacion_inversa'.

	operacion_normal:	/*OPERACION_NORMAL: En funcion a que los signos son iguales, realiza la operacion
							como fue introducida por pantalla.*/
                        ldr r10, =signo_resultado	@carga en r10 la posicion de memoria de signo_resultado
                        str r7, [r10]		@almacena lo que contiene r7 (signo1), a lo que apunta r10
			cmp r5, #'+'
			beq suma
			cmp r5, #'-'
			beq verificar_resta
	operacion_inversa:		/*OPERACION_INVERSA: Al contrario de operacion normal, realiza la operacion inversa
							de lo que se pide por pantalla.*/
			ldr r10, =signo_resultado
                        str r7, [r10]
			cmp r5, #'+'
			beq verificar_resta
			cmp r5, #'-'
			beq suma
	suma:
	   	add r6, r9
		bal almacenar_resultado
	verificar_resta:		/*VERIFICAR_RESTA: Verifica si el operando1 es mayor que el operando2*/
			cmp r6, r9
			bgt resta1	@si es mayor salta a 'resta1'
			bal resta2	@sino salta a 'resta2'
	resta2:		/*RESTA2: Recibe al operando1 siendo menor que el operando2*/
		sub r9, r6	@resta r9(num2) con r6(num1), y guarda el resultado en r9(num2)
		mov r6, r9	@mueve a r6, el resultado que se habia guardado en r9
		cmp r7, #'-'
		beq invertir_a_positivo
		bne invertir_a_negativo

	resta1:
		sub r6, r9
		bal almacenar_resultado
	invertir_a_positivo:	/*INVERTIR_A_POSITIVO: Invierte el valor resultante de la resta2 a positivo*/
			mov r7, #'$'
			str r7, [r10]
			bal almacenar_resultado
	invertir_a_negativo:	/*INVERTIR_A_NEGATIVO: Invierte el valor resultante de la resta2 a negativo*/
			mov r7, #'-'
			str r7, [r10]
			bal almacenar_resultado

	multiplicar_dividir:	/*MULTIPLICAR_DIVIDIR: Chequea si es una division o multiplicacion*/
			cmp r5, #'*'
			beq multiplicacion
			bal division

	multiplicacion:
		mul r6, r9
		bal almacenar_resultado
	signo_negativo:		/*SIGNO_NEGATIVO: Pasa a negativo el resultado de la operacion que se vaya a realizar*/
			mov r7, #'-'
			ldr r10, =signo_resultado
			str r7, [r10]
			bal multiplicar_dividir

	division:
		cmp r9, #0	@lanzara un error al intentar dividir por cero
		beq mensaje_ERROR
		mov r0, #0

		resta_recursiva:
			cmp r6, r9
			blt almacenar_division
			sub r6, r9
			add r0, #1
			bal resta_recursiva


		almacenar:
			ldr r3, =resto
			str r6, [r3]
			bal almacenar_resultado
		almacenar_division:
				mov r6, r0
				bal almacenar

	almacenar_resultado:	/*ALMACENAR_RESULTADO: Almacena el resultado final de la operacion ingresada por consola*/
			ldr r5, =resultado
			str r6, [r5]
			bx lr
	.fnend
/*--------------------------------------------------------------------*/

convertir_a_texto:		/*CONVERTIR_A_TEXTO: Esta subrutina se encargara de transformar el resultado de la
						operacion ya resuelta a codigo ascii, para poder mostrar el resultado
						por pantalla*/
		.fnstart
		mov r0, #0
		mov r2, #0
		mov r3, #0
		mov r8, #10	@muevo a r8 la longitud de lo que se va a imprimir
		ldr r6, =text_result
		ldr r1, =resultado
		ldr r10, =signo_resultado
		ldrsb r10, [r10]
		ldr r2, [r1]	@cargo a r2 el resultado de la operacion
		descomposicion_de_numero:	/*DESCOMPOSICION_DE_NUMERO: Resta 10 hasta que r2 sea menor a 10.
								(se resta 10 por que usamos sistema numerico decimal)*/
                        cmp r2, #10
                        blt trasformar_a_ascii
                        sub r2, #10
                        add r0, #1	@cuenta las veces que resta 10 a r2
                        bal descomposicion_de_numero
		trasformar_a_ascii:
				add r2, #0x30	@se suma 0x30 para obtener el valor ascii del numero
				push {r2}	@apila el valor ascii obtenido en r2
				add r3, #1	@cuenta las veces que se apila un valor ascii
				mov r2, r0	@movemos a r2 el valor de r0
				cmp r2, #10
				blt cargar_signo	@si r2 es menor que 10 salta a 'cargar_signo'
				mov r0, #0
				bal descomposicion_de_numero
		ultimo_digito:		/*ULTIMO_DIGITO: Almacena el digito restante directamente*/
				add r2, #0x30
				str r2, [r6]
				bal almacenar_a_ascii
		cargar_signo:		/*CARGAR_SIGNO: Carga el signo al texto resultado, si el resultado es negativo*/
				cmp r10, #'-'
				bne ultimo_digito
				str r10, [r6]
				add r6, #1
				bal ultimo_digito

		almacenar_a_ascii:	/*ALMACENAR_A_ASCII: Devuelve los valores que se apilaron y los almacena en
								el texto resultado*/
				add r6, #1
				cmp r3, #0
				mov r1, #1	@r1 --> indica que mensaje se debe imprimir
				beq retorno
				pop {r2}
				str r2, [r6]
				sub r3, #1
				bal almacenar_a_ascii
		.fnend

/*-------------------------------------------------------------------*/
imprimir:		/*IMPRIMIR: Imprime resultado(1), el mensaje de error(2) o el mensaje de adios(0)*/
	.fnstart
        cmp r1, #0
        beq es_adios
        cmp r1, #1
        beq es_resultado
        cmp r1, #2
        beq es_error
        es_adios:
                mov r0, #1 /* salida cadena*/
                ldr r1 , =mensaje_despedida
                mov r2, r8 /* Tamaño texto*/
                mov r7, #4 /*sacar por pantalla*/
                swi 0
                bal fin
        es_resultado:
                 mov r0, #1 /* salida cadena*/
                 ldr r1 , =text_result
                 mov r2, r8 /* Tamaño texto*/
                 mov r7, #4 /*sacar por pantalla*/
                 swi 0
                 bal retorno
        es_error:
                 mov r2, #0
                 mov r7, #0
                 mov r0, #1 /* salida cadena*/
                 ldr r1 , =mensaje_error
                 mov r2, r8 /* Tamaño texto*/
                 mov r7, #4 /*sacar por pantalla*/
                 swi 0
                 bal bucle_del_programa

        .fnend
/*-------------------------------------------------------------------*/
retorno:
	bx lr
/*-------------------------------------------------------------------*/
limpiar_datos:		/*LIMPIAR_DATOS: Resetea registros y variables*/
		.fnstart
		clear_variables:
				mov r0, #0
				mov r1, #''
				mov r2, #'$'
				ldr r12, =input_usuario
				ldr r11, =num1
				ldr r10, =num2
				ldr r9, =operacion
				ldr r8, =resultado
				ldr r7, =resto
				ldr r6, =signo1
				ldr r5, =signo2
				ldr r4, =signo_resultado
				str r1, [r12]
				str r0, [r11]
				str r0, [r10]
				str r0, [r9]
				str r0, [r8]
				str r0, [r7]
				str r2, [r6]
				str r2, [r5]
				str r2, [r4]

		clear_registros:
				mov r0, #0
				mov r1, #0
                                mov r2, #0
                                mov r3, #0
                                mov r4, #0
                                mov r5, #0
                                mov r6, #0
                                mov r7, #0
                                mov r8, #0
                                mov r9, #0
                                mov r10, #0
                                mov r11, #0
                                mov r12, #0
			bx lr
		.fnend
/*--------------------------------------------------------------------*/

mensaje_ERROR:
		.fnstart
		mov r8, #42	@muevo a r8 la longitud de lo que se va a imprimir
		mov r1, #2	@r1 --> indica que mensaje se debe imprimir
		bal imprimir
		.fnend
/*---------------------------------------------------------------------*/

es_salir:
	.fnstart
	mov r8, #8	@muevo a r8 la longitud de lo que se va a imprimir
	mov r1, #0	@r1 --> indica que mensaje se debe imprimir
	bal imprimir
	.fnend
/*---------------------------------------------------------------------*/

fin:
	mov r7, #1
	swi 0
