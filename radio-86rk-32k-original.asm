;  #################################################################################################
;  ##  УПРАВЛЯЮЩАЯ ПРОГРАММА "МОНИТОР" ДЛЯ КОМПЬЮТЕРА "РАДИО-86РК" 32 килобайта                   ##
;  #################################################################################################
;
;  Authors: Дмитрий Горшков, Геннадий Зеленко, Юрий Озеров, Сергей Попов,
;           дизассемблирование и комментарии Vitaliy Poedinok aka Vital72
;  www:     http://www.86rk.ru/
;  e-mail:  vital72@86rk.ru
;  =================================================================================================
;  Это авторская версия МОНИТОРА для компьютера "РАДИО-86РК", коды которого печатались в журнале
;  Радио №8 за 1986г. с.23, адаптированная для ОЗУ 32кб.
;  =================================================================================================

MONITOR_BASE		EQU	0F800h	;  стартовый адрес МОНИТОРа
MONITOR_EXTENSION	EQU	0F000h	;  стартовый адрес расширения МОНИТОРа
MONITOR_DATA		EQU	07600h	;  начало области рабочих ячеек МОНИТОРа
MONITOR_DATA_SIZE	EQU	000D0h	;  размер области рабочих ячеек МОНИТОРа
MONITOR_WARM_START	EQU	0F86Ch	;  горячий старт/консоль

;  базовые адреса микросхем периферии
ADDR_KBD		EQU	08000h
ADDR_PORT		EQU	0A000h
ADDR_CRT		EQU	0C000h
ADDR_DMA		EQU	0E000h

ADDR_KBD_PA		EQU	ADDR_KBD + 0
ADDR_KBD_PB		EQU	ADDR_KBD + 1
ADDR_KBD_PC		EQU	ADDR_KBD + 2
ADDR_KBD_CTRL		EQU	ADDR_KBD + 3

ADDR_PORT_PA		EQU	ADDR_PORT + 0
ADDR_PORT_PB		EQU	ADDR_PORT + 1
ADDR_PORT_PC		EQU	ADDR_PORT + 2
ADDR_PORT_CTRL		EQU	ADDR_PORT + 3

ADDR_CRT_PARAM		EQU	ADDR_CRT
ADDR_CRT_CTRL		EQU	ADDR_CRT + 1

;  флаги управляющих клавиш клавиатуры
KBD_RUS_FLAG		EQU	80h
KBD_CTRL_FLAG		EQU	40h
KBD_SHIFT_FLAG		EQU	20h

;  константы задержек при обработке нажатий клавиш
KBD_ANTIBOUNCE		EQU	21	;  антидребезг
KBD_DELAY_FIRST		EQU	224	;  задержка автоповтора для второго символа
KBD_DELAY_REGULAR	EQU	64	;  задержка автоповтора для остальных символов

;  размер видимой части экрана в символах
SCR_VIDEO_SIZE_X	EQU	64	;  по X
SCR_VIDEO_SIZE_Y	EQU	25	;  по Y
;  полный размер экрана, включающий бланкирующие зоны, в символах
SCR_SIZE_X		EQU	78	;  по X
SCR_SIZE_Y		EQU	30	;  по Y
SCR_ARRAY		EQU	SCR_SIZE_X * SCR_SIZE_Y
; отступ левого верхнего угла видимой части экрана, в символах
SCR_PAD_X		EQU	8	;  по горизонтали
SCR_PAD_Y		EQU	3	;  по вертикали
;  адреса экранной области и видимой его части
SCREEN			EQU	MONITOR_DATA + MONITOR_DATA_SIZE
SCREEN_VIDEO		EQU	SCREEN + SCR_SIZE_X * SCR_PAD_Y + SCR_PAD_X

;  управляющие коды дисплея
CHAR_CODE_CR		EQU	0Dh
CHAR_CODE_LF		EQU	0Ah
CHAR_CODE_BEL		EQU	07h
CHAR_CODE_HT		EQU	09h
CHAR_CODE_FF		EQU	0Ch
CHAR_CODE_SO		EQU	0Eh	;  Invoke G1 character set
CHAR_CODE_SI		EQU	0Fh	;  Select G0 character set

CHAR_CODE_LEFT		EQU	08h
CHAR_CODE_RIGHT		EQU	18h
CHAR_CODE_UP		EQU	19h
CHAR_CODE_DOWN		EQU	1Ah
CHAR_CODE_CLS		EQU	1Fh
CHAR_CODE_BACKSPACE	EQU	7Fh
CHAR_CODE_ENTER		EQU	0Dh
CHAR_CODE_ESC		EQU	1Bh
CHAR_CODE_CTRL_C	EQU	03h

;  параметры настройки контроллера CRT
CRT_PIXEL_CLOCK		EQU	8000	;  kHz
CRT_CHAR_WIDTH		EQU	6	;  ширина символа, пикселы
CRT_HORIZ_TIME		EQU	64	;  длительность строки, мкс
CRT_SPACED_ROWS		EQU	0	;  spaced row [0, 1]
CRT_VERT_ROW_COUNT	EQU	1	;  vertical retrace row count [1, 2, 3, 4]
CRT_UNDERLINE		EQU	10	;  underline placement [1..16]
CRT_LINES_PER_ROW	EQU	10	;  number of lines per character row [1..16]
CRT_LINE_OFFSET		EQU	1	;  line counter mode [0, 1]
CRT_NON_TRANSP_ATTR	EQU	0	;  field attribute mode [0, 1]
CRT_HORIZONTAL_COUNT	EQU	8	;  horizontal retrace count [2, 4, 6, .. 32]
CRT_BURST_SPACE_CODE	EQU	1	;  [0..7]
CRT_BURST_COUNT_CODE	EQU	3	;  [0..3]
CRT_ZZZZ		EQU	((CRT_HORIZ_TIME * CRT_PIXEL_CLOCK / 1000 / CRT_CHAR_WIDTH - SCR_SIZE_X + 1) >> 1) - 1

;
INP_BUFFER_SIZE		EQU	32
CURSOR_VIEW_INITIAL	EQU	10h

;  константа чтения с магнитофона
TAPE_READ_CONST		EQU	2Ah
;  константа записи на магнитофон
TAPE_WRITE_CONST	EQU	1Dh
;  синхробайт для чтения с магнитофона
TAPE_SYNC_BYTE		EQU	0E6h
;  задержка периода (высота тона) для стандартного сигнала
OUT_BELL_DELAY		EQU	05h
;  количество периодов (длительность) для стандартного сигнала
OUT_BELL_COUNT		EQU	0F0h
;  задержка периода (высота тона) для щелчка от нажатия клавиши
KBD_BELL_DELAY		EQU	50h
;  количество периодов (длительность) для щелчка от нажатия клавиши
KBD_BELL_COUNT		EQU	03h
;  адрес перехода по команде RST 6
RST_6_ADDR		EQU	30h

;  =================================================================================================
;  ====================================================================================  МОНИТОР  ==

	org	MONITOR_BASE

	jmp	cold_start		;  00  //  холодный старт
	jmp	in_char			;  03  //  ввод символа с клавиатуры (блок)
	jmp	tape_rd_byte		;  06  //  чтение байта с ленты
	jmp	out_char_c		;  09  //  вывод символа на экран (рег. C)
	jmp	tape_wr_byte		;  0c  //  запись байта на ленту
	jmp	out_char_c		;  0f  //  вывод символа на экран (рег. A)
	jmp	kbd_state		;  12  //  состояние клавиатуры
	jmp	out_hex			;  15  //  вывод на экран байта в hex-коде
	jmp	out_str			;  18  //  вывод строки на экран
	jmp	in_key			;  1b  //  код нажатой клавиши (не блок)
	jmp	get_cursor		;  1e  //  получение координат курсора
	jmp	get_scr			;  21  //  чтение байта с экрана в текущей позиции
	jmp	tape_rd_block		;  24  //  чтение блока с ленты
	jmp	tape_wr_block		;  27  //  запись блока на ленту
	jmp	check_sum		;  2a  //  подсчёт контрольной суммы блока
	jmp	init_video		;  2d  //  инициализация видео
	jmp	get_ram_top		;  30  //  получение верхней границы памяти
	jmp	set_ram_top		;  33  //  установка верхней границы памяти

cold_start:
	mvi	a, 10001010b
	sta	ADDR_KBD_CTRL
	lxi	sp, SCREEN - 1
	call	init_video
	;  очистка рабочих ячеек МОНИТОРА
	lxi	h, MONITOR_DATA
	lxi	d, MONITOR_DATA_END - 1
	mvi	c, 0
	call	directive_F
	;
	lxi	h, SCREEN - 1
	shld	SP_storage
	lxi	h, title_str
	call	out_str
	call	init_video
	lxi	h, MONITOR_DATA - 1
	shld	ram_top
	lxi	h, (TAPE_WRITE_CONST << 8) | TAPE_READ_CONST
	shld	tape_consts
	;  код команды JMP для директивы G
	mvi	a, 0C3h
	sta	jump_to_go

warm_start:
	;  т.н. теплый старт МОНИТОРА.
	.if $ - MONITOR_WARM_START
	.error MONITOR_WARM_START
	.endif

	lxi	sp, SCREEN - 1
	lxi	h, prompt_str
	call	out_str			;  после выхода из п/п в A будет 0
	sta	ADDR_KBD_PC
	dcr	a
	sta	ADDR_PORT_PC
	call	get_str
	lxi	h, warm_start
	push	h
	lxi	h, inp_buffer
	mov	a, m			;  первый символ введённой строки
	cpi	'X'
	jz	directive_X
	cpi	'U'
	jz	MONITOR_EXTENSION
	push	psw
	call	parse_params
	lhld	in_param3
	mov	c, l
	mov	b, h
	lhld	in_param2
	xchg
	lhld	in_param1
	pop	psw
	cpi	'D'
	jz	directive_D
	cpi	'C'
	jz	directive_C
	cpi	'F'
	jz	directive_F
	cpi	'S'
	jz	directive_S
	cpi	'T'
	jz	directive_T
	cpi	'M'
	jz	directive_M
	cpi	'G'
	jz	directive_G
	cpi	'I'
	jz	directive_I
	cpi	'O'
	jz	directive_O
	cpi	'L'
	jz	directive_L
	cpi	'R'
	jz	directive_R
	jmp	MONITOR_EXTENSION

get_str_back:
	mvi	a, low (inp_buffer)
	cmp	l
	jz	get_str_next
	push	h
	lxi	h, backspace_str
	call	out_str
	pop	h
	dcx	h
	jmp	get_str_loop

;  ВВОД СТРОКИ СИМВОЛОВ ВО ВНУТРЕННИЙ БУФЕР  _______________________________________________________
;  Ввод с клавиатуры во внутренний буфер МОНИТОРА, размер ограничен в 31 символ
;  Особо обрабатываемые клавиши:
;      [<-] и [ЗБ] - удаление последнего символа
;              [.] - выход на тёплый старт МОНИТОРА
;             [ВК] - возврат
get_str:
	lxi	h, inp_buffer
get_str_next:
	mvi	b, 0
get_str_loop:
	call	in_char
	cpi	CHAR_CODE_LEFT
	jz	get_str_back
	cpi	CHAR_CODE_BACKSPACE
	jz	get_str_back
	cnz	out_char_a
	mov	m, a
	cpi	CHAR_CODE_CR
	jz	get_str_cr
	cpi	'.'
	jz	warm_start
	mvi	b, 0FFh
	mvi	a, low (inp_buffer_end - 1)
	cmp	l
	jz	out_error_txt
	inx	h
	jmp	get_str_loop
get_str_cr:
	mov	a, b
	ral
	lxi	d, inp_buffer
	mvi	b, 0
	ret

;  ВЫВОД СТРОКИ СИМВОЛОВ  __________________________________________________________________________
;  Вход:  HL - адрес строки, строка оканчивается нулевым символом
out_str:
	mov	a, m
	ana	a
	rz
	call	out_char_a
	inx	h
	jmp	out_str

;  PARSE PARAMS  ___________________________________________________________________________________
parse_params:
	lxi	h, in_param1		;  обнуление переменных in_param1,
	lxi	d, in_param1 + 2 * 3	;  in_param2, in_param3 и in_param2_present
	mvi	c, 0			;
	call	directive_F		;
	lxi	d, inp_buffer + 1
	call	str2hex
	shld	in_param1
	shld	in_param2
	rc
	mvi	a, 0FFh			;  признак наличия второго параметра
	sta	in_param2_present
	call	str2hex
	shld	in_param2
	rc
	call	str2hex
	shld	in_param3
	rc
	jmp	out_error_txt

;  ПРЕОБРАЗОВАНИЕ HEX-СТРОКИ В ЧИСЛО  ______________________________________________________________
;  Вход:  DE - адрес строки
;  Выход: HL - результат
str2hex:
	lxi	h, 0
str2hex_loop:
	ldax	d
	inx	d
	cpi	CHAR_CODE_CR
	jz	str2hex_cr
	cpi	','
	rz
	cpi	' '
	jz	str2hex_loop
	sui	'0'
	jm	out_error_txt
	cpi	10
	jm	str2hex_add
	cpi	'A' - '0'
	jm	out_error_txt
	cpi	'F' - '0' + 1
	jp	out_error_txt
	sui	'A' - '9' - 1
str2hex_add:
	mov	c, a
	dad	h
	dad	h
	dad	h
	dad	h
	jc	out_error_txt
	dad	b
	jmp	str2hex_loop
str2hex_cr:
	stc
	ret

;  СРАВНЕНИЕ ДВУХ 16-РАЗРЯДНЫХ ЧИСЕЛ  ______________________________________________________________
;  Вход:  HL - первое слово
;         DE - второе слово
;  Выход: флаг Z = 1: DE == HL
cmp_hl_de:
	mov	a, h
	cmp	d
	rnz
	mov	a, l
	cmp	e
	ret

;  ПРОВЕРКА НА НАЖАТИЕ CTRL+C И ДОСТИЖЕНИЕ КОНЦА БЛОКА  ____________________________________________
cmp_and_check_ctrl_c:
	call	check_ctrl_c
cmp_hl_de_loop:
	call	cmp_hl_de
	jnz	$+6
exit_from_loop:
	inx	sp
	inx	sp
	ret
	inx	h
	ret

check_ctrl_c:
	call	in_key
	cpi	CHAR_CODE_CTRL_C
	rnz
	call	init_video
	jmp	out_error_txt

;  ВЫВОД ОТБИВКИ ОТ КРАЯ ЭКРАНА С НОВОЙ СТРОКИ  ____________________________________________________
out_padding:
	push	h
	lxi	h, padding_str
	call	out_str
	pop	h
	ret

;  ВЫВОД БАЙТА ИЗ ПЯМЯТИ НА ЭКРАН В HEX  ___________________________________________________________
;  Вход:  HL - адрес ячейки памяти
out_mem_hex_and_space:
	mov	a, m
out_hex_and_space:
	push	b
	call	out_hex
	mvi	a, ' '
	call	out_char_a
	pop	b
	ret

;  ________________________________________________________________________________  ДИРЕКТИВА D  __
directive_D:
	call	out_word
directive_D_loop:
	call	out_mem_hex_and_space
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	0Fh
	jz	directive_D
	jmp	directive_D_loop

;  ________________________________________________________________________________  ДИРЕКТИВА C  __
directive_C:
	ldax	b
	cmp	m
	jz	directive_C_skip
	call	out_word
	call	out_mem_hex_and_space
	ldax	b
	call	out_hex_and_space
directive_C_skip:
	inx	b
	call	cmp_and_check_ctrl_c
	jmp	directive_C

;  ________________________________________________________________________________  ДИРЕКТИВА F  __
directive_F:
	mov	m, c
	call	cmp_hl_de_loop
	jmp	directive_F

;  ________________________________________________________________________________  ДИРЕКТИВА S  __
directive_S:
	mov	a, c
	cmp	m
	cz	out_word
	call	cmp_and_check_ctrl_c
	jmp	directive_S

;  ________________________________________________________________________________  ДИРЕКТИВА T  __
directive_T:
	mov	a, m
	stax	b
	inx	b
	call	cmp_hl_de_loop
	jmp	directive_T

;  ________________________________________________________________________________  ДИРЕКТИВА L  __
directive_L:
	call	out_word
directive_L_loop:
	mov	a, m
	ora	a
	jm	$+8
	cpi	' '
	jnc	$+5
	mvi	a, '.'
	call	out_char_a
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	0Fh
	jz	directive_L
	jmp	directive_L_loop

;  ________________________________________________________________________________  ДИРЕКТИВА M  __
directive_M:
	call	out_word
	call	out_mem_hex_and_space
	push	h
	call	get_str
	pop	h
	jnc	directive_M_next
	push	h
	call	str2hex
	mov	a, l
	pop	h
	mov	m, a
directive_M_next:
	inx	h
	jmp	directive_M

;  ________________________________________________________________________________  ДИРЕКТИВА G  __
directive_G:
	call	cmp_hl_de
	jz	directive_G_nostop
	xchg
	shld	stop_addr
	mov	a, m
	sta	stop_addr_byte
	mvi	m, 0F7h			;  код команды RST 6
	mvi	a, 0C3h			;  код команды JMP
	sta	RST_6_ADDR
	lxi	h, return_address
	shld	RST_6_ADDR + 1
directive_G_nostop:
	lxi	sp, BC_storage
	pop	b
	pop	d
	pop	h
	pop	psw
	sphl
	lhld	HL_storage
	jmp	jump_to_go

;  ________________________________________________________________________________  ДИРЕКТИВА R  __
directive_R:
	mvi	a, 10010000b
	sta	ADDR_PORT_CTRL
directive_R_loop:
	shld	ADDR_PORT_PB
	lda	ADDR_PORT_PA
	stax	b
	inx	b
	call	cmp_hl_de_loop
	jmp	directive_R_loop

;  ЗАПРОС ПОЛОЖЕНИЯ КУРСОРА  _______________________________________________________________________
;  Выход: H - номер строки
;         L - номер позиции
get_cursor:
	lhld	cursor_pos
	ret

;  ЗАПРОС БАЙТА ИЗ ЭКРАННОГО БУФЕРА  _______________________________________________________________
;  Выход: A - код из буфера
get_scr:
	push	h
	lhld	cursor_addr
	mov	a, m
	pop	h
	ret

;  ________________________________________________________________________________  ДИРЕКТИВА I  __
directive_I:
	lda	in_param2_present
	ora	a
	jz	$+7
	mov	a, e
	sta	tape_consts
	call	tape_rd_block
	call	out_word
	xchg
	call	out_word
	xchg
	push	b
	call	check_sum
	mov	h, b
	mov	l, c
	call	out_word
	pop	d
	call	cmp_hl_de
	rz
	xchg
	call	out_word

out_error_txt:
	mvi	a, '?'
	call	out_char_a
	jmp	warm_start

;  ЧТЕНИЕ БЛОКА С МАГНИТНОЙ ЛЕНТЫ  _________________________________________________________________
;  Вход:  HL - смещение
;  Выход: HL - адрес начала
;         DE - адрес конца
;         BC - считанная контрольная сумма блока
;  Подпрограмма выполняет ввод блока данных, сформированный директивой 'O' МОНИТОРа.
;  Блок имеет следующую структуру:
;      - раккорд
;      - синхробайт
;      - начальный адрес
;      - конечный адрес
;      - собственно данные (N байт)
;      - раккорд
;      - синхробайт
;      - контрольная сумма 2 байта
;  Адреса и контрольная сумма записываются старшими байтами вперед
tape_rd_block:
	mvi	a, 0FFh			;  признак поиска синхробайта
	call	tape_rd_bc
	push	h
	dad	b
	xchg
	call	tape_rd_bc_nosync
	pop	h
	dad	b
	xchg
	push	h
	call	tape_rd_block_loop
	mvi	a, 0FFh			;  признак поиска синхробайта
	call	tape_rd_bc
	pop	h

;  ИНИЦИАЛИЗАЦИЯ КОНТРОЛЛЕРОВ  _____________________________________________________________________
init_video:
	push	h
	lxi	h, ADDR_CRT_CTRL
	mvi	m, 0			;  команда "сброс"
	dcx	h

	;  компоновка кадра: загружаются 4 байта в регистр параметров
	;  1. SHHHHHHH
	;     S        - знакоряды:
	;                0 - нормальные знакоряды
	;                1 - чередующиеся знакоряды
	;      HHHHHHH - число знаков в знакоряду минус один (от 1 до 80)
	mvi	m, (SCR_SIZE_X - 1) | (CRT_SPACED_ROWS << 7)

	;  2. VVRRRRRR
	;     VV       - длительность обратного хода кадровой развертки
	;                00 - 1 знакоряд
	;                01 - 2 знакоряда
	;                10 - 3 знакоряда
	;                11 - 4 знакоряда
	;       RRRRRR - число знакорядов в кадре минус один (от 1 до 64):
	mvi	m, (SCR_SIZE_Y - 1) | ((CRT_VERT_ROW_COUNT - 1) << 6)

	;  3. UUUULLLL
	;     UUUU     - номер строки подчеркивания в знакоряду, старший бит
	;                определяет гашение верхней и нижней строк растра в
	;                знакоряду, если UUUU = 1xxx, то строки гасятся
	;         LLLL - число строк растра в знакоряду (от 1 до 16)
	mvi	m, ((CRT_UNDERLINE - 1) << 4) | (CRT_LINES_PER_ROW - 1)

	;  4. MFCCZZZZ
	;     M        - режим счетчика строк:
	;                0 - не сдвинуто
	;                1 - смещено на 1 счет
	;                подробно на стр. 125
	;      F       - режим атрибутов поля:
	;                0 - прозрачный
	;                1 - непрозрачный
	;       CC     - тип курсора:
	;                00 - мерцающий негативный видеоблок
	;                01 - мерцающие подчеркивание
	;                10 - немерцающий негативный видеоблок
	;                11 - немерцающее подчеркивание
	;         ZZZZ - число знаков при обратном ходе строчной
	;                развертки (2, 4, 6, ..., 32): (3 + 1) * 2 = 8
	mvi	m, (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6) | (01b << 4) | CRT_ZZZZ
	inx	h			;  HL = адрес регистра команд CRT

	;  001SSSBB - команда "начало воспроизведения"
	;     SSS   - интервал между пакетами, число синхроимпульсов
	;             знака между пакетными запросами ПДП:
	;             000 = 0
	;             001 = 7
	;             010 = 15
	;             011 = 23
	;             100 = 31
	;             101 = 39
	;             110 = 47
	;             111 = 55
	;        BB - число запросов ПДП в пакете:
	;             00 = 1
	;             01 = 2
	;             10 = 4
	;             11 = 8
	mvi	m, 00100000b | (CRT_BURST_SPACE_CODE << 2) | CRT_BURST_COUNT_CODE
	mov	a, m			;  сброс регистра флагов
	mov	a, m			;  чтение слова состояния
	ani	20h			;  нужен флаг IR - запрос прерывания
	jz	$-3			;  ждём установленного IR

	lxi	h, ADDR_DMA + 8		;  адрес регистра режимов ПДП
	mvi	m, 10000000b		;  запрет ПДП
	mvi	l, low (ADDR_DMA + 04h)	;  адрес регистра адреса канала 2 ПДП
	mvi	m, low (SCREEN)		;  младший адрес памяти
	mvi	m, high (SCREEN)	;  старший адрес памяти
	inr	l			;  адрес регистра количества циклов ПДП канала 2

	;  16 бит = RWCCCCCC CCCCCCCC
	;  CCCCCC CCCCCCCC - количество циклов
	;  RW = 00 - цикл проверки ПД
	;  RW = 01 - цикл записи ПД
	;  RW = 10 - цикл чтения ПД
	;  RW = 11 - запрещенная комбинация
	;  младший байт счётчика циклов (биты C7-C0)
	mvi	m, low (SCR_ARRAY - 1)
	;  старший байт счётчика циклов (биты C13-C8)
	mvi	m, high (SCR_ARRAY - 1) | (01b << 6)
	mvi	l, low (ADDR_DMA + 08h)	;  адрес регистра режимов ПДП

	;  D7 [AL]  = 1 - автозагрузка
	;  D6 [TCS] = 0 - КС-стоп
	;  D5 [EW]  = 1 - удлиненная запись
	;  D4 [RP]  = 0 - циклический сдвиг
	;  D3 [EN3] = 0 - разрешение канала 3
	;  D2 [EN2] = 1 - разрешение канала 2
	;  D1 [EN1] = 0 - разрешение канала 1
	;  D0 [EN0] = 0 - разрешение канала 0
	mvi	m, 10100100b		;  установка режима

	;  здесь начинаются циклы ПДП
	pop	h
	ret

;  ВВОД 16-БИТНОГО СЛОВА С МАГНИТОФОНА  ____________________________________________________________
;  Выход: BC - СЛОВO
tape_rd_bc_nosync:
	mvi	a, 8			;  без поиска синхробайта
tape_rd_bc:
	call	tape_rd_byte
	mov	b, a
	mvi	a, 8			;  без поиска синхробайта
	call	tape_rd_byte
	mov	c, a
	ret

;  ЧТЕНИЕ МАССИВА ДАННЫХ С МАГНИТОФОНА  ____________________________________________________________
;  Вход: HL - начальный адрес массива
;        DE - конечный адрес массива
tape_rd_block_loop:
	mvi	a, 8			;  без поиска синхробайта
	call	tape_rd_byte
	mov	m, a
	call	cmp_hl_de_loop
	jmp	tape_rd_block_loop

;  ПОДСЧЁТ КОНТРОЛЬНОЙ СУММЫ БЛОКА  ________________________________________________________________
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
;  Выход: BC - контрольная сумма
check_sum:
	lxi	b, 0
check_sum_loop:
	mov	a, m
	add	c
	mov	c, a
	push	psw
	call	cmp_hl_de
	jz	exit_from_loop
	pop	psw
	mov	a, b
	adc	m
	mov	b, a
	call	cmp_hl_de_loop
	jmp	check_sum_loop

;  ________________________________________________________________________________  ДИРЕКТИВА O  __
directive_O:
	mov	a, c
	ora	a
	jz	$+6
	sta	tape_consts + 1
	push	h
	call	check_sum
	pop	h
	call	out_word
	xchg
	call	out_word
	xchg
	push	h
	mov	h, b
	mov	l, c
	call	out_word
	pop	h

;  ЗАПИСЬ БЛОКА НА МАГНИТНУЮ ЛЕНТУ  ________________________________________________________________
;  Вход: HL - начальный адрес блока,
;        DE - конечный адрес блока. 
;        BC - подсчитанная контрольная сумма
;  Структура выводимого блока:
;      - 256 байт (00) раккорда
;      - синхробайт
;      - начальный адрес блока
;      - конечный адрес блока
;      - собственно массив данных (N байт)
;      - раккорд 2 байта 00
;      - синхробайт
;      - контрольная сумма блока (2 байта)      
tape_wr_block:
	push	b
	lxi	b, 0
tape_wr_block_raccord_loop:
	call	tape_wr_byte
	dcr	b
	xthl
	xthl
	jnz	tape_wr_block_raccord_loop
	mvi	c, TAPE_SYNC_BYTE
	call	tape_wr_byte
	call	tape_wr_hl
	xchg
	call	tape_wr_hl
	xchg
	call	tape_wr_block_loop
	lxi	h, 0
	call	tape_wr_hl
	mvi	c, TAPE_SYNC_BYTE
	call	tape_wr_byte
	pop	h
	call	tape_wr_hl
	jmp	init_video

;  ВЫВОД СЛОВА НА ЭКРАН  ___________________________________________________________________________
;  Вход:  HL - слово
out_word:
	push	b
	call	out_padding
	mov	a, h
	call	out_hex
	mov	a, l
	call	out_hex_and_space
	pop	b
	ret

;  ВЫДАЧА МАССИВА БАЙТ НА МАГНИТОФОН  ______________________________________________________________
;  Вход: HL - начальный адрес массива
;        DE - конечный адрес массива
tape_wr_block_loop:
	mov	c, m
	call	tape_wr_byte
	call	cmp_hl_de_loop
	jmp	tape_wr_block_loop

tape_wr_hl:
	mov	c, h
	call	tape_wr_byte
	mov	c, l
	jmp	tape_wr_byte

;  ЧТЕНИЕ БАЙТА С МАГНИТНОЙ ЛЕНТЫ  _________________________________________________________________
;  Вход:  A = 8 - (8 - количество бит в байте) без синхробайта
;         A = 80h - 0FFh - (отрицательное число) с поиском синхробайта
;  Выход: A - прочитанный байт
tape_rd_byte:
	push	h
	push	b
	push	d
	mov	d, a
tape_rd_byte_start:
	mvi	a, 10000000b		;  запрет ПДП
	sta	ADDR_DMA + 8		;  адрес регистра режимов ПДП
	lxi	h, 0
	dad	sp
	lxi	sp, 0
	shld	save_sp
	mvi	c, 0			;  результат
	lda	ADDR_KBD_PC
	rrc
	rrc
	rrc
	rrc
	ani	1
	mov	e, a
tape_rd_byte_loop:
	pop	psw
	mov	a, c
	ani	7Fh
	rlc
	mov	c, a
	mvi	h, 0			;  счетчик попыток чтения уровня
tape_rd_byte_wait:
	dcr	h
	jz	tape_rd_byte_error
	pop	psw
	lda	ADDR_KBD_PC
	rrc
	rrc
	rrc
	rrc
	ani	1
	cmp	e
	jz	tape_rd_byte_wait
	ora	c
	mov	c, a
	dcr	d
	lda	tape_consts
	jnz	$+5
	sui	18			;  коррекция константы
	mov	b, a			;  счетчик задержки
	pop	psw
	dcr	b
	jnz	$-2
	inr	d
	lda	ADDR_KBD_PC
	rrc
	rrc
	rrc
	rrc
	ani	1
	mov	e, a
	mov	a, d
	ora	a
	jp	tape_rd_byte_lbl3
	mov	a, c
	cpi	TAPE_SYNC_BYTE
	jnz	tape_rd_byte_lbl1
	xra	a
	sta	tape_data_sign
	jmp	tape_rd_byte_lbl2
tape_rd_byte_lbl1:
	cpi	low (~TAPE_SYNC_BYTE)
	jnz	tape_rd_byte_loop
	mvi	a, 0FFh			;  инверсия входного сигнала
	sta	tape_data_sign
tape_rd_byte_lbl2:
	mvi	d, 8 + 1
tape_rd_byte_lbl3:
	dcr	d
	jnz	tape_rd_byte_loop
	lxi	h, ADDR_DMA + 4		;  адрес регистра адреса канала 2 ПДП
	mvi	m, low (SCREEN)		;  младший адрес памяти
	mvi	m, high (SCREEN)	;  старший адрес памяти
	inx	h			;  адрес регистра количества циклов ПДП канала 2
	mvi	m, low (SCR_ARRAY - 1)
	mvi	m, high (SCR_ARRAY - 1) | (01b << 6)
	;  команда "начало воспроизведения"
	mvi	a, 00100000b | (CRT_BURST_SPACE_CODE << 2) | CRT_BURST_COUNT_CODE
	sta	ADDR_CRT_CTRL
	mvi	a, 11100000b		;  команда "предустановка счётчиков"
	sta	ADDR_CRT_CTRL
	mvi	l, 08h			;  адрес регистра режимов ПДП
	mvi	m, 10100100b		;  установка режима
	lhld	save_sp
	sphl
	lda	tape_data_sign
	xra	c
	jmp	pop_dbh_and_ret

tape_rd_byte_error:
	lhld	save_sp
	sphl
	call	init_video
	mov	a, d
	ora	a
	jp	out_error_txt
	call	check_ctrl_c
	jmp	tape_rd_byte_start

;  ЗАПИСЬ БАЙТА НА МАГНИТНУЮ ЛЕНТУ  ________________________________________________________________
;  Вход:  C - байт
tape_wr_byte:
	push	h
	push	b
	push	d
	push	psw
	mvi	a, 10000000b		;  запрет ПДП
	sta	ADDR_DMA + 8		;  адрес регистра режимов ПДП
	lxi	h, 0
	dad	sp
	lxi	sp, 0
	mvi	d, 8			;  счетчик бит
tape_wr_byte_loop:
	pop	psw
	mov	a, c
	rlc
	mov	c, a
	mvi	a, 1
	xra	c
	sta	ADDR_KBD_PC
	lda	tape_consts + 1
	mov	b, a
	pop	psw
	dcr	b
	jnz	$-2
	mvi	a, 0			;  маска без инверсии
	xra	c
	sta	ADDR_KBD_PC
	dcr	d
	lda	tape_consts + 1
	jnz	$+5
	sui	14			;  коррекция константы
	mov	b, a
	pop	psw
	dcr	b
	jnz	$-2
	inr	d
	dcr	d
	jnz	tape_wr_byte_loop
	sphl
	lxi	h, ADDR_DMA + 4		;  адрес регистра адреса канала 2 ПДП
	mvi	m, low (SCREEN)		;  младший адрес памяти
	mvi	m, high (SCREEN)	;  старший адрес памяти
	inx	h			;  адрес регистра количества циклов ПДП канала 2
	mvi	m, low (SCR_ARRAY - 1)
	mvi	m, high (SCR_ARRAY - 1) | (01b << 6)
	;  команда "начало воспроизведения"
	mvi	a, 00100000b | (CRT_BURST_SPACE_CODE << 2) | CRT_BURST_COUNT_CODE
	sta	ADDR_CRT_CTRL
	mvi	a, 11100000b		;  команда "предустановка счётчиков"
	sta	ADDR_CRT_CTRL
	mvi	l, 08h			;  адрес регистра режимов ПДП
	mvi	m, 10100100b		;  установка режима
	pop	psw
pop_dbh_and_ret:
	pop	d
	pop	b
	pop	h
	ret

;  ВЫВОД БАЙТА В HEX-КОДЕ  _________________________________________________________________________
;  Вход:  A - байт
out_hex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	$+4
	pop	psw
	ani	0Fh
	cpi	10
	jm	$+5
	adi	07h
	adi	'0'

;  ВЫВОД СИМВОЛА  __________________________________________________________________________________
;  Вход:  A - код символа
out_char_a:
	mov	c, a

;  ВЫВОД СИМВОЛА  __________________________________________________________________________________
;  Вход:  C - код символа
out_char_c:
	push	psw
	push	b
	push	d
	push	h
	call	kbd_state
	lxi	h, out_char_update_and_exit
	push	h
	lhld	cursor_pos
	xchg
	lhld	cursor_addr
	lda	out_char_esc_phase
	dcr	a
	jm	out_char_no_esc			;  out_char_esc_phase == 0
	jz	out_char_esc1			;  out_char_esc_phase == 1
	jpo	out_char_esc2			;  out_char_esc_phase == 2
	;  out_char_esc_phase == 3
	;  обработка 3-го байта в ESC последовательности
	;  передается смещение курсора по горизонтали X + 20h					
	mov	a, c
	sui	20h
	mov	c, a
out_char_esc3_loop:	
	dcr	c
	jm	out_char_reset_and_exit
	push	b
	call	out_char_code_right
	pop	b
	jmp	out_char_esc3_loop

out_char_reset_and_exit:
	xra	a
out_char_exit:
	sta	out_char_esc_phase
	ret

out_char_no_esc:
	mov	a, c
	ani	7Fh			;  только 7 бит в символе
	mov	c, a
	cpi	CHAR_CODE_CLS
	jz	out_char_code_cls
	cpi	CHAR_CODE_FF
	jz	out_char_code_ff
	cpi	CHAR_CODE_CR
	jz	out_char_code_cr
	cpi	CHAR_CODE_LF
	jz	out_char_code_lf
	cpi	CHAR_CODE_LEFT
	jz	out_char_code_left
	cpi	CHAR_CODE_RIGHT
	jz	out_char_code_right
	cpi	CHAR_CODE_UP
	jz	out_char_code_up
	cpi	CHAR_CODE_DOWN
	jz	out_char_code_down
	cpi	CHAR_CODE_ESC
	jz	out_char_code_esc
	cpi	CHAR_CODE_BEL
	jnz	out_char_regular
	;  bell
	lxi	b, (OUT_BELL_DELAY << 8) | OUT_BELL_COUNT

;   ЗВУКОВОЙ СИГНАЛ  _______________________________________________________________________________
;   Вход: B - задержка периода (высота тона)
;         C - количество периодов (длительность)
out_char_bell:
	mov	a, b
	ei
	dcr	a
	jnz	$-2
	mov	a, b
	di
	dcr	a
	jnz	$-2
	dcr	c
	jnz	out_char_bell
	ret

out_char_regular:
	mov	m, c
	call	out_char_code_right
	mov	a, d
	cpi	SCR_PAD_Y
	rnz
	mov	a, e
	cpi	SCR_PAD_X
	rnz
	call	out_char_code_up

out_char_code_lf:
	mov	a, d
	cpi	SCR_PAD_Y + SCR_VIDEO_SIZE_Y - 1
	jnz	out_char_code_down
	push	h
	push	d
	lxi	h, SCREEN_VIDEO
	lxi	d, SCREEN_VIDEO + SCR_SIZE_X
	lxi	b, SCR_SIZE_X * SCR_VIDEO_SIZE_Y

out_char_code_scroll_loop:
	ldax	d
	mov	m, a
	inx	h
	inx	d
	dcx	b
	mov	a, c
	ora	b
	jnz	out_char_code_scroll_loop
	pop	d
	pop	h
	ret

out_char_esc1:
	;  обработка 1 байта в ESC последовательности
	;  обрабатывается только одна последовательность -- ESC+Y
	mov	a, c
	cpi	'Y'
	jnz	out_char_reset_and_exit
	call	out_char_code_ff
	mvi	a, 2			;  следующая фаза обработки ESC
	jmp	out_char_exit

out_char_esc2:
	;  обработка 2-го байта в ESC последовательности
	;  передается смещение курсора по вертикали Y + 20h
	mov	a, c
	sui	20h
	mov	c, a
out_char_esc2_loop:	
	dcr	c
	mvi	a, 4			;  следующая фаза обработки ESC
	jm	out_char_exit
	push	b
	call	out_char_code_down
	pop	b
	jmp	out_char_esc2_loop

out_char_update_and_exit:
	shld	cursor_addr
	xchg
	shld	cursor_pos
	mvi	a, 80h			;  команда "загрузка курсора"
	sta	ADDR_CRT_CTRL
	mov	a, l
	sta	ADDR_CRT_PARAM
	mov	a, h
	sta	ADDR_CRT_PARAM
	pop	h
	pop	d
	pop	b
	pop	psw
	ret

out_char_code_esc:
	mvi	a, 1			;  следующая фаза обработки ESC
	jmp	out_char_exit

out_char_code_cls:
	lxi	h, SCREEN + SCR_ARRAY
	lxi	d, SCR_SIZE_X * SCR_SIZE_Y + 1
out_char_code_cls_loop:
	xra	a
	mov	m, a
	dcx	h
	dcx	d
	mov	a, e
	ora	d
	jnz	out_char_code_cls_loop

out_char_code_ff:
	lxi	d, (SCR_PAD_Y << 8) | SCR_PAD_X
	lxi	h, SCREEN_VIDEO
	ret

out_char_code_right:
	mov	a, e
	inx	h
	inr	e
	cpi	SCR_PAD_X + SCR_VIDEO_SIZE_X - 1
	rnz
	mvi	e, SCR_PAD_X
	lxi	b, -SCR_VIDEO_SIZE_X
	dad	b

out_char_code_down:
	mov	a, d
	cpi	SCR_PAD_Y + SCR_VIDEO_SIZE_Y - 1
	lxi	b, SCR_SIZE_X
	jnz	out_char_code_down_skip
	mvi	d, SCR_PAD_Y - 1
	lxi	b, -SCR_SIZE_X * (SCR_VIDEO_SIZE_Y - 1)
out_char_code_down_skip:
	inr	d
	dad	b
	ret

out_char_code_left:
	mov	a, e
	dcx	h
	dcr	e
	cpi	SCR_PAD_X
	rnz
	mvi	e, SCR_PAD_X + SCR_VIDEO_SIZE_X - 1
	lxi	b, SCR_VIDEO_SIZE_X
	dad	b

out_char_code_up:
	mov	a, d
	cpi	SCR_PAD_Y
	lxi	b, -SCR_SIZE_X
	jnz	out_char_code_up_skip
	mvi	d, SCR_PAD_Y + SCR_VIDEO_SIZE_Y
	lxi	b, SCR_SIZE_X * (SCR_VIDEO_SIZE_Y - 1)
out_char_code_up_skip:
	dcr	d
	dad	b
	ret

out_char_code_cr:
	mov	a, l
	sub	e
	jnc	$+4
	dcr	h
	mov	l, a
	mvi	e, SCR_PAD_X
	lxi	b, SCR_PAD_X
	dad	b
	ret

;  ОПРОС СОСТОЯНИЯ КЛАВИАТУРЫ  _____________________________________________________________________
;  Выход: A = 00 - не нажата
;         A = FF - нажата
kbd_state:
	lda	ADDR_KBD_PC
	ani	KBD_RUS_FLAG		;  состояние клавиши [РУС/ЛАТ]
	jz	kbd_state_lbl1		;  нажата
	lda	kbd_key_pressed
	ora	a
	rnz
kbd_state_lbl1:
	push	h
	lhld	kbd_key_status
	call	in_key
	cmp	l
	mov	l, a
	jz	kbd_state_hold
kbd_state_released:
	mvi	a, 1			;  признак отпускания клавиши
	sta	kbd_key_released
	mvi	h, KBD_ANTIBOUNCE
kbd_state_reset_and_exit:
	xra	a
kbd_state_exit:
	shld	kbd_key_status
	pop	h
	sta	kbd_key_pressed
	ret

kbd_state_hold:
	dcr	h
	jnz	kbd_state_reset_and_exit
	inr	a
	jz	kbd_state_exit		;  in_key = FF
	inr	a
	jz	kbd_state_halt		;  in_key = FE
	push	b
	lxi	b, (KBD_BELL_DELAY << 8) | KBD_BELL_COUNT
	call	out_char_bell
	pop	b
	lda	kbd_key_released
	mvi	h, KBD_DELAY_FIRST
	dcr	a
	sta	kbd_key_released
	jz	$+5
	mvi	h, KBD_DELAY_REGULAR
	mvi	a, 0FFh			;  признак нажатия клавиши
	jmp	kbd_state_exit

kbd_state_halt:	
	lda	ADDR_KBD_PC
	ani	KBD_RUS_FLAG		;  состояние клавиши [РУС/ЛАТ]
	jz	kbd_state_halt
	lda	kbd_rus
	cma
	sta	kbd_rus
	jmp	kbd_state_released

;  ВВОД СИМВОЛА С КЛАВИАТУРЫ  ______________________________________________________________________
;  Выход: A - введенный код
in_char:
	call	kbd_state
	ora	a
	jz	in_char
	xra	a
	sta	kbd_key_pressed
	lda	kbd_key_status
	ret

;  ВВОД КОДА НАЖАТОЙ КЛАВИШИ  ______________________________________________________________________
;  Выход: A = FF - не нажата
;         A = FE - РУС/ЛАТ
;         A - код клавиши
in_key:
	lda	ADDR_KBD_PC
	ani	KBD_RUS_FLAG
	jnz	in_key_check
	mvi	a, 0FEh
	ret
in_key_check:
	xra	a
	sta	ADDR_KBD_PA
	sta	ADDR_KBD_PC
	lda	kbd_rus
	ani	1
	ori	3 << 1			;  3-й бит порта C
	sta	ADDR_KBD_CTRL		;  светодиод
	lda	ADDR_KBD_PB
	inr	a
	jnz	in_key_pressed
	dcr	a
	ret

in_key_pressed:
	push	h
	mvi	l, 1
	mvi	h, 7
in_key_scan_loop:
	mov	a, l
	rrc
	mov	l, a
	cma
	sta	ADDR_KBD_PA
	lda	ADDR_KBD_PB
	cma
	ora	a
	jnz	in_key_antibounce
	dcr	h
	jp	in_key_scan_loop
in_key_exit:
	mvi	a, 0FFh			;  не нажата
	pop	h
	ret

in_key_antibounce:
	mvi	l, 32			; счетчик количества опросов
in_key_antibounce_loop:	
	lda	ADDR_KBD_PB
	cma
	ora	a
	jz	in_key_exit
	dcr	l
	jnz	in_key_antibounce_loop
	mvi	l, 8			;  количество клавиш в столбце
	dcr	l
	rlc
	jnc	$-2
	mov	a, h
	mov	h, l
	mov	l, a
	cpi	1
	jz	in_key_column1
	jc	in_key_column0
	rlc
	rlc
	rlc
	adi	20h
	ora	h
	cpi	5Fh			;  клавиша пробела?
	jnz	in_key_lbl1
	mvi	a, 20h			;  код пробела
	pop	h
	ret

in_key_column1_table:
	db	CHAR_CODE_HT, CHAR_CODE_LF, CHAR_CODE_CR, CHAR_CODE_BACKSPACE
	db	CHAR_CODE_LEFT, CHAR_CODE_UP, CHAR_CODE_RIGHT, CHAR_CODE_DOWN

in_key_column0_table:
	db	CHAR_CODE_FF, CHAR_CODE_CLS, CHAR_CODE_ESC
	db	00h, 01h, 02h, 03h, 04h, 05h

in_key_column0:
	mov	a, h
	lxi	h, in_key_column0_table
	jmp	$+7
in_key_column1:
	mov	a, h
	lxi	h, in_key_column1_table
	add	l
	mov	l, a
	mov	a, m
	cpi	40h			;  клавиша backspace?
	pop	h
	rc
	push	h
in_key_lbl1:
	mov	l, a
	lda	ADDR_KBD_PC
	mov	h, a
	ani	KBD_CTRL_FLAG		;  состояние клавиши [УС]
	jnz	in_key_lbl2
	mov	a, l
	cpi	40h			;  буквы? 
	jm	in_key_lbl5
	ani	1Fh			;  сбросить старшие биты
	pop	h
	ret
in_key_lbl2:
	lda	kbd_rus
	ora	a
	jz	in_key_lbl3		;  латинская раскладка
	mov	a, l
	cpi	40h			;  что за клавиша?
	jm	in_key_lbl3		;  не буквенная
	ori	20h			;  если буквенная, то перевести
	mov	l, a			;  все буквы в русский регистр
in_key_lbl3:
	mov	a, h
	ani	KBD_SHIFT_FLAG		;  состояние клавиши [СС]
	jnz	in_key_lbl5
	mov	a, l
	cpi	40h			;  что за клавиша?
	jm	in_key_lbl4		;  не буквенная
	;  перевести латинские буквы в русские или наоборот
	mov	a, l
	xri	20h
	pop	h
	ret
in_key_lbl4:
	mov	a, l
	ani	2Fh
	mov	l, a
in_key_lbl5:
	mov	a, l
	cpi	40h			;  что за клавиша?
	pop	h
	rp				;  буква
	push	h
	mov	l, a
	ani	0Fh			;  очистить биты
	cpi	0Ch			;  для клавиш с кодом 20h - 2Ch
					;  и 30h - 3Ch инвертировать бит
	mov	a, l
	jm	$+5
	xri	10h
	pop	h
	ret

;  ПЕРЕДАЧА АДРЕСА ВЕРХНЕЙ ГРАНИЦЫ СВОБОДНОЙ ПАМЯТИ  _______________________________________________
;  Выход: HL - адрес границы
get_ram_top:
	lhld	ram_top
	ret

;  УСТАНОВКА АДРЕСА ВЕРХНЕЙ ГРАНИЦЫ СВОБОДНОЙ ПАМЯТИ  ______________________________________________
;  Вход:  HL - адрес границы
set_ram_top:
	shld	ram_top
	ret

title_str:
	db	CHAR_CODE_CLS, "radio-86rk", 0

prompt_str:
	db	0Dh, 0Ah, "-->", 0

padding_str:
	db	0Dh, 0Ah, CHAR_CODE_RIGHT, CHAR_CODE_RIGHT, CHAR_CODE_RIGHT, CHAR_CODE_RIGHT, 0

regs_str:
	db	0Dh, 0Ah, " PC-"
	db	0Dh, 0Ah, " HL-"
	db	0Dh, 0Ah, " BC-"
	db	0Dh, 0Ah, " DE-"
	db	0Dh, 0Ah, " SP-"
	db	0Dh, 0Ah, " AF-"
	db	CHAR_CODE_UP, CHAR_CODE_UP, CHAR_CODE_UP, CHAR_CODE_UP
	db	CHAR_CODE_UP, CHAR_CODE_UP, 0

backspace_str:
	db	CHAR_CODE_LEFT, " ", CHAR_CODE_LEFT, 0

;  Адрес возврата из отлаживаемой программы.
;  Выполняется только если в команде G МОНИТОРа указан адрес останова в качестве второго параметра.
;  Содержимое регистров сохраняется в служебных ячейках МОНИТОРа.
;  В последствии его можно просмотреть командой X МОНИТОРа.
;  На экран выдается адрес останова. И управление передается на "горячий" старт МОНИТОРа.
return_address:
	shld	HL_storage
	push	psw
	pop	h
	shld	AF_storage
	pop	h
	dcx	h
	shld	PC_storage
	lxi	h, 0
	dad	sp
	lxi	sp, SP_storage + 2
	push	h
	push	d
	push	b
	lhld	PC_storage
	lxi	sp, SCREEN - 1
	call	out_word
	xchg
	lhld	stop_addr
	call	cmp_hl_de
	jnz	warm_start
	lda	stop_addr_byte
	mov	m, a
	jmp	warm_start

;  ________________________________________________________________________________  ДИРЕКТИВА X  __
directive_X:
	lxi	h, regs_str
	call	out_str
	lxi	h, PC_storage
	mvi	b, 6
out_regs_loop:
	mov	e, m
	inx	h
	mov	d, m
	push	b
	push	h
	xchg
	call	out_word
	call	get_str
	jnc	out_regs_lbl
	call	str2hex
	pop	d
	push	d
	xchg
	mov	m, d
	dcx	h
	mov	m, e
out_regs_lbl:
	pop	h
	pop	b
	dcr	b
	inx	h
	jnz	out_regs_loop
	ret

	db	0FFh, 0FFh

;  =================================================================================================
;  рабочие переменные МОНИТОРА в оперативной памяти

	org	MONITOR_DATA

cursor_addr:				;  текущее значение адреса курсора [out_char]
	ds	2
cursor_pos:				;  текущее положение курсора [out_char]
	ds	2
out_char_esc_phase:
	ds	1
kbd_key_pressed:
	ds	1
kbd_rus:				;  флаг русской раскладки клавиатуры [in_key]
	ds	3
kbd_key_status:				;  код клавиши и переменная задержки [kbd_state]
	ds	2
kbd_key_released:
	ds	2
save_sp:				;  переменная для временного хранения
	ds	7
PC_storage:
	ds	2
HL_storage:
	ds	2
BC_storage:
	ds	2
DE_storage:
	ds	2
SP_storage:
	ds	2
AF_storage:
	ds	5
stop_addr:
	ds	2
stop_addr_byte:
	ds	1
jump_to_go:
	ds	1
in_param1:				;  параметр 1 директивы
	ds	2
in_param2:				;  параметр 2 директивы
	ds	2
in_param3:				;  параметр 3 директивы
	ds	2
in_param2_present:
	ds	1
tape_data_sign:
	ds	1
tape_consts:
	ds	2
ram_top:				;  верхняя граница памяти [get_ram_top] [set_ram_top]
	ds	2
inp_buffer:				;  буфер введенной строки
	ds	INP_BUFFER_SIZE
inp_buffer_end:
	ds	13			;  pad
MONITOR_DATA_END:

;  =================================================================================================
;  end of file  ====================================================================================
