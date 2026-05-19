# Minimal Zeek config for the lab. Enables the Modbus analyzer and
# logs writes to a dedicated stream.

@load base/protocols/modbus
@load policy/protocols/modbus/known-masters-slaves

redef LogAscii::use_json = T;

# Surface Modbus write function codes as notices.
module ModbusWatch;

export {
    redef enum Notice::Type += { Unsolicited_Write };
}

event modbus_message(c: connection, headers: ModbusHeaders, is_orig: bool) {
    if (!is_orig) return;
    if (headers$function_code in set(5, 6, 15, 16)) {
        NOTICE([$note=Unsolicited_Write,
                $msg=fmt("Modbus write from %s to %s (FC=%d)",
                         c$id$orig_h, c$id$resp_h, headers$function_code),
                $conn=c]);
    }
}
