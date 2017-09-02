ARM_TOOLCHAIN=
CC=$(ARM_TOOLCHAIN)arm-none-eabi-gcc
LD=$(ARM_TOOLCHAIN)arm-none-eabi-gcc
AS=$(ARM_TOOLCHAIN)arm-none-eabi-gcc
OBJCOPY=$(ARM_TOOLCHAIN)arm-none-eabi-objcopy

PROJECT_NAME=$(notdir $(CURDIR))
BUILD_DIR=build
LIB_DIR=lib/
# CMD_ECHO = @

# Defines required by included libraries
DEF = -DSTM32F746G_DISCO \
		-DUSE_STM32756G_DISCOVERY \
		-DUSE_USB_FS \
		-DUSE_IOEXPANDER \
		-DSTM32F746NGHx \
		-DSTM32F7 \
		-DSTM32 \
		-DDEBUG \
		-DUSE_HAL_DRIVER \
		-DSTM32F746xx \
		-DOS_SUPPORT \
		-DUSB_AUDIO \
		-DONBOARD_DAC \

INC = -I. \
      -I$(LIB_DIR)Drivers/BSP/Components/wm8994 \
      -I$(LIB_DIR)Drivers/BSP/STM32746G-Discovery \
      -I$(LIB_DIR)Drivers/STM32F7xx_HAL_Driver/Inc \
      -I$(LIB_DIR)Middlewares/ST/STM32_USB_Device_Library/Class/AUDIO/Inc \
      -I$(LIB_DIR)Middlewares/ST/STM32_USB_Device_Library/Core/Inc \
      -I$(LIB_DIR)CMSIS/Device/ST/STM32F7xx/Include \
      -I$(LIB_DIR)CMSIS/Include \
      -I$(LIB_DIR)Middlewares/ST/STemWin/inc \
      -Isrc/inc

LINC = -LMiddlewares/ST/STemWin/Lib 


ARCHFLAGS = -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16 -ffunction-sections
CFLAGS = $(ARCHFLAGS)

SRC_LD = src/std/LinkerScript.ld
LDFLAGS = $(ARCHFLAGS) -L$(LIB_DIR)Middlewares/ST/STemWin/Lib
LDLIBS = -l:STemWin528_CM7_GCC.a -lm 

SRC_C += $(wildcard src/main/*.c)
SRC_C += $(wildcard lib/Drivers/STM32F7xx_HAL_Driver/Src/*.c)
SRC_C += $(wildcard lib/Middlewares/ST/STM32_USB_Device_Library/Class/AUDIO/Src/*.c)
SRC_C += $(wildcard lib/Middlewares/ST/STemWin/OS/*.c)
SRC_C += $(wildcard lib/Middlewares/ST/STM32_USB_Device_Library/Core/Src/*.c)
SRC_C += $(wildcard lib/Middlewares/ST/STM32_USB_Device_Library/Class/AUDIO/Src/*.c)
SRC_C += $(wildcard lib/Drivers/STM32F7xx_HAL_Driver/Src/*.c)
SRC_C += $(wildcard lib/Drivers/BSP/STM32746G-Discovery/*.c)
SRC_C += $(wildcard lib/Drivers/BSP/Components/wm8994/*.c)
SRC_C += $(wildcard lib/Drivers/BSP/Components/ft5336/*.c)


vpath %.c $(dir $(SRC_C))

FILENAMES_C = $(notdir $(SRC_C))
OBJS_C = $(addprefix $(BUILD_DIR)/, $(FILENAMES_C:.c=.o))


SRC_ASM = $(wildcard src/std/*.s)
vpath %.s $(dir $(SRC_ASM))

FILENAMES_ASM = $(notdir $(SRC_ASM))
OBJS_ASM = $(addprefix $(BUILD_DIR)/, $(FILENAMES_ASM:.s=.o))





all: $(BUILD_DIR) BINARY

$(BUILD_DIR)/%.o: %.c
	@echo "Compiling C file: $(notdir $<)"
	$(CMD_ECHO) $(CC) $(CFLAGS) $(DEF) $(INC) -c -o $@ $<

$(BUILD_DIR)/%.o: %.s
	@echo "Compiling ASM file: $(notdir $<)"
	$(CMD_ECHO) $(AS) $(CFLAGS) $(DEF) $(INC) -c -o $@ $<
	

BINARY: $(OBJS_C) $(OBJS_ASM)
	$(CMD_ECHO) $(LD) $(LDFLAGS) -T$(SRC_LD) -o $(BUILD_DIR)/$(PROJECT_NAME).elf $^ $(LDLIBS)
	$(CMD_ECHO) $(OBJCOPY) -O binary $(BUILD_DIR)/$(PROJECT_NAME).elf $(BUILD_DIR)/$(PROJECT_NAME).bin

	@echo $(BUILD_DIR)/$(PROJECT_NAME).elf
	@echo $(BUILD_DIR)/$(PROJECT_NAME).bin

$(BUILD_DIR):
	$(CMD_ECHO) mkdir -p $(BUILD_DIR)

clean:
	rm -f $(BUILD_DIR)/*.elf $(BUILD_DIR)/*.hex $(BUILD_DIR)/*.map $(BUILD_DIR)/*.bin
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.sym $(BUILD_DIR)/*.disasm
