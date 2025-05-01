;  #################################################################################################
;  ##  УПРАВЛЯЮЩАЯ ПРОГРАММА "МОНИТОР" ДЛЯ КОМПЬЮТЕРА "РАДИО-86РК/Nova"                           ##
;  #################################################################################################
;
;  Authors: Дмитрий Горшков, Геннадий Зеленко, Юрий Озеров, Сергей Попов,
;           дизассемблирование и доработка Vitaliy Poedinok aka Vital72
;  License: MIT
;  www:     http://www.86rk.ru/
;  e-mail:  vital72@86rk.ru
;  Version: 1.0
;  =================================================================================================
;  Данная версия МОНИТОРа является доработкой авторской версии для компьютера "РАДИО-86РК/Nova".
;  Для получения дополнительного пространства часть кода подверглась оптимизации без потери
;  функциональности. Оставлены "как есть", без оптимизации, подпрограммы:
;      "out_char_c" -- вывод символа на экран (рег. C),
;      "in_char"    -- ввод символа с клавиатуры (блок),
;      "kbd_state"  -- состояние клавиатуры,
;      "in_key"     -- код нажатой клавиши (не блок).
;  Также, сохранены все адреса внутренних подпрограмм для совместимости с пользовательскими
;  программами, которые в обход договорённостям используют недокументированные вызовы.
;  =================================================================================================

;  конфигурация компьютера
CFG_ELEKTRONIKA_KR02	EQU	1	;  признак использования клавиатуры МС7007

MONITOR_BASE		EQU	0F800h	;  стартовый адрес МОНИТОРа
MONITOR_EXTENSION	EQU	0F000h	;  стартовый адрес расширения МОНИТОРа
MONITOR_DATA		EQU	07600h	;  начало области рабочих ячеек МОНИТОРа
MONITOR_DATA_SIZE	EQU	000D0h	;  размер области рабочих ячеек МОНИТОРа
MONITOR_WARM_START	EQU	0F86Ch	;  горячий старт/консоль

;  базовые адреса микросхем периферии
ADDR_KBD		EQU	08000h
ADDR_TIMER		EQU	09000h
ADDR_PORT		EQU	0A000h
ADDR_RTC		EQU	0B000h
ADDR_CRT		EQU	0C000h
ADDR_DMA		EQU	0E000h
ADDR_FONT_RAM		EQU	0F800h

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

ADDR_TIMER_CTRL		EQU	ADDR_TIMER + 3

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
CRT_NON_TRANSP_ATTR	EQU	1	;  field attribute mode [0, 1]
CRT_HORIZONTAL_COUNT	EQU	8	;  horizontal retrace count [2, 4, 6, .. 32]
CRT_BURST_SPACE_CODE	EQU	1	;  [0..7]
CRT_BURST_COUNT_CODE	EQU	3	;  [0..3]
CRT_ZZZZ6		EQU	((CRT_HORIZ_TIME * 8 / 6 - SCR_SIZE_X + 1) >> 1) - 1
CRT_ZZZZ8		EQU	((CRT_HORIZ_TIME * 10 / 8 - SCR_SIZE_X + 1) >> 1) - 1

;
INP_BUFFER_SIZE		EQU	32
CURSOR_VIEW_INITIAL	EQU	10h

;  константа чтения с магнитофона
TAPE_READ_CONST		EQU	2Ah
;  константа чтения записи на магнитофон
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

;  битовые маски байта конфигурации config_rk
CFG_RK_FONT_RAM		EQU	00000001b
CFG_RK_FONT_8BIT	EQU	00000100b

.macro inp
	in	((%%1) >> 8) | ((%%1) & 0FFh)
.endm

.macro outp
	out	((%%1) >> 8) | ((%%1) & 0FFh)
.endm

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

;  СИНХРОНИЗАЦИЯ С КАДРОВЫМ СИНХРОИМПУЛЬСОМ  _______________________________________________________
wait_sync:
	lda	ADDR_CRT_CTRL		;  сброс регистра флагов
	lda	ADDR_CRT_CTRL		;  чтение слова состояния
	ani	20h			;  нужен флаг IR - запрос прерывания
	jz	$-5			;  ждём установленного IR
	ret

	jmp	set_charset		;  42  //  выбор знакогенератора
	lda	config_rk		;  45  //  чтение конфигурации
	ret

cold_start:
	lxi	sp, SCREEN - 1
	;  все три канала таймера в режим 3
	lxi	h, ADDR_TIMER_CTRL
	mvi	m, 00110110b
	mvi	m, 01110110b
	mvi	m, 10110110b
	;
	call	init_monitor
	;
	lxi	h, MONITOR_DATA - 1
	shld	ram_top
	;
	lxi	h, (TAPE_WRITE_CONST << 8) | TAPE_READ_CONST
	shld	tape_consts
	;  код команды JMP для директивы G
	mvi	a, 0C3h
	sta	jump_to_go
	sta	extended_directive_handler
	;  pad
	ds	MONITOR_WARM_START - $, 0

warm_start:
	;  т.н. теплый старт МОНИТОРа.
	.if $ - MONITOR_WARM_START
	.error MONITOR_WARM_START
	.endif

	lxi	sp, SCREEN - 1
	lxi	h, prompt_str
	call	out_str			;  после выхода из п/п в A будет 0
	call	set_charset
	call	get_str			;  после выхода из п/п в B будет 0
	mov	c, b
	lxi	h, warm_start
	push	h
	lxi	h, inp_buffer
	mov	a, m			;  первый символ введённой строки
	call	check_run_sd_card
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
	jmp	extended_directive_handler

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
;  Ввод с клавиатуры во внутренний буфер МОНИТОРа, размер ограничен в 31 символ
;  Особо обрабатываемые клавиши:
;      [<-] и [ЗБ] - удаление последнего символа
;              [.] - Выход на тёплый старт МОНИТОРа
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
	call	out_char_a
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
	lxi	d, inp_buffer + 1
	call	str2hex
	cmc
	sbb	a
	cmc
	sta	in_param2_present	;  признак наличия второго параметра
	shld	in_param1
	cnc	str2hex
	shld	in_param2
	lxi	h, 0
	cnc	str2hex
	shld	in_param3
	jnc	out_error_txt
	ret

;  _________________________________________________________________________________________________
check_run_sd_card:
	cpi	'-'
	rnz
	push	b
	mov	l, b
	mov	h, b
	lxi	d, 007Fh
	jmp	directive_R
	
;  ПРЕОБРАЗОВАНИЕ HEX-СТРОКИ В ЧИСЛО  ______________________________________________________________
;  Вход:  DE - адрес строки
;  Выход: HL - результат
str2hex:
	xra	a
	mov	h, a
str2hex_loop:
	mov	l, a
	ldax	d
	inx	d
	cpi	CHAR_CODE_CR
	stc
	rz
	cpi	','
	rz
	cpi	' '
	jz	str2hex_loop
	lxi	b, out_error_txt
	push	b
	sui	'0'
	rm
	cpi	10
	jm	str2hex_add
	cpi	'A' - '0'
	rm
	cpi	'F' - '0' + 1
	rp
	sui	'A' - '9' - 1
str2hex_add:
	pop	b
	dad	h
	dad	h
	dad	h
	dad	h
	;  для получения дополнительного места в ПЗУ тут была убрана
	;  проверка на переполнение. большого смысла эта проверка всё равно
	;  не имеет, т.к. нет проверок на переполнение в сложениях выше
	ora	l
	jmp	str2hex_loop

set_cursor_view:
	mvi	a, CURSOR_VIEW_INITIAL
	sta	cursor_view
	jmp	out_title

;  СРАВНЕНИЕ ДВУХ 16-РАЗРЯДНЫХ ЧИСЕЛ  ______________________________________________________________
;  Вход:  HL - первое слово
;         DE - второе слово
;  Выход: флаг ZF = 1: DE == HL
;         флаг ZF = 0 и CF = 1: DE > HL
;         флаг ZF = 0 и CF = 0: DE < HL
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
	jz	exit_from_loop
	inx	h
	ret
exit_from_loop:
	inx	sp
	inx	sp
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
	inp	ADDR_KBD_PC
	ani	CFG_RK_FONT_8BIT
	mvi	l, CRT_ZZZZ6 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	jz	$+5
	mvi	l, CRT_ZZZZ8 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	lda	cursor_view
	ora	l
	mvi	l, low (ADDR_CRT_PARAM)
	mov	m, a
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

	call	wait_sync

	lxi	h, ADDR_DMA + 8		;  адрес регистра режимов ПДП
	mvi	m, 10000000b		;  запрет ПДП
	jmp	init_dma

	ds	2, 0FFh			;  pad

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
	push	d
	push	b
	mov	b, a
tape_rd_byte_start:
	mvi	a, 10000000b		;  запрет ПДП
	sta	ADDR_DMA + 8		;  адрес регистра режимов ПДП
	lxi	h, 0
	mov	c, l			;  результат
	dad	sp
	lxi	sp, 0
tape_rd_byte_loop:
	lda	ADDR_KBD_PC
	rrc
	rrc
	rrc
	rrc
	ani	1
	mov	e, a
	pop	psw
	mov	a, c
	ani	7Fh
	rlc
	mov	c, a
	mvi	d, 0			;  счетчик попыток чтения уровня
tape_rd_byte_wait:
	dcr	d
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
	lda	tape_consts		;  счетчик задержки
	dcr	b
	jnz	$+5
	sui	18			;  коррекция константы
	pop	d
	dcr	a
	jnz	$-2			;  цикл задержки
	inr	b
	jp	tape_rd_byte_lbl3
	mov	a, c
	xri	TAPE_SYNC_BYTE
	jz	tape_rd_byte_lbl2
	inr	a
	jnz	tape_rd_byte_loop
	dcr	a
tape_rd_byte_lbl2:
	sta	tape_data_sign
	mvi	b, 8 + 1
tape_rd_byte_lbl3:
	dcr	b
	jnz	tape_rd_byte_loop
	sphl
	lda	tape_data_sign
	xra	c
	jmp	restore_video_and_ret

tape_rd_byte_error:
	sphl
	call	init_video
	mov	a, b
	ora	a
	jp	out_error_txt
	call	check_ctrl_c
	jmp	tape_rd_byte_start

;  ИНИЦИАЛИЗАЦИЯ ДОПОЛНИТЕЛЬНЫХ ПАРАМЕТРОВ ДЛЯ РАДИО-86РК/Nova  ____________________________________
init_monitor:
	call	init_video
	;  очистка рабочих ячеек МОНИТОРа
	lxi	h, MONITOR_DATA
	lxi	d, MONITOR_DATA_END - 1
	mvi	c, 0
	call	directive_F
	;  регистр H уже имеет нужное значение
	mvi	l, low (SCREEN - 1)
	shld	SP_storage
	;  порт PC на ввод, для чтения конфигурации
	;  порт PC содержит конфигурацию компьютера:
	;  PC0 = 0 - знакогенератор хранится в ROM
	;  PC0 = 1 - знакогенератор хранится в RAM
	;  PC2 = 0 - шрифт имеет ширину 6 пикселов
	;  PC2 = 1 - шрифт имеет ширину 8 пикселов
	lxi	h, ADDR_KBD_CTRL
	mvi	m, 10001011b
	inp	ADDR_KBD_PC
	sta	config_rk
	mvi	m, 10001010b
	outp	ADDR_KBD_PC
	;
	lxi	h, MONITOR_BASE
	shld	extended_directive_handler + 1
	jmp	set_cursor_view

;  ВЫБОР ЗНАКОГЕНЕРАТОРА  __________________________________________________________________________
;  Вход:  A - номер знакогенератора
;         A = 0 - стандартный з/г: только заглавные латинские и русские буквы
;         A = 1 - графический з/г Апогея
;         A = 2 - расширенный з/г: заглавные и строчные буквы обоих алфавитов
set_charset:
	;  PC0 = ROM_A11
	;  PC1 = 0 => ROM_A10 = 1
	;  PC1 = 1 => ROM_A10 = screen attr
	;  A = 0: PC = 10b
	;  A = 1: PC = 00b
	;  A = 2: PC = 11b
	cpi	3
	rnc
	xri	1			;  A = 1, 0, 3
	push	psw
	ani	1
	ori	1 << 1
	outp	ADDR_KBD_CTRL		;  PC1
	pop	psw
	rar
	outp	ADDR_KBD_CTRL		;  PC0
	ret

;  ЗАПИСЬ БАЙТА НА МАГНИТНУЮ ЛЕНТУ  ________________________________________________________________
;  Вход:  C - байт
tape_wr_byte:
	push	h
	push	d
	push	b
	push	psw
	mvi	a, 10000000b		;  запрет ПДП
	outp	ADDR_DMA + 8		;  адрес регистра режимов ПДП
	lxi	h, 0
	dad	sp
	lxi	sp, 0
	mvi	b, 8			;  счетчик бит
tape_wr_byte_loop:
	pop	d
	mov	a, c
	rlc
	mov	c, a
	xri	1
	ani	1
	outp	ADDR_KBD_CTRL		;  0-й бит порта C
	lda	tape_consts + 1
	pop	d
	dcr	a
	jnz	$-2
	mov	a, c			;  маска без инверсии
	ani	1
	outp	ADDR_KBD_CTRL		;  0-й бит порта C
	lda	tape_consts + 1
	dcr	b
	jnz	$+5
	;  коррекция константы для последнего бита. значение на единицу меньше
	;  авторского варианта потому как далее выполняется код без двух инструкций
	sui	13
	pop	d
	dcr	a
	jnz	$-2
	inr	b
	dcr	b
	jnz	tape_wr_byte_loop
	sphl
	;  опыты показали, что видео восстанавливается и без
	;  команды "начало воспроизведения"
	mvi	a, 11100000b		;  команда "предустановка счётчиков"
	outp	ADDR_CRT_CTRL
	pop	psw

restore_video_and_ret:
	pop	b
	pop	d

init_dma:
	lxi	h, ADDR_DMA + 4		;  адрес регистра адреса канала 2 ПДП
	mvi	m, low (SCREEN)		;  младший адрес памяти
	mvi	m, high (SCREEN)	;  старший адрес памяти
	inx	h			;  адрес регистра количества циклов ПДП канала 2
	;  16 бит = RWCCCCCC CCCCCCCC
	;  CCCCCC CCCCCCCC - количество циклов
	;  RW = 00 - цикл проверки ПД
	;  RW = 01 - цикл записи ПД
	;  RW = 10 - цикл чтения ПД
	;  RW = 11 - запрещенная комбинация
	;  младший байт счётчика циклов (биты C7-C0)
	mvi	m, low (SCR_ARRAY - 1)
	;  старший байт счётчика циклов (биты C13-C8)
	;  цикл записи, т.к. в РК ПДП включён шиворот-навыворот
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

out_title:
	lxi	h, title_str
	call	out_str
	jmp	init_video

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
	jm	out_char_no_esc
	jz	out_char_esc1
	jpo	out_char_esc2
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

	ds	3, 0FFh		;  pad

out_char_no_esc:
	mov	a, c
;	ani	7Fh		;  фильтр 7-го бита больше не используется, это
;	mov	c, a		;  сделано для того, чтобы можно было передавать
				;  коды цвета и переключать знакогенераторы
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
out_char_code_scroll:
	ldax	d
	mov	m, a
	inx	h
	inx	d
	dcx	b
	mov	a, c
	ora	b
	jnz	out_char_code_scroll
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

	.if $ - 0FE01h
	.error FE01
	.endif

.if CFG_ELEKTRONIKA_KR02

;  ОПРОС СОСТОЯНИЯ КЛАВИАТУРЫ  _____________________________________________________________________
;  Выход: A = 00 - не нажата
;         A = FF - нажата
kbd_state:
	LDA	kbd_key_pressed
	ORA	A
	RNZ
	PUSH	H
	LHLD	kbd_key_status
	CALL	in_key
	CMP	L
	MOV	L, A
	JZ	LBL77
	MVI	A, 1
	STA	kbd_key_released
	MVI	H, 25H
LBL75:	XRA	A
LBL76:	SHLD	kbd_key_status
	POP	H
	STA	kbd_key_pressed
	RET
LBL77:	DCR	H
	JNZ	LBL75
	INR	A
	JZ	LBL76
	PUSH	B
	LXI	B, 5003H
	CALL	out_char_bell
	POP	B
	LDA	kbd_key_released
	INR	A
	MVI	H, 00H
	JNZ	LBL78
	MVI	H, 60H
LBL78:	MVI	A, 0FFH
	STA	kbd_key_released
	JMP	LBL76
LBL79:	JP	LBL90
	LXI	H,kbd_rus
	MOV	E, M
	INR	L
	MOV	D, M
	CPI	40H
	JC	LBL80
	XRA	E
	JMP	LBL81
LBL80:	CPI	21H
	JC	LBL81
	XRA	D
LBL81:	POP	D
	POP	B
	POP	H
	RET
	DB	0FFH, 0FFH

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
	LDA	kbd_rus
	ADI	0FFh
	MVI	A, 3 << 1
	ACI	0
	STA	ADDR_KBD_CTRL
	PUSH	H
	LXI	H, 0701H
LBL83:	MOV	A, L
	RRC
	MOV	L, A
	CMA
	STA	ADDR_KBD_PA
	LDA	ADDR_KBD_PB
	CMA
	ORA	A
	JNZ	LBL84
	DCR	H
	JP	LBL83
	MVI	A, 0FFH
	POP	H
	RET
REF4:	DB	00H, 20H, 00H, 40H	; ". .@"
	DB	00H, 10H, 0FFH, 00H	; "...."
	DB	9DH, 00H, 00H, 85H	; "...."
	DB	0A7H, 0A8H, 0A9H, 1BH	; "...."
	DB	09H, 83H, 81H, 80H	; "...."
	DB	0A0H, 9EH, 9CH, 3BH	; "...;"
	DB	4AH, 46H, 51H, 84H	; "JFQ."
	DB	0A1H, 0A2H, 0A3H, 00H	; "...."
	DB	31H, 43H, 59H, 5EH	; "1CY^"
	DB	0A4H, 0A5H, 0A6H, 01H	; "...."
	DB	32H, 55H, 57H, 53H	; "2UWS"
	DB	9BH, 0CH, 1FH, 02H	; "...."
	DB	33H, 4BH, 41H, 4DH	; "3KAM"
	DB	7FH, 00H, 0AH, 34H	; "\7F..4"
	DB	45H, 50H, 49H, 20H	; "EPI "
	DB	18H, 0DH, 3AH, 03H	; "..:."
	DB	35H, 4EH, 52H, 54H	; "5NRT"
	DB	1AH, 19H, 2FH, 04H	; "../."
	DB	36H, 47H, 4FH, 58H	; "6GOX"
	DB	2EH, 20H, 2DH, 37H	; ". -7"
	DB	5BH, 4CH, 42H, 08H	; "[LB."
	DB	5CH, 48H, 30H, 38H	; "\H08"
	DB	5DH, 44H, 40H, 2CH	; "]D@,"
	DB	56H, 5AH, 39H		; "VZ9"
LBL84:	PUSH	B
	PUSH	D
	LXI	D, 0302H
	MVI	L, 8
LBL85:	CMP	D
	JZ	LBL87
	INR	D
	INR	D
	INR	L
	DCR	E
	JP	LBL85
	MVI	L, 8
LBL86:	DCR	L
	RLC
	JNC	LBL86
LBL87:	LXI	B, REF4-1
	MOV	A, C
LBL88:	ADI	8
	DCR	L
	JP	LBL88
	MOV	C, A
	MOV	A, H
	ADD	C
	MOV	C, A
	LDAX	B
	CPI	7FH
	JZ	LBL81
	CPI	90H
	JC	LBL89
	SUI	70H
	JMP	LBL81
LBL89:	LXI	D, 0580H
	LXI	H, REF4
LBL90:	CMP	E
	JNZ	LBL92
	MOV	A, M
	LXI	H, kbd_rus
	MOV	C, A
	MOV	A, D
	CPI	2
	JNC	LBL91
	INR	L
LBL91:	MOV	M, C
	POP	D
	POP	B
	POP	H
	JMP	in_key
LBL92:	INR	E
	INR	L
	DCR	D
	JMP	LBL79

.else  ;  CFG_ELEKTRONIKA_KR02

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
	jz	kbd_state_halt		;  пока клавиша [РУС/ЛАТ] удерживается
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
	nop				;  sta	ADDR_KBD_PC
	nop
	nop
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

.endif  ;  CFG_ELEKTRONIKA_KR02

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

	db	"32"

	.if $ - 10000h
	.error code overflow
	.endif

;  =================================================================================================
;  рабочие переменные МОНИТОРа в оперативной памяти

	org	MONITOR_DATA

cursor_addr:				;  текущее значение адреса курсора [out_char]
	ds	2
cursor_pos:				;  текущее положение курсора [out_char]
	ds	2
out_char_esc_phase:			;  [out_char]
	ds	1
kbd_key_pressed:			;  [kbd_state] [in_char]
	ds	1
kbd_rus:				;  флаг русской раскладки клавиатуры [in_key] [kbd_state]
	ds	1
config_rk:				;  биты конфигурации, выставленные джамперами
	ds	1
cursor_view:				;  вид курсора (видеоблок/подчеркивание) [init_video]
	ds	1			;  допустимые значения: 00h, 10h, 20h, 30h
kbd_key_status:				;  код клавиши и переменная задержки [kbd_state]
	ds	2
kbd_key_released:			;  [kbd_state]
	ds	2
save_sp:				;  переменная для временного хранения
	ds	2
extended_directive_handler:
	ds	1			;  0C3h = jmp
	ds	2			;  адрес обработчика
	ds	2			;  не используется
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
