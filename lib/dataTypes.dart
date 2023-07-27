// ignore_for_file: file_names, camel_case_types, constant_identifier_names

enum DATA_ID {
  VOLTAGE,
  CURRENT,
  TEMPERATURE,
  MODE,

}

enum COMM_PACKET_ID {
  COMM_FW_VERSION,
  COMM_JUMP_TO_BOOTLOADER,
  COMM_ERASE_NEW_APP,
  COMM_WRITE_NEW_APP_DATA,
  COMM_GET_VALUES,
  COMM_SET_DUTY,
  COMM_SET_CURRENT,
  COMM_SET_CURRENT_BRAKE,
  COMM_SET_RPM,
  COMM_SET_POS,
  COMM_SET_HANDBRAKE,
  COMM_SET_DETECT,
  COMM_SET_SERVO_POS,
  COMM_SET_MCCONF,
  COMM_GET_MCCONF,
  COMM_GET_MCCONF_DEFAULT,
  COMM_SET_APPCONF,
  COMM_GET_APPCONF,
  COMM_GET_APPCONF_DEFAULT,
  COMM_SAMPLE_PRINT,
  COMM_TERMINAL_CMD,
  COMM_PRINT,
  COMM_ROTOR_POSITION,
  COMM_EXPERIMENT_SAMPLE,
  COMM_DETECT_MOTOR_PARAM,
  COMM_DETECT_MOTOR_R_L,
  COMM_DETECT_MOTOR_FLUX_LINKAGE,
  COMM_DETECT_ENCODER,
  COMM_DETECT_HALL_FOC,
  COMM_REBOOT,
  COMM_ALIVE,
  COMM_GET_DECODED_PPM,
  COMM_GET_DECODED_ADC,
  COMM_GET_DECODED_CHUK,
  COMM_FORWARD_CAN,
  COMM_SET_CHUCK_DATA,
  COMM_CUSTOM_APP_DATA,
  COMM_NRF_START_PAIRING,
  COMM_GPD_SET_FSW,
  COMM_GPD_BUFFER_NOTIFY,
  COMM_GPD_BUFFER_SIZE_LEFT,
  COMM_GPD_FILL_BUFFER,
  COMM_GPD_OUTPUT_SAMPLE,
  COMM_GPD_SET_MODE,
  COMM_GPD_FILL_BUFFER_INT8,
  COMM_GPD_FILL_BUFFER_INT16,
  COMM_GPD_SET_BUFFER_INT_SCALE,
  COMM_GET_VALUES_SETUP,
  COMM_SET_MCCONF_TEMP,
  COMM_SET_MCCONF_TEMP_SETUP,
  COMM_GET_VALUES_SELECTIVE,
  COMM_GET_VALUES_SETUP_SELECTIVE,
  COMM_EXT_NRF_PRESENT,
  COMM_EXT_NRF_ESB_SET_CH_ADDR,
  COMM_EXT_NRF_ESB_SEND_DATA,
  COMM_EXT_NRF_ESB_RX_DATA,
  COMM_EXT_NRF_SET_ENABLED,
  COMM_DETECT_MOTOR_FLUX_LINKAGE_OPENLOOP,
  COMM_DETECT_APPLY_ALL_FOC,
  COMM_JUMP_TO_BOOTLOADER_ALL_CAN,
  COMM_ERASE_NEW_APP_ALL_CAN,
  COMM_WRITE_NEW_APP_DATA_ALL_CAN,
  COMM_PING_CAN,
  COMM_APP_DISABLE_OUTPUT,
  COMM_TERMINAL_CMD_SYNC,
  COMM_GET_IMU_DATA,
  COMM_BM_CONNECT,
  COMM_BM_ERASE_FLASH_ALL,
  COMM_BM_WRITE_FLASH,
  COMM_BM_REBOOT,
  COMM_BM_DISCONNECT,
  COMM_BM_MAP_PINS_DEFAULT,
  COMM_BM_MAP_PINS_NRF5X,
  COMM_ERASE_BOOTLOADER,
  COMM_ERASE_BOOTLOADER_ALL_CAN,
  COMM_PLOT_INIT,
  COMM_PLOT_DATA,
  COMM_PLOT_ADD_GRAPH,
  COMM_PLOT_SET_GRAPH,
  COMM_GET_DECODED_BALANCE,
  COMM_BM_MEM_READ,
  COMM_WRITE_NEW_APP_DATA_LZO,
  COMM_WRITE_NEW_APP_DATA_ALL_CAN_LZO,
  COMM_BM_WRITE_FLASH_LZO,
  COMM_SET_CURRENT_REL,
  COMM_CAN_FWD_FRAME,
  COMM_SET_BATTERY_CUT,
  COMM_SET_BLE_NAME,
  COMM_SET_BLE_PIN,
  COMM_SET_CAN_MODE,
  COMM_GET_IMU_CALIBRATION,
  COMM_GET_MCCONF_TEMP, // Firmware 5.2 added

  // Custom configuration for hardware
  COMM_GET_CUSTOM_CONFIG_XML, // Firmware 5.2 added
  COMM_GET_CUSTOM_CONFIG, // Firmware 5.2 added
  COMM_GET_CUSTOM_CONFIG_DEFAULT, // Firmware 5.2 added
  COMM_SET_CUSTOM_CONFIG, // Firmware 5.2 added

  // BMS commands
  COMM_BMS_GET_VALUES, // Firmware 5.2 added
  COMM_BMS_SET_CHARGE_ALLOWED, // Firmware 5.2 added
  COMM_BMS_SET_BALANCE_OVERRIDE, // Firmware 5.2 added
  COMM_BMS_RESET_COUNTERS, // Firmware 5.2 added
  COMM_BMS_FORCE_BALANCE, // Firmware 5.2 added
  COMM_BMS_ZERO_CURRENT_OFFSET, // Firmware 5.2 added

  // FW updates commands for different HW types
  COMM_JUMP_TO_BOOTLOADER_HW, // Firmware 5.2 added
  COMM_ERASE_NEW_APP_HW, // Firmware 5.2 added
  COMM_WRITE_NEW_APP_DATA_HW, // Firmware 5.2 added
  COMM_ERASE_BOOTLOADER_HW, // Firmware 5.2 added
  COMM_JUMP_TO_BOOTLOADER_ALL_CAN_HW, // Firmware 5.2 added
  COMM_ERASE_NEW_APP_ALL_CAN_HW, // Firmware 5.2 added
  COMM_WRITE_NEW_APP_DATA_ALL_CAN_HW, // Firmware 5.2 added
  COMM_ERASE_BOOTLOADER_ALL_CAN_HW, // Firmware 5.2 added

  COMM_SET_ODOMETER, // Firmware 5.2 added

  // Power switch commands
  COMM_PSW_GET_STATUS, // Firmware 5.3 added
  COMM_PSW_SWITCH, // Firmware 5.3 added

  COMM_BMS_FWD_CAN_RX, // Firmware 5.3 added
  COMM_BMS_HW_DATA, // Firmware 5.3 added
  COMM_GET_BATTERY_CUT, // Firmware 5.3 added
  COMM_BM_HALT_REQ, // Firmware 5.3 added
  COMM_GET_QML_UI_HW, // Firmware 5.3 added
  COMM_GET_QML_UI_APP, // Firmware 5.3 added
  COMM_CUSTOM_HW_DATA, // Firmware 5.3 added
  COMM_QMLUI_ERASE, // Firmware 5.3 added
  COMM_QMLUI_WRITE, // Firmware 5.3 added

  // IO Board
  COMM_IO_BOARD_GET_ALL, // Firmware 5.3 added
  COMM_IO_BOARD_SET_PWM, // Firmware 5.3 added
  COMM_IO_BOARD_SET_DIGITAL, // Firmware 5.3 added
}

// CAN commands
// From datatypes.h
enum CAN_PACKET_ID {
  CAN_PACKET_SET_DUTY,
  CAN_PACKET_SET_CURRENT,
  CAN_PACKET_SET_CURRENT_BRAKE,
  CAN_PACKET_SET_RPM,
  CAN_PACKET_SET_POS,
  CAN_PACKET_FILL_RX_BUFFER,
  CAN_PACKET_FILL_RX_BUFFER_LONG,
  CAN_PACKET_PROCESS_RX_BUFFER,
  CAN_PACKET_PROCESS_SHORT_BUFFER,
  CAN_PACKET_STATUS,
  CAN_PACKET_SET_CURRENT_REL,
  CAN_PACKET_SET_CURRENT_BRAKE_REL,
  CAN_PACKET_SET_CURRENT_HANDBRAKE,
  CAN_PACKET_SET_CURRENT_HANDBRAKE_REL,
  CAN_PACKET_STATUS_2,
  CAN_PACKET_STATUS_3,
  CAN_PACKET_STATUS_4,
  CAN_PACKET_PING,
  CAN_PACKET_PONG,
  CAN_PACKET_DETECT_APPLY_ALL_FOC,
  CAN_PACKET_DETECT_APPLY_ALL_FOC_RES,
  CAN_PACKET_CONF_CURRENT_LIMITS,
  CAN_PACKET_CONF_STORE_CURRENT_LIMITS,
  CAN_PACKET_CONF_CURRENT_LIMITS_IN,
  CAN_PACKET_CONF_STORE_CURRENT_LIMITS_IN,
  CAN_PACKET_CONF_FOC_ERPMS,
  CAN_PACKET_CONF_STORE_FOC_ERPMS,
  CAN_PACKET_STATUS_5,
  CAN_PACKET_POLL_TS5700N8501_STATUS,
  CAN_PACKET_CONF_BATTERY_CUT,
  CAN_PACKET_CONF_STORE_BATTERY_CUT,
  CAN_PACKET_SHUTDOWN,

  CAN_PACKET_IO_BOARD_ADC_1_TO_4, // Firmware 5.2 added
  CAN_PACKET_IO_BOARD_ADC_5_TO_8, // Firmware 5.2 added
  CAN_PACKET_IO_BOARD_ADC_9_TO_12, // Firmware 5.2 added
  CAN_PACKET_IO_BOARD_DIGITAL_IN, // Firmware 5.2 added
  CAN_PACKET_IO_BOARD_SET_OUTPUT_DIGITAL, // Firmware 5.2 added
  CAN_PACKET_IO_BOARD_SET_OUTPUT_PWM, // Firmware 5.2 added
  CAN_PACKET_BMS_V_TOT, // Firmware 5.2 added
  CAN_PACKET_BMS_I, // Firmware 5.2 added
  CAN_PACKET_BMS_AH_WH, // Firmware 5.2 added
  CAN_PACKET_BMS_V_CELL, // Firmware 5.2 added
  CAN_PACKET_BMS_BAL, // Firmware 5.2 added
  CAN_PACKET_BMS_TEMPS, // Firmware 5.2 added
  CAN_PACKET_BMS_HUM, // Firmware 5.2 added
  CAN_PACKET_BMS_SOC_SOH_TEMP_STAT, // Firmware 5.2 added

  CAN_PACKET_PSW_STAT, // Firmware 5.3 added
  CAN_PACKET_PSW_SWITCH, // Firmware 5.3 added
  CAN_PACKET_BMS_HW_DATA_1, // Firmware 5.3 added
  CAN_PACKET_BMS_HW_DATA_2, // Firmware 5.3 added
  CAN_PACKET_BMS_HW_DATA_3, // Firmware 5.3 added
  CAN_PACKET_BMS_HW_DATA_4, // Firmware 5.3 added
  CAN_PACKET_BMS_HW_DATA_5, // Firmware 5.3 added
  CAN_PACKET_BMS_AH_WH_CHG_TOTAL, // Firmware 5.3 added
  CAN_PACKET_BMS_AH_WH_DIS_TOTAL, // Firmware 5.3 added
  CAN_PACKET_UPDATE_PID_POS_OFFSET, // Firmware 5.3 added
  CAN_PACKET_POLL_ROTOR_POS, // Firmware 5.3 added
  CAN_PACKET_MAKE_ENUM_32_BITS, //TODO: invalid Dart syntax// = 0xFFFFFFFF, // Firmware 5.3 added
}

// VESC based ESC faults
// From datatypes.h
enum mc_fault_code {
  FAULT_CODE_NONE,
  FAULT_CODE_OVER_VOLTAGE,
  FAULT_CODE_UNDER_VOLTAGE,
  FAULT_CODE_DRV,
  FAULT_CODE_ABS_OVER_CURRENT,
  FAULT_CODE_OVER_TEMP_FET,
  FAULT_CODE_OVER_TEMP_MOTOR,
  FAULT_CODE_GATE_DRIVER_OVER_VOLTAGE,
  FAULT_CODE_GATE_DRIVER_UNDER_VOLTAGE,
  FAULT_CODE_MCU_UNDER_VOLTAGE,
  FAULT_CODE_BOOTING_FROM_WATCHDOG_RESET,
  FAULT_CODE_ENCODER_SPI,
  FAULT_CODE_ENCODER_SINCOS_BELOW_MIN_AMPLITUDE,
  FAULT_CODE_ENCODER_SINCOS_ABOVE_MAX_AMPLITUDE,
  FAULT_CODE_FLASH_CORRUPTION,
  FAULT_CODE_HIGH_OFFSET_CURRENT_SENSOR_1,
  FAULT_CODE_HIGH_OFFSET_CURRENT_SENSOR_2,
  FAULT_CODE_HIGH_OFFSET_CURRENT_SENSOR_3,
  FAULT_CODE_UNBALANCED_CURRENTS,
  FAULT_CODE_BRK,
  FAULT_CODE_RESOLVER_LOT,
  FAULT_CODE_RESOLVER_DOS,
  FAULT_CODE_RESOLVER_LOS,
  FAULT_CODE_FLASH_CORRUPTION_APP_CFG, // Firmware 5.2 added
  FAULT_CODE_FLASH_CORRUPTION_MC_CFG, // Firmware 5.2 added
  FAULT_CODE_ENCODER_NO_MAGNET, // Firmware 5.2 added
  FAULT_CODE_ENCODER_MAGNET_TOO_STRONG, // Firmware 5.3 added
}