SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE ACCESS_POINT_BRIDGE_PACK IS
    PROCEDURE ADD_ACCESS_POINT_BRIDGE(v_essid IN access_point_bridge.ESSID%TYPE, v_bssid IN access_point_bridge.BSSID%TYPE);
    PROCEDURE UPD_ACCESS_POINT_BRIDGE(v_old_bssid IN access_point_bridge.BSSID%TYPE, v_new_bssid IN access_point_bridge.BSSID%TYPE);
    PROCEDURE DEL_ACCESS_POINT_BRIDGE(v_bssid IN access_point_bridge.BSSID%TYPE);
END ACCESS_POINT_BRIDGE_PACK;
/
CREATE OR REPLACE PACKAGE BODY ACCESS_POINT_BRIDGE_PACK IS
    PROCEDURE ADD_ACCESS_POINT_BRIDGE(v_essid IN access_point_bridge.ESSID%TYPE, v_bssid IN access_point_bridge.BSSID%TYPE) IS
    BEGIN
        INSERT INTO access_point_bridge VALUES(v_essid, v_bssid);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line('This product already exists!');
    END ADD_ACCESS_POINT_BRIDGE;
 
    PROCEDURE UPD_ACCESS_POINT_BRIDGE(v_old_bssid IN access_point_bridge.BSSID%TYPE, v_new_bssid IN access_point_bridge.BSSID%TYPE) IS
    BEGIN
        UPDATE access_point_bridge SET bssid = v_new_bssid WHERE bssid = v_old_bssid;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20017, 'no such mac');
        END IF;
    END UPD_ACCESS_POINT_BRIDGE;
    
    PROCEDURE DEL_ACCESS_POINT_BRIDGE(v_bssid IN access_point_bridge.BSSID%TYPE) IS
    BEGIN
        DELETE FROM access_point_bridge WHERE bssid = v_bssid;
    END DEL_ACCESS_POINT_BRIDGE;
    
END ACCESS_POINT_BRIDGE_PACK;
/

CREATE OR REPLACE TRIGGER ACCESS_POINT_BRIDGE_VALIDATE_ENTRY
BEFORE INSERT OR UPDATE ON access_point_bridge
FOR EACH ROW
DECLARE 
   wrong_essid EXCEPTION;
   wrong_mac EXCEPTION;
BEGIN
    IF (:NEW.ESSID < 1 OR :NEW.ESSID > 4) THEN
        RAISE wrong_essid;
    END IF;
   IF NOT (REGEXP_LIKE (:NEW.BSSID,'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')) THEN 
        RAISE wrong_mac;
   END IF;

EXCEPTION
    WHEN wrong_essid THEN
        RAISE_APPLICATION_ERROR(-20003, 'Wrong ESSID!! Available ESSID is from 1-4!');
    WHEN wrong_mac THEN
        RAISE_APPLICATION_ERROR(-20004, 'Wrong MAC address!! Please insert a device with a valid MAC address..');
END;
/

CREATE OR REPLACE TRIGGER ACCESS_POINT_BRIDGE_SELECT_PORT_ID
AFTER INSERT ON access_point_bridge
FOR EACH ROW
DECLARE 
   x INTEGER := 41;
   countPort INTEGER;
BEGIN
    WHILE (x <= 44) LOOP
        SELECT COUNT(switch.port_id) INTO countPort FROM switch where switch.port_id = x;
          
        IF (countPort = 0) THEN
            INSERT INTO switch(port_id, MAC, device_type) VALUES (x, :NEW.BSSID,'AccessPoint');
            x := 45;
        ELSE
            x := x + 1;
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER ACCESS_POINT_BRIDGE_UPDATE_BSSID
AFTER UPDATE ON access_point_bridge
FOR EACH ROW
DECLARE
BEGIN
    UPDATE switch SET MAC = :NEW.BSSID WHERE MAC = :OLD.BSSID;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20017, 'no such mac');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER ACCESS_POINT_BRIDGE_DELETE_FROM_SWITCH
    AFTER DELETE ON access_point_bridge
    FOR EACH ROW
    DECLARE
    BEGIN
        DELETE FROM switch WHERE MAC = :OLD.BSSID;
END;
/

CREATE OR REPLACE PACKAGE SWITCH_PACK IS
    PROCEDURE GET_SWITCH_DATA;
END SWITCH_PACK;
/

CREATE OR REPLACE PACKAGE BODY SWITCH_PACK IS
    PROCEDURE GET_SWITCH_DATA IS
        CURSOR switch_cursor is
            SELECT * FROM switch ORDER BY PORT_ID;
    BEGIN
        FOR switch_record IN switch_cursor LOOP
            DBMS_OUTPUT.put_line(switch_record.port_id || ': ' || switch_record.MAC || ' ( ' || switch_record.VLAN || ' - ' || switch_record.DEVICE_TYPE || ' )');
        END LOOP;
    END GET_SWITCH_DATA;
    
END SWITCH_PACK;
/

CREATE OR REPLACE TRIGGER SWITCH_VALIDATE_ENTRY
BEFORE INSERT OR UPDATE ON switch
FOR EACH ROW
DECLARE 
   wrong_port_id EXCEPTION;
   wrong_mac EXCEPTION;
   wrong_device_type EXCEPTION;
   wrong_wired_device EXCEPTION;
   wrong_access_point_device EXCEPTION;
   wrong_server_device EXCEPTION;
   wrong_router_device EXCEPTION;
BEGIN
    DBMS_OUTPUT.put_line(:NEW.device_type);
    IF (:NEW.port_id < 1 OR :NEW.port_id > 48) THEN
        RAISE wrong_port_id;
    END IF;
   IF NOT (REGEXP_LIKE (:NEW.MAC,'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')) THEN 
        RAISE wrong_mac;
   END IF;
       
   IF (:NEW.device_type != 'Computer' AND :NEW.device_type != 'Printer' AND :NEW.device_type != 'AccessPoint' AND :NEW.device_type != 'Server' AND :NEW.device_type != 'Router') THEN
        RAISE wrong_device_type;
    END IF;
    
    IF (:NEW.device_type='Computer' OR :NEW.device_type='Printer') THEN
        IF (:NEW.port_id > 0 AND :NEW.port_id <= 4) THEN
            :NEW.VLAN := '1';
        ELSIF (:NEW.port_id > 4 AND :NEW.port_id <= 8) THEN
            :NEW.VLAN := '2';
        ELSIF (:NEW.port_id > 8 AND :NEW.port_id <= 12) THEN
            :NEW.VLAN := '3';
        ELSIF (:NEW.port_id > 12 AND :NEW.port_id <= 16) THEN
            :NEW.VLAN := '4';
        ELSIF (:NEW.port_id > 16 AND :NEW.port_id <= 20) THEN
            :NEW.VLAN := '5';
        ELSIF (:NEW.port_id > 20 AND :NEW.port_id <= 24) THEN
            :NEW.VLAN := '6';
        ELSIF (:NEW.port_id > 24 AND :NEW.port_id <= 28) THEN
            :NEW.VLAN := '7';
        ELSIF (:NEW.port_id > 28 AND :NEW.port_id <= 32) THEN
            :NEW.VLAN := '8';
        ELSIF (:NEW.port_id > 32 AND :NEW.port_id <= 36) THEN
            :NEW.VLAN := '9';
        ELSIF (:NEW.port_id > 36 AND :NEW.port_id <= 40) THEN
            :NEW.VLAN := '10';
        ELSE
            RAISE wrong_wired_device;
        END IF;
    END IF;

    IF (:NEW.device_type='AccessPoint') THEN
        IF (:NEW.port_id > 40 AND :NEW.port_id <= 44) THEN
            :NEW.VLAN := '11';
        ELSE
            RAISE wrong_access_point_device;
        END IF;
    END IF;
    
    IF (:NEW.device_type='Server') THEN
        IF (:NEW.port_id > 44 AND :NEW.port_id <= 47) THEN
            :NEW.VLAN := '12';
        ELSE
            RAISE wrong_server_device;
        END IF;
    END IF;
    
    IF (:NEW.device_type='Router') THEN
        IF (:NEW.port_id = 48) THEN
            :NEW.VLAN := '12';
        ELSE
            RAISE wrong_router_device;
        END IF;
    END IF;

EXCEPTION
    WHEN wrong_port_id THEN
        RAISE_APPLICATION_ERROR(-20005, 'Wrong port!! Available ports are from 1-48');
    WHEN wrong_mac THEN
        RAISE_APPLICATION_ERROR(-20004, 'Wrong MAC address!! Please insert a device with a valid MAC address..');
    WHEN wrong_device_type THEN
        RAISE_APPLICATION_ERROR(-20006, 'Wrong device type! Accepted types: Computer // Printer // AccessPoint // Server // Router !!');
    WHEN wrong_wired_device THEN
        RAISE_APPLICATION_ERROR(-20007, 'Wrong port for wired devices!! Available ports are 1:40');
    WHEN wrong_access_point_device THEN
        RAISE_APPLICATION_ERROR(-20008, 'Wrong port for AccessPoint!! Available ports are 41:44');
    WHEN wrong_server_device THEN
        RAISE_APPLICATION_ERROR(-20009, 'Wrong port for Server!! Available ports are 45:47'); 
    WHEN wrong_router_device THEN
        RAISE_APPLICATION_ERROR(-20010, 'Wrong port for Router!! Available ports is 48');  
END;
/

--------------------- terminare switch & ap_bridge ---------------------

CREATE OR REPLACE PACKAGE ROUTER_PACK IS
    PROCEDURE ADD_ROUTER(v_mac IN router.SWITCH_MAC%TYPE, v_ip_int_1 IN router.IP_INT_1%TYPE, v_ip_int_2 IN router.IP_INT_2%TYPE, v_ip_int_3 IN router.IP_INT_3%TYPE, v_ip_int_4 IN router.IP_INT_4%TYPE);
    PROCEDURE DEL_ROUTER;
END ROUTER_PACK;
/

CREATE OR REPLACE PACKAGE BODY ROUTER_PACK IS
    PROCEDURE ADD_ROUTER(v_mac IN router.SWITCH_MAC%TYPE, v_ip_int_1 IN router.IP_INT_1%TYPE, v_ip_int_2 IN router.IP_INT_2%TYPE, v_ip_int_3 IN router.IP_INT_3%TYPE, v_ip_int_4 IN router.IP_INT_4%TYPE) IS
    BEGIN
        INSERT INTO router(SWITCH_MAC, IP_INT_1, IP_INT_2, IP_INT_3, IP_INT_4) VALUES(v_mac, v_ip_int_1, v_ip_int_2, v_ip_int_3, v_ip_int_4);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line('This router already exists!');
    END ADD_ROUTER;
    
    PROCEDURE DEL_ROUTER IS
    BEGIN
        DELETE FROM router;
    END DEL_ROUTER;
    
END ROUTER_PACK;
/

CREATE OR REPLACE TRIGGER ROUTER_VALIDATE_ENTRY
BEFORE INSERT OR UPDATE ON router
FOR EACH ROW
DECLARE 
   wrong_ip EXCEPTION;
   wrong_mac EXCEPTION;
BEGIN
    
   IF NOT (REGEXP_LIKE (:NEW.SWITCH_MAC,'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')) THEN 
        RAISE wrong_mac;
   END IF;
   
   IF NOT((REGEXP_LIKE (:NEW.IP_int_1, '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$')) OR
        (REGEXP_LIKE (:NEW.IP_int_2, '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$')) OR
        (REGEXP_LIKE (:NEW.IP_int_3, '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$')) OR
        (REGEXP_LIKE (:NEW.IP_int_4, '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$'))) THEN
        RAISE wrong_ip;
    END IF;

    INSERT INTO switch(port_id, MAC, device_type) VALUES (48, :NEW.SWITCH_MAC, 'Router');
EXCEPTION
    WHEN wrong_ip THEN
        RAISE_APPLICATION_ERROR(-20011, 'Wrong IP address for a router interface!!');
    WHEN wrong_mac THEN
        RAISE_APPLICATION_ERROR(-20004, 'Wrong MAC address!! Please insert a device with a valid MAC address..');
END;
/

CREATE OR REPLACE TRIGGER ROUTER_DELETE_FROM_SWITCH
    AFTER DELETE ON router
    FOR EACH ROW
    DECLARE
    BEGIN
        DELETE FROM switch WHERE MAC = :OLD.SWITCH_MAC;
END;
/

--------------------- terminare router ---------------------

CREATE OR REPLACE PACKAGE SERVER_PACK IS
    PROCEDURE ADD_SERVER(v_mac IN server.SWITCH_MAC%TYPE, v_ip server.IP%TYPE, v_server_type server.server_type%TYPE, v_os server.OS%TYPE);
END SERVER_PACK;
/

CREATE OR REPLACE PACKAGE BODY SERVER_PACK IS
    PROCEDURE ADD_SERVER(v_mac IN server.SWITCH_MAC%TYPE, v_ip server.IP%TYPE, v_server_type server.server_type%TYPE, v_os server.OS%TYPE) IS
    BEGIN
        INSERT INTO server(SWITCH_MAC, IP, SERVER_TYPE, OS) VALUES(v_mac, v_ip, v_server_type, v_os);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line('This server already exists!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line('ce mm');
    END ADD_SERVER;
END SERVER_PACK;
/

--DROP TRIGGER SERVER_VALIDATE_ENTRY;

CREATE OR REPLACE TRIGGER SERVER_VALIDATE_ENTRY
BEFORE INSERT OR UPDATE ON server
FOR EACH ROW
DECLARE 
   wrong_ip EXCEPTION;
   wrong_mac EXCEPTION;
   wrong_server_type EXCEPTION;
   wrong_os EXCEPTION;
BEGIN
    
   IF NOT (REGEXP_LIKE (:NEW.SWITCH_MAC,'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')) THEN 
        RAISE wrong_mac;
   END IF;
   
    IF NOT(REGEXP_LIKE (:NEW.IP, '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$')) THEN
        RAISE wrong_ip;
    END IF;
    
    IF (:NEW.server_type != 'Proxy' AND :NEW.server_type != 'Mail' AND :NEW.server_type != 'FTP') THEN
        RAISE wrong_server_type;
    END IF;
    
    IF (:NEW.OS != 'Linux' AND :NEW.OS != 'Windows' AND :NEW.OS !='Solaris' AND :NEW.OS != 'FreeBD' AND :NEW.OS != 'MacOSX') THEN
        RAISE wrong_os;
    END IF;

EXCEPTION
    WHEN wrong_ip THEN
        RAISE_APPLICATION_ERROR(-20011, 'Wrong IP address for a router interface!!');
    WHEN wrong_mac THEN
        RAISE_APPLICATION_ERROR(-20004, 'Wrong MAC address!! Please insert a device with a valid MAC address..');
    WHEN wrong_server_type THEN
        RAISE_APPLICATION_ERROR(-20012, 'Wrong server type! Accepted types:
            Proxy // Mail // FTP !!');
    WHEN wrong_os THEN
        RAISE_APPLICATION_ERROR(-20013, 'Invalid operating system!! Example of valid OS:
            Linux // Windows // Solaris // FreeBd // MacOSX');
END;
/
--------------------- terminare server ---------------------


CREATE OR REPLACE PACKAGE DEVICE_PACK IS
        PROCEDURE ADD_DEVICE(v_mac IN devices.MAC%TYPE, v_ip IN devices.IP%TYPE, v_device_type IN devices.device_type%TYPE, v_op IN devices.OS%TYPE);
END DEVICE_PACK;
/

CREATE OR REPLACE PACKAGE BODY DEVICE_PACK IS
    PROCEDURE ADD_DEVICE(v_mac IN devices.MAC%TYPE, v_ip IN devices.IP%TYPE, v_device_type IN devices.device_type%TYPE, v_op IN devices.OS%TYPE)IS
    BEGIN
        INSERT INTO devices(MAC, IP, DEVICE_TYPE, OS) VALUES(v_mac, v_ip, v_device_type, v_op);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line('This device already exists!');
    END ADD_DEVICE;
    
END DEVICE_PACK;
/

CREATE OR REPLACE TRIGGER DEVICE_VALIDATE_ENTRY
BEFORE INSERT OR UPDATE ON devices
FOR EACH ROW
DECLARE 
   wrong_ip EXCEPTION;
   wrong_mac EXCEPTION;
   wrong_dev_type EXCEPTION;
BEGIN
    
   IF NOT (REGEXP_LIKE (:NEW.MAC,'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')) THEN 
        RAISE wrong_mac;
   END IF;
   
   IF NOT(REGEXP_LIKE (:NEW.IP, '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$')) THEN
        RAISE wrong_ip;
    END IF;
    
    IF (:NEW.device_type!='Computer' AND :NEW.device_type!='Laptop' AND :NEW.device_type!='Smartphone' AND :NEW.device_type!= 'Printer') THEN
        RAISE wrong_dev_type;
    END IF;

EXCEPTION
    WHEN wrong_ip THEN
        RAISE_APPLICATION_ERROR(-20011, 'Wrong IP address for a router interface!!');
    WHEN wrong_mac THEN
        RAISE_APPLICATION_ERROR(-20004, 'Wrong MAC address!! Please insert a device with a valid MAC address..');
    WHEN wrong_dev_type THEN
        RAISE_APPLICATION_ERROR(-20013, 'Wrong device type! Accepted types:
            Computer // Laptop // Smarthpone // Printer !!');
END;
/

CREATE OR REPLACE TRIGGER ACCESS_POINT_VALIDATE_ENTRY
BEFORE INSERT OR UPDATE ON access_point
FOR EACH ROW
DECLARE 
    wrong_ap_essid EXCEPTION;
   wrong_mac EXCEPTION;
   wrong_ap_type EXCEPTION;
BEGIN

    IF (:NEW.AP_ESSID < 1 OR :NEW.AP_ESSID >4) THEN
        RAISE wrong_ap_essid;
    END IF;
    
   IF NOT (REGEXP_LIKE (:NEW.MAC,'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')) THEN 
        RAISE wrong_mac;
   END IF;
   
    IF (:NEW.device_type!='Laptop' AND :NEW.device_type!='Smartphone') THEN
        RAISE wrong_ap_type;
    END IF;
   
EXCEPTION
    WHEN wrong_ap_essid THEN
        RAISE_APPLICATION_ERROR(-20014, 'Wrong ESSID!! Available ESSID is from 1-4!');
    WHEN wrong_mac THEN
        RAISE_APPLICATION_ERROR(-20004, 'Wrong MAC address!! Please insert a device with a valid MAC address..');
    WHEN wrong_ap_type THEN
        RAISE_APPLICATION_ERROR(-20015, 'Wrong device type! Accepted types:
            Laptop // Smarthpone!!');
END;
/

CREATE OR REPLACE TRIGGER MANAGE_DEVICES
AFTER INSERT OR UPDATE ON devices
FOR EACH ROW
DECLARE
    countPort INTEGER;
    x INTEGER;
BEGIN
    IF (:NEW.device_type='Computer' OR :NEW.device_type='Printer') THEN
        x := 1;
        
        WHILE (x <= 40) LOOP
            SELECT COUNT(switch.port_id) INTO countPort FROM switch WHERE switch.port_id = x;
            DBMS_OUTPUT.put_line(countPort);
            
            IF (countPort = 0) THEN
                INSERT INTO switch(MAC, device_type, port_id) VALUES(:NEW.MAC, :NEW.device_type, x);
                x := 41;
            ELSE
                x := x + 1;
            END IF;
        END LOOP;
    END IF;
    
    IF (:NEW.device_type='Laptop' OR :NEW.device_type='Smartphone') THEN
        INSERT INTO access_point(MAC, AP_ESSID, device_type) VALUES (:NEW.MAC, DBMS_RANDOM.value(1, 4), :NEW.device_type);
    END IF;
END;
/

