EXECUTE ACCESS_POINT_BRIDGE_PACK.ADD_ACCESS_POINT_BRIDGE(1, '11:22:33:44:55:66');
EXECUTE ACCESS_POINT_BRIDGE_PACK.DEL_ACCESS_POINT_BRIDGE('11:22:33:44:55:66');

BEGIN
    SAVEPOINT EDIT_AP_TRANSACTION;
    ACCESS_POINT_BRIDGE_PACK.ADD_ACCESS_POINT_BRIDGE(1, '11:22:33:44:55:65');
    ACCESS_POINT_BRIDGE_PACK.UPD_ACCESS_POINT_BRIDGE('11:22:33:44:55:65', '11:22:33:44:55:66');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO EDIT_AP_TRANSACTION;
    RAISE;
END;

BEGIN
    SAVEPOINT INSERT_AP_TRANSACTION;
    ACCESS_POINT_BRIDGE_PACK.ADD_ACCESS_POINT_BRIDGE(2, '22:33:44:55:66:77');
    ACCESS_POINT_BRIDGE_PACK.ADD_ACCESS_POINT_BRIDGE(3, '33:44:55:66:77:88');
    ACCESS_POINT_BRIDGE_PACK.ADD_ACCESS_POINT_BRIDGE(4, '44:55:66:77:88:99');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO INSERT_AP_TRANSACTION;
    RAISE;
END;



EXECUTE ROUTER_PACK.ADD_ROUTER('43:54:65:21:EA:FF', '123.54.0.255', '127.0.10.22', '128.0.0.1', '222.43.76.255');
EXECUTE ROUTER_PACK.DEL_ROUTER;

BEGIN
    SAVEPOINT BEFORE_INSERT_SERVER;
    INSERT INTO SWITCH(PORT_ID, MAC, DEVICE_TYPE) VALUES(45, '43:54:65:88:99:AA', 'Server');
    INSERT INTO SWITCH(PORT_ID, MAC, DEVICE_TYPE) VALUES(46, '43:54:65:88:99:AB', 'Server');
    INSERT INTO SWITCH(PORT_ID, MAC, DEVICE_TYPE) VALUES(47, '43:54:65:88:99:AC', 'Server');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO BEFORE_INSERT_SERVER;
    RAISE;
END;

BEGIN
    SAVEPOINT BEFORE_INSERT_ROUTER;
    SERVER_PACK.ADD_SERVER('43:54:65:88:99:AA', '123.54.12.25', 'Proxy', 'Linux');
    SERVER_PACK.ADD_SERVER('43:54:65:88:99:AB', '123.54.12.26', 'Mail', 'Linux');
    SERVER_PACK.ADD_SERVER('43:54:65:88:99:AC', '123.54.12.27', 'FTP', 'Linux');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO BEFORE_INSERT_ROUTER;
    RAISE;
END;



EXECUTE DEVICE_PACK.ADD_DEVICE('11:F2:C9:33:EE:7E', '101.42.58.52', 'Computer', 'Windows');
EXECUTE DEVICE_PACK.ADD_DEVICE('15:F2:C9:33:E7:7E', '145.42.36.52', 'Smartphone', 'Android');


BEGIN
    SAVEPOINT BULK_WRITE;
    DEVICE_PACK.ADD_DEVICE('11:EE:C9:34:E3:7E', '123.42.50.52', 'Printer', 'Linux');
    DEVICE_PACK.ADD_DEVICE('11:F2:C9:33:E9:7E', '112.42.26.52', 'Laptop', 'Linux');
    DEVICE_PACK.ADD_DEVICE('23:F2:C9:33:E3:7E', '111.42.58.52', 'Computer', 'Windows');
    DEVICE_PACK.ADD_DEVICE('46:EE:C9:34:E3:7F', '111.42.55.52', 'Printer', 'Linux');
    DEVICE_PACK.ADD_DEVICE('15:F2:C9:33:D7:8C', '145.42.46.52', 'Smartphone', 'Android');
    DEVICE_PACK.ADD_DEVICE('19:F2:C9:23:E9:7E', '112.32.26.52', 'Laptop', 'Linux');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO BULK_WRITE;
    RAISE;
END;

EXECUTE SWITCH_PACK.GET_SWITCH_DATA;
